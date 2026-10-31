import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/core/utils/api_key_resolver.dart';
import 'package:literasi_ai/core/utils/api_key_store.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/repositories/learn_repository.dart';
import 'package:literasi_ai/features/learn/presentation/providers/learn_providers.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';
import 'package:literasi_ai/features/score/presentation/screens/profile_screen.dart';

class _MemoryKeyStore implements ApiKeyStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String key) async {
    value = key;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class _ControlledScoreRepository implements ScoreRepository {
  final controller = StreamController<LiteracyScore>.broadcast();

  @override
  Stream<LiteracyScore> watch(String userId) => controller.stream;

  @override
  Future<void> awardVerification(String userId) async {}

  @override
  Future<void> awardModule(String userId, String moduleId) async {}

  @override
  Future<void> awardQuiz(String userId, {required bool correct}) async {}
}

class _FakeLearnRepository implements LearnRepository {
  @override
  List<CourseModule> modules() => LearnContentDatasource().modules();

  @override
  CourseModule? moduleById(String id) => LearnContentDatasource().byId(id);

  @override
  Stream<CourseProgress> watchProgress(String userId) =>
      Stream.value(const CourseProgress());

  @override
  Future<bool> completeModule(String userId, String moduleId) async => true;

  @override
  Future<int> submitQuiz(
    String userId,
    String moduleId,
    int correctCount,
  ) async => correctCount;
}

Future<void> _pumpProfile(
  WidgetTester tester,
  _ControlledScoreRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiKeyStoreProvider.overrideWithValue(_MemoryKeyStore()),
        historyUserIdProvider.overrideWithValue('u1'),
        learnRepositoryProvider.overrideWithValue(_FakeLearnRepository()),
        scoreRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    ),
  );
  // Tanpa pumpAndSettle: skeleton skor beranimasi selama menunggu snapshot.
  await tester.pump();
}

/// Varian yang mengganti [scoreProvider] langsung: menguji perilaku widget
/// saat data terakhir dipertahankan bersama error, tanpa bergantung pada
/// jadwal backoff retry internal provider.
Future<void> _pumpProfileWithScoreStream(
  WidgetTester tester,
  _ControlledScoreRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiKeyStoreProvider.overrideWithValue(_MemoryKeyStore()),
        historyUserIdProvider.overrideWithValue('u1'),
        learnRepositoryProvider.overrideWithValue(_FakeLearnRepository()),
        scoreProvider.overrideWith((ref) => repository.controller.stream),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  group('Skor tidak kembali error saat stream diam', () {
    testWidgets('skor tetap tampil setelah 11 detik tanpa snapshot', (
      tester,
    ) async {
      final repository = _ControlledScoreRepository();
      addTearDown(repository.controller.close);
      await _pumpProfile(tester, repository);

      repository.controller.add(const LiteracyScore(verifications: 6));
      await tester.pump();
      expect(find.text('6 x 10'), findsOneWidget);

      // Inti regresi: timeout lama menyala setelah 10 detik idle sehingga
      // kartu "Skor tidak dapat dimuat" muncul, lalu hilang saat retry,
      // berulang tanpa henti.
      await tester.pump(const Duration(seconds: 11));

      expect(find.text('6 x 10'), findsOneWidget);
      expect(find.text(AppStrings.scoreLoadFailed), findsNothing);
      expect(find.text(AppStrings.scoreStale), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('error setelah data: skor terakhir + strip peringatan', (
      tester,
    ) async {
      final repository = _ControlledScoreRepository();
      addTearDown(repository.controller.close);
      await _pumpProfileWithScoreStream(tester, repository);

      repository.controller.add(const LiteracyScore(verifications: 6));
      await tester.pump();
      expect(find.text('6 x 10'), findsOneWidget);

      repository.controller.addError(Exception('skor putus'));
      await tester.pump();

      // Skor yang sudah dikumpulkan tidak boleh menghilang dari UI.
      expect(find.text('6 x 10'), findsOneWidget);
      expect(find.text(AppStrings.scoreStale), findsOneWidget);
      expect(find.text(AppStrings.retry), findsOneWidget);
      expect(find.text(AppStrings.scoreLoadFailed), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_local_datasource.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/repositories/learn_repository.dart';
import 'package:literasi_ai/features/learn/presentation/providers/learn_providers.dart';
import 'package:literasi_ai/features/learn/presentation/screens/course_list_screen.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository dengan stream yang bisa dikendalikan tes: meniru snapshot
/// Firestore yang tetap terbuka dan boleh diam lama setelah data pertama.
class _ControlledLearnRepository implements LearnRepository {
  final controller = StreamController<CourseProgress>.broadcast();

  @override
  List<CourseModule> modules() => LearnContentDatasource().modules();

  @override
  CourseModule? moduleById(String id) => LearnContentDatasource().byId(id);

  @override
  Stream<CourseProgress> watchProgress(String userId) => controller.stream;

  @override
  Future<bool> completeModule(String userId, String moduleId) async => true;

  @override
  Future<int> submitQuiz(
    String userId,
    String moduleId,
    int correctCount,
  ) async => correctCount;
}

class _FakeScoreRepository implements ScoreRepository {
  @override
  Stream<LiteracyScore> watch(String userId) =>
      Stream.value(const LiteracyScore());

  @override
  Future<void> awardVerification(String userId) async {}

  @override
  Future<void> awardModule(String userId, String moduleId) async {}

  @override
  Future<void> awardQuiz(String userId, {required bool correct}) async {}
}

Future<void> _pumpStreamingList(
  WidgetTester tester,
  _ControlledLearnRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        historyUserIdProvider.overrideWithValue('u1'),
        learnRepositoryProvider.overrideWithValue(repository),
        scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
      ],
      child: const MaterialApp(home: Scaffold(body: CourseListScreen())),
    ),
  );
  // Sengaja tanpa pumpAndSettle: skeleton shimmer beranimasi terus selama
  // progres belum tiba.
  await tester.pump();
}

void main() {
  group('Progres belajar tidak kembali nol saat stream diam', () {
    testWidgets('1 modul selesai tetap 1/12 setelah 11 detik idle', (
      tester,
    ) async {
      final repository = _ControlledLearnRepository();
      addTearDown(repository.controller.close);
      await _pumpStreamingList(tester, repository);

      repository.controller.add(
        const CourseProgress(completedModuleIds: ['clickbait']),
      );
      await tester.pump();
      expect(find.text('1 ${AppStrings.learnProgressSuffix}'), findsOneWidget);
      expect(find.text('1/12'), findsOneWidget);

      // Inti regresi: timer lama menyala setelah 10 detik tanpa snapshot,
      // membuat UI merender 0 modul selesai padahal progres tersimpan.
      await tester.pump(const Duration(seconds: 11));

      expect(find.text('1 ${AppStrings.learnProgressSuffix}'), findsOneWidget);
      expect(find.text('1/12'), findsOneWidget);
      expect(find.text('0 ${AppStrings.learnProgressSuffix}'), findsNothing);
      expect(find.text('0/12'), findsNothing);
      expect(find.text(AppStrings.learnProgressError), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('error tanpa data tampil sebagai kartu retry, bukan 0/12', (
      tester,
    ) async {
      final repository = _ControlledLearnRepository();
      addTearDown(repository.controller.close);
      await _pumpStreamingList(tester, repository);

      repository.controller.addError(Exception('progres putus'));
      await tester.pump();

      expect(find.text(AppStrings.learnProgressError), findsOneWidget);
      expect(find.text(AppStrings.learnProgressRetry), findsOneWidget);
      expect(find.text('0/12'), findsNothing);
      expect(find.text('0 ${AppStrings.learnProgressSuffix}'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('error setelah data: angka terakhir + strip peringatan', (
      tester,
    ) async {
      final repository = _ControlledLearnRepository();
      addTearDown(repository.controller.close);
      await _pumpStreamingList(tester, repository);

      repository.controller.add(
        const CourseProgress(completedModuleIds: ['clickbait']),
      );
      await tester.pump();
      repository.controller.addError(Exception('refresh gagal'));
      await tester.pump();

      expect(find.text('1 ${AppStrings.learnProgressSuffix}'), findsOneWidget);
      expect(find.text('1/12'), findsOneWidget);
      expect(find.text(AppStrings.learnProgressStale), findsOneWidget);
      expect(find.text('0/12'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Jalur tamu', () {
    test('cache datasource memuat modul setelah completeModule', () async {
      SharedPreferences.setMockInitialValues({});
      final datasource = LearnLocalDatasource();
      await datasource.readProgress();

      await datasource.completeModule('clickbait');

      final cached = datasource.readCachedProgress();
      expect(cached.isCompleted('clickbait'), isTrue);
    });

    test('emisi pertama setelah invalidasi tidak kosong', () async {
      SharedPreferences.setMockInitialValues({});
      final datasource = LearnLocalDatasource();
      final container = ProviderContainer(
        overrides: [
          historyUserIdProvider.overrideWithValue(null),
          learnLocalDatasourceProvider.overrideWithValue(datasource),
        ],
      );
      addTearDown(container.dispose);

      final before = await container.read(learnProgressProvider.future);
      expect(before.completedCount, 0);

      await container
          .read(learnActionProvider.notifier)
          .completeModule('clickbait');

      final after = await container.read(learnProgressProvider.future);
      expect(
        after.isCompleted('clickbait'),
        isTrue,
        reason: 'invalidasi tidak boleh mengirim progres kosong lebih dulu',
      );
    });
  });
}

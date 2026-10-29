import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/repositories/learn_repository.dart';
import 'package:literasi_ai/features/learn/presentation/providers/learn_providers.dart';
import 'package:literasi_ai/features/learn/presentation/screens/course_detail_screen.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';

class _NavLearnRepository implements LearnRepository {
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

class _NavScoreRepository implements ScoreRepository {
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

void main() {
  testWidgets('daftar isi: tap baris menyebabkan bagian aktif yang benar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyUserIdProvider.overrideWithValue('u1'),
          learnRepositoryProvider.overrideWithValue(_NavLearnRepository()),
          scoreRepositoryProvider.overrideWithValue(_NavScoreRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: CourseDetailScreen(moduleId: 'clickbait')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Bagian pertama tersedia saat layar pertama dibuka.
    expect(find.text('Ciri judul clickbait'), findsWidgets);
    expect(tester.takeException(), isNull);

    // Tap baris "Uji 3 detik sebelum klik" -> bagian 2 yang aktif.
    await tester.tap(find.text('Uji 3 detik sebelum klik').first);
    await tester.pumpAndSettle();

    expect(find.text('Uji 3 detik sebelum klik'), findsWidgets);
    expect(
      tester.getRect(find.text('Bagian 2')).top,
      lessThan(tester.view.physicalSize.height),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('scroll manual: bagian terakhir yang terpasang menjadi aktif', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyUserIdProvider.overrideWithValue('u1'),
          learnRepositoryProvider.overrideWithValue(_NavLearnRepository()),
          scoreRepositoryProvider.overrideWithValue(_NavScoreRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: CourseDetailScreen(moduleId: 'clickbait')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pilih bagian terakhir dari daftar isi.
    await tester.tap(find.text('Latihan mandiri').first);
    await tester.pumpAndSettle();

    expect(find.text('Bagian 4'), findsOneWidget);
    expect(
      tester.getRect(find.text('Bagian 4')).top,
      lessThan(tester.view.physicalSize.height),
    );
    expect(tester.takeException(), isNull);
  });
}

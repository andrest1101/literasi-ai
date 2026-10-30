import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/repositories/learn_repository.dart';
import 'package:literasi_ai/features/learn/presentation/providers/learn_providers.dart';
import 'package:literasi_ai/features/learn/presentation/screens/quiz_screen.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';

class _QuizLearnRepository implements LearnRepository {
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

class _QuizScoreRepository implements ScoreRepository {
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

Future<void> _pumpQuiz(
  WidgetTester tester,
  String moduleId, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        historyUserIdProvider.overrideWithValue('u1'),
        learnRepositoryProvider.overrideWithValue(_QuizLearnRepository()),
        scoreRepositoryProvider.overrideWithValue(_QuizScoreRepository()),
      ],
      child: MaterialApp(home: QuizScreen(moduleId: moduleId)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('UI kuis: header progres tidak terpotong di layar sempit', () {
    for (final width in [320.0, 360.0]) {
      testWidgets('lebar ${width.toInt()}px: status, segmen, dan judul utuh', (
        tester,
      ) async {
        await _pumpQuiz(tester, 'fakta-opini-satire', size: Size(width, 800));

        // Judul modul penuh pada AppBar dua baris.
        expect(find.text('Fakta, Opini, dan Satire'), findsOneWidget);
        // Penghitung jawaban utuh, bukan ellipsis seperti sebelumnya.
        expect(
          find.text('0/4 ${AppStrings.learnQuizAnsweredShort}'),
          findsOneWidget,
        );
        expect(
          find.text(
            '${AppStrings.learnQuizOf} 1 ${AppStrings.learnQuizFrom} 4',
          ),
          findsOneWidget,
        );
        // Satu segmen bernomor per soal, tanpa sisa segmen ekstra.
        for (var i = 0; i < 4; i++) {
          expect(find.byKey(ValueKey('quiz-step-$i')), findsOneWidget);
        }
        expect(find.byKey(const ValueKey('quiz-step-4')), findsNothing);
        // Opsi memakai label huruf agar mudah dirujuk.
        for (final letter in ['A', 'B', 'C', 'D']) {
          expect(find.text(letter), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('penghitung bertambah setelah satu soal dijawab', (
      tester,
    ) async {
      await _pumpQuiz(tester, 'fakta-opini-satire', size: const Size(320, 800));

      final module = LearnContentDatasource().byId('fakta-opini-satire')!;
      final answer = module.quiz.first.correctIndex;
      final option = find.byKey(ValueKey('quiz-option-0-$answer'));
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();

      expect(
        find.text('1/4 ${AppStrings.learnQuizAnsweredShort}'),
        findsOneWidget,
      );
      expect(find.text(AppStrings.learnQuizCorrect), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('judul modul terpanjang tetap tampil penuh di 320px', (
      tester,
    ) async {
      const moduleId = 'algoritma-filter-bubble';
      await _pumpQuiz(tester, moduleId, size: const Size(320, 800));

      final title = LearnContentDatasource().byId(moduleId)!.title;
      expect(find.text(title), findsOneWidget);
      expect(find.byKey(const ValueKey('quiz-step-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('quiz-step-3')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

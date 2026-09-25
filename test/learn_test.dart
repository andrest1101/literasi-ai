import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/data/models/learn_progress_model.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/repositories/learn_repository.dart';
import 'package:literasi_ai/features/learn/presentation/providers/learn_providers.dart';
import 'package:literasi_ai/features/learn/presentation/screens/course_detail_screen.dart';
import 'package:literasi_ai/features/learn/presentation/screens/quiz_screen.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';

class _FakeLearnRepository implements LearnRepository {
  _FakeLearnRepository();

  int completes = 0;
  int submits = 0;
  int lastCorrect = 0;

  @override
  List<CourseModule> modules() => LearnContentDatasource().modules();

  @override
  CourseModule? moduleById(String id) => LearnContentDatasource().byId(id);

  @override
  Stream<CourseProgress> watchProgress(String userId) =>
      Stream.value(const CourseProgress());

  @override
  Future<bool> completeModule(String userId, String moduleId) async {
    completes++;
    return true;
  }

  @override
  Future<int> submitQuiz(
    String userId,
    String moduleId,
    int correctCount,
  ) async {
    submits++;
    lastCorrect = correctCount;
    return correctCount;
  }
}

class _FakeScoreRepository implements ScoreRepository {
  int modules = 0;
  int quizzes = 0;

  @override
  Stream<LiteracyScore> watch(String userId) =>
      Stream.value(const LiteracyScore());

  @override
  Future<void> awardVerification(String userId) async {}

  @override
  Future<void> awardModule(String userId, String moduleId) async {
    modules++;
  }

  @override
  Future<void> awardQuiz(String userId, {required bool correct}) async {
    if (correct) quizzes++;
  }
}

void main() {
  group('Konten 3 modul PRD', () {
    test('valid: 3 modul, 4 seksi, 3 soal berpenjelasan', () {
      final modules = LearnContentDatasource().modules();
      expect(modules, hasLength(3));
      expect(modules.map((m) => m.id), [
        'clickbait',
        'gambar-manipulasi',
        'verifikasi-sumber',
      ]);
      for (final module in modules) {
        expect(module.sections, hasLength(4));
        expect(module.quiz, hasLength(3));
        for (final q in module.quiz) {
          expect(q.options, hasLength(4));
          expect(q.correctIndex, inInclusiveRange(0, 3));
          expect(q.explanation.isNotEmpty, isTrue);
        }
      }
    });
  });

  group('LearnProgressModel', () {
    test('fallback aman untuk dokumen korup', () {
      final progress = LearnProgressModel.fromMap({
        'completedModules': 'bukan-list',
        'quizBest': {'clickbait': 'NaN'},
      });
      expect(progress.completedCount, 0);
      expect(progress.bestFor('clickbait'), 0);
    });
  });

  group('Learn providers', () {
    test('guest mendapat progres kosong tanpa login', () async {
      final container = ProviderContainer(
        overrides: [historyUserIdProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);
      final progress = await container.read(learnProgressProvider.future);
      expect(progress.completedCount, 0);
    });

    test('complete modul memicu award Score sekali', () async {
      final learn = _FakeLearnRepository();
      final score = _FakeScoreRepository();
      final container = ProviderContainer(
        overrides: [
          historyUserIdProvider.overrideWithValue('u1'),
          learnRepositoryProvider.overrideWithValue(learn),
          scoreRepositoryProvider.overrideWithValue(score),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(learnActionProvider.notifier)
          .completeModule('clickbait');
      expect(learn.completes, 1);
      expect(score.modules, 1);
    });
  });

  testWidgets('tab belajar render 3 kartu heterogen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Belajar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Naikkan'), findsOneWidget);
    expect(find.text('Kenali Judul Clickbait'), findsOneWidget);
    expect(find.text('Ciri Gambar Manipulasi'), findsOneWidget);
    expect(find.text('Verifikasi Sumber Berita'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail modul klaim dan buka kuis', (
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
          learnRepositoryProvider.overrideWithValue(_FakeLearnRepository()),
          scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
        ],
        child: const MaterialApp(
          home: CourseDetailScreen(moduleId: 'clickbait'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bagian 1'), findsOneWidget);
    final claimButton = find.text('Tandai selesai +20');
    await tester.ensureVisible(claimButton);
    await tester.pumpAndSettle();
    await tester.tap(claimButton);
    await tester.pumpAndSettle();
    expect(find.text('Modul selesai. +20 poin diklaim.'), findsOneWidget);

    final quizButton = find.text('Mulai kuis');
    await tester.ensureVisible(quizButton);
    await tester.pumpAndSettle();
    await tester.tap(quizButton);
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(find.textContaining('Soal 1/3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kuis kunci jawaban dan klaim poin', (
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
          learnRepositoryProvider.overrideWithValue(_FakeLearnRepository()),
          scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
        ],
        child: const MaterialApp(home: QuizScreen(moduleId: 'clickbait')),
      ),
    );
    await tester.pumpAndSettle();

    // Jawaban benar per soal modul clickbait (indeks 0, 1, 1).
    const correctTexts = [
      'HEBOH! Minum ini sembuh total dalam semalam, sebarkan!',
      'Periksa penerbit, tanggal, dan isi artikel',
      'Karena hoaks dirancang memicu reaksi sebelum berpikir',
    ];
    for (var i = 0; i < 3; i++) {
      final option = find.text(correctTexts[i]);
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
      // Penjelasan tampil = jawaban terkunci benar.
      expect(find.text('Benar!'), findsOneWidget);
      final next = find.text(i == 2 ? 'Lihat hasil' : 'Lanjut');
      await tester.ensureVisible(next);
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text('Hasil kuismu'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);

    await tester.tap(find.text('Klaim poin'));
    await tester.pumpAndSettle();
    expect(find.textContaining('poin kuis diklaim'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

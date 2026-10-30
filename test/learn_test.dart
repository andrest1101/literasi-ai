import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/data/models/learn_progress_model.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/entities/quiz_submission.dart';
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

/// Menjawab seluruh soal modul lewat data konten, bukan teks opsi hardcoded.
///
/// [wrongAt] membuat satu soal dijawab salah untuk menguji skor parsial.
Future<void> _answerModule(
  WidgetTester tester,
  String moduleId, {
  int wrongAt = -1,
}) async {
  final module = LearnContentDatasource().byId(moduleId)!;
  for (var i = 0; i < module.quiz.length; i++) {
    final question = module.quiz[i];
    final isWrong = i == wrongAt;
    final optionIndex = isWrong
        ? (question.correctIndex + 1) % question.options.length
        : question.correctIndex;
    final option = find.byKey(ValueKey('quiz-option-$i-$optionIndex'));
    await tester.ensureVisible(option);
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(
      find.text(
        isWrong ? AppStrings.learnQuizWrong : AppStrings.learnQuizCorrect,
      ),
      findsOneWidget,
    );
    final next = find.text(
      i == module.quiz.length - 1
          ? AppStrings.learnQuizFinish
          : AppStrings.learnQuizNext,
    );
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
}

void main() {
  group('Katalog modul literasi digital', () {
    test('12 modul unik dengan materi dan kuis yang lengkap', () {
      final modules = LearnContentDatasource().modules();
      expect(modules, hasLength(12));
      expect(modules.map((m) => m.id), [
        'clickbait',
        'gambar-manipulasi',
        'verifikasi-sumber',
        'cek-konteks-media',
        'statistik-menyesatkan',
        'literasi-kesehatan',
        'anti-phishing',
        'konten-ai-deepfake',
        'fakta-opini-satire',
        'privasi-data',
        'jejak-digital',
        'algoritma-filter-bubble',
      ]);
      for (final module in modules) {
        expect(module.sections, hasLength(4));
        expect(module.quiz.length, inInclusiveRange(3, 4));
        for (final q in module.quiz) {
          expect(q.options, hasLength(4));
          expect(q.correctIndex, inInclusiveRange(0, 3));
          expect(q.explanation.isNotEmpty, isTrue);
        }
      }
      expect(modules.map((m) => m.id).toSet(), hasLength(12));
    });

    test('distribusi jawaban benar tersebar, tidak menumpuk di satu opsi', () {
      final modules = LearnContentDatasource().modules();
      final perIndex = List<int>.filled(4, 0);
      for (final module in modules) {
        final indices = module.quiz.map((q) => q.correctIndex).toSet();
        expect(
          indices.length,
          greaterThanOrEqualTo(2),
          reason: '${module.id} memakai satu posisi jawaban terus',
        );
        for (final q in module.quiz) {
          perIndex[q.correctIndex]++;
        }
      }
      final total = perIndex.reduce((a, b) => a + b);
      expect(perIndex.every((count) => count > 0), isTrue);
      for (final count in perIndex) {
        expect(count / total, lessThanOrEqualTo(0.3));
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

    test('membaca best score dari map bertingkat dan field legacy dotted', () {
      final progress = LearnProgressModel.fromMap({
        'quizBest': {'fakta-opini-satire': 4},
        'quizBest.clickbait': 3,
      });

      expect(progress.bestFor('fakta-opini-satire'), 4);
      expect(progress.bestFor('clickbait'), 3);
    });
  });

  group('Learn providers', () {
    test(
      'progres tamu tersimpan lokal dan hanya menambah best score',
      () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer(
          overrides: [historyUserIdProvider.overrideWithValue(null)],
        );
        addTearDown(container.dispose);
        final actions = container.read(learnActionProvider.notifier);
        expect(
          await actions.completeModule('clickbait'),
          ModuleCompletion.firstTime,
        );
        expect(
          await actions.completeModule('clickbait'),
          ModuleCompletion.alreadyDone,
        );
        final firstQuiz = await actions.submitQuiz('clickbait', 2);
        expect(firstQuiz.status, QuizSaveStatus.saved);
        expect(firstQuiz.points, 2);
        final secondQuiz = await actions.submitQuiz('clickbait', 1);
        expect(secondQuiz.status, QuizSaveStatus.unchanged);
        expect(secondQuiz.points, 0);
        final progress = await container
            .read(learnLocalDatasourceProvider)
            .readProgress();
        expect(progress.isCompleted('clickbait'), isTrue);
        expect(progress.bestFor('clickbait'), 2);
      },
    );

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

  testWidgets('tab belajar render katalog modul beragam', (
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

  testWidgets('detail modul klaim dan buka kuis', (WidgetTester tester) async {
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
    expect(find.textContaining('Soal 1 dari 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kuis: hasil tersimpan otomatis saat selesai', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final learn = _FakeLearnRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyUserIdProvider.overrideWithValue('u1'),
          learnRepositoryProvider.overrideWithValue(learn),
          scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
        ],
        child: const MaterialApp(home: QuizScreen(moduleId: 'clickbait')),
      ),
    );
    await tester.pumpAndSettle();

    // Semua soal clickbait dijawab benar lewat data katalog.
    await _answerModule(tester, 'clickbait');
    expect(find.text('Hasil kuismu'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    // Hasil kuis otomatis tersimpan begitu kuis selesai (best-score 3/3).
    await tester.pumpAndSettle();
    expect(learn.submits, 1);
    expect(find.textContaining('poin kuis diklaim'), findsWidgets);
    // Status klaim tampil langsung: trofi + angka + sublabel.
    expect(find.text('Sudah masuk ke skormu.'), findsWidgets);
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    // Ulangi kuis selalu aktif dari hasil.
    expect(find.text('Ulangi kuis'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hasil parsial: hero biru + hint belajar lagi', (
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

    // 2 benar 1 salah: soal terakhir sengaja dijawab dengan opsi lain.
    await _answerModule(tester, 'clickbait', wrongAt: 2);
    expect(find.text('Hasil kuismu'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    // Hero parsial: tanpa catatan sempurna, dengan hint belajar lagi.
    expect(find.text('Sempurna! Semua jawaban benar.'), findsNothing);
    expect(
      find.text('Pelajari lagi bagian yang salah, lalu ulangi kuis.'),
      findsOneWidget,
    );
    // Hasil parsial otomatis tersimpan sebagai best-score 2/3.
    await tester.pumpAndSettle();
    expect(find.text('Sudah masuk ke skormu.'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

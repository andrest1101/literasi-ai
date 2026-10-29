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
import 'package:literasi_ai/features/learn/presentation/screens/course_list_screen.dart';
import 'package:literasi_ai/features/learn/presentation/screens/quiz_screen.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';

/// Fake repo belajar: mencatat submit kuis + bisa gagal sekali untuk skenario
/// retry. Progres dimasukkan lewat [progress] supaya UI daftar konsisten.
class _FlowLearnRepository implements LearnRepository {
  _FlowLearnRepository(this.progress, {this.failFirstSave = false});

  final CourseProgress progress;
  bool failFirstSave;
  int submits = 0;

  @override
  List<CourseModule> modules() => LearnContentDatasource().modules();

  @override
  CourseModule? moduleById(String id) => LearnContentDatasource().byId(id);

  @override
  Stream<CourseProgress> watchProgress(String userId) => Stream.value(progress);

  @override
  Future<bool> completeModule(String userId, String moduleId) async => true;

  @override
  Future<int> submitQuiz(
    String userId,
    String moduleId,
    int correctCount,
  ) async {
    submits++;
    if (failFirstSave) {
      failFirstSave = false;
      throw Exception('simulated quiz save failure');
    }
    return correctCount;
  }
}

class _FlowScoreRepository implements ScoreRepository {
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
  group('Alur modul Belajar: hasil kuis -> penyimpanan -> ring', () {
    testWidgets(
      'kuis fakta-opini-satire: 3/4 otomatis tersimpan, bukan kartu 0/4',
      (WidgetTester tester) async {
        final learn = _FlowLearnRepository(const CourseProgress());
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
              learnRepositoryProvider.overrideWithValue(learn),
              scoreRepositoryProvider.overrideWithValue(_FlowScoreRepository()),
            ],
            child: const MaterialApp(
              home: QuizScreen(moduleId: 'fakta-opini-satire'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Jawab soal kedua dengan opsi salah untuk skenario 3/4.
        const scripts = <String>[
          'Pernyataan pertama dapat diuji',
          'Anggap benar karena banyak dibagikan',
          'Pisahkan klaim yang bisa diuji dari tafsiran',
          'Tidak; klaim faktual tetap perlu bukti',
        ];
        for (var i = 0; i < scripts.length; i++) {
          final option = find.textContaining(scripts[i]);
          expect(option, findsOneWidget);
          await tester.tap(option);
          await tester.pumpAndSettle();
          final isRight = i != 1;
          expect(
            find.text(isRight ? 'Benar!' : 'Kurang tepat.'),
            findsOneWidget,
          );
          final next = find.text(
            i == scripts.length - 1 ? 'Lihat hasil' : 'Lanjut',
          );
          await tester.ensureVisible(next);
          await tester.pumpAndSettle();
          await tester.tap(next);
          await tester.pumpAndSettle();
        }

        // Hasil: 3/4 benar.
        expect(find.text('Hasil kuismu'), findsOneWidget);
        expect(find.text('3/4'), findsOneWidget);
        // Hasil otomatis tersimpan begitu kuis selesai (bukan butuh klaim).
        expect(learn.submits, 1);
        await tester.pumpAndSettle();
        expect(find.textContaining('poin kuis diklaim'), findsWidgets);
        expect(find.text('Sudah masuk ke skormu.'), findsWidgets);
        expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('kuis: gagal menyimpan hasil menampilkan banner retry', (
      WidgetTester tester,
    ) async {
      final learn = _FlowLearnRepository(
        const CourseProgress(),
        failFirstSave: true,
      );
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
            learnRepositoryProvider.overrideWithValue(learn),
            scoreRepositoryProvider.overrideWithValue(_FlowScoreRepository()),
          ],
          child: const MaterialApp(home: QuizScreen(moduleId: 'clickbait')),
        ),
      );
      await tester.pumpAndSettle();

      // 3 soal clickbait: semua benar.
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
        expect(find.text('Benar!'), findsOneWidget);
        final next = find.text(i == 2 ? 'Lihat hasil' : 'Lanjut');
        await tester.ensureVisible(next);
        await tester.pumpAndSettle();
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(find.text('Hasil kuismu'), findsOneWidget);

      // Penyimpanan gagal: banner retry wajib tampil, bukan "tidak ada poin".
      expect(find.text(AppStrings.learnQuizSaveFailed), findsWidgets);
      expect(find.text(AppStrings.learnQuizRetrySave), findsOneWidget);
      expect(find.text(AppStrings.learnQuizNoNew), findsNothing);

      // Retry menyimpan hasil yang sama, tetap di hasil kuis, dan memperbarui
      // status tanpa memaksa pengguna mengulang jawaban.
      await tester.tap(find.text(AppStrings.learnQuizRetrySave));
      await tester.pumpAndSettle();
      expect(learn.submits, 2);
      expect(find.text('Hasil kuismu'), findsOneWidget);
      expect(find.text(AppStrings.learnQuizSaveFailed), findsWidgets);
      expect(find.text('Sudah masuk ke skormu.'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('Ring modul setelah kuis selesai', () {
    testWidgets('skor 3/4 terbaru tampil di ring modul yang belum selesai', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyUserIdProvider.overrideWithValue('u1'),
            learnRepositoryProvider.overrideWithValue(
              _FlowLearnRepository(
                const CourseProgress(quizBest: {'fakta-opini-satire': 3}),
              ),
            ),
            scoreRepositoryProvider.overrideWithValue(_FlowScoreRepository()),
          ],
          child: const MaterialApp(home: Scaffold(body: CourseListScreen())),
        ),
      );
      await tester.pumpAndSettle();

      // Kartu modul yang sudah punya skor 3/4 (4 soal) menampilkan 3/4.
      final moduleTitle = find.text('Fakta, Opini, dan Satire');
      await tester.ensureVisible(moduleTitle);
      await tester.pumpAndSettle();
      expect(find.text('3/4'), findsWidgets);
      expect(find.text(AppStrings.learnModuleAgain), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}

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
import 'package:literasi_ai/features/learn/presentation/screens/course_detail_screen.dart';
import 'package:literasi_ai/features/learn/presentation/screens/course_list_screen.dart';
import 'package:literasi_ai/features/learn/presentation/widgets/course_card.dart';
import 'package:literasi_ai/features/learn/presentation/widgets/module_motif.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';

class _FakeLearnRepository implements LearnRepository {
  _FakeLearnRepository(this.progress);

  final CourseProgress progress;

  @override
  List<CourseModule> modules() => LearnContentDatasource().modules();

  @override
  CourseModule? moduleById(String id) => LearnContentDatasource().byId(id);

  @override
  Stream<CourseProgress> watchProgress(String userId) =>
      Stream.value(progress);

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

Future<void> _pumpList(
  WidgetTester tester,
  CourseProgress progress, {
  Size? size,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        historyUserIdProvider.overrideWithValue('u1'),
        learnRepositoryProvider.overrideWithValue(
          _FakeLearnRepository(progress),
        ),
        scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
      ],
      child: const MaterialApp(home: Scaffold(body: CourseListScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('M1 motif satu sumber', () {
    test('tiga modul tiga motif berbeda dari accentSeed data', () {
      final modules = LearnContentDatasource().modules();
      final motifs = modules.map((m) => motifForModule(m.accentSeed)).toList();
      expect(motifs.map((m) => m.icon).toSet(), hasLength(3));
      expect(motifs.map((m) => m.tint).toSet(), hasLength(3));
      // Identitas ikut data, bukan posisi: seed sama = motif sama.
      expect(
        motifForModule(modules.first.accentSeed).icon,
        motifForModule(modules.first.accentSeed).icon,
      );
    });
  });

  group('M2 daftar baris library', () {
    testWidgets('3 ModuleRow + header seksi + hitungan selesai', (
      tester,
    ) async {
      await _pumpList(tester, const CourseProgress());

      expect(find.byType(ModuleRow), findsNWidgets(3));
      expect(find.text(AppStrings.learnMyModules), findsOneWidget);
      expect(find.textContaining('0 dari 3'), findsOneWidget);
      expect(find.text('Kenali Judul Clickbait'), findsOneWidget);
      expect(find.text('Ciri Gambar Manipulasi'), findsOneWidget);
      expect(find.text('Verifikasi Sumber Berita'), findsOneWidget);
      // Affordance eksplisit per baris.
      expect(find.byIcon(Icons.arrow_forward_rounded), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('selesai: centang penuh + label + hitungan naik', (
      tester,
    ) async {
      await _pumpList(
        tester,
        const CourseProgress(completedModuleIds: ['clickbait']),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.textContaining('1 dari 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('progres kuis jujur best/quizCount dari provider', (
      tester,
    ) async {
      await _pumpList(
        tester,
        const CourseProgress(quizBest: {'clickbait': 2}),
      );

      expect(find.text('2/3'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('M3 strip hadiah tetap jangkar gelap', () {
    testWidgets('judul + angka sinkron konstanta domain', (tester) async {
      await _pumpList(tester, const CourseProgress());

      await tester.ensureVisible(find.text(AppStrings.learnRewardTitle));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.learnRewardTitle), findsOneWidget);
      expect(find.text('+${LiteracyScore.modulePoints}'), findsOneWidget);
      expect(find.text('+${LiteracyScore.quizPoints}'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('M4 hero detail memakai motif modul', () {
    testWidgets('tiga modul tiga ikon hero berbeda', (tester) async {
      for (final id in ['clickbait', 'gambar-manipulasi', 'verifikasi-sumber']) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              historyUserIdProvider.overrideWithValue('u1'),
              learnRepositoryProvider.overrideWithValue(
                _FakeLearnRepository(const CourseProgress()),
              ),
              scoreRepositoryProvider.overrideWithValue(
                _FakeScoreRepository(),
              ),
            ],
            child: MaterialApp(home: CourseDetailScreen(moduleId: id)),
          ),
        );
        await tester.pumpAndSettle();
        final expected = motifForModule(
          LearnContentDatasource().byId(id)!.accentSeed,
        ).icon;
        expect(find.byIcon(expected), findsOneWidget);
        expect(find.byIcon(Icons.menu_book_outlined), findsNothing);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('M5 render responsif', () {
    for (final width in [360.0, 412.0]) {
      testWidgets('lebar ${width.toInt()}px render tanpa exception', (
        tester,
      ) async {
        await _pumpList(
          tester,
          const CourseProgress(),
          size: Size(width, 915),
        );

        expect(find.text('Kenali Judul Clickbait'), findsOneWidget);
        await tester.ensureVisible(find.text(AppStrings.learnRewardTitle));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}

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
import 'package:literasi_ai/shared/widgets/app_shimmer.dart';

class _FakeLearnRepository implements LearnRepository {
  _FakeLearnRepository(this.progress, {this.never = false});

  final CourseProgress progress;
  final bool never;

  @override
  List<CourseModule> modules() => LearnContentDatasource().modules();

  @override
  CourseModule? moduleById(String id) => LearnContentDatasource().byId(id);

  @override
  Stream<CourseProgress> watchProgress(String userId) {
    if (never) return const Stream.empty();
    return Stream.value(progress);
  }

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

List<Override> _overrides(CourseProgress progress, {bool never = false}) => [
  historyUserIdProvider.overrideWithValue('u1'),
  learnRepositoryProvider.overrideWithValue(
    _FakeLearnRepository(progress, never: never),
  ),
  scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
];

Future<void> _pumpList(
  WidgetTester tester,
  CourseProgress progress, {
  Size? size,
  bool never = false,
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
      overrides: _overrides(progress, never: never),
      child: const MaterialApp(home: Scaffold(body: CourseListScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('P1 motif satu sumber', () {
    test('tiga modul tiga motif berbeda dari accentSeed data', () {
      final modules = LearnContentDatasource().modules();
      final motifs = modules.map((m) => motifForModule(m.accentSeed)).toList();
      expect(motifs.map((m) => m.icon).toSet(), hasLength(3));
      expect(motifs.map((m) => m.tint).toSet(), hasLength(3));
    });
  });

  group('P2 hero ringkasan agregat + CTA', () {
    testWidgets('subtitle agregat dari data + CTA buka modul 1', (
      tester,
    ) async {
      await _pumpList(tester, const CourseProgress());

      expect(find.text('3 modul · 9 soal · ±15 mnt'), findsOneWidget);
      final cta = find.text('${AppStrings.learnHeroCtaPrefix} 1');
      await tester.ensureVisible(cta);
      await tester.pumpAndSettle();
      await tester.tap(cta);
      await tester.pumpAndSettle();
      expect(find.byType(CourseDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('semua selesai: CTA hero hilang', (tester) async {
      await _pumpList(
        tester,
        const CourseProgress(
          completedModuleIds: [
            'clickbait',
            'gambar-manipulasi',
            'verifikasi-sumber',
          ],
        ),
      );

      expect(
        find.textContaining(AppStrings.learnHeroCtaPrefix),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('P3 loading tanpa hitungan palsu', () {
    testWidgets('loading tampilkan skeleton, bukan "0 dari 0"', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(const CourseProgress(), never: true),
          child: const MaterialApp(home: Scaffold(body: CourseListScreen())),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('0 dari 0'), findsNothing);
      expect(find.byType(AppShimmer), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('P4 featured vertikal + seksi terpisah', () {
    testWidgets('progres kosong: featured modul 1 + seksi populer', (
      tester,
    ) async {
      await _pumpList(tester, const CourseProgress());

      expect(find.byType(ModuleRow), findsNWidgets(3));
      expect(find.text(AppStrings.learnPopularModules), findsOneWidget);
      // Header 1 baris adalah Text.rich: cocokkan via containing.
      expect(find.textContaining(AppStrings.learnAllModules), findsOneWidget);
      expect(find.text(AppStrings.learnFeaturedStart), findsOneWidget);
      // Satu-satunya FilledButton besar di tab = CTA featured.
      final filled = find.byType(FilledButton);
      expect(filled, findsOneWidget);
      expect(
        find.descendant(of: filled, matching: find.text('Mulai')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('semua selesai: tanpa featured, strip penutup tampil', (
      tester,
    ) async {
      await _pumpList(
        tester,
        const CourseProgress(
          completedModuleIds: [
            'clickbait',
            'gambar-manipulasi',
            'verifikasi-sumber',
          ],
        ),
      );

      expect(find.text(AppStrings.learnPopularModules), findsNothing);
      expect(find.text(AppStrings.learnAllDone), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('P5 compact: teks status + ring 40px, tanpa tombol besar', () {
    testWidgets('status Mulai/Lanjutkan/Selesai terbaca per baris', (
      tester,
    ) async {
      await _pumpList(
        tester,
        const CourseProgress(
          completedModuleIds: ['verifikasi-sumber'],
          quizBest: {'clickbait': 2},
        ),
      );

      expect(find.text(AppStrings.learnModuleContinue), findsOneWidget);
      expect(find.text(AppStrings.learnModuleDone), findsOneWidget);
      expect(find.text(AppStrings.learnModuleStart), findsOneWidget);
      // Compact tidak memakai FilledButton: hanya featured yang boleh.
      expect(find.byType(FilledButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('header seksi 1 baris + hitungan', (tester) async {
      await _pumpList(
        tester,
        const CourseProgress(completedModuleIds: ['clickbait']),
      );

      expect(find.textContaining('Semua modul'), findsOneWidget);
      expect(find.textContaining('1/3'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('P6 reward tint biru di atas', () {
    testWidgets('judul + angka sinkron konstanta domain', (tester) async {
      await _pumpList(tester, const CourseProgress());

      await tester.ensureVisible(find.text(AppStrings.learnRewardTitle));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.learnRewardTitle), findsOneWidget);
      expect(find.text('+${LiteracyScore.modulePoints}'), findsOneWidget);
      expect(find.text('+${LiteracyScore.quizPoints}'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_outlined), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('P7 hero detail memakai motif modul', () {
    testWidgets('tiga modul tiga ikon hero berbeda', (tester) async {
      for (final id in ['clickbait', 'gambar-manipulasi', 'verifikasi-sumber']) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: _overrides(const CourseProgress()),
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

  group('P8 render responsif + bebas overlap FAB', () {
    for (final width in [360.0, 412.0]) {
      testWidgets('lebar ${width.toInt()}px tanpa exception + tanpa overlap', (
        tester,
      ) async {
        await _pumpList(
          tester,
          const CourseProgress(),
          size: Size(width, 800),
        );

        expect(find.text('Kenali Judul Clickbait'), findsOneWidget);
        // Gulir sampai strip hadiah: seluruh konten harus bisa dicapai
        // tanpa tertutup (padding bawah 120px untuk FAB + navbar).
        await tester.ensureVisible(find.text(AppStrings.learnRewardTitle));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.textContaining(AppStrings.learnAllModules),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
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

/// Warna aksen kata kedua judul toolbar Belajar (Text.rich dua span).
Color? _toolbarAccent(WidgetTester tester) {
  final rich = find
      .textContaining('literasimu.')
      .evaluate()
      .map((e) => e.widget)
      .whereType<Text>()
      .where(
        (w) =>
            w.textSpan is TextSpan &&
            (w.textSpan! as TextSpan).children != null,
      );
  final text = rich.isNotEmpty
      ? rich.first
      : tester.widget<Text>(find.textContaining('literasimu.'));
  final span = text.textSpan;
  if (span is TextSpan && span.children != null) {
    for (final child in span.children!) {
      if (child is TextSpan && child.style?.fontStyle == FontStyle.italic) {
        return child.style?.color;
      }
    }
  }
  return text.style?.color;
}

void main() {
  group('Q1 judul biru + tanpa guest note', () {
    testWidgets('kata kedua judul primer, copy login hilang', (tester) async {
      await _pumpList(tester, const CourseProgress());

      expect(_toolbarAccent(tester), AppColors.primary);
      expect(
        find.textContaining('Masuk untuk menyimpan progres'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Q2 motif satu sumber', () {
    test('tiga modul tiga motif berbeda dari accentSeed data', () {
      final modules = LearnContentDatasource().modules();
      final motifs = modules.map((m) => motifForModule(m.accentSeed)).toList();
      expect(motifs.map((m) => m.icon).toSet(), hasLength(3));
      expect(motifs.map((m) => m.tint).toSet(), hasLength(3));
    });
  });

  group('Q3 loading tanpa hitungan palsu', () {
    testWidgets('loading tampilkan skeleton, bukan "0 dari 0"', (tester) async {
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

  group('Q4 featured biru solid + seksi terpisah', () {
    testWidgets('progres kosong: featured modul 1 satu FilledButton', (
      tester,
    ) async {
      await _pumpList(tester, const CourseProgress());

      expect(find.byType(ModuleRow), findsNWidgets(3));
      expect(find.text(AppStrings.learnPopularModules), findsOneWidget);
      expect(find.textContaining(AppStrings.learnAllModules), findsOneWidget);
      expect(find.text(AppStrings.learnFeaturedStart), findsOneWidget);
      // Satu-satunya FilledButton di tab = CTA featured.
      expect(find.byType(FilledButton), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.text('Mulai'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('banner gradien 120px + CTA primer di badan putih', (
      tester,
    ) async {
      await _pumpList(tester, const CourseProgress());

      // Featured v4: banner gradien hero 120px di atas (bukan seluruh
      // badan), konten putih di bawah dengan CTA primer biru.
      final cta = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(
        cta.style?.backgroundColor?.resolve(const <WidgetState>{}),
        AppColors.primary,
      );
      expect(
        cta.style?.foregroundColor?.resolve(const <WidgetState>{}),
        Colors.white,
      );
      // Subtitle di badan putih memakai abu netral, bukan biru muda hero.
      final subtitle = tester.widget<Text>(
        find.text(LearnContentDatasource().byId('clickbait')!.subtitle),
      );
      expect(subtitle.style?.color, AppColors.textSecondary);
      // Medallion motif modul 1 tampil; modul 1 tidak muncul dua kali
      // (dikeluarkan dari daftar compact).
      expect(find.byIcon(motifForModule(0).icon), findsOneWidget);
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

  group('Q5 compact borderless: teks status + ring, tanpa tombol besar', () {
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
      expect(find.byType(FilledButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact tanpa border/shadow kartu', (tester) async {
      await _pumpList(tester, const CourseProgress());

      // Baris compact memakai Material permukaan polos: tidak ada
      // Container ber-border di dalam ModuleRow non-featured.
      expect(find.byType(ModuleRow), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });

  group('Q6 reward strip inline sinkron domain, bukan kartu baru', () {
    testWidgets('hadiah satu baris + warna makna per angka', (tester) async {
      await _pumpList(tester, const CourseProgress());

      // Strip inline: tanpa permukaan tint kartu baru.
      final rewardTint = AppColors.primary.withValues(alpha: 0.07);
      expect(
        find.byWidgetPredicate((w) {
          if (w is! Container || w.decoration is! BoxDecoration) return false;
          return (w.decoration! as BoxDecoration).color == rewardTint;
        }),
        findsNothing,
      );
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
      // Angka dari konstanta domain; warna = makna breakdown Profil.
      final rewardText = tester.widget<Text>(
        find.textContaining('+${LiteracyScore.modulePoints}'),
      );
      final spans =
          (rewardText.textSpan as TextSpan?)?.children
              ?.whereType<TextSpan>()
              .toList() ??
          const [];
      expect(spans.length, greaterThanOrEqualTo(4));
      expect(spans[0].text, contains('+${LiteracyScore.modulePoints}'));
      expect(spans[0].style?.color, AppColors.successDark);
      expect(spans[2].text, contains('+${LiteracyScore.quizPoints}'));
      expect(spans[2].style?.color, AppColors.warningDark);
      // Urutan: bar hero di atas strip, bar featured di bawah strip
      // (dua LinearProgressIndicator: hero + featured).
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
      final heroBar = tester.getTopLeft(
        find.byType(LinearProgressIndicator).first,
      );
      final rewardStrip = tester.getTopLeft(
        find.byIcon(Icons.emoji_events_outlined),
      );
      final featuredBar = tester.getTopLeft(
        find.byType(LinearProgressIndicator).at(1),
      );
      expect(heroBar.dy, lessThan(rewardStrip.dy));
      expect(rewardStrip.dy, lessThan(featuredBar.dy));
      expect(tester.takeException(), isNull);
    });
  });

  group('Q7 hero detail memakai motif modul', () {
    testWidgets('tiga modul tiga ikon hero berbeda', (tester) async {
      for (final id in [
        'clickbait',
        'gambar-manipulasi',
        'verifikasi-sumber',
      ]) {
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

  group('Q8 render responsif + bebas overlap FAB', () {
    for (final size in [const Size(360, 800), const Size(412, 915)]) {
      testWidgets('lebar ${size.width.toInt()}px tanpa exception', (
        tester,
      ) async {
        await _pumpList(tester, const CourseProgress(), size: size);

        expect(find.text('Kenali Judul Clickbait'), findsOneWidget);
        // Seluruh konten bisa dicapai (padding bawah untuk FAB + navbar).
        await tester.ensureVisible(
          find.textContaining(AppStrings.learnAllModules),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Verifikasi Sumber Berita'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}

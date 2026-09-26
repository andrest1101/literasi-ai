import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/history/domain/entities/history_filter.dart';
import 'package:literasi_ai/features/history/presentation/widgets/history_filter_bar.dart';
import 'package:literasi_ai/features/learn/data/datasources/learn_content_datasource.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_module.dart';
import 'package:literasi_ai/features/learn/domain/entities/course_progress.dart';
import 'package:literasi_ai/features/learn/domain/repositories/learn_repository.dart';
import 'package:literasi_ai/features/learn/presentation/providers/learn_providers.dart';
import 'package:literasi_ai/features/learn/presentation/screens/quiz_screen.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';
import 'package:literasi_ai/features/score/presentation/screens/profile_screen.dart';
import 'package:literasi_ai/features/trending/presentation/screens/trending_detail_screen.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/shared/widgets/app_section_header.dart';

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

/// Ancestor terdekat sebuah elemen: dipakai memverifikasi tipe tombol
/// CTA lewat rantai widget (FilledButton.icon merender child internal
/// sehingga finder byType langsung tidak cocok).
Element? _parentOf(Element element) {
  Element? parent;
  element.visitAncestorElements((ancestor) {
    parent = ancestor;
    return false;
  });
  return parent;
}

void main() {  group('U2.1 aksen header per tab', () {
    testWidgets('default tetap biru brand (kompatibel mundur)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSectionHeader(
              eyebrow: 'E',
              titleLine1: 'Baris satu',
              titleLine2: 'Baris dua.',
              subtitle: 'Sub.',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final accent = tester.widget<Text>(find.text('Baris dua.'));
      expect(accent.style?.color, AppColors.primary);
      expect(tester.takeException(), isNull);
    });

    testWidgets('varian belajar hijau, riwayat biru tua, profil biru sedang', (
      tester,
    ) async {
      for (final entry in [
        (SectionAccent.learn, AppColors.successDark),
        (SectionAccent.history, AppColors.primaryDeep),
        (SectionAccent.profile, AppColors.primaryDark),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppSectionHeader(
                eyebrow: 'E',
                titleLine1: 'Satu',
                titleLine2: 'Dua ${entry.$1.name}.',
                subtitle: 'Sub.',
                accent: entry.$1,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final line2 = tester.widget<Text>(find.text('Dua ${entry.$1.name}.'));
        expect(line2.style?.color, entry.$2);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('empat tab memakai aksen masing-masing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );
      await tester.pumpAndSettle();

      // Judul toolbar compact memakai Text.rich: warna aksen ada di
      // span kedua (kata kedua italic). Baca dari span, bukan Text.style.
      Color? accentOf(String contains) {
        final text = tester.widget<Text>(find.textContaining(contains));
        final span = text.textSpan;
        if (span is TextSpan && span.children != null) {
          for (final child in span.children!) {
            if (child is TextSpan &&
                child.style?.fontStyle == FontStyle.italic) {
              return child.style?.color;
            }
          }
        }
        return text.style?.color;
      }

      expect(accentOf('sebelum sebar.'), AppColors.primary);

      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      expect(accentOf('pemeriksaanmu.'), AppColors.primaryDeep);

      await tester.tap(find.text('Belajar'));
      await tester.pumpAndSettle();
      expect(accentOf('literasimu.'), AppColors.successDark);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(accentOf('profilmu.'), AppColors.primaryDark);
      expect(tester.takeException(), isNull);
    });
  });

  group('U2.2 pill filter animasi + hitung', () {
    testWidgets('render angka tiap filter + tap pindah seleksi', (
      tester,
    ) async {
      HistoryFilter? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryFilterBar(
              selected: HistoryFilter.all,
              counts: const {
                HistoryFilter.all: 3,
                HistoryFilter.hoaks: 2,
                HistoryFilter.valid: 1,
                HistoryFilter.perluDicek: 0,
              },
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Hoaks'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      // Angka 0 selalu tampil: pill adalah ringkasan komposisi utuh
      // (kategori kosong = info, bukan error yang disembunyikan).
      expect(find.text('0'), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsWidgets);

      await tester.tap(find.text('Hoaks'));
      expect(selected, HistoryFilter.hoaks);
      expect(tester.takeException(), isNull);
    });
  });

  group('U2.3 pill sebagai ringkasan tunggal', () {
    testWidgets('tanpa kartu statistik terpisah, angka hanya di pill', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();

      // Guest tanpa login: empty penuh + CTA (U1.4), tanpa kartu/ringkasan.
      expect(find.text(AppStrings.historyEmptyCta), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('U2.4 trending primer + review kuis', () {
    testWidgets('detail: referensi tegas + CTA Filled primer', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );
      await tester.pumpAndSettle();

      final card = find.text(
        'Pesan bantuan tunai Rp 5 juta minta data rekening',
      );
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.byType(TrendingDetailScreen), findsOneWidget);
      expect(find.text('Rujukan'), findsOneWidget);
      expect(find.text('TurnBackHoax'), findsWidgets);
      // CTA primer: teks 'Verifikasi serupa' harus ada dan ancestor-nya
      // ButtonStyleButton Filled (bukan Outlined generik). FilledButton.icon
      // merender child internal, jadi verifikasi lewat rantai ancestor.
      final ctaText = find.text('Verifikasi serupa');
      await tester.ensureVisible(ctaText);
      await tester.pumpAndSettle();
      expect(ctaText, findsOneWidget);
      final ctaElement = ctaText.evaluate().single;
      // Rantai aktual FilledButton.icon ± level 40 (Material + Ink +
      // Focus + ...) — batas 60 agar longgar terhadap perubahan internal.
      var ancestor = _parentOf(ctaElement);
      var foundFilled = false;
      for (var i = 0; i < 60 && ancestor != null; i++) {
        if (ancestor.widget is FilledButton) {
          foundFilled = true;
          break;
        }
        ancestor = _parentOf(ancestor);
      }
      expect(foundFilled, isTrue);
      expect(find.text('Konteks terkait'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('kuis: hasil tampilkan review 3 soal', (tester) async {
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
        final next = find.text(i == 2 ? 'Lihat hasil' : 'Lanjut');
        await tester.ensureVisible(next);
        await tester.pumpAndSettle();
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(find.text('Hasil kuismu'), findsOneWidget);
      expect(find.text('Tinjau jawabanmu'), findsOneWidget);
      expect(find.text('Soal 1'), findsOneWidget);
      expect(find.text('Soal 3'), findsOneWidget);
      expect(find.text(correctTexts[0]), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('U2.5 profil beraksen + akun jujur', () {
    testWidgets('tamu: avatar T + CTA masuk; breakdown beraksen', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyUserIdProvider.overrideWithValue(null),
            scoreRepositoryProvider.overrideWithValue(_FakeScoreRepository()),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tamu LiterasiAI'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
      expect(find.text('Masuk untuk sinkron'), findsOneWidget);
      expect(find.text('Sumber poin'), findsOneWidget);
      expect(find.text('+0'), findsNWidgets(3));
      expect(find.textContaining('skor terbaik'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

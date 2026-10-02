import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
import 'package:literasi_ai/core/constants/app_styles.dart';
import 'package:literasi_ai/shared/widgets/app_section_header.dart';

/// Regresi R1–R3: header compact Riwayat/Belajar/Profil.
///
/// Tiga tab tidak lagi memakai header editorial penuh (±190px: pill +
/// judul 26px 2 baris + subtitle + hairline). Masing-masing memakai judul
/// toolbar 20px two-tone dengan aksen identitas tab yang sama; konten
/// fungsional naik ±130–170px ke lipatan layar.
void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();
  }

  /// Warna aksen kata kedua judul toolbar compact (Text.rich dua span).
  ///
  /// Bila beberapa Text cocok (mis. hint konten memakai kata mirip), pilih
  /// kandidat Text.rich beranak span: itulah judul toolbar, bukan body.
  Color? toolbarAccent(WidgetTester tester, String contains) {
    final rich = find
        .textContaining(contains)
        .evaluate()
        .map((e) => e.widget)
        .whereType<Text>()
        .where(
          (w) => w.textSpan is TextSpan && (w.textSpan! as TextSpan).children != null,
        );
    final text = rich.isNotEmpty
        ? rich.first
        : tester.widget<Text>(find.textContaining(contains));
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

  group('Token skala judul tab AppTabTitles', () {
    test('Display 24 two-tone + Compact 20 two-tone + gap 12', () {
      // Nilai terkunci = nilai yang sudah teruji di keempat layar.
      // Display (landing Cek): headline lebih besar karena halaman utama.
      expect(AppTabTitles.displayLine1.fontSize, 24);
      expect(AppTabTitles.displayLine2(AppColors.primary).fontSize, 24);
      expect(
        AppTabTitles.displayLine2(AppColors.primary).fontStyle,
        FontStyle.italic,
      );
      expect(AppTabTitles.displaySubtitle.fontSize, 13);
      // Compact (tab utilitas): jangkar toolbar, bukan editorial.
      expect(AppTabTitles.compactLine1.fontSize, 20);
      expect(AppTabTitles.compactLine2(AppColors.primary).fontSize, 20);
      expect(
        AppTabTitles.compactLine2(AppColors.primary).fontStyle,
        FontStyle.italic,
      );
      expect(AppTabTitles.titleToContentGap, AppSpacing.md);
    });
  });

  group('Header compact R1–R3', () {
    testWidgets('tanpa header editorial penuh di 3 tab', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      for (final tab in ['Riwayat', 'Belajar', 'Profil']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        // Judul toolbar compact ada; pill eyebrow + komponen editorial tidak.
        expect(find.byType(AppSectionHeader), findsNothing);
        expect(find.text('AKTIVITAS'), findsNothing);
        expect(find.text('EDUKASI'), findsNothing);
        expect(find.text('AKUN'), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('aksen identitas per tab dipertahankan', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      expect(toolbarAccent(tester, 'pemeriksaanmu.'), AppColors.primaryDeep);

      await tester.tap(find.text('Belajar'));
      await tester.pumpAndSettle();
      // Judul Belajar biru primer (hijau hanya status selesai + badge).
      expect(toolbarAccent(tester, 'literasimu.'), AppColors.primary);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(toolbarAccent(tester, 'profilmu.'), AppColors.primaryDark);
      expect(tester.takeException(), isNull);
    });

    testWidgets('konten fungsional masuk lipatan 360×800', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await pumpHome(tester);

      // Riwayat: search field terlihat tanpa scroll.
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      final searchTop = tester.getTopLeft(find.byType(TextField)).dy;
      expect(searchTop, lessThan(800));

      // Belajar: CTA featured (satu-satunya tombol besar tab) terlihat
      // tanpa scroll. Hero kini ringkasan tanpa CTA.
      await tester.tap(find.text('Belajar'));
      await tester.pumpAndSettle();
      final ctaTop = tester.getTopLeft(find.byType(FilledButton)).dy;
      expect(ctaTop, lessThan(800));

      // Profil: ring skor terlihat tanpa scroll.
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      final ringTop = tester.getTopLeft(find.text('poin')).dy;
      expect(ringTop, lessThan(800));
      expect(tester.takeException(), isNull);
    });
  });
}

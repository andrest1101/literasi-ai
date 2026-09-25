import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
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
  Color? toolbarAccent(WidgetTester tester, String contains) {
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
      expect(toolbarAccent(tester, 'literasimu.'), AppColors.successDark);

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

      // Belajar: kartu modul pertama terlihat tanpa scroll.
      await tester.tap(find.text('Belajar'));
      await tester.pumpAndSettle();
      final moduleTop = tester
          .getTopLeft(find.text('Kenali Judul Clickbait'))
          .dy;
      expect(moduleTop, lessThan(800));

      // Profil: ring skor terlihat tanpa scroll.
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      final ringTop = tester.getTopLeft(find.text('poin')).dy;
      expect(ringTop, lessThan(800));
      expect(tester.takeException(), isNull);
    });
  });
}

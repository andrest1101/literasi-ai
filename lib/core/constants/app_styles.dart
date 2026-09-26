import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography & theme: Material 3, font Inter (fallback sistematis).
/// Google Sans tidak tersedia publik, jadi Inter adalah padanan resmi PRD §7.3.
///
/// Token radius/spacing/elevasi terpusat di sini agar widget tidak memakai
/// angka magic tersebar. Nilai lama tidak diubah, hanya diberi nama.
abstract final class AppStyles {
  static const String fontFamily = 'Inter';

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      error: AppColors.danger,
      surface: AppColors.surface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.shadowInk.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.disabledSurface,
          disabledForegroundColor: AppColors.disabledInk,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.small),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.14),
        disabledColor: AppColors.disabledSurface,
        side: BorderSide(
          color: AppColors.neutral.withValues(alpha: 0.25),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.neutral.withValues(alpha: 0.18),
        thickness: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}

/// Radius terpusat: satu sumber kebenaran untuk semua kartu/tombol/pill.
abstract final class AppRadii {
  static const double card = 22;
  static const double hero = 26;
  static const double button = 16;
  static const double small = 14;
  static const double pill = 999;
}

/// Spacing grid 8pt: pakai kelipatan ini untuk ritme vertikal konsisten.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

/// Skala judul tab: SATU sumber kebenaran agar keempat tab satu keluarga.
///
/// Dua tingkat yang disengaja, bukan kebetulan:
/// * Display (landing Cek): 24px two-tone 2 baris + subtitle + hairline.
///   Landing utama boleh sedikit lebih besar: di sinilah aksi primer.
/// * Compact (Riwayat/Belajar/Profil): 20px two-tone 1 baris.
///   Tab utilitas: judul hanya jangkar toolbar fungsional di bawahnya.
/// Hairline pemisah hanya milik Display sebagai jangkar editorial landing
/// (tiga tab Compact sengaja tanpa hairline: judulnya jangkar toolbar,
/// bukan editorial). Perbedaan ini keputusan yang didokumentasikan, bukan
/// inkonsistensi.
/// Nilai di sini = nilai yang sudah teruji di keempat layar; refactor
/// screen ke token ini TIDAK mengubah satu piksel pun visual.
abstract final class AppTabTitles {
  static const TextStyle displayLine1 = TextStyle(
    fontSize: 24,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle displayLine2(Color accent) => TextStyle(
    fontSize: 24,
    height: 1.15,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.5,
    color: accent,
  );

  static const TextStyle displaySubtitle = TextStyle(
    fontSize: 13,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  static const TextStyle compactLine1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static TextStyle compactLine2(Color accent) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.4,
    color: accent,
  );

  /// Gap vertikal judul ke konten: 12px konsisten di keempat tab.
  static const double titleToContentGap = AppSpacing.md;
}

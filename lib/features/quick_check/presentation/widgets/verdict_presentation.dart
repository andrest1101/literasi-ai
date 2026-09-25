import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/verification_result.dart';

/// Gaya presentasi tiap verdict — hanya memakai palet resmi LiterasiAI.
///
/// Dipisah ke file sendiri agar dipakai bersama oleh
/// [QuickCheckResultSection] (layar sesi) dan [ShareCard] (gambar share)
/// tanpa circular import antar widget.
class VerdictPresentation {
  const VerdictPresentation({
    required this.accent,
    required this.deep,
    required this.soft,
    required this.icon,
    required this.headline,
  });

  final Color accent;
  final Color deep;
  final Color soft;
  final IconData icon;

  /// Kesimpulan satu-baris yang terbaca dalam 1 detik — status definitif
  /// atas informasi yang diperiksa, bukan perintah perilaku. Teks + ikon +
  /// warna sehingga aman untuk pengguna buta warna.
  final String headline;

  factory VerdictPresentation.of(Verdict verdict) {
    return switch (verdict) {
      Verdict.hoaks => VerdictPresentation(
        accent: AppColors.danger,
        deep: AppColors.dangerDark,
        soft: AppColors.danger.withValues(alpha: 0.1),
        icon: Icons.gpp_bad_outlined,
        headline: AppStrings.verdictHeadlineHoaks,
      ),
      Verdict.valid => VerdictPresentation(
        accent: AppColors.success,
        deep: AppColors.successDark,
        soft: AppColors.success.withValues(alpha: 0.1),
        icon: Icons.verified_outlined,
        headline: AppStrings.verdictHeadlineValid,
      ),
      Verdict.perluDicek => VerdictPresentation(
        accent: AppColors.verdictAmber,
        deep: AppColors.warningDark,
        soft: AppColors.warning.withValues(alpha: 0.16),
        icon: Icons.search_outlined,
        headline: AppStrings.verdictHeadlinePerluDicek,
      ),
      Verdict.tidakDapatDipastikan => VerdictPresentation(
        accent: AppColors.neutral,
        deep: AppColors.textSecondary,
        soft: AppColors.neutral.withValues(alpha: 0.12),
        icon: Icons.help_outline_rounded,
        headline: AppStrings.verdictHeadlineTidakPasti,
      ),
    };
  }
}

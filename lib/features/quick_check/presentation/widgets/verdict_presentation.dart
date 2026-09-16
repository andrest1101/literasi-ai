import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/verification_result.dart';

/// Gaya presentasi tiap verdict — hanya memakai palet resmi LiterasiAI.
///
/// Dipisah ke file sendiri agar dipakai bersama oleh
/// [QuickCheckResultSection] (layar sesi) dan [ShareCard] (gambar share)
/// tanpa circular import antar widget.
class VerdictPresentation {
  const VerdictPresentation({required this.accent, required this.icon});

  final Color accent;
  final IconData icon;

  factory VerdictPresentation.of(Verdict verdict) {
    return switch (verdict) {
      Verdict.hoaks => const VerdictPresentation(
        accent: AppColors.danger,
        icon: Icons.gpp_bad_outlined,
      ),
      Verdict.valid => const VerdictPresentation(
        accent: AppColors.success,
        icon: Icons.verified_outlined,
      ),
      Verdict.perluDicek => const VerdictPresentation(
        accent: Color(0xFFB7791F),
        icon: Icons.search_outlined,
      ),
      Verdict.tidakDapatDipastikan => const VerdictPresentation(
        accent: AppColors.neutral,
        icon: Icons.help_outline_rounded,
      ),
    };
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Motif identitas per modul: satu sumber kebenaran untuk thumbnail daftar
/// dan hero detail.
///
/// Dipilih dari `accentSeed` data (bukan posisi list): identitas modul
/// tetap sama walau urutan berubah. Tint terang satu keluarga (biru → teal
/// → hijau), bukan warna acak per permukaan.
class ModuleMotif {
  const ModuleMotif({
    required this.icon,
    required this.tint,
    required this.ink,
  });

  final IconData icon;
  final Color tint;
  final Color ink;
}

ModuleMotif motifForModule(int seed) {
  return switch (seed % 12) {
    0 => const ModuleMotif(
      icon: Icons.ads_click_rounded,
      tint: Color(0xFFE3EEFD),
      ink: AppColors.primaryDark,
    ),
    1 => const ModuleMotif(
      icon: Icons.image_search_rounded,
      tint: Color(0xFFDFF3F0),
      ink: Color(0xFF0B6B5F),
    ),
    2 => const ModuleMotif(
      icon: Icons.verified_outlined,
      tint: Color(0xFFE2F4E5),
      ink: AppColors.successDark,
    ),
    3 => const ModuleMotif(
      icon: Icons.video_library_outlined,
      tint: Color(0xFFE9E5FA),
      ink: Color(0xFF59469B),
    ),
    4 => const ModuleMotif(
      icon: Icons.bar_chart_rounded,
      tint: Color(0xFFFFF0DA),
      ink: Color(0xFF8A5A00),
    ),
    5 => const ModuleMotif(
      icon: Icons.health_and_safety_outlined,
      tint: Color(0xFFFFE9E7),
      ink: AppColors.dangerDark,
    ),
    6 => const ModuleMotif(
      icon: Icons.phishing_outlined,
      tint: Color(0xFFFFE9E7),
      ink: AppColors.dangerDark,
    ),
    7 => const ModuleMotif(
      icon: Icons.auto_awesome_outlined,
      tint: Color(0xFFE9E5FA),
      ink: Color(0xFF59469B),
    ),
    8 => const ModuleMotif(
      icon: Icons.forum_outlined,
      tint: Color(0xFFDFF3F0),
      ink: Color(0xFF0B6B5F),
    ),
    9 => const ModuleMotif(
      icon: Icons.lock_outline_rounded,
      tint: Color(0xFFE3EEFD),
      ink: AppColors.primaryDark,
    ),
    10 => const ModuleMotif(
      icon: Icons.fingerprint_rounded,
      tint: Color(0xFFE9E5FA),
      ink: Color(0xFF59469B),
    ),
    _ => const ModuleMotif(
      icon: Icons.hub_outlined,
      tint: Color(0xFFDFF3F0),
      ink: Color(0xFF0B6B5F),
    ),
  };
}

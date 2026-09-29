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
  return switch (seed % 3) {
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
    _ => const ModuleMotif(
      icon: Icons.verified_outlined,
      tint: Color(0xFFE2F4E5),
      ink: AppColors.successDark,
    ),
  };
}

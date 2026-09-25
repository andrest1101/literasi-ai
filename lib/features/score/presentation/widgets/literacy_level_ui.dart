import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/literacy_level.dart';

/// Pemetaan level ke gaya visual: tinggal di presentation, bukan domain.
extension LiteracyLevelUi on LiteracyLevel {
  Color get accent => switch (this) {
    LiteracyLevel.pemula => AppColors.neutral,
    LiteracyLevel.waspada => AppColors.primary,
    LiteracyLevel.kritis => AppColors.warning,
    LiteracyLevel.ahli => AppColors.success,
  };

  IconData get icon => switch (this) {
    LiteracyLevel.pemula => Icons.spa_outlined,
    LiteracyLevel.waspada => Icons.visibility_outlined,
    LiteracyLevel.kritis => Icons.psychology_outlined,
    LiteracyLevel.ahli => Icons.emoji_events_outlined,
  };
}

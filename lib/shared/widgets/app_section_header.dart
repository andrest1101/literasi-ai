import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Header editorial per tab — murni tipografi, tanpa dekorasi.
///
/// Komposisi: eyebrow pill kecil + judul two-tone (baris 1 gelap, baris 2
/// biru italic) + subtitle + hairline pemisah. Emblem gradien sengaja
/// dihapus: lima layar memakai dekorasi identik terbukti menumpuk dan
/// monoton. Pembeda tiap tab datang dari konten fungsional di bawahnya.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.eyebrow,
    required this.titleLine1,
    required this.titleLine2,
    required this.subtitle,
  });

  final String eyebrow;
  final String titleLine1;
  final String titleLine2;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppColors.primary.withValues(alpha: 0.08),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            eyebrow,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          titleLine1,
          style: const TextStyle(
            fontSize: 26,
            height: 1.14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          titleLine2,
          style: const TextStyle(
            fontSize: 26,
            height: 1.14,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: AppColors.neutral.withValues(alpha: 0.18),
        ),
      ],
    );
  }
}

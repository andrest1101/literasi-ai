import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Aksen identitas per tab — satu keluarga palet resmi, tanpa warna asing.
///
/// Cek tetap biru brand ([AppColors.primary]); Riwayat biru tua arsip;
/// Belajar hijau tumbuh; Profil biru sedang personal. Aksen hanya mewarnai
/// eyebrow pill + baris judul kedua; tipografi dan hairline tidak berubah
/// sehingga keempat tab tetap terbaca satu keluarga.
enum SectionAccent {
  check(AppColors.primary),
  history(AppColors.primaryDeep),
  learn(AppColors.successDark),
  profile(AppColors.primaryDark);

  const SectionAccent(this.color);

  final Color color;
}

/// Header editorial per tab — tipografi + aksen identitas, tanpa dekorasi.
///
/// Komposisi: eyebrow pill kecil + judul two-tone (baris 1 gelap, baris 2
/// warna aksen italic) + subtitle + hairline pemisah. Emblem gradien sengaja
/// tidak ada: lima layar memakai dekorasi identik terbukti menumpuk dan
/// monoton. Pembeda tiap tab datang dari aksen + konten fungsional.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.eyebrow,
    required this.titleLine1,
    required this.titleLine2,
    required this.subtitle,
    this.accent = SectionAccent.check,
  });

  final String eyebrow;
  final String titleLine1;
  final String titleLine2;
  final String subtitle;
  final SectionAccent accent;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: accentColor.withValues(alpha: 0.08),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            eyebrow,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: accentColor,
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
          style: TextStyle(
            fontSize: 26,
            height: 1.14,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
            color: accentColor,
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

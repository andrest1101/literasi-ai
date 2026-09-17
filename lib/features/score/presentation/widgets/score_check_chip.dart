import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/score_providers.dart';
import 'literacy_level_ui.dart';

/// Pill skor ringkas di tab Cek — satu baris, ketuk masuk Profil.
///
/// Menampilkan ikon + label level dan total poin dari stream skor aktif.
/// Tanpa login menampilkan level Pemula 0 poin secara jujur, bukan angka
/// palsu. Tinggi ~44px agar tidak menambah ramai tab Cek.
class ScoreCheckChip extends ConsumerWidget {
  const ScoreCheckChip({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);
    return Semantics(
      button: true,
      label: 'Lihat skor literasi di Profil',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.neutral.withValues(alpha: 0.22),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D101A33),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: score.when(
              loading: () => const _ChipContent(
                icon: Icons.spa_outlined,
                text: 'Memuat skor...',
              ),
              error: (_, _) => const _ChipContent(
                icon: Icons.spa_outlined,
                text: 'Pemula - 0 poin',
              ),
              data: (value) => _ChipContent(
                icon: value.level.icon,
                iconColor: value.level.accent,
                text: '${value.level.label} - ${value.total} poin',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipContent extends StatelessWidget {
  const _ChipContent({
    required this.icon,
    required this.text,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}

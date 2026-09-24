import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/literacy_score.dart';

/// Rincian sumber poin — transparansi cara naik level.
///
/// Tiga baris (Verifikasi/Modul/Kuis) dengan hitungan dan subtotal masing
/// masing, plus catatan jujur bahwa modul dibuka di Phase 3b.
class ScoreBreakdown extends StatelessWidget {
  const ScoreBreakdown({super.key, required this.score});

  final LiteracyScore score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.neutral.withValues(alpha: 0.2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101A33),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.scoreBreakdownTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _SourceRow(
            icon: Icons.fact_check_outlined,
            label: AppStrings.scoreVerifyRow,
            detail: '${score.verifications} x 10',
            total: score.verificationTotal,
            accent: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _SourceRow(
            icon: Icons.school_outlined,
            label: AppStrings.scoreModuleRow,
            detail: '${score.modulesDone.length} x 20',
            total: score.moduleTotal,
            accent: AppColors.success,
          ),
          const SizedBox(height: 10),
          _SourceRow(
            icon: Icons.quiz_outlined,
            label: AppStrings.scoreQuizRow,
            detail: '${score.quizCorrect} x 5',
            total: score.quizTotal,
            accent: AppColors.verdictAmber,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withValues(alpha: 0.06),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.scoreModuleSoon,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.icon,
    required this.label,
    required this.detail,
    required this.total,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String detail;
  final int total;

  /// Aksen identitas sumber poin: verifikasi biru, modul hijau, kuis amber.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: accent.withValues(alpha: 0.1),
          ),
          child: Icon(icon, size: 19, color: accent),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        Text(
          '+$total',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: accent,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

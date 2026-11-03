import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../domain/entities/literacy_score.dart';

/// Rincian sumber poin: transparansi cara naik level.
///
/// Satu strip tiga kolom (Verifikasi/Modul/Kuis): angka capaian besar,
/// label, lalu poin yang disumbang. Tidak ada kartu di dalam kartu: saat
/// [onHero] true, strip menempel langsung pada gradien [ScoreRing] dan
/// memakai tinta putih; saat false, strip dibungkus satu permukaan putih
/// agar tetap bisa dipakai mandiri.
class ScoreBreakdown extends StatelessWidget {
  const ScoreBreakdown({super.key, required this.score, this.onHero = false});

  static const ValueKey<String> verificationsKey = ValueKey(
    'score-stat-verifications',
  );
  static const ValueKey<String> modulesKey = ValueKey('score-stat-modules');
  static const ValueKey<String> quizzesKey = ValueKey('score-stat-quizzes');

  final LiteracyScore score;

  /// True bila dirender di atas gradien hero: tanpa permukaan tambahan.
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final strip = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Stat(
                key: verificationsKey,
                count: score.verifications,
                label: AppStrings.scoreVerifyRow,
                points: score.verificationTotal,
                accent: AppColors.primary,
                onHero: onHero,
              ),
            ),
            _StatDivider(onHero: onHero),
            Expanded(
              child: _Stat(
                key: modulesKey,
                count: score.modulesDone.length,
                label: AppStrings.scoreModuleRow,
                points: score.moduleTotal,
                accent: AppColors.success,
                onHero: onHero,
              ),
            ),
            _StatDivider(onHero: onHero),
            Expanded(
              child: _Stat(
                key: quizzesKey,
                count: score.quizCorrect,
                label: AppStrings.scoreQuizRow,
                points: score.quizTotal,
                accent: AppColors.verdictAmber,
                onHero: onHero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: onHero ? AppColors.heroInkSoft : AppColors.primary,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                AppStrings.scorePointsRule,
                style: TextStyle(
                  fontSize: onHero ? 11.5 : 12,
                  height: 1.55,
                  color: onHero
                      ? AppColors.heroInkSoft
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    if (onHero) return strip;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        color: AppColors.surface,
        border: Border.all(color: AppColors.hairline),
      ),
      child: strip,
    );
  }
}

/// Satu sumber poin: angka capaian, label, dan kontribusi poin.
class _Stat extends StatelessWidget {
  const _Stat({
    super.key,
    required this.count,
    required this.label,
    required this.points,
    required this.accent,
    required this.onHero,
  });

  final int count;
  final String label;
  final int points;
  final Color accent;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final valueColor = onHero ? Colors.white : AppColors.textPrimary;
    final labelColor = onHero ? AppColors.heroInkSoft : AppColors.textSecondary;
    final pointsColor = onHero ? Colors.white : accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          maxLines: 1,
          style: TextStyle(
            fontSize: 22,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: valueColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            height: 1.35,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '+$points',
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: pointsColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Garis pemisah tipis antar stat: putih transparan di hero, hairline di
/// permukaan putih.
class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.onHero});

  final bool onHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      color: onHero ? Colors.white.withValues(alpha: 0.18) : AppColors.hairline,
    );
  }
}

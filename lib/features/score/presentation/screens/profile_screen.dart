import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../providers/score_providers.dart';
import '../widgets/score_breakdown.dart';
import '../widgets/score_ring.dart';

/// Tab Profil fungsional pertama — skor + akun + info.
///
/// Header kontekstual, cincin skor animasi, rincian sumber poin, dan kartu
/// akun yang jujur membedakan mode anonim vs tersinkron.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);
    final userId = ref.watch(historyUserIdProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionHeader(
                eyebrow: AppStrings.homeProfileEyebrow,
                titleLine1: AppStrings.homeProfileTitle1,
                titleLine2: AppStrings.homeProfileTitle2,
                subtitle: AppStrings.homeProfileSubtitle,
              ),
              const SizedBox(height: 18),
              score.when(
                loading: () => const _ScoreSkeleton(),
                error: (_, _) => const _ScoreSkeleton(),
                data: (value) => ScoreRing(score: value),
              ),
              const SizedBox(height: 14),
              score.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (value) => ScoreBreakdown(score: value),
              ),
              const SizedBox(height: 14),
              _AccountCard(synced: userId != null),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.synced});

  final bool synced;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: (synced ? AppColors.success : AppColors.primary)
                  .withValues(alpha: 0.1),
            ),
            child: Icon(
              synced ? Icons.cloud_done_outlined : Icons.person_outline,
              size: 23,
              color: synced ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.scoreAccountTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  synced
                      ? AppStrings.scoreSyncedNote
                      : AppStrings.scoreAnonymousNote,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
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

class _ScoreSkeleton extends StatelessWidget {
  const _ScoreSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.neutral.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import 'quick_check_session_screen.dart';

/// Landing tab Quick Check — ringkas, memberi ruang sesi dedicated.
///
/// Tab ini tidak lagi menampung form penuh. Satu CTA membuka
/// [QuickCheckSessionScreen] agar pemeriksaan punya ruang fokus sendiri.
class QuickCheckHomeTab extends StatelessWidget {
  const QuickCheckHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2F80ED), Color(0xFF124A9B)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x331558B0),
                      blurRadius: 26,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withValues(alpha: 0.16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        AppStrings.quickCheckLandingBadge,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      AppStrings.quickCheckLandingTitle,
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.quickCheckLandingSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: Color(0xFFD6E5FE),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(QuickCheckSessionScreen.route),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 22),
                        label: const Text(AppStrings.quickCheckStartSession),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.quickCheckStepsTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const _StepRow(
                number: '1',
                title: AppStrings.quickCheckStep1Title,
                subtitle: AppStrings.quickCheckStep1Subtitle,
                icon: Icons.edit_note_outlined,
              ),
              const SizedBox(height: 10),
              const _StepRow(
                number: '2',
                title: AppStrings.quickCheckStep2Title,
                subtitle: AppStrings.quickCheckStep2Subtitle,
                icon: Icons.psychology_outlined,
              ),
              const SizedBox(height: 10),
              const _StepRow(
                number: '3',
                title: AppStrings.quickCheckStep3Title,
                subtitle: AppStrings.quickCheckStep3Subtitle,
                icon: Icons.verified_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String number;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 23, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neutral.withValues(alpha: 0.35),
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

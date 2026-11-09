import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/gemini_connectivity_probe.dart';
import 'gemini_probe_step_row.dart';

/// Section 2: tes koneksi AI dengan hasil per tahap sebagai timeline.
class ApiKeyTestCard extends StatelessWidget {
  const ApiKeyTestCard({
    super.key,
    required this.testing,
    required this.testOk,
    required this.testSteps,
    required this.testResult,
    required this.canTest,
    required this.onTest,
  });

  final bool testing;
  final bool? testOk;
  final List<GeminiProbeStep> testSteps;
  final String? testResult;
  final bool canTest;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(badge: '2', title: AppStrings.connectionTestTitle),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: testing || !canTest ? null : onTest,
            icon: testing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.network_check_outlined, size: 19),
            label: Text(
              testing
                  ? AppStrings.connectionTestRunning
                  : AppStrings.connectionTestRun,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          canTest ? AppStrings.apiKeyTestSavedKey : AppStrings.apiKeyTestNeedsKey,
          style: const TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        if (testResult != null) ...[
          const SizedBox(height: 12),
          _ResultBanner(ok: testOk == true, message: testResult!),
        ],
        if (testSteps.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            AppStrings.apiKeyProbeStepsTitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              for (var i = 0; i < testSteps.length; i++)
                GeminiProbeStepRow(
                  step: testSteps[i],
                  isLast: i == testSteps.length - 1,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Header section bernomor: lingkaran badge + judul.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.badge, required this.title});

  final String badge;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Text(
            badge,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Banner ringkas hasil tes: hijau (sukses) atau merah (gagal).
class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.ok, required this.message});

  final bool ok;
  final String message;

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.09),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

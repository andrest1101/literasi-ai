import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/gemini_connectivity_probe.dart';

/// Satu tahap pemeriksaan jalur sebagai entri timeline:
/// titik status + garis penghubung + nama + durasi (tabular figures).
class GeminiProbeStepRow extends StatelessWidget {
  const GeminiProbeStepRow({
    super.key,
    required this.step,
    this.isLast = true,
  });

  final GeminiProbeStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = step.ok ? AppColors.success : AppColors.danger;
    final secs = (step.elapsed.inMilliseconds / 1000).toStringAsFixed(1);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: color.withValues(alpha: 0.35),
                    width: 3,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: AppColors.hairline,
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 2 : 12),
            child: Row(
              children: [
                Icon(
                  step.ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$secs dtk',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

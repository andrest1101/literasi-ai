import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/usecases/verify_claim.dart';

/// Counter karakter rapi untuk Quick Check.
///
/// Format Indonesia dengan pemisah ribuan, contoh: `0 / 2.000 karakter`.
/// Ditempatkan natural di pojok kanan bawah area input, bukan di header.
class CharCounterText extends StatelessWidget {
  const CharCounterText({
    super.key,
    required this.length,
    this.showTrack = true,
  });

  final int length;
  final bool showTrack;

  /// Format Indonesia dengan pemisah ribuan.
  static String format(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      count++;
      if (count % 3 == 0 && i > 0) buffer.write('.');
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final max = VerifyClaim.maxLength;
    final ratio = length / max;
    final nearLimit = length >= max - 100;
    final color = nearLimit ? AppColors.danger : AppColors.textSecondary;

    return Semantics(
      label: 'Jumlah karakter ${format(length)} dari ${format(max)}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTrack) ...[
            SizedBox(
              width: 34,
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.neutral.withValues(alpha: 0.2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio.clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: nearLimit
                            ? AppColors.danger
                            : AppColors.primary.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '${format(length)} / ${format(max)} karakter',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

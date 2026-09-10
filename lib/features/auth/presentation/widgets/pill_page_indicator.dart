import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Indikator halaman capsule/pill yang dinamis (animated).
///
/// Aktif: lonjong `w=28` warna gelap. Nonaktif: titik `w=8` abu terang.
class PillPageIndicator extends StatelessWidget {
  const PillPageIndicator({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Halaman ${current + 1} dari $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? AppColors.textPrimary : AppColors.neutral
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Aksi tunggal untuk keluar dari sesi pemeriksaan.
///
/// Lingkaran tonal 40px memberi affordance yang lebih jelas daripada panah
/// polos, tanpa menambah CTA kedua yang mengulang fungsi kembali.
class SessionBackButton extends StatelessWidget {
  const SessionBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali ke Beranda',
      child: Tooltip(
        message: 'Kembali ke Beranda',
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: Ink(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A101A33),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

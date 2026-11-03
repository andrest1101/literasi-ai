import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

/// Dialog aksi khas LiterasiAI: medallion ikon + judul + body + aksi.
///
/// Satu bahasa visual untuk konfirmasi penting di seluruh aplikasi
/// (keluar akun, gagal keluar, Tentang, hapus kunci API) menggantikan
/// `AlertDialog` generik: medallion 52px tint aksen, judul 17px, body 14px,
/// tombol primer penuh, dan aksi sekunder berbentuk teks.
class AppMedallionDialog extends StatelessWidget {
  const AppMedallionDialog({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryDanger = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool primaryDanger;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 27, color: accent),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: onPrimary,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryDanger
                      ? AppColors.danger
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(primaryLabel, overflow: TextOverflow.ellipsis),
              ),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 4),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

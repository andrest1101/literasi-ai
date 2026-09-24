import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Empty state riwayat — ikon + copy + CTA mulai memeriksa.
///
/// [onStartCheck] opsional agar widget tetap decoupled: layar pengisi
/// memutuskan navigasinya (push sesi Quick Check). Varian [filtered]
/// (hasil filter kosong) tidak menampilkan CTA karena masalahnya filter,
/// bukan belum ada data — CTA di sana hanya menambah noise.
class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key, required this.filtered, this.onStartCheck});

  final bool filtered;
  final VoidCallback? onStartCheck;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 56),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            filtered
                ? AppStrings.historyEmptyFilteredTitle
                : AppStrings.historyEmptyTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filtered
                ? AppStrings.historyEmptyFilteredSubtitle
                : AppStrings.historyEmptySubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          if (!filtered && onStartCheck != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onStartCheck,
              icon: const Icon(Icons.verified_outlined, size: 19),
              label: const Text(AppStrings.historyEmptyCta),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/widgets/quick_check_result_section.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../../domain/entities/history_entry.dart';
import '../providers/history_providers.dart';
import '../widgets/history_card.dart';

/// Layar detail satu entri riwayat: kartu hasil penuh + aksi hapus.
///
/// Hapus di sini adalah jalur discoverable kedua selain swipe di daftar
/// (swipe tidak punya affordance visual). Alur sama persis: dialog
/// konfirmasi, hapus via [DeleteHistory], snackbar + Urungkan, kembali
/// ke daftar. Stateless diubah menjadi ConsumerStateful agar guard
/// `_deleting` mencegah ketuk ganda saat request berjalan.
class HistoryDetailScreen extends ConsumerStatefulWidget {
  const HistoryDetailScreen({super.key, required this.entry});

  final HistoryEntry entry;

  @override
  ConsumerState<HistoryDetailScreen> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  var _deleting = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.historyDeleteTitle),
        content: const Text(AppStrings.historyDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.historyDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text(AppStrings.historyDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      final userId = ref.read(historyUserIdProvider);
      if (userId == null || !mounted) return;
      await ref.read(historyActionProvider.notifier).delete(
            widget.entry.id,
          );
      if (!mounted) return;
      final action = ref.read(historyActionProvider);
      if (action.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.historyDeleteFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text(AppStrings.historyDeleted),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: AppStrings.historyUndo,
              onPressed: () {
                final restoreId = ref.read(historyUserIdProvider);
                if (restoreId == null) return;
                ref.read(saveHistoryProvider)(
                  userId: restoreId,
                  result: widget.entry.result,
                );
              },
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 56,
        leading: SessionBackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text(AppStrings.historyDetailTitle),
        titleTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.historyDeleteTitle,
            onPressed: _deleting ? null : _confirmDelete,
            icon: _deleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.neutral.withValues(alpha: 0.2)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: QuickCheckResultSection(
              result: widget.entry.result,
              loading: false,
              onNewCheck: () => Navigator.of(context).maybePop(),
              heroTag: HistoryCard.heroTagFor(widget.entry.id),
            ),
          ),
        ),
      ),
    );
  }
}

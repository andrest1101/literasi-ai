import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../quick_check/presentation/widgets/quick_check_result_section.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/history_filter.dart';
import '../providers/history_providers.dart';
import '../widgets/history_card.dart';
import '../widgets/history_empty_state.dart';
import '../widgets/history_filter_bar.dart';
import 'history_detail_screen.dart';

class HistoryListScreen extends ConsumerWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(historyEntriesProvider);
    final filter = ref.watch(historyFilterProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(historyEntriesProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSectionHeader(
                  eyebrow: AppStrings.homeHistoryEyebrow,
                  titleLine1: AppStrings.homeHistoryTitle1,
                  titleLine2: AppStrings.homeHistoryTitle2,
                  subtitle: AppStrings.homeHistorySubtitle,
                ),
                const SizedBox(height: 20),
                HistoryFilterBar(
                  selected: filter,
                  onSelected: (value) =>
                      ref.read(historyFilterProvider.notifier).state = value,
                ),
                const SizedBox(height: 16),
                entries.when(
                  loading: () => const _HistoryLoading(),
                  error: (error, _) => _HistoryError(
                    onRetry: () => ref.invalidate(historyEntriesProvider),
                  ),
                  data: (items) {
                    final visible = items
                        .where((entry) => filter.matches(entry.result.verdict))
                        .toList();
                    if (visible.isEmpty) {
                      return HistoryEmptyState(
                        filtered: filter != HistoryFilter.all,
                      );
                    }
                    return _HistoryList(entries: visible);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.entries});

  final List<HistoryEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (final entry in entries) ...[
          Dismissible(
            key: ValueKey(entry.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) async {
              await ref.read(historyActionProvider.notifier).delete(entry.id);
              final action = ref.read(historyActionProvider);
              if (!context.mounted) return;
              if (action.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.historyDeleteFailed),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(
                SnackBar(
                  content: const Text(AppStrings.historyDeleted),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: AppStrings.historyUndo,
                    onPressed: () {
                      final userId = ref.read(historyUserIdProvider);
                      if (userId == null) return;
                      ref.read(saveHistoryProvider)(
                        userId: userId,
                        result: entry.result,
                      );
                    },
                  ),
                ),
              );
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: AppColors.danger,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            ),
            child: HistoryCard(
              entry: entry,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoryDetailScreen(entry: entry),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 102,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.neutral.withValues(alpha: 0.18)),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return QuickCheckErrorSection(
      error: const UnknownFailure(
        'Riwayat tidak dapat dimuat. Periksa koneksi lalu coba lagi.',
      ),
      canRetry: true,
      onRetry: onRetry,
    );
  }
}

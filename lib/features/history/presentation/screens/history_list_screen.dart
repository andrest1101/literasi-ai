import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../quick_check/domain/entities/verification_result.dart';
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
    final query = ref.watch(historySearchProvider).trim().toLowerCase();
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
                _HistorySearchField(
                  onChanged: (value) =>
                      ref.read(historySearchProvider.notifier).state = value,
                ),
                const SizedBox(height: 12),
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
                        .where(
                          (entry) =>
                              query.isEmpty ||
                              entry.result.claim.toLowerCase().contains(query) ||
                              (entry.result.sourceUrl
                                      ?.toLowerCase()
                                      .contains(query) ??
                                  false),
                        )
                        .toList();
                    if (visible.isEmpty) {
                      return HistoryEmptyState(
                        filtered:
                            filter != HistoryFilter.all || query.isNotEmpty,
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HistoryStats(items: items),
                        const SizedBox(height: 14),
                        _HistoryList(entries: visible),
                      ],
                    );
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

/// Kolom pencarian riwayat — filter lokal di atas stream yang sama.
///
/// Tidak menambah query Firestore: pencarian hanya menyaring klaim + URL
/// yang sudah dimuat, sehingga tetap cepat dan konsisten dengan filter
/// verdict di atasnya.
class _HistorySearchField extends ConsumerStatefulWidget {
  const _HistorySearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  ConsumerState<_HistorySearchField> createState() => _HistorySearchState();
}

class _HistorySearchState extends ConsumerState<_HistorySearchField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101A33),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: AppStrings.historySearchHint,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Bersihkan pencarian',
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

/// Ringkasan verdict — strip 3 angka agar tab Riwayat terasa hidup.
///
/// Dihitung dari seluruh riwayat (bukan hasil filter), sehingga angka
/// tetap jadi konteks walau user menyaring satu verdict.
class _HistoryStats extends StatelessWidget {
  const _HistoryStats({required this.items});

  final List<HistoryEntry> items;

  @override
  Widget build(BuildContext context) {
    var hoaks = 0;
    var valid = 0;
    var perlu = 0;
    for (final entry in items) {
      switch (entry.result.verdict) {
        case Verdict.hoaks:
          hoaks++;
          break;
        case Verdict.valid:
          valid++;
          break;
        case Verdict.perluDicek:
        case Verdict.tidakDapatDipastikan:
          perlu++;
          break;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insights_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          const Text(
            AppStrings.historyStatsTitle,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 14),
          _StatDot(
            color: AppColors.danger,
            label: '$hoaks Hoaks',
          ),
          const SizedBox(width: 12),
          _StatDot(color: AppColors.success, label: '$valid Valid'),
          const SizedBox(width: 12),
          _StatDot(
            color: AppColors.verdictAmber,
            label: '$perlu Perlu dicek',
          ),
        ],
      ),
    );
  }
}

class _StatDot extends StatelessWidget {
  const _StatDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
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

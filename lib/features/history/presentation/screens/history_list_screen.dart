import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../quick_check/domain/entities/verification_result.dart';
import '../../../quick_check/presentation/screens/quick_check_session_screen.dart';
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
        // 120px: ruang pill navbar mengambang + FAB Chat 60px di atasnya.
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HistoryToolbarTitle(),
              const SizedBox(height: AppTabTitles.titleToContentGap),
                _HistorySearchField(
                  onChanged: (value) =>
                      ref.read(historySearchProvider.notifier).state = value,
                ),
                const SizedBox(height: 12),
                entries.maybeWhen(
                  data: (items) => HistoryFilterBar(
                    selected: filter,
                    counts: _filterCounts(items),
                    onSelected: (value) =>
                        ref.read(historyFilterProvider.notifier).state = value,
                  ),
                  orElse: () => HistoryFilterBar(
                    selected: filter,
                    onSelected: (value) =>
                        ref.read(historyFilterProvider.notifier).state = value,
                  ),
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
                        onStartCheck: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const QuickCheckSessionScreen(),
                          ),
                        ),
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

/// Kolom pencarian riwayat: filter lokal di atas stream yang sama.
///
/// Tidak menambah query Firestore: pencarian hanya menyaring klaim + URL
/// yang sudah dimuat, sehingga tetap cepat dan konsisten dengan filter
/// verdict di atasnya.
/// Judul toolbar compact tab Riwayat: satu baris 20px sebagai jangkar
/// toolbar fungsional (search + filter) tepat di bawahnya.
///
/// Menggantikan header editorial penuh (±190px: pill + judul 26px 2 baris
/// + subtitle + hairline). Subtitle lama ("Semua hasil yang tersimpan…")
/// dihapus karena tidak menambah info bagi user yang sudah membuka tab
/// Riwayat. Aksen arsip biru-tua dipertahankan pada kata kedua agar
/// identitas tab tidak hilang.
class _HistoryToolbarTitle extends StatelessWidget {
  const _HistoryToolbarTitle();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: AppStrings.homeHistoryTitle1,
            style: AppTabTitles.compactLine1,
          ),
          TextSpan(
            text: ' ${AppStrings.homeHistoryTitle2}',
            style: AppTabTitles.compactLine2(AppColors.primaryDeep),
          ),
        ],
      ),
    );
  }
}

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

/// Hitung isi tiap filter dari daftar yang sama: tanpa query baru.
///
/// `perluDicek` mencakup verdict kuning + abu (konsisten dengan strip
/// [_HistoryStats]) agar angka pill dan ringkasan selalu selaras.
Map<HistoryFilter, int> _filterCounts(List<HistoryEntry> items) {
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
  return {
    HistoryFilter.all: items.length,
    HistoryFilter.hoaks: hoaks,
    HistoryFilter.valid: valid,
    HistoryFilter.perluDicek: perlu,
  };
}

/// Ringkasan verdict: 3 kolom angka besar agar tab Riwayat terasa hidup.
///
/// Dihitung dari seluruh riwayat (bukan hasil filter), sehingga angka
/// tetap jadi konteks walau user menyaring satu verdict. Selaras dengan
/// angka pill filter ([_filterCounts]).
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
    return Semantics(
      label:
          '${AppStrings.historyStatsTitle}: $hoaks Hoaks, $valid Valid, $perlu Perlu dicek',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.surface,
          border: Border.all(color: AppColors.neutral.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            _StatColumn(
              value: hoaks,
              label: AppStrings.historyFilterHoaks,
              accent: AppColors.danger,
            ),
            _StatsDivider(),
            _StatColumn(
              value: valid,
              label: AppStrings.historyFilterValid,
              accent: AppColors.success,
            ),
            _StatsDivider(),
            _StatColumn(
              value: perlu,
              label: AppStrings.historyFilterNeedCheck,
              accent: AppColors.verdictAmber,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.neutral.withValues(alpha: 0.2),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.accent,
  });

  final int value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 3,
            width: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
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

/// Skeleton bernyawa saat riwayat dimuat: meniru bentuk [HistoryCard].
///
/// Baris badge + klaim + footer berdenyut via [AppShimmer] bersama, bukan
/// kotak putih polos. Bentuk meniru kartu asli agar transisi loading → data
/// tidak melompat jauh (layout shift kecil).
class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      semanticsLabel: AppStrings.historyLoading,
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.18),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerCircle(size: 44),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShimmerBar(width: 64, height: 12),
                            Spacer(),
                            ShimmerBar(width: 40, height: 14),
                          ],
                        ),
                        SizedBox(height: 8),
                        ShimmerBar(height: 14),
                        SizedBox(height: 6),
                        ShimmerBar(width: 180, height: 14),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ShimmerBar(width: 84, height: 11),
                            Spacer(),
                            ShimmerBar(width: 56, height: 11),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

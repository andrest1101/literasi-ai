import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../quick_check/domain/entities/verification_result.dart';
import '../utils/history_time_ago.dart';
import '../../../quick_check/presentation/screens/quick_check_session_screen.dart';
import '../../../quick_check/presentation/widgets/quick_check_result_section.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/history_filter.dart';
import '../providers/history_providers.dart';
import '../widgets/history_card.dart';
import '../widgets/history_empty_state.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/swipe_delete_background.dart';
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
      child: CustomScrollView(
        // Virtualisasi: hanya kartu yang terlihat yang dibangun, sehingga
        // riwayat ratusan entri tetap ringan. Physics selalu-scrollable
        // menjaga pull-to-refresh tetap hidup saat daftar kosong/pendek.
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _TabContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _HistoryToolbarTitle(),
                    const SizedBox(height: 4),
                    _HistorySubContext(entries: entries),
                    const SizedBox(height: AppTabTitles.titleToContentGap),
                    _HistorySearchField(
                      onChanged: (value) =>
                          ref.read(historySearchProvider.notifier).state =
                              value,
                    ),
                    const SizedBox(height: 12),
                    entries.maybeWhen(
                      data: (items) => HistoryFilterBar(
                        selected: filter,
                        counts: _filterCounts(items),
                        onSelected: (value) =>
                            ref.read(historyFilterProvider.notifier).state =
                                value,
                      ),
                      orElse: () => HistoryFilterBar(
                        selected: filter,
                        onSelected: (value) =>
                            ref.read(historyFilterProvider.notifier).state =
                                value,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          ..._contentSlivers(
            ref,
            context,
            entries: entries,
            filter: filter,
            query: query,
          ),
          // 120px: ruang pill navbar mengambang + FAB Chat 60px di atasnya.
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  /// Isi daftar sebagai sliver, supaya header tetap satu blok dan kartu
  /// dibangun malas (lazy) oleh [SliverList].
  List<Widget> _contentSlivers(
    WidgetRef ref,
    BuildContext context, {
    required AsyncValue<List<HistoryEntry>> entries,
    required HistoryFilter filter,
    required String query,
  }) {
    Widget boxed(Widget child) => SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(child: _TabContentWidth(child: child)),
    );

    return entries.when(
      loading: () => [boxed(const _HistoryLoading())],
      error: (error, _) => [
        boxed(
          _HistoryError(onRetry: () => ref.invalidate(historyEntriesProvider)),
        ),
      ],
      data: (items) {
        final visible = items
            .where((entry) => filter.matches(entry.result.verdict))
            .where(
              (entry) =>
                  query.isEmpty ||
                  entry.result.claim.toLowerCase().contains(query) ||
                  (entry.result.sourceUrl?.toLowerCase().contains(query) ??
                      false),
            )
            .toList();
        if (visible.isEmpty) {
          return [
            boxed(
              HistoryEmptyState(
                filtered: filter != HistoryFilter.all || query.isNotEmpty,
                onStartCheck: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QuickCheckSessionScreen(),
                  ),
                ),
              ),
            ),
          ];
        }
        // Badge TERBARU hanya bila daftar utuh (>1, tanpa filter atau
        // search): menandai entri pertama sebagai titik orientasi tanpa
        // menyesatkan saat daftar disaring.
        final markLatest =
            filter == HistoryFilter.all && query.isEmpty && visible.length > 1;
        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _TabContentWidth(
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: _SwipeHint(),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: visible.length,
                (context, index) => _TabContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryDismissible(
                      entry: visible[index],
                      isLatest: markLatest && index == 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      },
    );
  }
}

/// Pembungkus lebar baca: satu-satunya sumber batas 640px di tab ini.
///
/// Dipakai per-item (bukan membungkus seluruh sliver) agar tetap konsisten
/// saat daftar divisualisasikan dan saat layar melebar di tablet/desktop.
class _TabContentWidth extends StatelessWidget {
  const _TabContentWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        // Lebar penuh sampai 640: perilaku yang sama dengan Column
        // `stretch` sebelumnya, kini berlaku juga untuk item SliverList.
        child: SizedBox(width: double.infinity, child: child),
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

/// Sub-konteks data-driven di bawah judul: total pemeriksaan + waktu
/// pemeriksaan terakhir ("4 pemeriksaan · terakhir 2 jam lalu").
///
/// Data dari stream yang sama dengan daftar (tanpa query baru); dihitung
/// dari SELURUH riwayat, bukan hasil filter, agar konsisten dengan kartu
/// statistik. Saat loading/error: tidak tampil (satu baris teks tidak
/// butuh skeleton; daftar sudah punya shimmer sendiri).
class _HistorySubContext extends StatelessWidget {
  const _HistorySubContext({required this.entries});

  final AsyncValue<List<HistoryEntry>> entries;

  @override
  Widget build(BuildContext context) {
    return entries.maybeWhen(
      data: (items) {
        if (items.isEmpty) {
          return const Text(
            AppStrings.historySubEmpty,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          );
        }
        var latest = items.first.result.checkedAt;
        for (final entry in items.skip(1)) {
          final checkedAt = entry.result.checkedAt;
          if (checkedAt.isAfter(latest)) latest = checkedAt;
        }
        final totalLabel = items.length == 1
            ? '1 pemeriksaan'
            : '${items.length} pemeriksaan';
        final ago = historyTimeAgo(latest);
        final latestLabel = ago == 'Baru saja' ? ago : '$ago lalu';
        return Text(
          '$totalLabel · terakhir $latestLabel',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
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
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Focus ring biru-arsip: search terasa hidup hanya saat dipakai,
    // tenang saat idle. Ikon mengikuti status focus yang sama.
    final focused = _focusNode.hasFocus;
    final accent = focused ? AppColors.primaryDeep : AppColors.textSecondary;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surface,
        border: Border.all(
          color: focused
              ? AppColors.primaryDeep.withValues(alpha: 0.55)
              : AppColors.neutral.withValues(alpha: 0.2),
          width: focused ? 1.4 : 1,
        ),
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
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: AppStrings.historySearchHint,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: accent),
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
/// `perluDicek` mencakup verdict kuning + abu. Pill filter adalah
/// satu-satunya representasi angka komposisi verdict di tab ini.
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

/// Petunjuk sekali pandang: kartu riwayat bisa digeser untuk menghapus.
///
/// Tanpa hint ini, swipe adalah fitur tak terlihat: user tidak tahu aksi
/// hapus ada sampai tidak sengaja menggeser. Teks kecil + ikon swipe
/// memberi affordance tanpa menambah tombol di tiap kartu.
class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.swipe_rounded, size: 14, color: AppColors.textSecondary),
        SizedBox(width: 6),
        Text(
          AppStrings.historySwipeHint,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Satu kartu riwayat yang bisa digeser dua arah untuk menghapus.
///
/// Dua arah horizontal: pengguna kidal maupun kanan-dominan sama-sama
/// menemukan hapus, dan keduanya memakai jalur hapus + Urungkan yang sama.
class _HistoryDismissible extends StatelessWidget {
  const _HistoryDismissible({required this.entry, required this.isLatest});

  final HistoryEntry entry;
  final bool isLatest;

  /// Hapus ditunggu SEBELUM kartu dilepas dari daftar.
  ///
  /// Versi lama menjalankan hapus di `onDismissed`: Dismissible sudah
  /// melepas kartunya sementara entri masih ada di stream, sehingga request
  /// yang lambat/gagal memicu assertion "A dismissed Dismissible widget is
  /// still part of the tree" dan menyisakan kartu hantu. Dengan
  /// `confirmDismiss`, `true` hanya dikembalikan setelah hapus benar-benar
  /// sukses; gagal = `false` dan kartu kembali ke posisinya.
  Future<bool> _confirmDelete(BuildContext context) async {
    // Container diambil sebelum await: aksi Urungkan pada SnackBar bisa
    // ditekan setelah widget ini tidak lagi di pohon.
    final container = ProviderScope.containerOf(context, listen: false);
    final deleted = await container
        .read(historyActionProvider.notifier)
        .delete(entry.id);
    if (!context.mounted) return false;

    final messenger = ScaffoldMessenger.of(context);
    if (!deleted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(AppStrings.historyDeleteFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text(AppStrings.historyDeleted),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: AppStrings.historyUndo,
          onPressed: () {
            final userId = container.read(historyUserIdProvider);
            if (userId == null) return;
            container.read(saveHistoryProvider)(
              userId: userId,
              result: entry.result,
            );
          },
        ),
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (_) => _confirmDelete(context),
      background: const SwipeDeleteBackground(side: SwipeDeleteSide.leading),
      secondaryBackground: const SwipeDeleteBackground(
        side: SwipeDeleteSide.trailing,
      ),
      child: HistoryCard(
        entry: entry,
        isLatest: isLatest,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => HistoryDetailScreen(entry: entry)),
        ),
      ),
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

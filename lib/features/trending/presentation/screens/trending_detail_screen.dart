import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/screens/quick_check_session_screen.dart';
import '../../../quick_check/presentation/widgets/quick_check_result_section.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../../../quick_check/presentation/widgets/verdict_presentation.dart';
import '../../domain/entities/trending_item.dart';
import '../providers/trending_providers.dart';
import '../widgets/trending_rail.dart';

/// Detail trending — reuse kartu hasil + share, tanpa duplikasi UI verdict.
///
/// Hierarki aksi tegas: `Verifikasi serupa` adalah CTA primer halaman ini
/// (Filled), sedangkan Bagikan di dalam result section adalah sekunder.
/// Box rujukan memakai border tegas + ikon agar tidak seperti info box
/// generik. Bagian bawah menampilkan konteks terkait satu kategori agar
/// halaman tidak berhenti datar setelah tombol (disembunyikan bila
/// item se-kategori kurang dari 2).
class TrendingDetailScreen extends ConsumerWidget {
  const TrendingDetailScreen({super.key, required this.item});

  final TrendingItem item;

  void _verifySimilar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuickCheckSessionScreen(initialClaim: item.title),
        settings: const RouteSettings(name: QuickCheckSessionScreen.route),
      ),
    );
  }

  void _openRelated(BuildContext context, TrendingItem other) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TrendingDetailScreen(item: other)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = item.toResult();
    final related = ref
        .watch(trendingItemsProvider)
        .where((e) => e.id != item.id && e.category == item.category)
        .take(2)
        .toList();
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
        leading: SessionBackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '${AppStrings.trendingTitle} - ${item.category}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.neutral.withValues(alpha: 0.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primary.withValues(alpha: 0.06),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D101A33),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          size: 17,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.trendingReference,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.reference,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                QuickCheckResultSection(
                  result: result,
                  loading: false,
                  onNewCheck: () => _verifySimilar(context),
                  heroTag: TrendingRail.heroTagFor(item.id),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _verifySimilar(context),
                    icon: const Icon(Icons.fact_check_outlined, size: 20),
                    label: const Text(AppStrings.trendingVerifySimilar),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (related.length >= 2) ...[
                  const SizedBox(height: 22),
                  const Text(
                    AppStrings.trendingRelatedTitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < related.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _RelatedCard(
                      item: related[i],
                      onTap: () =>
                          _openRelated(context, related[i]),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu konteks terkait — ringkas: badge verdict + judul 2 baris.
class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.item, required this.onTap});

  final TrendingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = VerdictPresentation.of(item.verdict);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.neutral.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: style.accent.withValues(alpha: 0.1),
                ),
                child: Icon(style.icon, size: 19, color: style.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

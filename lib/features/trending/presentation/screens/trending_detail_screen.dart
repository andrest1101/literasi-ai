import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/screens/quick_check_session_screen.dart';
import '../../../quick_check/presentation/widgets/quick_check_result_section.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../../domain/entities/trending_item.dart';
import '../widgets/trending_rail.dart';

/// Detail trending — reuse kartu hasil + share, tanpa duplikasi UI verdict.
///
/// Dua aksi kontekstual: verifikasi serupa (buka sesi dengan klaim terisi)
/// dan bagikan (reuse ShareService di dalam result section).
class TrendingDetailScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final result = item.toResult();
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
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 17,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${AppStrings.trendingReference}: ${item.reference}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
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
                  height: 52,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _verifySimilar(context),
                    icon: const Icon(Icons.fact_check_outlined, size: 19),
                    label: const Text(AppStrings.trendingVerifySimilar),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

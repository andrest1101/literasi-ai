import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../domain/entities/course_progress.dart';
import '../providers/learn_providers.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

/// Daftar 3 modul — tab Belajar fungsional pertama.
///
/// Header editorial + ringkasan progres global + 3 kartu heterogen + catatan
/// poin. Guest bisa membaca semua modul; progres sync menunggu login.
class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(learnContentProvider);
    final progress = ref.watch(learnProgressProvider);
    return SingleChildScrollView(
      // 120px: ruang pill navbar mengambang + FAB Chat 60px di atasnya.
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionHeader(
                eyebrow: AppStrings.homeLearnEyebrow,
                titleLine1: AppStrings.homeLearnTitle1,
                titleLine2: AppStrings.homeLearnTitle2,
                subtitle: AppStrings.homeLearnSubtitle,
                accent: SectionAccent.learn,
              ),
              const SizedBox(height: 18),
              progress.when(
                loading: () => const _ProgressSkeleton(),
                error: (_, _) => const SizedBox.shrink(),
                data: (value) => _ProgressSummary(progress: value, total: modules.length),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < modules.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                progress.when(
                  loading: () => CourseCard(
                    module: modules[i],
                    completed: false,
                    bestScore: 0,
                    onTap: () => _openDetail(context, modules[i].id),
                  ),
                  error: (_, _) => CourseCard(
                    module: modules[i],
                    completed: false,
                    bestScore: 0,
                    onTap: () => _openDetail(context, modules[i].id),
                  ),
                  data: (value) => CourseCard(
                    module: modules[i],
                    completed: value.isCompleted(modules[i].id),
                    bestScore: value.bestFor(modules[i].id),
                    onTap: () => _openDetail(context, modules[i].id),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.primary.withValues(alpha: 0.06),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.learnPointsNote,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, String moduleId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(moduleId: moduleId),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.progress, required this.total});

  final CourseProgress progress;
  final int total;

  @override
  Widget build(BuildContext context) {
    final done = progress.completedCount.clamp(0, total);
    final ratio = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.neutral.withValues(alpha: 0.2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101A33),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(
              painter: _MiniRing(progress: ratio),
              child: Center(
                child: Text(
                  '$done/$total',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$done ${AppStrings.learnProgressSuffix}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  AppStrings.learnGuestNote,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRing extends CustomPainter {
  _MiniRing({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final track = Paint()
      ..color = AppColors.neutral.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    final arc = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5 * 3.14159,
      progress.clamp(0.0, 1.0) * 2 * 3.14159,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_MiniRing old) => old.progress != progress;
}

/// Skeleton bernyawa saat progres dimuat — meniru [_ProgressSummary].
///
/// Ring + dua baris teks berdenyut via [AppShimmer] bersama agar transisi
/// loading → data tidak melompat jauh.
class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      semanticsLabel: AppStrings.learnProgressLoading,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.neutral.withValues(alpha: 0.18),
          ),
        ),
        child: const Row(
          children: [
            ShimmerCircle(size: 56),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBar(width: 130, height: 15),
                  SizedBox(height: 8),
                  ShimmerBar(height: 12),
                  SizedBox(height: 5),
                  ShimmerBar(width: 170, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

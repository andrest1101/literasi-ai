import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../score/domain/entities/literacy_score.dart';
import '../../domain/entities/course_module.dart';
import '../../domain/entities/course_progress.dart';
import '../providers/learn_providers.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

/// Library modul: daftar baris terang senada + strip hadiah gelap.
///
/// Satu layar satu bahasa visual: variasi hanya motif thumbnail (bukan
/// warna permukaan). Guest bisa membaca semua modul; progres sync
/// menunggu login.
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
              const _LearnToolbarTitle(),
              const SizedBox(height: AppTabTitles.titleToContentGap),
              progress.when(
                loading: () => const _ProgressSkeleton(),
                error: (_, _) => const SizedBox.shrink(),
                data: (value) =>
                    _ProgressSummary(progress: value, total: modules.length),
              ),
              const SizedBox(height: 16),
              progress.when(
                loading: () => _ModuleSectionHeader(done: 0, total: 0),
                error: (_, _) => _ModuleSectionHeader(done: 0, total: 0),
                data: (value) => _ModuleSectionHeader(
                  done: value.completedCount.clamp(0, modules.length),
                  total: modules.length,
                ),
              ),
              const SizedBox(height: 10),
              progress.when(
                loading: () => _ModuleList(
                  modules: modules,
                  progress: const CourseProgress(),
                  onOpen: _openDetail,
                ),
                error: (_, _) => _ModuleList(
                  modules: modules,
                  progress: const CourseProgress(),
                  onOpen: _openDetail,
                ),
                data: (value) => _ModuleList(
                  modules: modules,
                  progress: value,
                  onOpen: _openDetail,
                ),
              ),
              const SizedBox(height: 14),
              const _RewardStrip(),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, String moduleId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CourseDetailScreen(moduleId: moduleId)),
    );
  }
}

/// Judul toolbar compact tab Belajar: satu baris 20px menempel dengan
/// ringkasan progres tepat di bawahnya sebagai satu blok.
///
/// Aksen hijau-tumbuh dipertahankan pada kata kedua agar identitas tab
/// utuh. Info poin kini milik strip hadiah di akhir daftar.
class _LearnToolbarTitle extends StatelessWidget {
  const _LearnToolbarTitle();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: AppStrings.homeLearnTitle1,
            style: AppTabTitles.compactLine1,
          ),
          TextSpan(
            text: ' ${AppStrings.homeLearnTitle2}',
            style: AppTabTitles.compactLine2(AppColors.successDark),
          ),
        ],
      ),
    );
  }
}

/// Header seksi daftar modul: kalimat orientasi + hitungan selesai.
///
/// Menggantikan tumpukan kartu tanpa jangkar. Hitungan dibaca dari
/// [CourseProgress] yang sama dengan ringkasan (tanpa query baru).
class _ModuleSectionHeader extends StatelessWidget {
  const _ModuleSectionHeader({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.learnMyModules,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$done ${AppStrings.learnModulesOf} $total ${AppStrings.learnModulesDone}',
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Daftar baris library: satu bahasa terang, tanpa kartu berat.
///
/// Status selesai + skor terbaik dibaca dari [CourseProgress] yang sama
/// dengan ringkasan (tanpa query baru). Logika buka detail tidak berubah.
class _ModuleList extends StatelessWidget {
  const _ModuleList({
    required this.modules,
    required this.progress,
    required this.onOpen,
  });

  final List<CourseModule> modules;
  final CourseProgress progress;
  final void Function(BuildContext context, String moduleId) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < modules.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          ModuleRow(
            module: modules[i],
            completed: progress.isCompleted(modules[i].id),
            bestScore: progress.bestFor(modules[i].id),
            onTap: () => onOpen(context, modules[i].id),
          ),
        ],
      ],
    );
  }
}

/// Strip hadiah: info poin disajikan sebagai hadiah, bukan catatan kaki.
///
/// Panel hijau pekat identitas Belajar (bukan info biru generik) dengan dua
/// kolom angka dari [LiteracyScore.modulePoints]/[quizPoints] agar angka
/// selalu sinkron dengan domain. Satu label semantics gabungan.
class _RewardStrip extends StatelessWidget {
  const _RewardStrip();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${AppStrings.learnRewardTitle}: '
          '+${LiteracyScore.modulePoints} poin ${AppStrings.learnRewardModuleLabel}, '
          '+${LiteracyScore.quizPoints} poin ${AppStrings.learnRewardQuizLabel}.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.learnRewardSurface,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F3D22),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.learnRewardTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        AppStrings.learnRewardHint,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.55,
                          color: AppColors.learnRewardInkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RewardCell(
                    value: '+${LiteracyScore.modulePoints}',
                    label: AppStrings.learnRewardModuleLabel,
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                Expanded(
                  child: _RewardCell(
                    value: '+${LiteracyScore.quizPoints}',
                    label: AppStrings.learnRewardQuizLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCell extends StatelessWidget {
  const _RewardCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11.5,
            height: 1.5,
            color: AppColors.learnRewardInkSoft,
          ),
        ),
      ],
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
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
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

/// Skeleton bernyawa saat progres dimuat: meniru [_ProgressSummary].
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
          border: Border.all(color: AppColors.neutral.withValues(alpha: 0.18)),
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

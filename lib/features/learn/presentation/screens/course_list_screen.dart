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

/// Library modul: ringkasan + hadiah + featured + daftar.
///
/// Hierarki tegas: judul toolbar, ringkasan progres ring, strip hadiah
/// (satu-satunya fokal gelap, dipindah ke atas agar impactful), featured
/// row untuk modul pertama yang belum selesai, lalu daftar compact.
/// Guest bisa membaca semua modul; progres sync menunggu login.
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
              _HeroSummary(
                modules: modules,
                progress: progress,
                onOpen: _openDetail,
              ),
              const SizedBox(height: 12),
              const _RewardStrip(),
              const SizedBox(height: 20),
              progress.when(
                loading: () => const _SectionSkeleton(),
                error: (_, _) => _ModuleSections(
                  modules: modules,
                  progress: const CourseProgress(),
                  onOpen: _openDetail,
                ),
                data: (value) => _ModuleSections(
                  modules: modules,
                  progress: value,
                  onOpen: _openDetail,
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

/// Judul seksi 1 baris: "Semua modul · 1/3 selesai".
///
/// Judul + hitungan digabung satu baris agar tidak membuang ruang vertikal.
/// Hitungan dibaca dari [CourseProgress] yang sama dengan ringkasan
/// (tanpa query baru). Saat loading, pemanggil menampilkan [_SectionSkeleton]
/// agar tidak pernah render "0 dari 0" yang menyesatkan.
class _ModuleSectionHeader extends StatelessWidget {
  const _ModuleSectionHeader({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: AppStrings.learnAllModules,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          TextSpan(
            text: ' · $done/$total ${AppStrings.learnSectionDoneSuffix}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Judul seksi featured: "Modul populer" tanpa hitungan.
///
/// Label jujur secara produk (modul yang disarankan dibuka, bukan klaim
/// popularitas dari data): modul pertama yang belum selesai.
class _FeaturedSectionHeader extends StatelessWidget {
  const _FeaturedSectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      AppStrings.learnPopularModules,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// Skeleton seksi modul saat loading: judul + 2 baris + 3 baris kartu.
///
/// Meniru bentuk [_ModuleSections] agar transisi loading ke data tidak
/// melompat, dan tidak pernah menampilkan hitungan "0 dari 0".
class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      semanticsLabel: AppStrings.learnProgressLoading,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBar(width: 110, height: 17),
          SizedBox(height: 6),
          ShimmerBar(width: 150, height: 12),
          SizedBox(height: 12),
          ShimmerBar(height: 150),
          SizedBox(height: 10),
          ShimmerBar(height: 120),
          SizedBox(height: 10),
          ShimmerBar(height: 120),
        ],
      ),
    );
  }
}

/// Seksi modul: featured + daftar compact + strip semua-selesai.
///
/// Featured = modul pertama yang belum selesai (derivable dari progress,
/// tanpa ubah domain): focal point daftar dengan label jujur
/// "Mulai dari sini"/"Lanjutkan belajarmu". Bila semua selesai, featured
/// hilang dan tampil strip "Semua modul selesai". Status + skor dibaca
/// dari [CourseProgress] yang sama dengan ringkasan. Logika buka detail
/// tidak berubah.
class _ModuleSections extends StatelessWidget {
  const _ModuleSections({
    required this.modules,
    required this.progress,
    required this.onOpen,
  });

  final List<CourseModule> modules;
  final CourseProgress progress;
  final void Function(BuildContext context, String moduleId) onOpen;

  @override
  Widget build(BuildContext context) {
    final featuredIndex = modules.indexWhere(
      (m) => !progress.isCompleted(m.id),
    );
    final done = progress.completedCount.clamp(0, modules.length);
    final rest = [
      for (var i = 0; i < modules.length; i++)
        if (i != featuredIndex) modules[i],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (featuredIndex >= 0) ...[
          const _FeaturedSectionHeader(),
          const SizedBox(height: 2),
          Text(
            progress.bestFor(modules[featuredIndex].id) > 0
                ? AppStrings.learnFeaturedContinue
                : AppStrings.learnFeaturedStart,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          ModuleRow(
            module: modules[featuredIndex],
            completed: false,
            bestScore: progress.bestFor(modules[featuredIndex].id),
            onTap: () => onOpen(context, modules[featuredIndex].id),
            featured: true,
          ),
          const SizedBox(height: 20),
        ] else
          const _AllDoneStrip(),
        _ModuleSectionHeader(done: done, total: modules.length),
        const SizedBox(height: 10),
        if (rest.isNotEmpty) ...[
          for (var i = 0; i < rest.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            ModuleRow(
              module: rest[i],
              completed: progress.isCompleted(rest[i].id),
              bestScore: progress.bestFor(rest[i].id),
              onTap: () => onOpen(context, rest[i].id),
            ),
          ],
        ],
      ],
    );
  }
}

/// Strip kompak saat semua modul selesai: penutup jujur daftar.
///
/// Muncul menggantikan featured (bukan menambah permukaan baru): dorong
/// user mengulang kuis untuk pertahankan skor.
class _AllDoneStrip extends StatelessWidget {
  const _AllDoneStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.success.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 22,
            color: AppColors.successDark,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.learnAllDone,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  AppStrings.learnAllDoneHint,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
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

/// Strip hadiah: tint biru primer (satu keluarga tab Cek).
///
/// Deep green ditinggalkan: tabrakan dengan brand biru. Angka hadiah
/// memakai font display 26px dari [LiteracyScore.modulePoints]/[quizPoints]
/// agar sinkron domain. Satu label semantics gabungan. Radius 20 (batas
/// atas aturan repo untuk permukaan baru).
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
          borderRadius: BorderRadius.circular(20),
          color: AppColors.learnRewardTint,
          border: Border.all(color: AppColors.learnRewardRim),
          boxShadow: const [
            BoxShadow(
              color: Color(0x141A73E8),
              blurRadius: 16,
              offset: Offset(0, 6),
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
                    color: AppColors.primary,
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        AppStrings.learnRewardHint,
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
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
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
                  height: 48,
                  color: AppColors.primary.withValues(alpha: 0.15),
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
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: AppColors.primary,
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
            color: AppColors.successDark,
          ),
        ),
      ],
    );
  }
}

/// Ringkasan hero: agregat jujur + bar tebal + CTA utama.
///
/// Subtitle agregat ("3 modul · 9 soal · ±X mnt") dihitung dari data modul
/// yang sama, bukan hardcode. Bar 8px fill primer. CTA "Mulai Modul N"
/// membuka modul first-incomplete (atau modul 1 saat loading); hilang
/// bila semua selesai. Guest note dipertahankan sebagai catatan jujur.
class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.modules,
    required this.progress,
    required this.onOpen,
  });

  final List<CourseModule> modules;
  final AsyncValue<CourseProgress> progress;
  final void Function(BuildContext context, String moduleId) onOpen;

  @override
  Widget build(BuildContext context) {
    final quizTotal = modules.fold<int>(0, (s, m) => s + m.quizCount);
    final minutes = modules.fold<int>(0, (s, m) => s + m.minutes);
    final aggregate =
        '${modules.length} modul · $quizTotal soal · ±$minutes mnt';
    return progress.when(
      loading: () => const _ProgressSkeleton(),
      error: (_, _) => _HeroSummaryBody(
        aggregate: aggregate,
        done: 0,
        total: modules.length,
        ctaIndex: 0,
        onOpen: modules.isEmpty
            ? null
            : () => onOpen(context, modules.first.id),
      ),
      data: (value) {
        final done = value.completedCount.clamp(0, modules.length);
        final next = modules.indexWhere((m) => !value.isCompleted(m.id));
        return _HeroSummaryBody(
          aggregate: aggregate,
          done: done,
          total: modules.length,
          ctaIndex: next,
          onOpen: next < 0 || modules.isEmpty
              ? null
              : () => onOpen(context, modules[next].id),
        );
      },
    );
  }
}

class _HeroSummaryBody extends StatelessWidget {
  const _HeroSummaryBody({
    required this.aggregate,
    required this.done,
    required this.total,
    required this.ctaIndex,
    required this.onOpen,
  });

  final String aggregate;
  final int done;
  final int total;
  final int ctaIndex;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                    Text(
                      aggregate,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.55,
                        color: AppColors.textSecondary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.neutral.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          if (onOpen != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: Text(
                  '${AppStrings.learnHeroCtaPrefix} ${ctaIndex + 1}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            AppStrings.learnGuestNote,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.5,
              color: AppColors.textSecondary,
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

/// Skeleton bernyawa saat progres dimuat: meniru [_HeroSummaryBody].
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

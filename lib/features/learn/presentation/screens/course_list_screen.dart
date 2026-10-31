import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../../../score/domain/entities/literacy_score.dart';
import '../../domain/entities/course_module.dart';
import '../../domain/entities/course_progress.dart';
import '../providers/learn_providers.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

/// Library modul: ringkasan + hadiah + featured + daftar.
///
/// Hierarki tegas: judul toolbar, ringkasan progres ring (ramping, tanpa
/// CTA), kartu achievement hadiah (tint biru, terpisah agar hero tidak
/// jadi kotak status pucat), featured hero gradien (fokal tab, satu
/// bahasa dengan hero Cek), lalu daftar compact. Guest bisa membaca
/// semua modul; progres sync menunggu login.
class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(learnContentProvider);
    final progress = ref.watch(learnProgressProvider);
    final value = progress.valueOrNull;
    void retry() => ref.invalidate(learnProgressProvider);
    return SingleChildScrollView(
      // 160px: zona FAB Chat (navbar ~76 + gap 8 + badan 60 = ~144 dari
      // bawah) + margin, sehingga baris terakhir tidak pernah tertutup
      // FAB saat scroll berakhir. Test fab_clearance mengunci angka ini.
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
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
                onRetry: retry,
              ),
              const SizedBox(height: 10),
              const _RewardStrip(),
              const SizedBox(height: 16),
              if (progress.isLoading && value == null)
                const _SectionSkeleton()
              else if (progress.hasError && value == null)
                // Kartu error sudah tampil di hero; daftar modul tidak
                // dipalsukan menjadi "semua belum dimulai".
                const SizedBox.shrink()
              else
                _ModuleSections(
                  modules: modules,
                  progress: value ?? const CourseProgress(),
                  onOpen: _openDetail,
                ),
              if (ref.watch(historyUserIdProvider) == null) ...[
                const SizedBox(height: 14),
                const _GuestProgressNote(),
              ],
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

class _GuestProgressNote extends StatelessWidget {
  const _GuestProgressNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: const Row(
        children: [
          Icon(Icons.phone_android_rounded, size: 19, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Progres tamu tersimpan di perangkat ini. Masuk untuk sinkronisasi dan mengumpulkan poin.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
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
            style: AppTabTitles.compactLine2(AppColors.primary),
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

/// Skeleton seksi modul saat loading: judul + sublabel + featured + baris.
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
          ShimmerBar(height: 230),
          SizedBox(height: 14),
          ShimmerBar(height: 100),
          SizedBox(height: 10),
          ShimmerBar(height: 100),
        ],
      ),
    );
  }
}

/// Seksi modul: carousel rekomendasi + daftar compact + strip semua-selesai.
///
/// Rekomendasi = hingga tiga modul yang belum selesai, dengan yang paling
/// awal diurutkan mengikuti katalog. Modul yang sudah direkomendasikan tidak
/// diduplikasi di daftar ringkas di bawahnya. Semua modul tetap dapat dibuka.
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
    final pending = modules.where((m) => !progress.isCompleted(m.id)).toList();
    final recommended = pending.take(3).toList();
    final done = progress.completedCount.clamp(0, modules.length);
    final recommendedIds = recommended.map((module) => module.id).toSet();
    final rest = modules
        .where((module) => !recommendedIds.contains(module.id))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (recommended.isNotEmpty) ...[
          const _FeaturedSectionHeader(),
          const SizedBox(height: 2),
          Text(
            recommended.any((module) => progress.bestFor(module.id) > 0)
                ? AppStrings.learnFeaturedContinue
                : AppStrings.learnFeaturedStart,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _RecommendedCarousel(
            modules: recommended,
            progress: progress,
            onOpen: onOpen,
          ),
          const SizedBox(height: 16),
        ] else
          const _AllDoneStrip(),
        _ModuleSectionHeader(done: done, total: modules.length),
        const SizedBox(height: 10),
        if (rest.isNotEmpty) ...[
          for (var i = 0; i < rest.length; i++) ...[
            if (i > 0)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 5),
                color: AppColors.hairline,
              ),
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

class _RecommendedCarousel extends StatelessWidget {
  const _RecommendedCarousel({
    required this.modules,
    required this.progress,
    required this.onOpen,
  });

  final List<CourseModule> modules;
  final CourseProgress progress;
  final void Function(BuildContext context, String moduleId) onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth * 0.84)
            .clamp(280.0, 360.0)
            .toDouble();
        return SizedBox(
          height: 380,
          child: ListView.separated(
            key: const ValueKey('learn-recommendations-carousel'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 20),
            itemCount: modules.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final module = modules[index];
              return SizedBox(
                width: cardWidth,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ModuleRow(
                    module: module,
                    completed: progress.isCompleted(module.id),
                    bestScore: progress.bestFor(module.id),
                    onTap: () => onOpen(context, module.id),
                    featured: true,
                  ),
                ),
              );
            },
          ),
        );
      },
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

/// Ringkasan hero: progres saja dalam kartu putih ramping.
///
/// Subtitle agregat ("3 modul · 9 soal · ±X mnt") dihitung dari data modul
/// yang sama, bukan hardcode. Bar 8px fill primer. Hadiah DIPISAH ke
/// [_RewardCard] di bawahnya: hero kini satu pekerjaan (progres), dan
/// kartu achievement memberi warna yang hilang dari kotak status gabungan.
/// Tanpa CTA (peran aksi milik featured/strip), tanpa guest note
/// (duplikat CTA profil).
class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.modules,
    required this.progress,
    required this.onRetry,
  });

  final List<CourseModule> modules;
  final AsyncValue<CourseProgress> progress;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final quizTotal = modules.fold<int>(0, (s, m) => s + m.quizCount);
    final minutes = modules.fold<int>(0, (s, m) => s + m.minutes);
    final aggregate =
        '${modules.length} modul · $quizTotal soal · ±$minutes mnt';
    // Data terakhir tetap dipakai saat refresh gagal: progres yang sudah
    // diketuk pengguna tidak boleh berubah menjadi 0 hanya karena stream
    // Firestore sedang diam atau putus.
    final value = progress.valueOrNull;
    if (value == null) {
      return progress.isLoading
          ? const _ProgressSkeleton()
          : _ProgressLoadFailed(onRetry: onRetry);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroSummaryBody(
          aggregate: aggregate,
          done: value.completedCount.clamp(0, modules.length),
          total: modules.length,
        ),
        if (progress.hasError) ...[
          const SizedBox(height: 8),
          _ProgressStaleStrip(onRetry: onRetry),
        ],
      ],
    );
  }
}

/// Kartu kegagalan saat belum ada data progres sama sekali.
///
/// Bukan angka 0: menampilkan "0 modul selesai" untuk kegagalan jaringan
/// membuat pengguna mengira progresnya hilang.
class _ProgressLoadFailed extends StatelessWidget {
  const _ProgressLoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neutral.withValues(alpha: 0.14),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              AppStrings.learnProgressError,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              AppStrings.learnProgressRetry,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Strip tipis saat pembaruan progres gagal padahal data terakhir tersedia.
class _ProgressStaleStrip extends StatelessWidget {
  const _ProgressStaleStrip({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.warningDark,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              AppStrings.learnProgressStale,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              AppStrings.learnProgressRetry,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSummaryBody extends StatelessWidget {
  const _HeroSummaryBody({
    required this.aggregate,
    required this.done,
    required this.total,
  });

  final String aggregate;
  final int done;
  final int total;

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
        ],
      ),
    );
  }
}

/// Strip hadiah inline: satu baris info, bukan kartu baru.
///
/// Menggantikan [_RewardCard] lama yang menambah pola kartu persegi ke
/// tab yang sudah penuh (hero + featured + daftar). Bentuk strip:
/// ikon trofi kecil + teks satu baris berisi kedua angka hadiah. Angka
/// tetap dari konstanta [LiteracyScore] (sinkron domain); warna mengikuti
/// makna breakdown Profil: +20 hijau sukses, +5 amber gelap. Tanpa
/// permukaan kartu, tanpa border, tanpa shadow.
class _RewardStrip extends StatelessWidget {
  const _RewardStrip();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${AppStrings.learnRewardTitle}: '
          '+${LiteracyScore.modulePoints} ${AppStrings.learnRewardModuleLabel}, '
          '+${LiteracyScore.quizPoints} ${AppStrings.learnRewardQuizLabel}.',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '+${LiteracyScore.modulePoints} ',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.successDark,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    TextSpan(
                      text: '${AppStrings.learnRewardModuleLabel} · ',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextSpan(
                      text: '+${LiteracyScore.quizPoints} ',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warningDark,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const TextSpan(
                      text: AppStrings.learnRewardQuizLabel,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

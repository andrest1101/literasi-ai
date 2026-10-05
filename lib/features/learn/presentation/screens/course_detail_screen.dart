import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/widgets/session_back_button.dart';
import '../../domain/entities/course_module.dart';
import '../providers/learn_providers.dart';
import '../widgets/module_motif.dart';
import 'quiz_screen.dart';

/// Artikel modul: hero gradien + progres baca + sticky CTA.
///
/// Hero memakai gradien [AppColors.heroBegin]/[AppColors.heroEnd] yang sama
/// dengan kartu modul agar detail terasa satu keluarga dengan daftar.
/// Bilah progres baca di bawah AppBar digerakkan [ScrollController] dan
/// selalu di-dispose. CTA primer `Mulai kuis` menempel di bawah (sticky)
/// dengan hierarki jelas: klaim +20 menjadi aksi sekunder di bawahnya.
/// Logika [_claim]/[_openQuiz] tidak berubah.
class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  bool _claiming = false;
  final _scrollController = ScrollController();
  double _readProgress = 0.0;

  static const _sectionIcons = [
    Icons.visibility_outlined,
    Icons.timer_outlined,
    Icons.psychology_outlined,
    Icons.fitness_center_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final value = max <= 0
        ? 1.0
        : (_scrollController.offset / max).clamp(0.0, 1.0);
    if ((value - _readProgress).abs() > 0.005) {
      setState(() => _readProgress = value);
    }
  }

  Future<void> _claim() async {
    if (_claiming) return;
    setState(() => _claiming = true);
    final ok = await ref
        .read(learnActionProvider.notifier)
        .completeModule(widget.moduleId);
    if (!mounted) return;
    setState(() => _claiming = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? AppStrings.learnMarkedDone : 'Modul sudah diklaim sebelumnya.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizScreen(moduleId: widget.moduleId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = ref
        .watch(learnContentProvider)
        .where((m) => m.id == widget.moduleId)
        .firstOrNull;
    if (module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.learnQuizBack)),
        body: const Center(child: Text('Modul tidak ditemukan.')),
      );
    }
    final progress = ref.watch(learnProgressProvider).valueOrNull;
    final done = progress?.isCompleted(module.id) ?? false;
    final motif = motifForModule(module.accentSeed);
    final percent = (_readProgress * 100).round();
    assert(
      module.sections.length == _sectionIcons.length,
      'Jumlah ikon statis harus sama dengan jumlah seksi modul',
    );
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
        title: const Text(AppStrings.learnDetailTitle),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Semantics(
            label: AppStrings.learnReadingProgress,
            value: '$percent persen',
            child: LinearProgressIndicator(
              value: _readProgress,
              minHeight: 3,
              backgroundColor: AppColors.neutral.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModuleHero(moduleId: module.id, done: done),
                const SizedBox(height: 14),
                _ContentsCard(module: module),
                const SizedBox(height: 18),
                for (var i = 0; i < module.sections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _ArticleSection(
                    number: i + 1,
                    icon: _sectionIcons[i % _sectionIcons.length],
                    heading: module.sections[i].heading,
                    body: module.sections[i].body,
                    featured: i == 0,
                    ink: motif.ink,
                    last: i == module.sections.length - 1,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.neutral.withValues(alpha: 0.2)),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14101A33),
                blurRadius: 18,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _openQuiz,
                  icon: const Icon(Icons.quiz_outlined, size: 20),
                  label: const Text(AppStrings.learnStartQuiz),
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
              const SizedBox(height: 8),
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _claiming ? null : _claim,
                  icon: _claiming
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Icon(Icons.emoji_events_outlined, size: 18),
                  label: const Text(AppStrings.learnMarkDone),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero gradien pembuka modul: motif thumbnail modul versi besar.
///
/// Daftar dan detail satu benda: medallion memakai ikon + tint identitas
/// modul yang sama dengan thumbnail daftar ([motifForModule]), dibesarkan
/// di atas gradien hero biru. Gradien hero dipertahankan (satu keluarga
/// dengan hero Cek). Logika klaim/kuis tidak berubah.
class _ModuleHero extends ConsumerWidget {
  const _ModuleHero({required this.moduleId, required this.done});

  final String moduleId;
  final bool done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = ref
        .watch(learnContentProvider)
        .where((m) => m.id == moduleId)
        .firstOrNull;
    if (module == null) return const SizedBox.shrink();
    final motif = motifForModule(module.accentSeed);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroBegin, AppColors.heroEnd],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331A73E8),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: motif.tint,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CustomPaint(
                    painter: _HeroMotifPattern(),
                    child: Center(
                      child: Icon(motif.icon, size: 27, color: motif.ink),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${module.minutes} mnt baca',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (done) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: AppColors.success,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        AppStrings.learnModuleDone,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            module.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            module.subtitle,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: AppColors.heroInkSoft,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${module.sections.length} bagian • ${module.quizCount} soal',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.85),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pola diagonal samar hero: gema motif thumbnail dalam versi terang.
///
/// Alpha 10% di atas tint medallion agar tekstur terbaca di atas gradien
/// biru. Dekoratif murni (di dalam ExcludeSemantics).
class _HeroMotifPattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var x = -size.height; x < size.width + size.height; x += 14) {
      canvas.drawLine(
        Offset(x, size.height + 3),
        Offset(x + size.height + 6, -3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HeroMotifPattern old) => false;
}

/// Kartu daftar isi modul: peta baca sebelum 4 kartu artikel.
///
/// Fungsi = kolom "The Course includes" pada referensi, isi = data jujur:
/// judul tiap [CourseSection] + nomor motif modul (bukan nomor ghost
/// dekoratif). Satu kartu putih, tanpa CTA (aksi milik sticky bottom bar).
class _ContentsCard extends StatelessWidget {
  const _ContentsCard({required this.module});

  final CourseModule module;

  @override
  Widget build(BuildContext context) {
    final motif = motifForModule(module.accentSeed);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.learnContentsTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < module.sections.length; i++) ...[
            if (i > 0)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 9),
                color: AppColors.hairline,
              ),
            _ContentsRow(
              number: i + 1,
              heading: module.sections[i].heading,
              ink: motif.ink,
            ),
          ],
        ],
      ),
    );
  }
}

/// Satu baris daftar isi: nomor motif + judul seksi.
///
/// Nomor memakai tint motif modul (identitas, bukan warna acak): konsisten
/// dengan thumbnail daftar + medallion hero. Judul 1 baris ellipsis agar
/// tidak mendorong kartu terlalu tinggi di layar kecil.
class _ContentsRow extends StatelessWidget {
  const _ContentsRow({
    required this.number,
    required this.heading,
    required this.ink,
  });

  final int number;
  final String heading;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ink.withValues(alpha: 0.12),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            heading,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Satu seksi artikel: rel nomor ghost + medallion tint motif.
///
/// Ritme 4 kartu dipecah tanpa 4 warna acak: rel kiri (angka ghost +
/// konektor vertikal) menandai alur baca 1-4; medallion ikon memakai tint
/// motif modul (identitas, konsisten dengan kartu isi + hero). Seksi
/// pertama ([featured]) tetap aksen primer sebagai pembuka. Konektor
/// terakhir diputus via [last] dari panjang seksi data (tanpa hardcode
/// angka). Label `Bagian N`, heading, body, CTA tidak berubah
/// (dikunci test).
class _ArticleSection extends StatelessWidget {
  const _ArticleSection({
    required this.number,
    required this.icon,
    required this.heading,
    required this.body,
    required this.ink,
    required this.last,
    this.featured = false,
  });

  final int number;
  final IconData icon;
  final String heading;
  final String body;
  final Color ink;
  final bool last;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionRail(number: number, last: last),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: AppColors.surface,
                border: Border.all(
                  color: featured
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.neutral.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: featured
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0x0D101A33),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: (featured ? AppColors.primary : ink)
                              .withValues(alpha: 0.09),
                        ),
                        child: Icon(
                          icon,
                          size: 19,
                          color: featured ? AppColors.primary : ink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Bagian $number',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: featured ? AppColors.primary : ink,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    heading,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rel nomor ghost di sisi kiri kartu artikel: alur baca 1-4.
///
/// Angka ghost netral (bukan warna status) + konektor vertikal hairline
/// antar kartu. Kartu terakhir tanpa ekor konektor ([last]). Lebar tetap
/// 26px agar tidak menggeser kartu di layar 360px. Dekoratif
/// (nomor nyata tetap di label `Bagian N` dalam kartu).
class _SectionRail extends StatelessWidget {
  const _SectionRail({required this.number, required this.last});

  final int number;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 26,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              '$number',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.neutral.withValues(alpha: 0.55),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (!last)
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: AppColors.neutral.withValues(alpha: 0.25),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

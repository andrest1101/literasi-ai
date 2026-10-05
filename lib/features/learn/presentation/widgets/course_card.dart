import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/course_module.dart';
import 'module_motif.dart';

/// Status CTA derivable dari data yang ada (tanpa ubah domain):
/// selesai / dikerjakan-sebagian / belum-mulai.
enum ModuleCta { done, progress, fresh }

/// Baris library modul: featured biru solid vs compact borderless.
///
/// Dua anatomi radikal berbeda, bukan satu pola berulang: featured adalah
/// satu-satunya kartu biru solid di tab (banner gradien + konten putih di
/// atasnya mustahil tertukar); compact adalah daftar borderless dengan
/// divider hairline (pola daftar, bukan kartu). Satu-satunya tombol besar
/// di tab ini milik featured; compact memakai teks status kecil.
class ModuleRow extends StatelessWidget {
  const ModuleRow({
    super.key,
    required this.module,
    required this.completed,
    required this.bestScore,
    required this.onTap,
    this.featured = false,
  });

  final CourseModule module;
  final bool completed;
  final int bestScore;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final cta = completed
        ? ModuleCta.done
        : bestScore > 0
        ? ModuleCta.progress
        : ModuleCta.fresh;
    if (featured) {
      return _FeaturedCard(
        module: module,
        bestScore: bestScore,
        cta: cta,
        onTap: onTap,
      );
    }
    return _CompactRow(
      module: module,
      completed: completed,
      bestScore: bestScore,
      cta: cta,
      onTap: onTap,
    );
  }
}

/// Kerangka kartu bersama: permukaan + InkWell.
///
/// Radius 20 (batas aturan repo). Compact memakai varian borderless via
/// [borderless]: tanpa border/shadow, divider digambar pemanggil.
class _RowShell extends StatelessWidget {
  const _RowShell({
    required this.label,
    required this.onTap,
    required this.child,
    this.padding,
    this.borderless = false,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: padding ?? const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: borderless
                  ? null
                  : Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
              boxShadow: borderless
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x0D101A33),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Baris compact borderless: thumbnail kiri + teks tengah + status kanan.
///
/// Tanpa border/shadow: variasi dari ketiadaan kartu, bukan kartu lagi.
/// Kolom kanan 56px: circular progress 40px (fill primer, track abu,
/// label "0/3") + teks status kecil di bawahnya. Tanpa tombol besar,
/// tanpa panah generik.
class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.module,
    required this.completed,
    required this.bestScore,
    required this.cta,
    required this.onTap,
  });

  final CourseModule module;
  final bool completed;
  final int bestScore;
  final ModuleCta cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final quizTotal = module.quizCount;
    final quizDone = bestScore.clamp(0, quizTotal);
    return _RowShell(
      label: '${AppStrings.learnOpenModule}: ${module.title}',
      onTap: onTap,
      borderless: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ModuleThumb(module: module, dimmed: completed),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  module.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _MetaRow(module: module, bestScore: bestScore),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QuizRing(done: quizDone, total: quizTotal),
                const SizedBox(height: 6),
                _StatusText(cta: cta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu featured biru solid: banner gradien + konten putih di bawah.
///
/// Satu-satunya kartu biru di tab: banner gradien heroBegin→heroEnd
/// (reuse token hero tab Cek) berisi medallion putih + ikon identitas;
/// judul 20px + meta + bar + CTA FilledButton putih 48px di area putih.
/// Tanpa pattern diagonal (alpha 0). Kontras: judul 20px/w800 dan meta
/// 12px/w700 memenuhi WCAG large-text di atas gradien.
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.module,
    required this.bestScore,
    required this.cta,
    required this.onTap,
  });

  final CourseModule module;
  final int bestScore;
  final ModuleCta cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final motif = motifForModule(module.accentSeed);
    final quizTotal = module.quizCount;
    final quizDone = bestScore.clamp(0, quizTotal);
    final ctaLabel = cta == ModuleCta.progress
        ? AppStrings.learnModuleContinue
        : AppStrings.learnModuleStart;
    return _RowShell(
      label: '${AppStrings.learnOpenModule}: ${module.title}',
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.heroBegin, AppColors.heroEnd],
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x400B2F66),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(motif.icon, size: 32, color: motif.ink),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                _MetaRow(module: module, bestScore: bestScore),
                const SizedBox(height: 10),
                _QuizBar(done: quizDone, total: quizTotal),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Text(ctaLabel, overflow: TextOverflow.ellipsis),
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

/// Teks status kecil di bawah ring: "Mulai"/"Lanjutkan"/"Selesai".
///
/// Visual murni (tap milik InkWell baris). Warna status: primer untuk
/// aksi, hijau hanya untuk selesai.
class _StatusText extends StatelessWidget {
  const _StatusText({required this.cta});

  final ModuleCta cta;

  @override
  Widget build(BuildContext context) {
    final label = switch (cta) {
      ModuleCta.done => AppStrings.learnModuleDone,
      ModuleCta.progress => AppStrings.learnModuleContinue,
      ModuleCta.fresh => AppStrings.learnModuleStart,
    };
    final color = cta == ModuleCta.done
        ? AppColors.successDark
        : AppColors.primary;
    return ExcludeSemantics(
      child: Text(
        label,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// Circular progress 40px: fill primer, track abu, label "0/3".
///
/// Angka nyata dalam ruang kecil. Data `bestScore/quizCount` dari
/// provider yang sama.
class _QuizRing extends StatelessWidget {
  const _QuizRing({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return Semantics(
      label: '${AppStrings.learnQuizProgressLabel}: $done/$total',
      excludeSemantics: true,
      child: SizedBox(
        width: 40,
        height: 40,
        child: CustomPaint(
          painter: _RingPainter(progress: ratio),
          child: Center(
            child: Text(
              '$done/$total',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final track = Paint()
      ..color = AppColors.neutral.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    final arc = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
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
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

/// Bar progres kuis featured: tebal 8px + label kanan tabular.
///
/// Hanya di featured (compact memakai ring): tanpa triple-encoding
/// dalam satu baris.
class _QuizBar extends StatelessWidget {
  const _QuizBar({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return Semantics(
      label: '${AppStrings.learnQuizProgressLabel}: $done/$total',
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
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
          ),
          const SizedBox(width: 8),
          Text(
            '$done/$total',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Meta pills konsisten: durasi + jumlah soal + skor terbaik.
///
/// Label "Selesai" TIDAK di sini: sudah dinyatakan teks status + ring +
/// hitungan seksi. Satu sumber status per baris, tanpa pengulangan.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.module, required this.bestScore});

  final CourseModule module;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _Pill(icon: Icons.timer_outlined, text: '${module.minutes} mnt'),
        _Pill(icon: Icons.quiz_outlined, text: '${module.quizCount} soal'),
        if (bestScore > 0)
          _Pill(
            icon: Icons.star_rounded,
            text: '$bestScore/${module.quizCount}',
            highlight: true,
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, this.highlight = false});

  final IconData icon;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.primary : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.neutral.withValues(alpha: 0.08),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
      ),
      // Flexible + ellipsis: pill tidak pernah overflow di baris sempit
      // (font aksesibilitas besar / font test yang lebar).
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail compact: medallion tint + ikon identitas, tanpa pola.
///
/// Garis diagonal dihapus total: di ukuran 56px ia terbaca sebagai
/// coretan/kesalahan, bukan tekstur. Medallion bersih (tint + border +
/// ikon motif) sudah cukup sebagai identitas; banner featured yang memakai
/// gradien solid juga tanpa pattern. Tanpa aset gambar: offline-safe,
/// tanpa biaya unduh.
class _ModuleThumb extends StatelessWidget {
  const _ModuleThumb({required this.module, required this.dimmed});

  final CourseModule module;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final motif = motifForModule(module.accentSeed);
    return ExcludeSemantics(
      child: Opacity(
        opacity: dimmed ? 0.55 : 1.0,
        child: Container(
          width: 56,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: motif.tint,
            border: Border.all(color: motif.ink.withValues(alpha: 0.3)),
          ),
          child: Center(child: Icon(motif.icon, size: 25, color: motif.ink)),
        ),
      ),
    );
  }
}

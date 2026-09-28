import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/course_module.dart';
import 'module_motif.dart';

/// Satu baris library modul: thumbnail prosedural + teks + panah CTA.
///
/// Bahasa visual tab Belajar kini: SELURUH daftar terang senada, variasi
/// hanya dari motif thumbnail (bukan warna permukaan kartu). Hierarki dari
/// tipografi: judul 16 + subtitle 2 baris + meta pills. Satu-satunya titik
/// fokal gelap di tab ini adalah strip hadiah di akhir daftar, sehingga
/// kontrasnya berfungsi. Affordance eksplisit: tombol panah lingkaran.
///
/// Progres kuis adalah data nyata `bestScore/quizCount` dari provider yang
/// sama (bukan persen dekoratif). Status selesai: centang hijau penuh +
/// thumbnail sedikit redup, bukan kartu berbeda.
class ModuleRow extends StatelessWidget {
  const ModuleRow({
    super.key,
    required this.module,
    required this.completed,
    required this.bestScore,
    required this.onTap,
  });

  final CourseModule module;
  final bool completed;
  final int bestScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final quizTotal = module.quizCount;
    final quizDone = bestScore.clamp(0, quizTotal);
    return Semantics(
      button: true,
      label: '${AppStrings.learnOpenModule}: ${module.title}',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
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
            child: Column(
              children: [
                Row(
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
                              fontSize: 16,
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
                          _MetaRow(
                            module: module,
                            completed: completed,
                            bestScore: bestScore,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _OpenButton(completed: completed),
                  ],
                ),
                const SizedBox(height: 10),
                _QuizProgress(done: quizDone, total: quizTotal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Meta pills konsisten: durasi + jumlah soal + skor terbaik + selesai.
class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.module,
    required this.completed,
    required this.bestScore,
  });

  final CourseModule module;
  final bool completed;
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
        if (completed)
          const _Pill(
            icon: Icons.check_circle_rounded,
            text: AppStrings.learnModuleDone,
            done: true,
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.text,
    this.highlight = false,
    this.done = false,
  });

  final IconData icon;
  final String text;
  final bool highlight;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.success
        : highlight
        ? AppColors.primary
        : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: done
            ? AppColors.success.withValues(alpha: 0.12)
            : highlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.neutral.withValues(alpha: 0.08),
        border: Border.all(
          color: done
              ? AppColors.success.withValues(alpha: 0.35)
              : highlight
              ? AppColors.primary.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail prosedural per modul: tint terang satu keluarga (biru → teal
/// → hijau) + ikon identitas modul + pola diagonal samar via CustomPainter.
///
/// Tanpa aset gambar: offline-safe, tanpa biaya unduh, tanpa placeholder
/// palsu. Motif yang sama dipakai hero detail dalam versi besar sehingga
/// daftar dan detail terasa satu benda.
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
          width: 64,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: motif.tint,
            border: Border.all(color: motif.ink.withValues(alpha: 0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: CustomPaint(
              painter: _ThumbPattern(color: motif.ink),
              child: Center(
                child: Icon(motif.icon, size: 28, color: motif.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pola diagonal samar di atas tint thumbnail: kedalaman tanpa gambar.
///
/// Alpha 8% cukup memberi tekstur tanpa mengganggu ikon; dekoratif murni
/// (di dalam ExcludeSemantics).
class _ThumbPattern extends CustomPainter {
  _ThumbPattern({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var x = -size.height; x < size.width + size.height; x += 18) {
      canvas.drawLine(
        Offset(x, size.height + 4),
        Offset(x + size.height + 8, -4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ThumbPattern old) => old.color != color;
}

/// Tombol panah lingkaran: affordance eksplisit "ketuk untuk masuk".
///
/// Selesai = centang hijau penuh (status), belum = panah aksen primer.
/// Ukuran 40px = target sentuh aman, tercakup tap InkWell baris.
class _OpenButton extends StatelessWidget {
  const _OpenButton({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completed
              ? AppColors.success
              : AppColors.primary.withValues(alpha: 0.1),
          border: completed
              ? null
              : Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Icon(
          completed ? Icons.check_rounded : Icons.arrow_forward_rounded,
          size: 19,
          color: completed ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}

/// Bilah progres kuis jujur: `bestScore/quizCount` dari provider yang sama.
///
/// Tipis 5px, label kanan tabular. Bukan persen dekoratif: angkanya persis
/// skor terbaik yang menentukan poin (+5 per benar baru).
class _QuizProgress extends StatelessWidget {
  const _QuizProgress({required this.done, required this.total});

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
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: AppColors.neutral.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$done/$total',
            style: const TextStyle(
              fontSize: 11,
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

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Penanda asisten AI: buku terbuka + sparkle.
///
/// Sengaja berbeda dari ikon aplikasi (buku + pohon sirkuit). Glyph logo
/// penuh punya cabang sirkuit dan bayangan halus yang menyatu menjadi
/// gumpalan di avatar bubble 30 px, sedangkan buku tunggal tetap terbaca.
/// Hubungan dengan logo dijaga lewat warna dan bentuk buku yang sama.
///
/// Semua ukuran memakai proporsi, bukan angka tetap, supaya penanda tetap
/// konsisten dari bubble chat sampai sapaan kosong.
class AssistantMark extends StatelessWidget {
  const AssistantMark({
    super.key,
    this.size = 32,
    this.shape = AssistantMarkShape.squircle,
    this.showSparkle = true,
    this.showShadow = false,
  });

  final double size;
  final AssistantMarkShape shape;

  /// Sparkle adalah isyarat "AI". Di bawah 40 px ia dibuang agar buku tidak
  /// kehilangan ruang dan berubah menjadi bintik.
  final bool showSparkle;

  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final sparkle = showSparkle && size >= 40;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape == AssistantMarkShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: shape == AssistantMarkShape.circle
            ? null
            : BorderRadius.circular(size * 0.34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroBegin, AppColors.heroEnd],
        ),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x331558B0),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AssistantGlyph(size: size * (sparkle ? 0.55 : 0.7)),
          if (sparkle)
            Positioned(
              right: size * 0.16,
              top: size * 0.15,
              child: AssistantSparkle(size: size * 0.22),
            ),
        ],
      ),
    );
  }
}

enum AssistantMarkShape { squircle, circle }

/// Glyph buku terbuka satu warna: dipakai di dalam [AssistantMark] dan
/// langsung pada tombol chat (FAB) yang sudah punya bidang gradien sendiri.
class AssistantGlyph extends StatelessWidget {
  const AssistantGlyph({
    super.key,
    required this.size,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _BookPainter(color));
  }
}

/// Sparkle empat sudut: isyarat AI yang sama dengan badge pada FAB.
class AssistantSparkle extends StatelessWidget {
  const AssistantSparkle({
    super.key,
    required this.size,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(color),
    );
  }
}

/// Buku terbuka: dua halaman simetris dengan celah punggung buku.
///
/// Digambar pada kanvas 100Ã—100 ternormalisasi. Halaman kiri memakai kurva
/// atas yang naik ke tepi luar dan kurva bawah yang turun ke punggung buku,
/// lalu dicerminkan untuk halaman kanan.
class _BookPainter extends CustomPainter {
  const _BookPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    final page = Path()
      ..moveTo(47.5, 27)
      ..cubicTo(37, 19.5, 21, 16.5, 5, 19.5)
      ..lineTo(5, 68)
      ..cubicTo(21, 64, 37, 68.5, 47.5, 78)
      ..close();
    canvas.drawPath(page, paint);

    canvas.save();
    canvas.translate(100, 0);
    canvas.scale(-1, 1);
    canvas.drawPath(page, paint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BookPainter oldDelegate) => oldDelegate.color != color;
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    final s = size.width / 100.0;
    canvas.save();
    canvas.scale(s, s);
    final path = Path()
      ..moveTo(50, 0)
      ..cubicTo(55, 32, 68, 45, 100, 50)
      ..cubicTo(68, 55, 55, 68, 50, 100)
      ..cubicTo(45, 68, 32, 55, 0, 50)
      ..cubicTo(32, 45, 45, 32, 50, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.color != color;
}

import 'package:flutter/material.dart';

/// Logo "G" Google 4 warna resmi, digambar dengan [CustomPainter].
///
/// Tanpa file aset, tanpa dependensi baru. Warna: biru #4285F4,
/// hijau #34A853, kuning #FBBC05, merah #EA4335.
class GoogleGLogo extends StatelessWidget {
  const GoogleGLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo Google',
      child: CustomPaint(
        size: Size.square(size),
        painter: _GoogleGPainter(),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s * 0.2;
    final center = Offset(s / 2, s / 2);
    final radius = s / 2 - stroke / 2;

    // Kuning: busur kiri bawah.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.6,
      1.9,
      false,
      Paint()
        ..color = _yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
    // Hijau: busur bawah kanan.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.5,
      1.35,
      false,
      Paint()
        ..color = _green
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
    // Merah: busur atas (kiri ke kanan).
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.75,
      2.35,
      false,
      Paint()
        ..color = _red
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
    // Biru: palang horizontal kanan.
    final barPaint = Paint()
      ..color = _blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(center.dx - stroke * 0.15, center.dy),
      Offset(s - stroke * 0.35, center.dy),
      barPaint,
    );
    // Biru: lengkung kanan atas penghubung.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.6,
      1.0,
      false,
      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

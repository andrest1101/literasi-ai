import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Status ekspresi maskot login.
enum MascotMood { idle, typing, cover, peek, happy, sad }

/// Header Auth: maskot perisai bermata yang hidup di atas gradien ber-curve.
///
/// Menggantikan kartu hero yang kaku. Perilaku:
/// * [MascotMood.idle]: napas halus (finite, berhenti sendiri).
/// * [MascotMood.typing]: mata melirik mengikuti panjang teks + alis naik.
/// * [MascotMood.cover]: kedua tangan menutup mata (kolom sandi fokus).
/// * [MascotMood.peek]: satu tangan terangkat sedikit (tampilkan sandi).
/// * [MascotMood.happy]/[MascotMood.sad]: umpan balik hasil masuk.
class LoginMascotHeader extends StatelessWidget {
  const LoginMascotHeader({super.key, required this.mood, this.lookAt = 0});

  final MascotMood mood;
  final double lookAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B7DE9), Color(0xFF1558B0)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Orb dekoratif.
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: -46,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // Bintang kecil.
          const Positioned(
              top: 44, left: 48, child: _Sparkle(size: 10)),
          const Positioned(
              top: 88, right: 64, child: _Sparkle(size: 7)),
          const Positioned(
              top: 60, right: 130, child: _Sparkle(size: 5)),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 44),
            child: Center(
              child: LoginMascot(mood: mood, lookAt: lookAt),
            ),
          ),
          // Curve lembut di bawah agar menyatu dengan form.
          const Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _HeaderCurve(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lengkungan bawah header (transisi gradien ke background form).
class _HeaderCurve extends StatelessWidget {
  const _HeaderCurve();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: CustomPaint(painter: _CurvePainter()),
    );
  }
}

class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.background;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.5,
        -size.height * 0.35,
        size.width,
        size.height * 0.45,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_rounded,
      size: size + 8,
      color: Colors.white.withValues(alpha: 0.55),
    );
  }
}

/// Maskot perisai bermata: badan perisai, dua mata, tangan mungil.
///
/// Semua digambar dengan widget standar (tanpa aset). Tangan menutup mata
/// memakai [AnimatedPositioned] + [AnimatedOpacity] agar transisi mulus.
class LoginMascot extends StatefulWidget {
  const LoginMascot({super.key, required this.mood, this.lookAt = 0});

  final MascotMood mood;
  final double lookAt;

  @override
  State<LoginMascot> createState() => _LoginMascotState();
}

class _LoginMascotState extends State<LoginMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;
  late final Animation<double> _breathValue;

  @override
  void initState() {
    super.initState();
    // Napas halus: maju 2x lalu berhenti (finite, aman untuk test).
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _breathValue = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _breath, curve: Curves.easeInOut),
    );
    _breath.forward().then((_) {
      if (!mounted) return;
      _breath.reverse().then((_) {
        if (mounted) _breath.forward();
      });
    });
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.mood;
    final covering = mood == MascotMood.cover;
    final peeking = mood == MascotMood.peek;
    // Mata melirik mengikuti panjang teks email (dijepit -1..1).
    final look = widget.lookAt.clamp(-1.0, 1.0);
    final mouthHappy = mood == MascotMood.happy;
    final mouthSad = mood == MascotMood.sad;

    return AnimatedBuilder(
      animation: _breathValue,
      builder: (context, child) {
        final breath = math.sin(_breathValue.value * math.pi * 2);
        return Transform.translate(
          offset: Offset(0, breath * 2.5),
          child: child,
        );
      },
      child: SizedBox(
        width: 168,
        height: 168,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bayangan lantai.
            Positioned(
              bottom: 6,
              child: Container(
                width: 110,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.black.withValues(alpha: 0.18),
                ),
              ),
            ),
            // Badan perisai.
            Container(
              width: 132,
              height: 144,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(44),
                  topRight: Radius.circular(44),
                  bottomLeft: Radius.circular(66),
                  bottomRight: Radius.circular(66),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFDCE7FA)],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            // PipI kiri kanan.
            Positioned(
              left: 38,
              top: 88,
              child: Container(
                width: 20,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.primary.withValues(alpha: 0.16),
                ),
              ),
            ),
            Positioned(
              right: 38,
              top: 88,
              child: Container(
                width: 20,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.primary.withValues(alpha: 0.16),
                ),
              ),
            ),
            // Mata (tertutup saat cover).
            if (!covering)
              Positioned(
                top: 62,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Eye(
                      lookX: look * 5,
                      happy: mouthHappy,
                      sleepy: mouthSad,
                    ),
                    const SizedBox(width: 18),
                    _Eye(
                      lookX: look * 5,
                      happy: mouthHappy,
                      sleepy: mouthSad,
                    ),
                  ],
                ),
              ),
            // Alis (naik saat mengetik).
            Positioned(
              top: mood == MascotMood.typing ? 46 : 50,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Brow(flipped: false),
                  SizedBox(width: 26),
                  _Brow(flipped: true),
                ],
              ),
            ),
            // Mulut.
            Positioned(
              top: 102,
              child: _Mouth(happy: mouthHappy, sad: mouthSad),
            ),
            // Badge centang di dada.
            Positioned(
              bottom: 30,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mouthSad
                      ? AppColors.neutral
                      : AppColors.success,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  mouthSad ? Icons.remove_rounded : Icons.check_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ),
            // Tangan kiri (menutup / mengintip).
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              left: covering
                  ? 52
                  : peeking
                      ? 62
                      : 30,
              top: covering
                  ? 56
                  : peeking
                      ? 50
                      : 112,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: (covering || peeking) ? 1 : 0.55,
                child: _Hand(
                  size: covering ? 34 : 26,
                  peekGap: peeking,
                ),
              ),
            ),
            // Tangan kanan (menutup penuh).
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              right: covering ? 52 : 30,
              top: covering ? 56 : 112,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: covering ? 1 : 0.55,
                child: _Hand(size: covering ? 34 : 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({this.lookX = 0, this.happy = false, this.sleepy = false});

  final double lookX;
  final bool happy;
  final bool sleepy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: happy || sleepy ? 12 : 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: AppColors.textPrimary,
      ),
      child: (!happy && !sleepy)
          ? Align(
              alignment: Alignment(lookX / 5, 0),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}

class _Brow extends StatelessWidget {
  const _Brow({required this.flipped});

  final bool flipped;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: flipped,
      child: Container(
        width: 20,
        height: 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: AppColors.textPrimary.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _Mouth extends StatelessWidget {
  const _Mouth({this.happy = false, this.sad = false});

  final bool happy;
  final bool sad;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 14),
      painter: _MouthPainter(happy: happy, sad: sad),
    );
  }
}

class _MouthPainter extends CustomPainter {
  _MouthPainter({this.happy = false, this.sad = false});

  final bool happy;
  final bool sad;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path();
    if (happy) {
      path.moveTo(2, 3);
      path.quadraticBezierTo(size.width / 2, size.height + 2, size.width - 2, 3);
    } else if (sad) {
      path.moveTo(2, size.height - 3);
      path.quadraticBezierTo(size.width / 2, -2, size.width - 2, size.height - 3);
    } else {
      path.moveTo(size.width * 0.3, size.height / 2);
      path.lineTo(size.width * 0.7, size.height / 2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MouthPainter oldDelegate) =>
      oldDelegate.happy != happy || oldDelegate.sad != sad;
}

/// Tangan mungil maskot. [peekGap]: celah intip saat mode peek.
class _Hand extends StatelessWidget {
  const _Hand({required this.size, this.peekGap = false});

  final double size;
  final bool peekGap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9DB9E8), Color(0xFF6E93D6)],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: peekGap
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textPrimary,
                ),
              ),
            )
          : null,
    );
  }
}

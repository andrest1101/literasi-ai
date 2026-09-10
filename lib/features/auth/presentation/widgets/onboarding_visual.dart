import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Ilustrasi tiap slide onboarding — murni Flutter (tanpa aset gambar).
///
/// Interaktif (press-glow): saat visual ditekan ia mengecil 0.96x dan
/// glow + border aksen menyala; saat dilepas kembali normal (~180ms).
/// Responsif: stage 320x300 diskalakan turun proporsional di layar sempit
/// via [LayoutBuilder] + [FittedBox], sehingga tidak pernah overflow.
class OnboardingVisual extends StatefulWidget {
  const OnboardingVisual({super.key, required this.index});

  final int index;

  @override
  State<OnboardingVisual> createState() => _OnboardingVisualState();
}

class _OnboardingVisualState extends State<OnboardingVisual> {
  bool _pressed = false;

  static const _pressScale = 0.96;
  static const _pressMs = 180;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final Widget visual = switch (widget.index) {
      0 => const _TextVerifyVisual(),
      1 => const _MediaVisual(),
      _ => const _HistoryVisual(),
    };
    final label = switch (widget.index) {
      0 => 'Ilustrasi verifikasi teks, ketuk untuk pratinjau efek',
      1 => 'Ilustrasi analisis gambar dan tautan, ketuk untuk pratinjau efek',
      _ => 'Ilustrasi riwayat verifikasi, ketuk untuk pratinjau efek',
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        // Stage referensi 320x300; skala turun bila ruang lebih sempit.
        final scale = (constraints.maxWidth / 320).clamp(0.72, 1.0);
        return Semantics(
          button: true,
          enabled: true,
          label: label,
          child: Tooltip(
            message: 'Ketuk untuk melihat efek',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - t)),
                    child: child,
                  ),
                ),
                child: AnimatedScale(
                  scale: _pressed ? _pressScale : 1.0,
                  duration: const Duration(milliseconds: _pressMs),
                  curve: Curves.easeOut,
                  child: SizedBox(
                    width: 320 * scale,
                    height: 300 * scale,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 320,
                        height: 300,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: _pressMs),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(
                              color: _pressed
                                  ? AppColors.primary.withValues(alpha: 0.55)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: _pressed ? 0.34 : 0.12,
                                ),
                                blurRadius: _pressed ? 48 : 32,
                                spreadRadius: _pressed ? 2 : 0,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: visual,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Fondasi visual
// ---------------------------------------------------------------------------

/// Panggung gradien terang + dekorasi lingkaran tembus pandang + grid halus.
class _Stage extends StatelessWidget {
  const _Stage({required this.children, this.accent = AppColors.primary});

  final List<Widget> children;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFEAF1FC)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Grid titik halus.
          const Positioned.fill(child: _DotGrid()),
          // Orb dekoratif.
          Positioned(
            top: -52,
            right: -52,
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.16),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.12),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Grid titik-titik halus ala bento premium.
class _DotGrid extends StatelessWidget {
  const _DotGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter());
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07);
    const gap = 22.0;
    for (var y = gap; y < size.height; y += gap) {
      for (var x = gap; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Baris skeleton teks tiruan.
class _Bar extends StatelessWidget {
  const _Bar(this.width, {this.height = 8});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: AppColors.neutral.withValues(alpha: 0.28),
      ),
    );
  }
}

/// Chip pill floating (putih / gelap) dengan ikon berbingkai.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    this.dark = false,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final bool dark;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final accent = iconColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 12, top: 6, bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: dark ? AppColors.textPrimary : Colors.white,
        border: dark
            ? null
            : Border.all(color: AppColors.neutral.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.24 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dark)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 7),
              ],
            )
          else
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.14),
              ),
              child: Icon(icon, size: 13, color: accent),
            ),
          const SizedBox(width: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu putih standar dengan shadow lembut + border rambut.
class _FloatCard extends StatelessWidget {
  const _FloatCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border:
            Border.all(color: AppColors.neutral.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Avatar lingkaran dengan inisial (tanpa aset foto).
class _Avatar extends StatelessWidget {
  const _Avatar(this.initials, this.tint);

  final String initials;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: 0.85), tint],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide 1 — verifikasi teks instan (multi-sumber: chat, medsos, portal berita)
// ---------------------------------------------------------------------------

class _TextVerifyVisual extends StatelessWidget {
  const _TextVerifyVisual();

  @override
  Widget build(BuildContext context) {
    return _Stage(
      accent: AppColors.danger,
      children: [
        // Tumpukan 2 kartu sumber di belakang: chat + medsos.
        Positioned(
          left: 14,
          top: 26,
          child: Transform.rotate(
            angle: -0.1,
            child: const SizedBox(
              width: 232,
              child: _FloatCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Avatar('WA', AppColors.success),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Grup Keluarga',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '09.41',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _Bar(190),
                    SizedBox(height: 6),
                    _Bar(150),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 76,
          top: 14,
          child: Transform.rotate(
            angle: 0.09,
            child: const SizedBox(
              width: 228,
              child: _FloatCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Avatar('X', AppColors.textPrimary),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            '@info_viral • medsos',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.neutral,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _Bar(186),
                    SizedBox(height: 6),
                    _Bar(168),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Kartu verdict di lapisan depan.
        Positioned(
          left: 28,
          right: 28,
          top: 108,
          child: _FloatCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.danger.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 17,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Verifikasi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'baru saja • Teks',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(999)),
                        gradient: LinearGradient(
                          colors: [Color(0xFFF05545), AppColors.danger],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x55EA4335),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'HOAKS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '87%',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.neutral.withValues(alpha: 0.2),
                  ),
                  child: const FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.87,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        gradient: LinearGradient(
                          colors: [Color(0xFFF05545), AppColors.danger],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    _SourceDot(
                        icon: Icons.chat_bubble_outline, label: 'Chat'),
                    SizedBox(width: 8),
                    _SourceDot(
                        icon: Icons.public_outlined, label: 'Medsos'),
                    SizedBox(width: 8),
                    _SourceDot(
                        icon: Icons.newspaper_outlined, label: 'Berita'),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Pill status AI melayang kanan atas.
        Positioned(
          top: 46,
          right: 16,
          child: Transform.rotate(
            angle: 0.05,
            child: const _Chip(
              icon: Icons.smart_toy_outlined,
              label: 'AI Menganalisis',
              dark: true,
            ),
          ),
        ),
        // Chip kecepatan kiri bawah.
        const Positioned(
          left: 18,
          bottom: 18,
          child: _Chip(
            icon: Icons.bolt_outlined,
            label: '±3 detik',
            iconColor: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

/// Titik sumber teks (chat / medsos / berita) — bukti multi-sumber.
class _SourceDot extends StatelessWidget {
  const _SourceDot({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.primary.withValues(alpha: 0.07),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide 2 — analisis gambar & URL
// ---------------------------------------------------------------------------

class _MediaVisual extends StatelessWidget {
  const _MediaVisual();

  @override
  Widget build(BuildContext context) {
    return _Stage(
      children: [
        // Cincin orbit dekoratif + titik satelit.
        Center(
          child: SizedBox(
            width: 264,
            height: 264,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 264,
                  height: 264,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          AppColors.primary.withValues(alpha: 0.14),
                      width: 1.5,
                    ),
                  ),
                ),
                Container(
                  width: 186,
                  height: 186,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          AppColors.primary.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                ),
                const Positioned(
                  top: 18,
                  right: 52,
                  child: _OrbitDot(size: 10, color: AppColors.warning),
                ),
                const Positioned(
                  bottom: 34,
                  left: 40,
                  child: _OrbitDot(size: 8, color: AppColors.success),
                ),
              ],
            ),
          ),
        ),
        // Kartu tengah: thumbnail gambar + baris URL.
        Positioned(
          left: 52,
          right: 52,
          top: 50,
          child: _FloatCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 102,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.18),
                        AppColors.primary.withValues(alpha: 0.07),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 34,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'foto_berita.png',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '2,1 MB • teks terbaca',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bingkai pindai (scan frame) dekoratif.
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                  color: AppColors.primary, width: 2),
                              top: BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                  color: AppColors.primary, width: 2),
                              bottom: BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            AppColors.primary.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.link,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'turnbackhoax.id',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Link artikel • 128 kata',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Chip format melayang.
        Positioned(
          left: 10,
          top: 96,
          child: Transform.rotate(
            angle: -0.07,
            child: const _Chip(icon: Icons.image_outlined, label: 'Gambar'),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 58,
          child: Transform.rotate(
            angle: 0.07,
            child: const _Chip(icon: Icons.link, label: 'URL'),
          ),
        ),
        // Gelembung centang kanan atas.
        Positioned(
          right: 36,
          top: 30,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4DB96A), AppColors.success],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D34A853),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child:
                const Icon(Icons.check, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _OrbitDot extends StatelessWidget {
  const _OrbitDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide 3 — riwayat terpercaya
// ---------------------------------------------------------------------------

class _HistoryVisual extends StatelessWidget {
  const _HistoryVisual();

  @override
  Widget build(BuildContext context) {
    return _Stage(
      accent: AppColors.success,
      children: [
        Positioned(
          left: 30,
          right: 30,
          top: 26,
          child: _FloatCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Riwayat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color:
                            AppColors.primary.withValues(alpha: 0.12),
                      ),
                      child: const Text(
                        '12 tersimpan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const _HistoryRow(
                  dot: AppColors.danger,
                  label: 'HOAKS',
                  score: '87%',
                ),
                const SizedBox(height: 8),
                const _HistoryRow(
                  dot: AppColors.success,
                  label: 'VALID',
                  score: '92%',
                ),
                const SizedBox(height: 8),
                const _HistoryRow(
                  dot: AppColors.warning,
                  label: 'PERLU DICEK',
                  score: '64%',
                ),
                const SizedBox(height: 12),
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4B8DF6), AppColors.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share_outlined,
                          size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Bagikan ke WhatsApp',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
        // Pill tersimpan melayang.
        Positioned(
          top: 10,
          right: 20,
          child: Transform.rotate(
            angle: 0.05,
            child: const _Chip(
              icon: Icons.lock_outline,
              label: 'Tersimpan',
              dark: true,
            ),
          ),
        ),
        // Gelembung bagikan kiri bawah + avatar penumpuk.
        Positioned(
          left: 18,
          bottom: 22,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4DB96A), AppColors.success],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D34A853),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.share_outlined,
                size: 20, color: Colors.white),
          ),
        ),
        const Positioned(
          right: 24,
          bottom: 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Avatar('B', AppColors.primary),
              _StackedAvatar('S', AppColors.warning),
              _StackedAvatar('A', AppColors.success),
            ],
          ),
        ),
      ],
    );
  }
}

/// Avatar yang menumpuk ke kiri (efek sosial).
class _StackedAvatar extends StatelessWidget {
  const _StackedAvatar(this.initials, this.tint);

  final String initials;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _Avatar(initials, tint),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.dot,
    required this.label,
    required this.score,
  });

  final Color dot;
  final String label;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dot,
            boxShadow: [
              BoxShadow(
                color: dot.withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const _Bar(120, height: 6),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

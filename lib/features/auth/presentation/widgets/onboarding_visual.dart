import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Ilustrasi tiap slide onboarding — murni Flutter (tanpa aset gambar).
///
/// Setiap visual adalah komposisi kartu floating + chip pill + badge
/// di atas panggung gradien lembut, mengikuti bahasa referensi:
/// elemen berlapis, sudut membulat besar, shadow halus.
class OnboardingVisual extends StatelessWidget {
  const OnboardingVisual({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final Widget visual = switch (index) {
      0 => const _TextVerifyVisual(),
      1 => const _MediaVisual(),
      _ => const _HistoryVisual(),
    };
    // Entrance satu-shot (finite) — aman untuk widget test.
    return TweenAnimationBuilder<double>(
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
      child: SizedBox(width: 320, height: 300, child: visual),
    );
  }
}

// ---------------------------------------------------------------------------
// Fondasi visual
// ---------------------------------------------------------------------------

/// Panggung gradien terang + dekorasi lingkaran tembus pandang.
class _Stage extends StatelessWidget {
  const _Stage({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFEAF1FC)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -48,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -56,
            left: -36,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
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

/// Chip pill floating (putih / gelap).
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: dark ? AppColors.textPrimary : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.22 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dark)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            )
          else
            Icon(icon, size: 14, color: iconColor ?? AppColors.primary),
          const SizedBox(width: 6),
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

/// Kartu putih standar dengan shadow lembut.
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

// ---------------------------------------------------------------------------
// Slide 1 — verifikasi teks instan
// ---------------------------------------------------------------------------

class _TextVerifyVisual extends StatelessWidget {
  const _TextVerifyVisual();

  @override
  Widget build(BuildContext context) {
    return _Stage(
      children: [
        // Kartu chat "diteruskan" di lapisan belakang, sedikit miring.
        Positioned(
          left: 16,
          top: 36,
          child: Transform.rotate(
            angle: -0.1,
            child: const SizedBox(
              width: 240,
              child: _FloatCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesan diteruskan',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 8),
                    _Bar(200),
                    SizedBox(height: 6),
                    _Bar(160),
                    SizedBox(height: 6),
                    _Bar(180),
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
          top: 102,
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.danger,
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
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const _Bar(double.infinity),
                const SizedBox(height: 6),
                const _Bar(160),
              ],
            ),
          ),
        ),
        // Pill status AI melayang kanan atas.
        Positioned(
          top: 32,
          right: 18,
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
          bottom: 20,
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

// ---------------------------------------------------------------------------
// Slide 2 — analisis gambar & URL
// ---------------------------------------------------------------------------

class _MediaVisual extends StatelessWidget {
  const _MediaVisual();

  @override
  Widget build(BuildContext context) {
    return _Stage(
      children: [
        // Cincin orbit dekoratif.
        Center(
          child: Container(
            width: 252,
            height: 252,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.14),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                width: 178,
                height: 178,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Kartu tengah: thumbnail gambar + baris URL.
        Positioned(
          left: 52,
          right: 52,
          top: 52,
          child: _FloatCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.16),
                        AppColors.primary.withValues(alpha: 0.07),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'screenshot_wa.png',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '2,1 MB • terbaca jelas',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
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
                        color: AppColors.primary.withValues(alpha: 0.12),
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
          left: 12,
          top: 92,
          child: Transform.rotate(
            angle: -0.07,
            child: const _Chip(icon: Icons.image_outlined, label: 'Gambar'),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 62,
          child: Transform.rotate(
            angle: 0.07,
            child: const _Chip(icon: Icons.link, label: 'URL'),
          ),
        ),
        // Gelembung centang kanan atas.
        Positioned(
          right: 38,
          top: 34,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success,
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D34A853),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.check, size: 18, color: Colors.white),
          ),
        ),
      ],
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
      children: [
        Positioned(
          left: 30,
          right: 30,
          top: 28,
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
                        color: AppColors.primary.withValues(alpha: 0.12),
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
                    color: AppColors.primary,
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
          top: 12,
          right: 22,
          child: Transform.rotate(
            angle: 0.05,
            child: const _Chip(
              icon: Icons.lock_outline,
              label: 'Tersimpan',
              dark: true,
            ),
          ),
        ),
        // Gelembung bagikan kiri bawah.
        Positioned(
          left: 20,
          bottom: 26,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success,
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D34A853),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child:
                const Icon(Icons.share_outlined, size: 20, color: Colors.white),
          ),
        ),
      ],
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
          decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
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

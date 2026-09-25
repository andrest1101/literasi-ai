import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Kilau loading bersama: denyut alpha halus mengikuti pola shimmer
/// bernyawa di tab Profil.
///
/// Dipakai skeleton Riwayat dan Belajar agar loading terasa hidup, bukan
/// kotak putih polos. Tanpa dependensi baru: hanya [AnimationController]
/// + [AnimatedBuilder] bawaan Flutter. Selalu beri [semanticsLabel] agar
/// pembaca layar tahu konten sedang dimuat.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.semanticsLabel,
    required this.child,
  });

  final String semanticsLabel;
  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return _ShimmerScope(
            intensity: _controller.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Meneruskan intensitas denyut ke [ShimmerBar]/[ShimmerCircle] di bawahnya.
class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.intensity, required super.child});

  final double intensity;

  static double of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ShimmerScope>();
    return scope?.intensity ?? 0.5;
  }

  @override
  bool updateShouldNotify(_ShimmerScope old) =>
      old.intensity != intensity;
}

/// Batang placeholder (menggantikan baris teks/kartu saat loading).
class ShimmerBar extends StatelessWidget {
  const ShimmerBar({
    super.key,
    this.width,
    this.height = 13,
    this.radius = 7,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final intensity = _ShimmerScope.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: AppColors.neutral.withValues(alpha: 0.1 + 0.07 * intensity),
      ),
    );
  }
}

/// Lingkaran placeholder (menggantikan badge/avatar/ring saat loading).
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final intensity = _ShimmerScope.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.neutral.withValues(alpha: 0.12 + 0.08 * intensity),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Logo "G" Google resmi dari aset (`assets/image/logo_google.png`).
///
/// Bila aset gagal dimuat (mis. lupa `flutter pub get`), tampilkan
/// fallback lingkaran "G" agar tombol tidak pernah kosong.
class GoogleGLogo extends StatelessWidget {
  const GoogleGLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo Google',
      child: Image.asset(
        'assets/image/logo_google.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, _, __) => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
          ),
          child: Center(
            child: Text(
              'G',
              style: TextStyle(
                fontSize: size * 0.65,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

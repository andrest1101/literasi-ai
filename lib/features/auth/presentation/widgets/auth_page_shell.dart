import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'auth_form_parts.dart';

/// Cangkang halaman auth dengan hero medallion verifikasi.
///
/// Hero sengaja tidak memakai ilustrasi besar: onboarding sudah menjelaskan
/// value app. Di halaman auth, prioritasnya kredibilitas, proporsi yang lega,
/// dan form yang cepat terlihat. Medallion dibuat overlap dengan kartu agar
/// transisi hero ke form terasa menyatu tanpa boundary curve yang rapuh.
class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (leading != null)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
                child: Align(alignment: Alignment.centerLeft, child: leading!),
              ),
            ),
          Expanded(
            child: SafeArea(
              top: leading == null,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  leading == null ? 20 : 8,
                  20,
                  24,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AuthHeroCopy(title: title, subtitle: subtitle),
                        const SizedBox(height: 4),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 68),
                              child: child,
                            ),
                            const Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(child: AuthTrustMedallion()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeroCopy extends StatelessWidget {
  const _AuthHeroCopy({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              height: 1.18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

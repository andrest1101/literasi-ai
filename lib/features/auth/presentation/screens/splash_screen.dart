import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../app/home_screen.dart';
import '../providers/auth_controller.dart';
import '../providers/onboarding_provider.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';
import 'verify_email_screen.dart';

/// Splash: tampil singkat lalu routing sesuai flag onboarding.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const route = '/';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeAfterSplash();
  }

  Future<void> _routeAfterSplash() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    bool completed = false;
    try {
      final repository = await ref.read(onboardingRepositoryProvider.future);
      completed = await repository.isCompleted();
    } catch (_) {
      completed = false;
    }
    if (!mounted) return;
    final user = await ref.read(authControllerProvider.future);
    if (!mounted) return;
    final String route;
    if (user == null) {
      route = completed ? AuthScreen.route : OnboardingScreen.route;
    } else if (user.needsEmailVerification) {
      route = VerifyEmailScreen.route;
    } else {
      route = HomeScreen.route;
    }
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            // Jaga napas kiri-kanan: tanpa ini tagline 14sp hampir menyentuh
            // tepi layar 360dp (lebar teksnya ~342dp).
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mark yang sama dengan launch screen native (iOS LaunchImage +
                // Android launch_mark): glyph putih dari master putih, di atas
                // bidang brand, jadi logo selalu terpisah jelas dari background.
                // Aset ini sudah rapat ke glyph, jadi lebar 100dp = glyph 98dp
                // dan tidak ada margin transparan yang mendorong judul menjauh.
                Image(
                  image: const AssetImage('assets/branding/app_mark.png'),
                  width: 100,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.appName,
                  style: AppStyles.heading.copyWith(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    AppStrings.tagline,
                    textAlign: TextAlign.center,
                    // Putih penuh: white70 hanya 2.9:1 di atas brand blue
                    // (WCAG AA butuh 4.5:1 untuk teks kecil).
                    style: AppTabTitles.displaySubtitle.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

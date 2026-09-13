import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../providers/onboarding_provider.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';

/// Splash — tampil singkat lalu routing sesuai flag onboarding.
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
    Navigator.of(context).pushReplacementNamed(
      completed ? AuthScreen.route : OnboardingScreen.route,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fact_check, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

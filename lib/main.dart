import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/home_screen.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_styles.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

/// Entry point LiterasiAI.
///
/// Firebase diinisialisasi best-effort: jika `firebase_options.dart` /
/// `google-services.json` belum ada (project Firebase user masih setup),
/// app tetap jalan dalam mode offline.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    debugPrint(AppStrings.geminiApiKeyMissing);
  }
  runApp(const ProviderScope(child: LiterasiAIApp()));
}

class LiterasiAIApp extends StatelessWidget {
  const LiterasiAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppStyles.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.route,
      routes: {
        SplashScreen.route: (_) => const SplashScreen(),
        OnboardingScreen.route: (_) => const OnboardingScreen(),
        AuthScreen.route: (_) => const AuthScreen(),
        HomeScreen.route: (_) => const HomeScreen(),
      },
    );
  }
}

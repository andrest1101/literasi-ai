import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/home_screen.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_styles.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/quick_check/presentation/screens/quick_check_screen.dart';
import 'features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'firebase_options.dart';

/// Entry point LiterasiAI.
///
/// Firebase diinisialisasi dengan [DefaultFirebaseOptions] hasil
/// `flutterfire configure` (project literasi-ai-f67aa). Jika init gagal
/// (mis. google-services belum lengkap), app tetap jalan mode offline.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    debugPrint('Firebase init gagal, lanjut mode offline.');
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
        RegisterScreen.route: (_) => const RegisterScreen(),
        ForgotPasswordScreen.route: (_) => const ForgotPasswordScreen(),
        QuickCheckScreen.route: (_) => const QuickCheckScreen(),
        QuickCheckSessionScreen.route: (_) => const QuickCheckSessionScreen(),
        ChatScreen.route: (_) => const ChatScreen(),
        HomeScreen.route: (_) => const HomeScreen(),
      },
    );
  }
}

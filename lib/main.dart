import 'dart:async';
import 'dart:io' as io;
import 'dart:ui' show FramePhase;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
import 'features/score/presentation/screens/api_key_screen.dart';
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
  _startFrameProbe();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    debugPrint('Firebase init gagal, lanjut mode offline.');
  }
  runApp(const ProviderScope(child: LiterasiAIApp()));
}

/// Probe diagnostik performa — HANYA aktif saat env `FRAME_PROBE` diset
/// dan mode debug. Menulis timing tiap frame (build/raster/total/vsync)
/// ke file untuk analisis jank. Tidak mempengaruhi run normal.
void _startFrameProbe() {
  if (!kDebugMode) return;
  final path = io.Platform.environment['FRAME_PROBE'];
  if (path == null) return;
  final out = io.File(path).openWrite();
  final sw = Stopwatch()..start();
  var n = 0;
  out.writeln('elapsedMs,vsyncStartMs,buildMs,rasterMs,totalMs,vsyncOverheadMs');
  WidgetsBinding.instance.addTimingsCallback((timings) {
    for (final t in timings) {
      n++;
      out.writeln([
        sw.elapsedMilliseconds,
        (t.timestampInMicroseconds(FramePhase.vsyncStart) / 1000)
            .toStringAsFixed(2),
        (t.buildDuration.inMicroseconds / 1000).toStringAsFixed(2),
        (t.rasterDuration.inMicroseconds / 1000).toStringAsFixed(2),
        (t.totalSpan.inMicroseconds / 1000).toStringAsFixed(2),
        (t.vsyncOverhead.inMicroseconds / 1000).toStringAsFixed(2),
      ].join(','));
    }
    if (n % 30 == 0) unawaited(out.flush());
  });
  debugPrint('[frame-probe] logging ke $path');
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
        ApiKeyScreen.route: (_) => const ApiKeyScreen(),
        HomeScreen.route: (_) => const HomeScreen(),
      },
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import 'package:literasi_ai/app/home_screen.dart';

/// Auth Screen — Google Sign-In + Anonymous (PRD §5).
/// Firebase penuh (firebase_options.dart) menyusul setelah user setup
/// project Firebase; sementara ini anonymous login dicoba dan fallback
/// ke mode offline agar app tetap bisa didemokan.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  static const route = '/auth';

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _loading = false;

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.route);
  }

  Future<void> _signInAnonymously() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mode offline — Firebase belum dikonfigurasi.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
      _goHome();
    }
  }

  void _signInWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In aktif setelah setup Firebase.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.fact_check,
                  size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text(AppStrings.authTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(AppStrings.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _loading ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text(AppStrings.authGoogle),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loading ? null : _signInAnonymously,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.authAnonymous),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

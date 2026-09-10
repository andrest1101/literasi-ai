import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:literasi_ai/app/home_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/auth_form_parts.dart';
import '../widgets/google_g_logo.dart';
import '../widgets/login_mascot.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Auth Screen: Masuk via email, Google, atau tanpa akun (PRD Fitur Auth).
///
/// Tata letak: header maskot interaktif, judul, form email dan sandi,
/// tautan lupa sandi, tombol Masuk, divider, tombol Google, opsi anonim,
/// lalu tautan daftar. Maskot bereaksi: mengetik saat email diisi, menutup
/// mata saat sandi fokus, mengintip saat sandi ditampilkan, ceria atau
/// murung mengikuti hasil masuk.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  static const route = '/auth';

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  MascotMood _mood = MascotMood.idle;
  double _lookAt = 0;
  bool _obscure = true;
  bool _googleLoading = false;
  bool _anonLoading = false;
  bool _emailLoading = false;

  bool get _loading => _googleLoading || _anonLoading || _emailLoading;

  static final _emailPattern =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _passwordFocus.addListener(_onPasswordFocus);
  }

  void _onEmailChanged() {
    final text = _emailController.text;
    setState(() {
      _lookAt = (text.length / 24).clamp(0.0, 1.0);
      if (_mood != MascotMood.cover && _mood != MascotMood.peek) {
        _mood = text.isEmpty ? MascotMood.idle : MascotMood.typing;
      }
    });
  }

  void _onPasswordFocus() {
    if (!mounted) return;
    setState(() {
      if (_passwordFocus.hasFocus) {
        _mood = _obscure ? MascotMood.cover : MascotMood.peek;
      } else if (_emailController.text.isEmpty) {
        _mood = MascotMood.idle;
      } else {
        _mood = MascotMood.typing;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.route);
  }

  void _react(bool success) {
    if (!mounted) return;
    setState(() => _mood = success ? MascotMood.happy : MascotMood.sad);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _react(true);
      _goHome();
    } catch (_) {
      _react(false);
      if (mounted) {
        showAuthMessage(context, AppStrings.authGoogleFailed);
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() => _anonLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      _react(true);
      _goHome();
    } on FirebaseAuthException catch (e) {
      _react(false);
      if (mounted) {
        showAuthMessage(
            context, '${AppStrings.authAnonymousFailed} (${e.code})');
      }
      _goHome();
    } catch (_) {
      _react(false);
      if (mounted) {
        showAuthMessage(context, AppStrings.authAnonymousFailed);
      }
      _goHome();
    } finally {
      if (mounted) setState(() => _anonLoading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      _react(false);
      return;
    }
    setState(() => _emailLoading = true);
    try {
      // Provider email belum aktif di Firebase project ini.
      // Validasi lolos, lalu arahkan jujur ke jalur yang tersedia.
      _react(true);
      if (!mounted) return;
      showAuthMessage(context, AppStrings.authNoAccount);
    } finally {
      if (mounted) setState(() => _emailLoading = false);
    }
  }

  void _toggleObscure() {
    setState(() {
      _obscure = !_obscure;
      if (_passwordFocus.hasFocus) {
        _mood = _obscure ? MascotMood.cover : MascotMood.peek;
      }
    });
  }

  void _goRegister() {
    Navigator.of(context).pushNamed(RegisterScreen.route);
  }

  void _goForgot() {
    Navigator.of(context).pushNamed(ForgotPasswordScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoginMascotHeader(mood: _mood, lookAt: _lookAt),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: AuthEyebrow(text: AppStrings.authEyebrow),
                    ),
                    const SizedBox(height: 12),
                    const AuthHeading(
                      title: AppStrings.authTitle,
                      subtitle: AppStrings.authSubtitle,
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            onFieldSubmitted: (_) =>
                                _passwordFocus.requestFocus(),
                            decoration: authInputDecoration(
                              label: AppStrings.authEmailLabel,
                              hint: AppStrings.authEmailHint,
                              icon: Icons.mail_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  !_emailPattern.hasMatch(value.trim())) {
                                return AppStrings.authEmailError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _signInWithEmail(),
                            decoration: authInputDecoration(
                              label: AppStrings.authPasswordLabel,
                              hint: AppStrings.authPasswordHint,
                              icon: Icons.lock_outline_rounded,
                            ).copyWith(
                              suffixIcon: IconButton(
                                tooltip: _obscure
                                    ? 'Tampilkan kata sandi'
                                    : 'Sembunyikan kata sandi',
                                onPressed: _toggleObscure,
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return AppStrings.authPasswordError;
                              }
                              return null;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _goForgot,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text(
                                  AppStrings.authForgotLink),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AuthPrimaryButton(
                            label: AppStrings.authSubmit,
                            loading: _emailLoading,
                            onPressed:
                                _loading ? null : _signInWithEmail,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _DividerRow(text: AppStrings.authDivider),
                    const SizedBox(height: 20),
                    Semantics(
                      button: true,
                      label: AppStrings.authGoogle,
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _signInWithGoogle,
                        icon: _googleLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const GoogleGLogo(size: 20),
                        label: const Text(AppStrings.authGoogle),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: AppColors.neutral
                                .withValues(alpha: 0.35),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      button: true,
                      label: AppStrings.authAnonymous,
                      child: TextButton.icon(
                        onPressed: _loading ? null : _signInAnonymously,
                        icon: _anonLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.person_outline_rounded,
                                size: 20,
                              ),
                        label: const Text(AppStrings.authAnonymous),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(48),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _goRegister,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child:
                            const Text(AppStrings.authGoRegister),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.authOfflineNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AuthTrustRow(text: AppStrings.authTrust),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerRow extends StatelessWidget {
  const _DividerRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(
        color: AppColors.neutral.withValues(alpha: 0.35),
        thickness: 1,
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

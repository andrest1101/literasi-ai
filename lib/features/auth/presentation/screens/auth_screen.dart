import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:literasi_ai/app/home_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/auth_form_parts.dart';
import '../widgets/auth_page_shell.dart';
import '../widgets/google_g_logo.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Auth Screen: Masuk via email, Google, atau tanpa akun (PRD Fitur Auth).
///
/// Tata letak fokus: header brand kompak, judul, kartu form email+sandi+CTA,
/// lalu aksi sekunder Google/anonim dan tautan daftar. Tidak ada ilustrasi
/// besar di auth agar form dan tombol utama langsung terlihat.
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
  final _passwordFocus = FocusNode();

  bool _obscure = true;
  bool _googleLoading = false;
  bool _anonLoading = false;
  bool _emailLoading = false;

  bool get _loading => _googleLoading || _anonLoading || _emailLoading;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.route);
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
      _goHome();
    } catch (_) {
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
      // Catatan offline yang dulu teks permanen kini jadi pesan sekali
      // tampil agar footer bernapas.
      if (mounted) {
        showAuthMessage(context, AppStrings.authOfflineNote);
      }
      await Future<void>.delayed(const Duration(milliseconds: 600));
      _goHome();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        showAuthMessage(
          context,
          '${AppStrings.authAnonymousFailed} (${e.code})',
        );
      }
      _goHome();
    } catch (_) {
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
      return;
    }
    setState(() => _emailLoading = true);
    try {
      // Provider email belum aktif di Firebase project ini.
      // Validasi lolos, lalu arahkan jujur ke jalur yang tersedia.
      if (!mounted) return;
      showAuthMessage(context, AppStrings.authNoAccount);
    } finally {
      if (mounted) setState(() => _emailLoading = false);
    }
  }

  void _toggleObscure() {
    setState(() => _obscure = !_obscure);
  }

  void _goRegister() {
    Navigator.of(context).pushNamed(RegisterScreen.route);
  }

  void _goForgot() {
    Navigator.of(context).pushNamed(ForgotPasswordScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      title: AppStrings.authTitle,
      subtitle: AppStrings.authSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthFormCard(
            title: AppStrings.authFormTitle,
            subtitle: AppStrings.authFormSubtitle,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _signInWithEmail(),
                    decoration:
                        authInputDecoration(
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
                      child: const Text(AppStrings.authForgotLink),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthPrimaryButton(
                    label: AppStrings.authSubmit,
                    loading: _emailLoading,
                    onPressed: _loading ? null : _signInWithEmail,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AuthSecondaryPanel(
            children: [
              const _DividerRow(text: AppStrings.authDivider),
              const SizedBox(height: 12),
              Semantics(
                button: true,
                label: AppStrings.authGoogle,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _signInWithGoogle,
                  icon: _googleLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const GoogleGLogo(size: 20),
                  label: const Text(AppStrings.authGoogle),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: AppColors.neutral.withValues(alpha: 0.32),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Semantics(
                button: true,
                label: AppStrings.authAnonymous,
                child: TextButton.icon(
                  onPressed: _loading ? null : _signInAnonymously,
                  icon: _anonLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_outline_rounded, size: 20),
                  label: const Text(AppStrings.authAnonymous),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(46),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: AuthBottomLink(
              prefix: AppStrings.authGoRegisterPrefix,
              action: AppStrings.authGoRegisterAction,
              onTap: _goRegister,
            ),
          ),
          const SizedBox(height: 8),
        ],
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

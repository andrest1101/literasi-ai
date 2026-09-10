import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/auth_form_parts.dart';
import '../widgets/login_mascot.dart';
import 'auth_screen.dart';

/// Halaman Lupa Sandi: kirim tautan atur ulang via email.
///
/// Satu-satunya fitur email yang benar-benar berjalan tanpa provider
/// tambahan: `sendPasswordResetEmail` asli Firebase. Berhasil atau gagal
/// selalu dilaporkan jujur lewat snackbar.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const route = '/forgot-password';

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  double _lookAt = 0;
  bool _sending = false;
  bool _sent = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    setState(() {
      _lookAt =
          (_emailController.text.length / 24).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _sending = true;
      _sent = false;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _sent = true);
      showAuthMessage(context, AppStrings.forgotSent);
    } on FirebaseAuthException {
      if (!mounted) return;
      showAuthMessage(context, AppStrings.forgotFailed);
    } catch (_) {
      if (!mounted) return;
      showAuthMessage(context, AppStrings.forgotFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
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
              Stack(
                children: [
                  LoginMascotHeader(
                    mood: _sent ? MascotMood.happy : MascotMood.typing,
                    lookAt: _lookAt,
                  ),
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: AuthBackButton(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child:
                          AuthEyebrow(text: AppStrings.forgotEyebrow),
                    ),
                    const SizedBox(height: 12),
                    const AuthHeading(
                      title: AppStrings.forgotTitle,
                      subtitle: AppStrings.forgotSubtitle,
                    ),
                    const SizedBox(height: 24),
                    if (_sent)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.success
                              .withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.success
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.mark_email_read_outlined,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppStrings.forgotSent,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_sent) const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType:
                                TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [
                              AutofillHints.email
                            ],
                            onFieldSubmitted: (_) => _send(),
                            decoration: authInputDecoration(
                              label: AppStrings.authEmailLabel,
                              hint: AppStrings.authEmailHint,
                              icon: Icons.mail_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  !_emailPattern
                                      .hasMatch(value.trim())) {
                                return AppStrings.authEmailError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AuthPrimaryButton(
                            label: AppStrings.forgotSubmit,
                            loading: _sending,
                            onPressed: _sending ? null : _send,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed(AuthScreen.route),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child:
                            const Text(AppStrings.forgotBack),
                      ),
                    ),
                    const SizedBox(height: 12),
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

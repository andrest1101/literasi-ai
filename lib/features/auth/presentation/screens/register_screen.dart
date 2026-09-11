import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/auth_form_parts.dart';
import '../widgets/login_mascot.dart';
import '../widgets/password_requirement_list.dart';
import 'auth_screen.dart';

/// Halaman Daftar: nama, email, kata sandi, dan konfirmasi.
///
/// Maskot tampil ceria menyambut pendaftar baru. Syarat sandi dievaluasi
/// live saat mengetik. Provider email belum dibuka di backend, jadi tombol
/// Daftar memvalidasi lalu mengarahkan ke jalur yang tersedia (Google atau
/// tanpa akun). Tidak ada akun yang dibuat diam-diam.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static const route = '/register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String _password = '';
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  MascotMood get _mood {
    // Kedua kolom sandi bersifat rahasia: maskot menutup mata saat
    // salah satunya fokus, mengintip bila isinya sedang ditampilkan.
    if (_passwordFocus.hasFocus) {
      return _obscure ? MascotMood.cover : MascotMood.peek;
    }
    if (_confirmFocus.hasFocus) {
      return _obscureConfirm ? MascotMood.cover : MascotMood.peek;
    }
    return MascotMood.happy;
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _passwordFocus.addListener(_onFocusChanged);
    _confirmFocus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onPasswordChanged() {
    setState(() => _password = _passwordController.text);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      // Provider email belum aktif di Firebase project ini.
      // Validasi lolos, lalu arahkan jujur ke jalur yang tersedia.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      showAuthMessage(context, AppStrings.registerPending);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _toggleObscure() => setState(() => _obscure = !_obscure);

  void _toggleObscureConfirm() =>
      setState(() => _obscureConfirm = !_obscureConfirm);

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
                  LoginMascotHeader(mood: _mood),
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
                      child: AuthEyebrow(
                          text: AppStrings.registerEyebrow),
                    ),
                    const SizedBox(height: 12),
                    const AuthHeading(
                      title: AppStrings.registerTitle,
                      subtitle: AppStrings.registerSubtitle,
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            decoration: authInputDecoration(
                              label: AppStrings.registerNameLabel,
                              hint: AppStrings.registerNameHint,
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return AppStrings.registerNameError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
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
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.newPassword
                            ],
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
                              if (!PasswordRules.of(value ?? '').allOk) {
                                return AppStrings.authPasswordError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          PasswordRequirementList(password: _password),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmController,
                            focusNode: _confirmFocus,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: authInputDecoration(
                              label: AppStrings.registerConfirmLabel,
                              hint: AppStrings.registerConfirmHint,
                              icon: Icons.verified_user_outlined,
                            ).copyWith(
                              suffixIcon: IconButton(
                                tooltip: _obscureConfirm
                                    ? 'Tampilkan kata sandi'
                                    : 'Sembunyikan kata sandi',
                                onPressed: _toggleObscureConfirm,
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return AppStrings.registerMismatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AuthPrimaryButton(
                            label: AppStrings.registerSubmit,
                            loading: _submitting,
                            onPressed:
                                _submitting ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: AuthBottomLink(
                        prefix: AppStrings.authGoLoginPrefix,
                        action: AppStrings.authGoLoginAction,
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed(AuthScreen.route),
                      ),
                    ),
                    const SizedBox(height: 8),
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

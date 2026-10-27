import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/home_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/auth_failure.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_form_parts.dart';
import '../widgets/auth_page_shell.dart';
import 'auth_screen.dart';

/// Gerbang wajib bagi akun email yang belum terbukti memiliki inbox-nya.
///
/// Layar ini satu-satunya tujuan yang bisa diakses sebelum verifikasi selesai.
/// Tiga jalan keluar disediakan agar pengguna tidak pernah terkunci: kirim
/// ulang tautan, cek status setelah membuka email, atau batalkan pendaftaran.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  static const route = '/verify-email';

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;
  bool _checking = false;
  bool _resending = false;
  bool _deleting = false;

  bool get _busy => _checking || _resending || _deleting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pengguna biasanya membuka inbox lalu kembali ke app. Periksa diam-diam
    // agar satu langkah hilang: tidak perlu menekan tombol lagi.
    if (state == AppLifecycleState.resumed && !_busy) {
      _checkVerified();
    }
  }

  /// Menjalankan ulang hitung mundur tanpa menunggu tick berikutnya.
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final until = ref
          .read(authControllerProvider.notifier)
          .resendBlockedUntil;
      final counting = until != null && DateTime.now().isBefore(until);
      if (!counting) timer.cancel();
      setState(() {});
    });
  }

  int get _resendRemainingSeconds {
    final until = ref.read(authControllerProvider.notifier).resendBlockedUntil;
    if (until == null) return 0;
    final seconds = until.difference(DateTime.now()).inSeconds;
    return seconds > 0 ? seconds : 0;
  }

  Future<void> _checkVerified() async {
    setState(() => _checking = true);
    try {
      final user = await ref
          .read(authControllerProvider.notifier)
          .refreshUser();
      if (!mounted) return;
      if (user == null) {
        _goAuth();
        return;
      }
      if (user.needsEmailVerification) {
        showAuthMessage(context, AppStrings.verifyEmailStillUnverified);
        return;
      }
      _goHome();
    } on AuthFailure catch (error) {
      if (mounted) showAuthMessage(context, authFailureMessage(error));
    } catch (_) {
      if (mounted) showAuthMessage(context, AppStrings.authUnexpectedFailed);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    if (_resendRemainingSeconds > 0) return;
    setState(() => _resending = true);
    try {
      await ref.read(authControllerProvider.notifier).resendVerificationEmail();
      if (!mounted) return;
      showAuthMessage(context, AppStrings.verifyEmailSendAgain);
    } on AuthFailure catch (error) {
      if (mounted) showAuthMessage(context, authFailureMessage(error));
    } catch (_) {
      if (mounted) showAuthMessage(context, AppStrings.authUnexpectedFailed);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
    if (mounted) _startTicker();
  }

  Future<void> _signOut() async {
    setState(() => _deleting = true);
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (mounted) _goAuth();
    } catch (_) {
      if (mounted) showAuthMessage(context, AppStrings.authUnexpectedFailed);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.verifyEmailDeleteTitle),
        content: const Text(AppStrings.verifyEmailDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.verifyEmailDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text(AppStrings.verifyEmailDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (!mounted) return;
      showAuthMessage(context, AppStrings.verifyEmailDeleted);
      _goAuth();
    } on AuthFailure catch (error) {
      if (mounted) showAuthMessage(context, authFailureMessage(error));
    } catch (_) {
      if (mounted) showAuthMessage(context, AppStrings.authUnexpectedFailed);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(HomeScreen.route, (_) => false);
  }

  void _goAuth() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AuthScreen.route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final email = user?.email;
    final remaining = _resendRemainingSeconds;

    return AuthPageShell(
      title: AppStrings.verifyEmailTitle,
      subtitle: AppStrings.verifyEmailSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthFormCard(
            title: AppStrings.verifyEmailFormTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (email == null)
                  const Text(
                    AppStrings.verifyEmailMissingSession,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  )
                else ...[
                  const Text(
                    AppStrings.verifyEmailSentPrefix,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  AppStrings.verifyEmailGuide,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.verifyEmailNote,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AuthPrimaryButton(
                  label: AppStrings.verifyEmailCheck,
                  loading: _checking,
                  onPressed: _busy ? null : _checkVerified,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AuthSecondaryPanel(
            children: [
              OutlinedButton.icon(
                onPressed: _busy || remaining > 0 ? null : _resend,
                icon: const Icon(Icons.forward_to_inbox_rounded, size: 20),
                label: Text(
                  remaining > 0
                      ? '${AppStrings.verifyEmailResendIn} ${remaining}s'
                      : AppStrings.verifyEmailResend,
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.28),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _busy ? null : _signOut,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(AppStrings.verifyEmailSignOut),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size.fromHeight(44),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _busy ? null : _deleteAccount,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text(AppStrings.verifyEmailDelete),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  minimumSize: const Size.fromHeight(44),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

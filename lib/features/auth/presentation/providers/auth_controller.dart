import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_provider.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

/// Sumber kebenaran sesi auth di lapisan presentasi.
///
/// Menyimpan satu sesi Firebase, menegakkan jeda kirim ulang email verifikasi,
/// dan menyediakan refresh profil agar status `emailVerified` ikut berubah
/// tanpa perlu logout.
class AuthController extends AsyncNotifier<AuthUser?> {
  /// Jeda minimum antar permintaan email verifikasi.
  ///
  /// Firebase membatasi laju pengiriman email; jeda ini mencegah pengguna
  /// menekan tombol berulang dan mengenai kuota tanpa penjelasan.
  static const Duration resendCooldown = Duration(seconds: 60);

  DateTime? _resendBlockedUntil;

  /// Waktu paling awal email verifikasi boleh dikirim lagi, atau `null` bila
  /// pengguna boleh mengirim sekarang.
  DateTime? get resendBlockedUntil => _resendBlockedUntil;

  @override
  Future<AuthUser?> build() async {
    try {
      return ref.watch(authRepositoryProvider).currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) => _run(
    (repository) =>
        repository.signInWithEmail(email: email.trim(), password: password),
  );

  Future<AuthUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) => _run(
    (repository) => repository.registerWithEmail(
      name: name,
      email: email.trim(),
      password: password,
    ),
  );

  Future<AuthUser?> signInWithGoogle() =>
      _run((repository) => repository.signInWithGoogle(), allowNull: true);

  Future<AuthUser> signInAnonymously() =>
      _run((repository) => repository.signInAnonymously());

  Future<void> sendPasswordResetEmail(String email) async {
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email.trim());
  }

  /// Memuat ulang status verifikasi tanpa mengosongkan layar.
  ///
  /// State tidak dibuat `AsyncLoading` agar layar verifikasi tidak berkedip
  /// saat pengguna menekan "Saya sudah verifikasi".
  Future<AuthUser?> refreshUser() async {
    final user = await ref.read(authRepositoryProvider).refreshUser();
    state = AsyncData(user);
    return user;
  }

  /// Mengirim ulang tautan verifikasi, dengan jeda [resendCooldown].
  Future<void> resendVerificationEmail() async {
    final blockedUntil = _resendBlockedUntil;
    if (blockedUntil != null && DateTime.now().isBefore(blockedUntil)) {
      throw const AuthFailure(AuthFailureCode.tooManyRequests);
    }
    await ref.read(authRepositoryProvider).sendEmailVerification();
    _resendBlockedUntil = DateTime.now().add(resendCooldown);
  }

  /// Menghapus akun yang belum terverifikasi agar email salah ketik tidak
  /// meninggalkan akun yatim yang tidak bisa dipakai.
  Future<void> deleteAccount() async {
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
    } finally {
      _resendBlockedUntil = null;
      state = const AsyncData(null);
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    _resendBlockedUntil = null;
    state = const AsyncData(null);
  }

  Future<T> _run<T>(
    Future<T> Function(AuthRepository repository) action, {
    bool allowNull = false,
  }) async {
    final previous = state;
    state = const AsyncLoading();
    try {
      final result = await action(ref.read(authRepositoryProvider));
      if (result is AuthUser || (allowNull && result == null)) {
        state = AsyncData(result as AuthUser?);
      } else {
        state = previous;
      }
      return result;
    } on AuthFailure catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

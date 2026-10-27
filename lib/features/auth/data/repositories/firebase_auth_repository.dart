import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/services.dart';

import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._datasource);

  final FirebaseAuthDatasource _datasource;

  @override
  AuthUser? get currentUser => _mapUser(_datasource.currentUser);

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final credential = await _datasource.signInWithEmail(email, password);
    return _requireUser(credential.user);
  });

  @override
  Future<AuthUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    final existing = _datasource.currentUser;
    final credential = existing?.isAnonymous == true
        ? await _datasource.linkAnonymousWithEmail(existing!, email, password)
        : await _datasource.registerWithEmail(email, password);
    final user = _requireUser(credential.user);
    try {
      await _datasource.updateDisplayName(credential.user!, name.trim());
    } catch (_) {
      // Account creation/linking succeeded; a profile label failure must not
      // strand a valid new session on the registration form.
    }
    try {
      await _datasource.sendEmailVerification();
    } catch (_) {
      // Akun sudah sah meski pengiriman email gagal sesaat. Layar verifikasi
      // menyediakan "Kirim ulang email" yang melaporkan kegagalan sebenarnya.
    }
    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: name.trim(),
      isAnonymous: user.isAnonymous,
      emailVerified: user.emailVerified,
    );
  });

  @override
  Future<AuthUser?> signInWithGoogle() => _guard(() async {
    final user = await _datasource.signInWithGoogle();
    return _mapUser(user);
  });

  @override
  Future<AuthUser> signInAnonymously() => _guard(() async {
    final credential = await _datasource.signInAnonymously();
    return _requireUser(credential.user);
  });

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _guard(() => _datasource.sendPasswordResetEmail(email));

  @override
  Future<void> sendEmailVerification() =>
      _guard(_datasource.sendEmailVerification);

  @override
  Future<AuthUser?> refreshUser() =>
      _guard(() async => _mapUser(await _datasource.reloadCurrentUser()));

  @override
  Future<void> deleteAccount() => _guard(() async {
    await _datasource.deleteCurrentUser();
    await _datasource.signOut();
  });

  @override
  Future<void> signOut() => _guard(_datasource.signOut);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthFailure {
      rethrow;
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(firebaseAuthFailureForCode(error.code));
    } on GoogleIdTokenMissingException {
      throw const AuthFailure(AuthFailureCode.googleConfigMissing);
    } on PlatformException catch (error) {
      throw AuthFailure(googleAuthFailureFor(error));
    } catch (_) {
      throw const AuthFailure(AuthFailureCode.unknown);
    }
  }

  AuthUser _requireUser(firebase.User? user) =>
      _mapUser(user) ?? (throw const AuthFailure(AuthFailureCode.unknown));

  AuthUser? _mapUser(firebase.User? user) => user == null
      ? null
      : AuthUser(
          id: user.uid,
          email: user.email,
          displayName: user.displayName,
          isAnonymous: user.isAnonymous,
          emailVerified: user.emailVerified,
        );
}

AuthFailureCode firebaseAuthFailureForCode(String code) => switch (code) {
  'invalid-email' => AuthFailureCode.invalidEmail,
  'email-already-in-use' => AuthFailureCode.emailAlreadyInUse,
  'weak-password' => AuthFailureCode.weakPassword,
  'user-not-found' ||
  'wrong-password' ||
  'invalid-credential' => AuthFailureCode.invalidCredentials,
  'network-request-failed' => AuthFailureCode.network,
  'operation-not-allowed' => AuthFailureCode.providerDisabled,
  'account-exists-with-different-credential' ||
  'credential-already-in-use' => AuthFailureCode.accountConflict,
  'popup-closed-by-user' || 'sign_in_canceled' => AuthFailureCode.cancelled,
  'too-many-requests' => AuthFailureCode.tooManyRequests,
  'requires-recent-login' ||
  'user-token-expired' => AuthFailureCode.requiresRecentLogin,
  'user-disabled' => AuthFailureCode.accountDisabled,
  _ => AuthFailureCode.unknown,
};

/// Memetakan kegagalan plugin Google Sign-In ke kategori yang bisa dijelaskan.
///
/// `google_sign_in_android` membungkus `ApiException` Play Services menjadi
/// `PlatformException(code: 'sign_in_failed', message: '10: ...')`, sehingga
/// kode numeriknya hanya terbaca dari pesan.
AuthFailureCode googleAuthFailureFor(PlatformException error) {
  final raw = '${error.code} ${error.message ?? ''}';
  final apiCode = int.tryParse(
    RegExp(r'(\d{1,5}):').firstMatch(raw)?.group(1) ?? '',
  );
  return switch (apiCode) {
    // DEVELOPER_ERROR: paket + SHA-1 belum terdaftar sebagai OAuth client.
    10 => AuthFailureCode.googleConfigMissing,
    12500 => AuthFailureCode.googleConfigMissing,
    12501 => AuthFailureCode.cancelled,
    12502 => AuthFailureCode.googleSignInFailed,
    7 => AuthFailureCode.network,
    1 || 2 || 3 => AuthFailureCode.playServicesUnavailable,
    _ =>
      raw.contains('sign_in_canceled')
          ? AuthFailureCode.cancelled
          : AuthFailureCode.googleSignInFailed,
  };
}

/// Authenticated identity exposed to the presentation layer.
class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.isAnonymous = false,
    this.emailVerified = false,
  });

  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final bool emailVerified;

  /// Sesi email/sandi wajib membuktikan kepemilikan inbox sebelum masuk app.
  ///
  /// Akun Google datang dari Firebase dengan `emailVerified = true`, dan sesi
  /// anonim tidak punya email sama sekali, sehingga keduanya tidak digerbangi.
  bool get needsEmailVerification => email != null && !emailVerified;
}

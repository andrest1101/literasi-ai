import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthUser?> signInWithGoogle();

  Future<AuthUser> signInAnonymously();

  Future<void> sendPasswordResetEmail(String email);

  /// Mengirim ulang tautan verifikasi ke email sesi yang sedang aktif.
  Future<void> sendEmailVerification();

  /// Memuat ulang profil dari server dan mengembalikan status terbaru.
  ///
  /// Dipakai setelah pengguna membuka tautan verifikasi di emailnya.
  Future<AuthUser?> refreshUser();

  /// Menghapus akun aktif secara permanen lalu mengakhiri sesi.
  Future<void> deleteAccount();

  Future<void> signOut();
}

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

  Future<void> signOut();
}

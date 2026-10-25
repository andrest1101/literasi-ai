import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_provider.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthUser?> {
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

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
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

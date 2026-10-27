import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/features/auth/domain/entities/auth_failure.dart';
import 'package:literasi_ai/features/auth/domain/entities/auth_user.dart';
import 'package:literasi_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:literasi_ai/features/auth/presentation/providers/auth_controller.dart';
import 'package:literasi_ai/features/auth/presentation/providers/auth_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  AuthUser? user;
  String? lastEmail;
  String? lastPassword;
  String? lastName;
  String? resetEmail;
  int signOutCalls = 0;
  int sendVerificationCalls = 0;
  int deleteCalls = 0;
  int refreshCalls = 0;
  AuthUser? refreshedUser;

  @override
  AuthUser? get currentUser => user;

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    return user = AuthUser(id: 'signed-in', email: email);
  }

  @override
  Future<AuthUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    lastName = name;
    lastEmail = email;
    lastPassword = password;
    return user = AuthUser(id: 'registered', email: email, displayName: name);
  }

  @override
  Future<AuthUser?> signInWithGoogle() async => user = const AuthUser(
    id: 'google-user',
    email: 'user@example.com',
    emailVerified: true,
  );

  @override
  Future<AuthUser> signInAnonymously() async =>
      user = const AuthUser(id: 'guest', isAnonymous: true);

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    resetEmail = email;
  }

  @override
  Future<void> sendEmailVerification() async {
    sendVerificationCalls++;
  }

  @override
  Future<AuthUser?> refreshUser() async {
    refreshCalls++;
    return user = refreshedUser ?? user;
  }

  @override
  Future<void> deleteAccount() async {
    deleteCalls++;
    user = null;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    user = null;
  }
}

void main() {
  late _FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  test(
    'email sign-in trims email and updates Riverpod session state',
    () async {
      final controller = container.read(authControllerProvider.notifier);

      final user = await controller.signInWithEmail(
        email: '  user@example.com ',
        password: 'secret123',
      );

      expect(user.id, 'signed-in');
      expect(repository.lastEmail, 'user@example.com');
      expect(repository.lastPassword, 'secret123');
      expect(
        container.read(authControllerProvider).requireValue?.id,
        'signed-in',
      );
    },
  );

  test('registration passes name/email and establishes session', () async {
    final controller = container.read(authControllerProvider.notifier);

    final user = await controller.registerWithEmail(
      name: 'Nama Pengguna',
      email: 'new@example.com',
      password: 'secret123',
    );

    expect(repository.lastName, 'Nama Pengguna');
    expect(repository.lastEmail, 'new@example.com');
    expect(user.displayName, 'Nama Pengguna');
    expect(
      container.read(authControllerProvider).requireValue?.id,
      'registered',
    );
  });

  test('new email account stays gated until the inbox is verified', () async {
    final user = await container
        .read(authControllerProvider.notifier)
        .registerWithEmail(
          name: 'Nama Pengguna',
          email: 'new@example.com',
          password: 'secret123',
        );

    expect(user.needsEmailVerification, isTrue);
  });

  test('Google session arrives verified and is never gated', () async {
    final user = await container
        .read(authControllerProvider.notifier)
        .signInWithGoogle();

    expect(user?.needsEmailVerification, isFalse);
  });

  test('refreshUser replaces the session with the reloaded profile', () async {
    repository.user = const AuthUser(id: 'uid', email: 'a@example.com');
    repository.refreshedUser = const AuthUser(
      id: 'uid',
      email: 'a@example.com',
      emailVerified: true,
    );
    final controller = container.read(authControllerProvider.notifier);
    await container.read(authControllerProvider.future);

    final refreshed = await controller.refreshUser();

    expect(repository.refreshCalls, 1);
    expect(refreshed?.emailVerified, isTrue);
    expect(
      container.read(authControllerProvider).requireValue?.emailVerified,
      isTrue,
    );
  });

  test('resend enforces a cooldown after the first delivery', () async {
    final controller = container.read(authControllerProvider.notifier);

    await controller.resendVerificationEmail();
    expect(repository.sendVerificationCalls, 1);
    expect(controller.resendBlockedUntil, isNotNull);

    await expectLater(
      controller.resendVerificationEmail(),
      throwsA(
        isA<AuthFailure>().having(
          (failure) => failure.code,
          'code',
          AuthFailureCode.tooManyRequests,
        ),
      ),
    );
    expect(repository.sendVerificationCalls, 1);
  });

  test('sign out clears the cooldown so another account can verify', () async {
    final controller = container.read(authControllerProvider.notifier);
    await controller.resendVerificationEmail();
    await controller.signOut();

    expect(controller.resendBlockedUntil, isNull);
    await controller.resendVerificationEmail();
    expect(repository.sendVerificationCalls, 2);
  });

  test('deleteAccount removes the account and clears the session', () async {
    repository.user = const AuthUser(id: 'uid', email: 'a@example.com');
    final controller = container.read(authControllerProvider.notifier);
    await container.read(authControllerProvider.future);

    await controller.deleteAccount();

    expect(repository.deleteCalls, 1);
    expect(container.read(authControllerProvider).requireValue, isNull);
  });

  test('password reset trims email', () async {
    await container
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(' reset@example.com ');

    expect(repository.resetEmail, 'reset@example.com');
  });

  test('sign out clears session state', () async {
    final controller = container.read(authControllerProvider.notifier);
    await controller.signInAnonymously();
    await controller.signOut();

    expect(repository.signOutCalls, 1);
    expect(container.read(authControllerProvider).requireValue, isNull);
  });
}

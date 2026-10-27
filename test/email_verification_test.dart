import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/auth/domain/entities/auth_user.dart';
import 'package:literasi_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:literasi_ai/features/auth/domain/repositories/onboarding_repository.dart';
import 'package:literasi_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:literasi_ai/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:literasi_ai/features/auth/presentation/screens/auth_screen.dart';
import 'package:literasi_ai/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:literasi_ai/main.dart';

class _UnverifiedRepository implements AuthRepository {
  _UnverifiedRepository({this.verifiedAfterRefresh = false});

  final bool verifiedAfterRefresh;
  AuthUser? user = const AuthUser(id: 'uid', email: 'budi@example.com');
  int sendVerificationCalls = 0;
  int deleteCalls = 0;

  @override
  AuthUser? get currentUser => user;

  @override
  Future<AuthUser?> refreshUser() async {
    if (verifiedAfterRefresh) {
      user = const AuthUser(
        id: 'uid',
        email: 'budi@example.com',
        emailVerified: true,
      );
    }
    return user;
  }

  @override
  Future<void> sendEmailVerification() async {
    sendVerificationCalls++;
  }

  @override
  Future<void> deleteAccount() async {
    deleteCalls++;
    user = null;
  }

  @override
  Future<void> signOut() async => user = null;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<AuthUser> signInAnonymously() async =>
      user = const AuthUser(id: 'guest', isAnonymous: true);

  @override
  Future<AuthUser?> signInWithGoogle() async => user;

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async => user ?? (user = AuthUser(id: 'uid', email: email));

  @override
  Future<AuthUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async => user = AuthUser(id: 'uid', email: email, displayName: name);
}

class _CompletedOnboarding implements OnboardingRepository {
  @override
  Future<bool> isCompleted() async => true;

  @override
  Future<void> markCompleted() async {}
}

Widget _shell(_UnverifiedRepository repository, {Widget? home}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      onboardingRepositoryProvider.overrideWith(
        (ref) => _CompletedOnboarding(),
      ),
    ],
    child: home == null
        ? const LiterasiAIApp()
        : MaterialApp(
            home: home,
            routes: {
              HomeScreen.route: (_) =>
                  const Scaffold(body: Center(child: Text('HOME'))),
              AuthScreen.route: (_) =>
                  const Scaffold(body: Center(child: Text('AUTH'))),
            },
          ),
  );
}

void main() {
  /// Halaman auth memakai scroll; pastikan target benar-benar terlihat dulu.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('splash holds an unverified email session at the gate', (
    tester,
  ) async {
    await tester.pumpWidget(_shell(_UnverifiedRepository()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.verifyEmailTitle), findsOneWidget);
    expect(find.text('budi@example.com'), findsOneWidget);
  });

  testWidgets('verified session unlocks the app after checking', (
    tester,
  ) async {
    final repository = _UnverifiedRepository(verifiedAfterRefresh: true);
    await tester.pumpWidget(
      _shell(repository, home: const VerifyEmailScreen()),
    );
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text(AppStrings.verifyEmailCheck));

    expect(find.text('HOME'), findsOneWidget);
    expect(repository.user?.emailVerified, isTrue);
  });

  testWidgets('still unverified session explains what to do next', (
    tester,
  ) async {
    final repository = _UnverifiedRepository();
    await tester.pumpWidget(
      _shell(repository, home: const VerifyEmailScreen()),
    );
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text(AppStrings.verifyEmailCheck));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(AppStrings.verifyEmailStillUnverified), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('cancelling registration deletes the unverified account', (
    tester,
  ) async {
    final repository = _UnverifiedRepository();
    await tester.pumpWidget(
      _shell(repository, home: const VerifyEmailScreen()),
    );
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text(AppStrings.verifyEmailDelete));
    expect(find.text(AppStrings.verifyEmailDeleteTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.verifyEmailDeleteConfirm));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 1);
    expect(find.text('AUTH'), findsOneWidget);
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:literasi_ai/features/auth/domain/entities/auth_failure.dart';
import 'package:literasi_ai/features/auth/domain/entities/auth_user.dart';

void main() {
  group('FirebaseAuthRepository error mapping', () {
    const mappings = <String, AuthFailureCode>{
      'invalid-email': AuthFailureCode.invalidEmail,
      'email-already-in-use': AuthFailureCode.emailAlreadyInUse,
      'weak-password': AuthFailureCode.weakPassword,
      'user-not-found': AuthFailureCode.invalidCredentials,
      'wrong-password': AuthFailureCode.invalidCredentials,
      'invalid-credential': AuthFailureCode.invalidCredentials,
      'network-request-failed': AuthFailureCode.network,
      'operation-not-allowed': AuthFailureCode.providerDisabled,
      'account-exists-with-different-credential':
          AuthFailureCode.accountConflict,
      'credential-already-in-use': AuthFailureCode.accountConflict,
      'sign_in_canceled': AuthFailureCode.cancelled,
      'too-many-requests': AuthFailureCode.tooManyRequests,
      'requires-recent-login': AuthFailureCode.requiresRecentLogin,
      'user-token-expired': AuthFailureCode.requiresRecentLogin,
      'user-disabled': AuthFailureCode.accountDisabled,
      'some-new-firebase-error': AuthFailureCode.unknown,
    };

    for (final entry in mappings.entries) {
      test('${entry.key} -> ${entry.value.name}', () {
        expect(firebaseAuthFailureForCode(entry.key), entry.value);
      });
    }
  });

  group('Google Sign-In failure mapping', () {
    const messages = <String, AuthFailureCode>{
      // Play Services: paket + SHA-1 tidak cocok dengan OAuth client mana pun.
      '10: Developer console is not set up correctly.':
          AuthFailureCode.googleConfigMissing,
      '12500: Sign in failed': AuthFailureCode.googleConfigMissing,
      '12501: The user canceled the sign-in flow.': AuthFailureCode.cancelled,
      '12502: Sign in is already in progress':
          AuthFailureCode.googleSignInFailed,
      '7: Network error occurred': AuthFailureCode.network,
      '2: Google Play services out of date':
          AuthFailureCode.playServicesUnavailable,
      '3: Google Play services disabled':
          AuthFailureCode.playServicesUnavailable,
      'something unexpected': AuthFailureCode.googleSignInFailed,
    };

    for (final entry in messages.entries) {
      test('${entry.key} -> ${entry.value.name}', () {
        expect(
          googleAuthFailureFor(
            PlatformException(code: 'sign_in_failed', message: entry.key),
          ),
          entry.value,
        );
      });
    }

    test('plugin cancellation code maps to cancelled', () {
      expect(
        googleAuthFailureFor(
          PlatformException(code: 'sign_in_canceled', message: ''),
        ),
        AuthFailureCode.cancelled,
      );
    });
  });

  group('AuthUser verification gate', () {
    test('email account is gated until verified', () {
      const user = AuthUser(id: 'uid', email: 'a@example.com');
      expect(user.needsEmailVerification, isTrue);
    });

    test('verified email account is not gated', () {
      const user = AuthUser(
        id: 'uid',
        email: 'a@example.com',
        emailVerified: true,
      );
      expect(user.needsEmailVerification, isFalse);
    });

    test('anonymous and mailless sessions are not gated', () {
      expect(
        const AuthUser(id: 'guest', isAnonymous: true).needsEmailVerification,
        isFalse,
      );
      expect(const AuthUser(id: 'no-email').needsEmailVerification, isFalse);
    });
  });

  test('user-facing messages are Indonesian and do not expose server text', () {
    const failure = AuthFailure(AuthFailureCode.invalidCredentials);
    expect(authFailureMessage(failure), AppStrings.authErrorInvalidCredentials);
    expect(
      authFailureMessage(failure),
      isNot(contains('FirebaseAuthException')),
    );
    expect(
      authFailureMessage(
        const AuthFailure(AuthFailureCode.googleConfigMissing),
      ),
      contains('OAuth'),
    );
  });
}

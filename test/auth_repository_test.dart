import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:literasi_ai/features/auth/domain/entities/auth_failure.dart';

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
      'some-new-firebase-error': AuthFailureCode.unknown,
    };

    for (final entry in mappings.entries) {
      test('${entry.key} -> ${entry.value.name}', () {
        expect(firebaseAuthFailureForCode(entry.key), entry.value);
      });
    }
  });

  test('user-facing messages are Indonesian and do not expose server text', () {
    const failure = AuthFailure(AuthFailureCode.invalidCredentials);
    expect(authFailureMessage(failure), 'Email atau kata sandi tidak cocok.');
    expect(
      authFailureMessage(failure),
      isNot(contains('FirebaseAuthException')),
    );
  });
}

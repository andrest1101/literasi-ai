import '../../../../core/constants/app_strings.dart';

/// Safe, user-facing authentication failure categories.
enum AuthFailureCode {
  invalidCredentials,
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  network,
  providerDisabled,
  accountConflict,
  cancelled,
  googleConfigMissing,
  googleSignInFailed,
  playServicesUnavailable,
  verificationRequired,
  tooManyRequests,
  requiresRecentLogin,
  accountDisabled,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthFailureCode code;
}

String authFailureMessage(AuthFailure failure) => switch (failure.code) {
  AuthFailureCode.invalidCredentials => AppStrings.authErrorInvalidCredentials,
  AuthFailureCode.emailAlreadyInUse => AppStrings.authErrorEmailInUse,
  AuthFailureCode.invalidEmail => AppStrings.authErrorInvalidEmail,
  AuthFailureCode.weakPassword => AppStrings.authErrorWeakPassword,
  AuthFailureCode.network => AppStrings.authErrorNetwork,
  AuthFailureCode.providerDisabled => AppStrings.authErrorProviderDisabled,
  AuthFailureCode.accountConflict => AppStrings.authErrorAccountConflict,
  AuthFailureCode.cancelled => AppStrings.authErrorCancelled,
  AuthFailureCode.googleConfigMissing => AppStrings.authErrorGoogleConfig,
  AuthFailureCode.googleSignInFailed => AppStrings.authErrorGoogleFailed,
  AuthFailureCode.playServicesUnavailable => AppStrings.authErrorPlayServices,
  AuthFailureCode.verificationRequired =>
    AppStrings.authErrorVerificationRequired,
  AuthFailureCode.tooManyRequests => AppStrings.authErrorTooManyRequests,
  AuthFailureCode.requiresRecentLogin =>
    AppStrings.authErrorRequiresRecentLogin,
  AuthFailureCode.accountDisabled => AppStrings.authErrorAccountDisabled,
  AuthFailureCode.unknown => AppStrings.authErrorUnknown,
};

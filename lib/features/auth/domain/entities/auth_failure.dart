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
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthFailureCode code;
}

String authFailureMessage(AuthFailure failure) => switch (failure.code) {
  AuthFailureCode.invalidCredentials => 'Email atau kata sandi tidak cocok.',
  AuthFailureCode.emailAlreadyInUse =>
    'Email ini sudah terdaftar. Silakan masuk.',
  AuthFailureCode.invalidEmail => 'Format email belum benar.',
  AuthFailureCode.weakPassword =>
    'Kata sandi terlalu lemah. Coba gunakan yang lebih kuat.',
  AuthFailureCode.network =>
    'Koneksi bermasalah. Periksa internet lalu coba lagi.',
  AuthFailureCode.providerDisabled =>
    'Metode masuk ini belum diaktifkan di Firebase.',
  AuthFailureCode.accountConflict =>
    'Email ini sudah terhubung ke metode masuk lain. Coba metode tersebut.',
  AuthFailureCode.cancelled => 'Proses masuk dibatalkan.',
  AuthFailureCode.unknown => 'Terjadi kendala. Coba lagi beberapa saat.',
};

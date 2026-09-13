/// Failure terpusat untuk repository/usecase (Clean Architecture).
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi lambat, coba lagi.']);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Server AI tidak merespons, coba lagi.',
  ]);
}

class ParsingFailure extends Failure {
  const ParsingFailure([
    super.message = 'Hasil AI tidak dapat diproses, coba lagi.',
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Gagal masuk, coba lagi.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal menyimpan riwayat.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan tak terduga.']);
}

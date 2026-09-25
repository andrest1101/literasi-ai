/// Failure terpusat untuk repository/usecase (Clean Architecture).
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  static const String defaultMessage =
      'Server AI tidak menjawab dalam 30 detik. Periksa koneksi, matikan VPN/ad-block, '
      'atau izinkan aplikasi ini di firewall/antivirus, lalu coba lagi.';

  const NetworkFailure([super.message = defaultMessage]);
}

class ServerFailure extends Failure {
  /// Pesan default generik — DIPENSIUNKAN untuk error Gemini baru.
  ///
  /// Jangan pakai konstruktor default ini untuk error hasil request AI;
  /// pakai [GeminiErrorMapper.map]/`mapAny` agar pesan asli server sampai
  /// ke user + tercatat di log. Default ini dipertahankan hanya untuk
  /// kompatibilitas test lama dan jalur non-AI.
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

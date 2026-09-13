import '../../../../core/errors/failures.dart';
import '../entities/verification_result.dart';
import '../repositories/verification_repository.dart';

/// Validasi klaim sebelum dikirim ke AI.
///
/// Batas disepakati: minimal 10 karakter agar konteks cukup, maksimal 2.000
/// karakter agar prompt tetap hemat kuota free tier.
class VerifyClaim {
  VerifyClaim(this._repository);

  final VerificationRepository _repository;

  static const int minLength = 10;
  static const int maxLength = 2000;

  Future<VerificationResult> call(String rawClaim) async {
    final claim = _normalize(rawClaim);
    if (claim.length < minLength) {
      throw const UnknownFailure(
        'Tulis informasi minimal 10 karakter agar AI memiliki konteks yang cukup.',
      );
    }
    if (claim.length > maxLength) {
      throw const UnknownFailure(
        'Informasi terlalu panjang. Batasi maksimal 2.000 karakter.',
      );
    }
    return _repository.verifyTextClaim(claim);
  }

  String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

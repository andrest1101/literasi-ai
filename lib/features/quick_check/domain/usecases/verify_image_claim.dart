import '../../../../core/errors/failures.dart';
import '../entities/image_attachment.dart';
import '../entities/verification_result.dart';
import '../repositories/verification_repository.dart';
import 'verify_claim.dart';

/// Validasi lampiran gambar sebelum dikirim ke AI.
///
/// Caption boleh kosong: AI membaca isi gambar terlebih dahulu. Bila caption
/// diisi, aturan panjang teks yang sama tetap berlaku agar hemat kuota.
class VerifyImageClaim {
  VerifyImageClaim(this._repository);

  final VerificationRepository _repository;

  Future<VerificationResult> call({
    required ImageAttachment image,
    String caption = '',
  }) async {
    if (image.isEmpty) {
      throw const UnknownFailure(
        'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.',
      );
    }
    if (!image.isSupportedMime) {
      throw const UnknownFailure(
        'Format gambar belum didukung. Pakai JPG, PNG, atau WebP.',
      );
    }
    if (!image.isWithinSizeLimit) {
      throw const UnknownFailure(
        'Ukuran gambar maksimal 5 MB. Kompres dulu lalu coba lagi.',
      );
    }
    final normalized = caption.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isNotEmpty) {
      if (normalized.length < VerifyClaim.minLength) {
        throw const UnknownFailure(
          'Caption minimal 10 karakter, atau kosongkan bila hanya mengandalkan gambar.',
        );
      }
      if (normalized.length > VerifyClaim.maxLength) {
        throw const UnknownFailure(
          'Caption terlalu panjang. Batasi maksimal 2.000 karakter.',
        );
      }
    }
    return _repository.verifyImageClaim(image: image, caption: normalized);
  }
}

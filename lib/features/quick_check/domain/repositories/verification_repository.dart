import '../entities/image_attachment.dart';
import '../entities/verification_result.dart';

/// Kontrak verifikasi klaim teks, gambar, dan link artikel.
abstract class VerificationRepository {
  Future<VerificationResult> verifyTextClaim(String claim);

  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  });

  Future<VerificationResult> verifyUrlClaim({required String url});
}

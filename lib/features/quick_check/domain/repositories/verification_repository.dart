import '../entities/image_attachment.dart';
import '../entities/verification_result.dart';

/// Kontrak verifikasi klaim teks dan gambar — diimplementasikan di data layer.
abstract class VerificationRepository {
  Future<VerificationResult> verifyTextClaim(String claim);

  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  });
}

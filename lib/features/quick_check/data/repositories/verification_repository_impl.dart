import '../../domain/entities/image_attachment.dart';
import '../../domain/entities/verification_result.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/gemini_text_datasource.dart';
import '../datasources/gemini_vision_datasource.dart';

/// Implementasi repository verifikasi klaim teks dan gambar.
///
/// Lapisan ini tipis: validasi ada di use case, parsing ada di datasource.
/// Mapping failure dilakukan di datasource agar pesan error tetap akurat.
class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl(
    this._textDatasource, {
    GeminiVisionDatasource? visionDatasource,
  }) : _visionDatasource = visionDatasource ?? GeminiVisionDatasource();

  final GeminiTextDatasource _textDatasource;
  final GeminiVisionDatasource _visionDatasource;

  @override
  Future<VerificationResult> verifyTextClaim(String claim) {
    return _textDatasource.verifyText(claim);
  }

  @override
  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  }) {
    return _visionDatasource.verifyImage(image: image, caption: caption);
  }
}

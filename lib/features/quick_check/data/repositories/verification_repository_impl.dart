import '../../../../core/utils/url_fetcher.dart';
import '../../domain/entities/image_attachment.dart';
import '../../domain/entities/verification_result.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/gemini_text_datasource.dart';
import '../datasources/gemini_vision_datasource.dart';

/// Implementasi repository verifikasi klaim teks, gambar, dan link artikel.
///
/// Lapisan ini tipis: validasi ada di use case, parsing ada di datasource.
/// Mapping failure dilakukan di datasource agar pesan error tetap akurat.
/// Untuk mode URL, repository mengorkestrasi [UrlFetcher] (ambil judul dan
/// deskripsi artikel) lalu [GeminiTextDatasource] (nilai klaimnya) — dua
/// langkah berurutan, bukan satu request gabungan.
class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl(
    this._textDatasource, {
    GeminiVisionDatasource? visionDatasource,
    UrlFetcher? urlFetcher,
  }) : _visionDatasource = visionDatasource ?? GeminiVisionDatasource(),
       _urlFetcher = urlFetcher ?? UrlFetcher();

  final GeminiTextDatasource _textDatasource;
  final GeminiVisionDatasource _visionDatasource;
  final UrlFetcher _urlFetcher;

  /// Batas deskripsi yang dikirim ke AI agar prompt hemat kuota free tier.
  static const int maxDescriptionChars = 500;

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

  @override
  Future<VerificationResult> verifyUrlClaim({required String url}) async {
    final metadata = await _urlFetcher.fetchMetadata(url);
    final parsed = await _textDatasource.verifyText(
      _buildUrlClaim(url: url, metadata: metadata),
    );
    final title = metadata.title.trim();
    return VerificationResult(
      claim: title.isEmpty ? url : title,
      verdict: parsed.verdict,
      confidence: parsed.confidence,
      explanation: parsed.explanation,
      suggestion: parsed.suggestion,
      checkedAt: parsed.checkedAt,
      source: VerificationSource.url,
      sourceUrl: url,
      sourceTitle: title.isEmpty ? null : title,
    );
  }

  /// Rakit klaim terstruktur dari metadata agar prompt generik teks tetap
  /// paham konteks: URL asli, judul, dan deskripsi terpotong.
  String _buildUrlClaim({required String url, required UrlMetadata metadata}) {
    final description = metadata.description.trim();
    final truncated = description.length > maxDescriptionChars
        ? '${description.substring(0, maxDescriptionChars)}…'
        : description;
    final buffer = StringBuffer()
      ..writeln('Verifikasi artikel pada link berikut:')
      ..writeln('URL: $url')
      ..writeln('Judul: ${metadata.title}');
    if (truncated.isNotEmpty) {
      buffer.writeln('Deskripsi: $truncated');
    }
    buffer.writeln(
      'Nilai klaim utama artikel tersebut dari judul dan deskripsi di atas.',
    );
    return buffer.toString();
  }
}

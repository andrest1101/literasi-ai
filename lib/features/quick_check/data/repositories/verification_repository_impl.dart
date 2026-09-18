import '../../../../core/errors/failures.dart';
import '../../../../core/utils/url_fetcher.dart';
import '../../domain/entities/image_attachment.dart';
import '../../domain/entities/verification_result.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/demo_verification_datasource.dart';
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
    DemoVerificationDatasource? demoDatasource,
    String Function()? resolveApiKey,
    bool Function()? hasApiKey,
  }) : _visionDatasource = visionDatasource ?? GeminiVisionDatasource(),
       _urlFetcher = urlFetcher ?? UrlFetcher(),
       _demoDatasource = demoDatasource ?? DemoVerificationDatasource(),
       _resolveApiKey = resolveApiKey ?? (() => _compileKey),
       _hasApiKey = hasApiKey ?? (() => _defaultHasKey(resolveApiKey));

  static bool _defaultHasKey(String Function()? resolve) =>
      (resolve?.call() ?? _compileKey).isNotEmpty;

  static const String _compileKey = String.fromEnvironment('GEMINI_API_KEY');

  final GeminiTextDatasource _textDatasource;
  final GeminiVisionDatasource _visionDatasource;
  final UrlFetcher _urlFetcher;
  final DemoVerificationDatasource _demoDatasource;
  final String Function() _resolveApiKey;
  final bool Function() _hasApiKey;

  /// Batas deskripsi yang dikirim ke AI agar prompt hemat kuota free tier.
  static const int maxDescriptionChars = 500;

  bool get _demoMode => !_hasApiKey();

  @override
  Future<VerificationResult> verifyTextClaim(String claim) {
    if (_demoMode) return Future.value(_demoDatasource.verifyText(claim));
    return _textDatasource.verifyTextWithKey(claim, _resolveApiKey());
  }

  @override
  Future<VerificationResult> verifyImageClaim({
    required ImageAttachment image,
    String caption = '',
  }) {
    if (_demoMode) {
      return Future.value(
        _demoDatasource.verifyImage(
          fileName: image.fileName,
          caption: caption,
        ),
      );
    }
    return _visionDatasource.verifyImageWithKey(
      image: image,
      caption: caption,
      apiKey: _resolveApiKey(),
    );
  }

  @override
  Future<VerificationResult> verifyUrlClaim({required String url}) async {
    if (_demoMode) {
      var title = '';
      try {
        title = (await _urlFetcher.fetchMetadata(url)).title.trim();
      } on Failure {
        rethrow;
      } catch (_) {
        title = '';
      }
      return _demoDatasource.verifyUrl(url: url, title: title);
    }
    final metadata = await _urlFetcher.fetchMetadata(url);
    final parsed = await _textDatasource.verifyTextWithKey(
      _buildUrlClaim(url: url, metadata: metadata),
      _resolveApiKey(),
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

import 'dart:async';

import 'package:http/http.dart' as http;

import '../errors/failures.dart';

/// Metadata minimal hasil fetch URL (PRD §6.1: Quick Check mode URL).
class UrlMetadata {
  const UrlMetadata({required this.title, required this.description});

  final String title;
  final String description;
}

/// Fetch judul + deskripsi artikel via `http` untuk dikirim ke Gemini.
/// Timeout 10 detik → [NetworkFailure] ("Koneksi lambat, coba lagi").
class UrlFetcher {
  UrlFetcher({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final RegExp _titleExp = RegExp(
    r'<title[^>]*>(.*?)</title>',
    caseSensitive: false,
    dotAll: true,
  );
  static final RegExp _descExp = RegExp(
    '<meta[^>]+name="description"[^>]+content="([^"]*)"',
    caseSensitive: false,
  );
  static final RegExp _descExpAlt = RegExp(
    '<meta[^>]+content="([^"]*)"[^>]+name="description"',
    caseSensitive: false,
  );
  static final RegExp _ogTitleExp = RegExp(
    '<meta[^>]+property="og:title"[^>]+content="([^"]*)"',
    caseSensitive: false,
  );
  static final RegExp _ogTitleExpAlt = RegExp(
    '<meta[^>]+content="([^"]*)"[^>]+property="og:title"',
    caseSensitive: false,
  );
  static final RegExp _ogDescExp = RegExp(
    '<meta[^>]+property="og:description"[^>]+content="([^"]*)"',
    caseSensitive: false,
  );
  static final RegExp _ogDescExpAlt = RegExp(
    '<meta[^>]+content="([^"]*)"[^>]+property="og:description"',
    caseSensitive: false,
  );

  /// Batas body HTML yang diproses: cegah halaman raksasa memakan memori
  /// sebelum regex berjalan (potong 512 KB dari awal dokumen).
  static const int maxBodyChars = 512 * 1024;

  Future<UrlMetadata> fetchMetadata(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw const UnknownFailure('Link tidak valid, periksa kembali URL.');
    }
    try {
      final response = await _client
          .get(uri, headers: {
            'Accept': 'text/html',
            'User-Agent': 'LiterasiAI/1.0 (+fact-check)',
          })
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw NetworkFailure(
          'Gagal memuat link (HTTP ${response.statusCode}).',
        );
      }
      var body = response.body;
      if (body.length > maxBodyChars) {
        body = body.substring(0, maxBodyChars);
      }
      final title =
          _clean(
            _ogTitleExp.firstMatch(body)?.group(1) ??
                _ogTitleExpAlt.firstMatch(body)?.group(1) ??
                _titleExp.firstMatch(body)?.group(1) ??
                '',
          );
      final description = _clean(
        _descExp.firstMatch(body)?.group(1) ??
            _descExpAlt.firstMatch(body)?.group(1) ??
            _ogDescExp.firstMatch(body)?.group(1) ??
            _ogDescExpAlt.firstMatch(body)?.group(1) ??
            '',
      );
      return UrlMetadata(
        title: title.isEmpty ? uri.host : title,
        description: description,
      );
    } on TimeoutException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  /// Normalisasi teks metadata: hilangkan entity umum + rapikan whitespace.
  static String _clean(String raw) {
    return raw
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

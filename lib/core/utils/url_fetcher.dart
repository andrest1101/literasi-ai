import 'dart:async';

import 'package:http/http.dart' as http;

import '../errors/failures.dart';

/// Metadata minimal hasil fetch URL (PRD §6.1 — Quick Check mode URL).
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

  Future<UrlMetadata> fetchMetadata(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw const UnknownFailure('Link tidak valid, periksa kembali URL.');
    }
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'text/html'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw NetworkFailure(
          'Gagal memuat link (HTTP ${response.statusCode}).',
        );
      }
      final body = response.body;
      final title = _titleExp.firstMatch(body)?.group(1)?.trim() ?? uri.host;
      final description =
          _descExp.firstMatch(body)?.group(1)?.trim() ??
          _descExpAlt.firstMatch(body)?.group(1)?.trim() ??
          '';
      return UrlMetadata(title: title, description: description);
    } on TimeoutException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }
  }
}

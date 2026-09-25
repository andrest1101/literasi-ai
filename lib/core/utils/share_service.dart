import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../../features/quick_check/domain/entities/verification_result.dart';

/// Layanan share hasil verifikasi sebagai gambar (PRD §4.1 Feature 4).
///
/// Alur: [capture] gambar dari [ShareCard] via `screenshot`
/// `captureFromWidget` (tanpa perlu widget tampil di layar), lalu kirim ke
/// WhatsApp/aplikasi lain via `SharePlus.instance.share` sebagai file PNG.
/// Bila capture gagal, panggil [shareTextFallback] agar demo tidak buntu.
class ShareService {
  ShareService({Future<ShareResult> Function(ShareParams params)? shareFn})
    : _shareFn = shareFn ?? SharePlus.instance.share;

  final Future<ShareResult> Function(ShareParams params) _shareFn;

  static const String fileName = 'literasi-ai-hasil.png';
  static const String mimeType = 'image/png';

  /// Susun teks ringkas pendamping gambar: murni Dart agar unit-testable.
  static String buildShareText(VerificationResult result) {
    final buffer = StringBuffer()
      ..writeln('Hasil cek LiterasiAI: ${result.verdict.label}')
      ..writeln('Keyakinan AI: ${result.confidence}%')
      ..writeln('Informasi: ${_truncate(result.claim, 180)}')
      ..write('Cek sendiri di LiterasiAI. Hasil AI bukan kebenaran mutlak.');
    return buffer.toString();
  }

  /// Kirim gambar PNG + teks pendamping ke share sheet sistem.
  Future<ShareResult> shareImage({
    required Uint8List imageBytes,
    required String text,
  }) {
    if (imageBytes.isEmpty) {
      throw ArgumentError('imageBytes tidak boleh kosong.');
    }
    return _shareFn(
      ShareParams(
        files: [
          XFile.fromData(
            imageBytes,
            name: fileName,
            mimeType: mimeType,
          ),
        ],
        text: text,
        subject: 'Hasil verifikasi LiterasiAI',
      ),
    );
  }

  /// Fallback teks bila capture gambar gagal.
  Future<ShareResult> shareTextFallback(VerificationResult result) {
    return _shareFn(
      ShareParams(
        text: buildShareText(result),
        subject: 'Hasil verifikasi LiterasiAI',
      ),
    );
  }

  static String _truncate(String text, int max) {
    final normalized = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= max) return normalized;
    return '${normalized.substring(0, max)}…';
  }
}

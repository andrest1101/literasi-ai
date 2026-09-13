import 'dart:typed_data';

/// Lampiran gambar untuk verifikasi visual — domain murni, tanpa Flutter.
///
/// Batas disepakati tahap 1: JPG/PNG/WebP, maksimal 5 MB, satu gambar per sesi.
class ImageAttachment {
  const ImageAttachment({
    required this.bytes,
    required this.mimeType,
    required this.fileName,
  });

  /// Batas ukuran 5 MB agar hemat kuota free tier dan aman dikirim ke AI.
  static const int maxBytes = 5 * 1024 * 1024;

  static const Set<String> allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  final Uint8List bytes;
  final String mimeType;
  final String fileName;

  int get sizeBytes => bytes.length;

  bool get isEmpty => bytes.isEmpty;

  bool get isSupportedMime => allowedMimeTypes.contains(mimeType.toLowerCase());

  bool get isWithinSizeLimit => sizeBytes <= maxBytes;

  bool get isValid => !isEmpty && isSupportedMime && isWithinSizeLimit;

  String get formattedSize {
    const kb = 1024;
    const mb = 1024 * 1024;
    if (sizeBytes >= mb) {
      return '${(sizeBytes / mb).toStringAsFixed(1)} MB';
    }
    if (sizeBytes >= kb) {
      return '${(sizeBytes / kb).toStringAsFixed(0)} KB';
    }
    return '$sizeBytes B';
  }
}

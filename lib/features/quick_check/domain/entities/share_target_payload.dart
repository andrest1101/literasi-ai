import 'dart:typed_data';

/// Payload yang dikirim Android Share Target ke Flutter.
///
/// Payload ini adalah hasil parsing native (`MainActivity`) dan sengaja
/// immutable: setelah diterima, payload hanya diteruskan ke Quick Check,
/// tidak dimodifikasi. Parsing URL tetap dilakukan di lapisan Dart agar
/// validasi sama dengan input manual.
class ShareTargetPayload {
  const ShareTargetPayload({
    required this.id,
    this.text,
    this.imageBytes,
    this.fileName,
    this.mimeType,
    this.errorCode,
  });

  /// Id monoton dari native: berguna untuk diagnostik dan deduplikasi.
  final int id;
  final String? text;
  final Uint8List? imageBytes;
  final String? fileName;
  final String? mimeType;

  /// Kode error stabil dari native/service. `null` berarti payload sah.
  final String? errorCode;

  bool get isImage => imageBytes != null && imageBytes!.isNotEmpty;
  bool get isText => text != null && text!.trim().isNotEmpty;
  bool get hasError => errorCode != null;

  factory ShareTargetPayload.fromMap(Map<Object?, Object?> map) {
    final id = map['id'];
    final bytes = map['imageBytes'];
    final error = map['error'];

    return ShareTargetPayload(
      id: id is int ? id : DateTime.now().millisecondsSinceEpoch,
      text: map['text'] as String?,
      imageBytes: bytes is Uint8List ? bytes : null,
      fileName: map['fileName'] as String?,
      mimeType: map['mimeType'] as String?,
      errorCode: error is String ? error : null,
    );
  }
}

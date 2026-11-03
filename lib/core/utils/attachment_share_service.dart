import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Layanan share file/lampiran untuk kebutuhan pratinjau.
///
/// Berbeda dengan [ShareService] yang mengirim gambar kartu hasil AI,
/// layanan ini mengirim bytes lampiran asli pengguna beserta nama dan
/// MIME type aslinya. Tidak ada galeri/izin tambahan yang dibutuhkan;
/// perangkat menentukan target pembagiannya.
class AttachmentShareService {
  AttachmentShareService({
    Future<ShareResult> Function(ShareParams params)? shareFn,
  }) : _shareFn = shareFn ?? SharePlus.instance.share;

  final Future<ShareResult> Function(ShareParams params) _shareFn;

  /// Kirim lampiran gambar ke share sheet sistem.
  ///
  /// Melempar [ArgumentError] bila bytes kosong: service tetap bersih dan
  /// pemanggil dapat menampilkan pesan tanpa menyentuh share sheet.
  Future<ShareResult> shareAttachment({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) {
    if (bytes.isEmpty) {
      throw ArgumentError('bytes tidak boleh kosong.');
    }
    final normalizedName = fileName.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('fileName tidak boleh kosong.');
    }
    final normalizedMime = mimeType.trim().toLowerCase();
    if (normalizedMime.isEmpty || !normalizedMime.startsWith('image/')) {
      throw ArgumentError('mimeType harus image/*.');
    }

    // `path` tidak dirujuk untuk membaca file, tetapi di IO XFile menurunkan
    // `name` dari path. Karakter path dibersihkan agar nama terlihat benar.
    final safeFileName = _safeFileName(normalizedName);

    return _shareFn(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            name: safeFileName,
            path: safeFileName,
            mimeType: normalizedMime,
          ),
        ],
        subject: safeFileName,
      ),
    );
  }

  static String _safeFileName(String name) {
    // Windows melarang karakter berikut; backslash/slash dibuang agar nama
    // tidak memuat direktori. Ekstensi tetap dipertahankan.
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }
}

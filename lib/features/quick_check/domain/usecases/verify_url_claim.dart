import '../../../../core/errors/failures.dart';
import '../entities/verification_result.dart';
import '../repositories/verification_repository.dart';

/// Validasi link artikel sebelum diambil metadatanya dan dikirim ke AI.
///
/// Aturan: wajib skema http/https, wajib punya authority (host), tanpa spasi
/// internal, dan panjang total dalam batas hemat kuota seperti mode teks.
/// Fetch metadata dan error jaringan ditangani di data layer.
class VerifyUrlClaim {
  VerifyUrlClaim(this._repository);

  final VerificationRepository _repository;

  static const int minLength = 12;
  static const int maxLength = 2000;

  static const Set<String> allowedSchemes = {'http', 'https'};

  /// Normalisasi URL mentah: trim + hapus semua whitespace internal.
  static String normalize(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), '');
  }

  /// Validasi cepat untuk UI (tombol aktif + pratinjau host): tanpa throw.
  /// Validasi penuh dengan pesan error tetap di [call].
  static bool isParsable(String raw) {
    final url = normalize(raw);
    if (url.length < minLength || url.length > maxLength) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        allowedSchemes.contains(uri.scheme.toLowerCase()) &&
        uri.hasAuthority;
  }

  Future<VerificationResult> call(String rawUrl) async {
    final url = normalize(rawUrl);
    if (url.length < minLength) {
      throw const UnknownFailure(
        'Tempel link artikel yang valid agar AI bisa memuat isinya.',
      );
    }
    if (url.length > maxLength) {
      throw const UnknownFailure(
        'Link terlalu panjang. Batasi maksimal 2.000 karakter.',
      );
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !allowedSchemes.contains(uri.scheme.toLowerCase()) ||
        !uri.hasAuthority) {
      throw const UnknownFailure(
        'Link tidak valid. Pakai link http(s), contoh: https://contoh.id/berita.',
      );
    }
    return _repository.verifyUrlClaim(url: url);
  }
}

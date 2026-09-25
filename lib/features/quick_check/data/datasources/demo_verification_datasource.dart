import '../../domain/entities/verification_result.dart';

/// Datasource demo offline: heuristik transparan, bukan AI.
///
/// Dipakai saat tidak ada kunci API sama sekali. Hasil SELALU verdict
/// `TIDAK_DAPAT_DIPASTIKAN` dengan confidence 0 dan penjelasan yang jujur
/// menyebut mode demo + langkah menuju hasil live. Tidak pernah mengarang
/// verdict HOAKS/VALID agar tidak menyesatkan pengguna.
class DemoVerificationDatasource {
  VerificationResult verifyText(String claim) {
    return VerificationResult.uncertain(
      claim,
      isDemo: true,
      explanation:
          'Mode demo tanpa kunci API: klaim tidak dikirim ke AI. '
          'Tempel kunci API di Pengaturan atau jalankan dengan dart-define untuk hasil live.',
      suggestion:
          'Buka Pengaturan untuk menempel kunci API, atau bandingkan klaim ini di TurnBackHoax dan media arus utama.',
    );
  }

  VerificationResult verifyImage({
    required String fileName,
    String caption = '',
  }) {
    final claim = caption.isEmpty ? 'Gambar: $fileName' : caption;
    return VerificationResult.uncertain(
      claim,
      isDemo: true,
      explanation:
          'Mode demo tanpa kunci API: gambar tidak dikirim ke AI. '
          'Tempel kunci API di Pengaturan untuk analisis gambar live.',
      suggestion:
          'Periksa gambar secara manual: cari sumber asli via pencarian gambar terbalik sebelum menyebarkan.',
      imageFileName: fileName,
      source: VerificationSource.image,
    );
  }

  VerificationResult verifyUrl({
    required String url,
    String? title,
  }) {
    return VerificationResult.uncertain(
      title?.isNotEmpty == true ? title! : url,
      isDemo: true,
      explanation:
          'Mode demo tanpa kunci API: link tidak dimuat ke AI. '
          'Tempel kunci API di Pengaturan untuk verifikasi link live.',
      suggestion:
          'Buka link langsung dan periksa domain, tanggal, serta penulisnya sebelum mempercayai isinya.',
      source: VerificationSource.url,
      sourceUrl: url,
      sourceTitle: title,
    );
  }
}

import '../../../quick_check/domain/entities/verification_result.dart';
import '../../domain/entities/trending_item.dart';

/// Feed curated 7 hoaks Indonesia: statis lokal, tanpa network.
///
/// Ditulis sebagai ringkasan jurnalistik nyata: judul natural, kategori,
/// tanggal cek, dan rujukan verifikasi. Tanpa login, tanpa API key, tanpa
/// Firebase: guest offline tetap melihat feed penuh.
class TrendingLocalDatasource {
  /// Paket konten offline v1.1, dikurasi Oktober 2026.
  /// Bukan feed live: tanggal per item sengaja dilepas agar tidak basi,
  /// penilaian redaksi ditandai jujur di UI sebagai kurasi offline.
  static const String packVersion = 'v1.1';
  static final DateTime packUpdatedAt = DateTime(2026, 10, 6);

  // Non-const karena DateTime bukan constant expression.
  List<TrendingItem> items() => [
    TrendingItem(
      id: 'bantuan-tunai-berantai',
      title: 'Pesan bantuan tunai Rp5 juta yang minta data rekening',
      summary:
          'Pesan berantai menjanjikan bantuan cair hari ini asal mengisi data rekening lewat tautan. Pola tautan asing, urgensi, dan permintaan data pribadi adalah ciri khas penipuan bansos.',
      verdict: Verdict.hoaks,
      confidence: 93,
      category: 'Penipuan',
      isHot: true,
      checkedAt: packUpdatedAt,
      reference: 'TurnBackHoax',
      referenceUrl: 'https://turnbackhoax.id/',
    ),
    TrendingItem(
      id: 'libur-nasional-tambahan',
      title: 'Broadcast libur nasional tambahan tanpa surat resmi',
      summary:
          'Pesan viral menyebut ada libur tambahan tanpa melampirkan keputusan resmi. Hari libur nasional hanya sah bila diumumkan pemerintah melalui keputusan resmi.',
      verdict: Verdict.perluDicek,
      confidence: 71,
      category: 'Kebijakan',
      isHot: true,
      checkedAt: packUpdatedAt,
      reference: 'Setkab RI',
      referenceUrl: 'https://setkab.go.id/',
    ),
    TrendingItem(
      id: 'air-rebusan-sembuh-total',
      title: 'Rebusan daun kelor diklaim bersihkan paru-paru',
      summary:
          'Unggahan menyebut rebusan daun kelor bisa membersihkan paru-paru dari racun dan polusi. Belum ada bukti klinis yang mendukung klaim penyembuhan total tersebut.',
      verdict: Verdict.hoaks,
      confidence: 91,
      category: 'Kesehatan',
      isHot: true,
      checkedAt: packUpdatedAt,
      reference: 'Kemenkes RI',
      referenceUrl: 'https://kemkes.go.id/hoaks-kesehatan',
    ),
    TrendingItem(
      id: 'undian-telepon-seluler',
      title: 'SMS undian berhadiah yang minta transfer pajak kemenangan',
      summary:
          'SMS dari nomor tak dikenal mengaku pemenang undian, lalu meminta pajak kemenangan ditransfer dulu. Penyelenggara resmi tidak memungut biaya lewat nomor pribadi.',
      verdict: Verdict.hoaks,
      confidence: 95,
      category: 'Penipuan',
      isHot: false,
      checkedAt: packUpdatedAt,
      reference: 'TurnBackHoax',
      referenceUrl: 'https://turnbackhoax.id/',
    ),
    TrendingItem(
      id: 'foto-banjir-daur-ulang',
      title: 'Foto banjir lama disebar ulang sebagai kejadian kemarin',
      summary:
          'Foto yang sama pernah muncul pada peristiwa tahun-tahun sebelumnya, lalu disebar ulang dengan narasi baru. Pencarian gambar terbalik bisa menemukan sumber aslinya.',
      verdict: Verdict.perluDicek,
      confidence: 78,
      category: 'Visual',
      isHot: false,
      checkedAt: packUpdatedAt,
      reference: 'Cek Fakta Tempo',
      referenceUrl: 'https://cekfakta.tempo.co/',
    ),
    TrendingItem(
      id: 'vaksin-autisme',
      title: 'Klaim lama vaksin menyebabkan autisme pada anak',
      summary:
          'Klaim ini sudah dibantah banyak studi besar dan konsensus medis dunia. Bila ragu soal jadwal imunisasi, konsultasikan langsung ke dokter anak atau puskesmas.',
      verdict: Verdict.hoaks,
      confidence: 94,
      category: 'Kesehatan',
      isHot: false,
      checkedAt: packUpdatedAt,
      reference: 'WHO Indonesia',
      referenceUrl: 'https://www.who.int/indonesia',
    ),
    TrendingItem(
      id: 'lowongan-kerja-palsu',
      title: 'Lowongan gaji besar tanpa seleksi yang minta biaya di awal',
      summary:
          'Tawaran kerja instan meminta biaya pendaftaran atau data KTP di awal percakapan. Rekrutmen resmi selalu lewat kanal perusahaan dan tidak memungut biaya pendaftaran.',
      verdict: Verdict.perluDicek,
      confidence: 74,
      category: 'Penipuan',
      isHot: false,
      checkedAt: packUpdatedAt,
      reference: 'Kemnaker RI',
      referenceUrl: 'https://kemnaker.go.id/',
    ),
  ];
}

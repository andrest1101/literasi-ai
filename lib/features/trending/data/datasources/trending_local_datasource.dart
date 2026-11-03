import '../../../quick_check/domain/entities/verification_result.dart';
import '../../domain/entities/trending_item.dart';

/// Feed curated 7 hoaks Indonesia: statis lokal, tanpa network.
///
/// Ditulis sebagai ringkasan jurnalistik nyata: judul natural, kategori,
/// tanggal cek, dan rujukan verifikasi. Tanpa login, tanpa API key, tanpa
/// Firebase: guest offline tetap melihat feed penuh.
class TrendingLocalDatasource {
  /// Paket konten offline v1.2, dikurasi Oktober 2026.
  /// Bukan feed live: tanggal per item sengaja dilepas agar tidak basi,
  /// penilaian redaksi ditandai jujur di UI sebagai kurasi offline.
  static const String packVersion = 'v1.2';
  static final DateTime packUpdatedAt = DateTime(2026, 10, 6);

  // Non-const karena DateTime bukan constant expression.
  List<TrendingItem> items() => [
    TrendingItem(
      id: 'bantuan-tunai-berantai',
      title: 'Bantuan tunai Rp5 juta minta data rekening',
      summary:
          'Pesan ini menjanjikan bantuan yang katanya cair hari ini. Tapi link mencurigakan dan permintaan data rekening adalah ciri penipuan bansos.',
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
      title: 'Libur nasional tambahan tanpa pengumuman resmi',
      summary:
          'Pesan heboh soal libur tambahan, tapi belum ada surat atau pengumuman resmi. Hari libur tidak muncul hanya karena pesan grup.',
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
      title: 'Daun kelor diklaim bisa bersihkan paru-paru',
      summary:
          'Banyak unggahan bilang kelor bisa bersihkan paru-paru. Belum ada penelitian yang membuktikan klaim ini atau soal menyembuhkan semua penyakit.',
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
      title: 'Undian palsu minta bayar pajak hadiah dulu',
      summary:
          'SMS ini minta kamu bayar pajak dulu sebelum hadiahnya cair. Hadiah resmi tidak pernah minta transfer ke nomor pribadi.',
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
      title: 'Foto banjir lama dipakai untuk cerita banjir baru',
      summary:
          'Foto lama disebar dengan cerita seolah-olah itu kejadian baru. Coba cari gambarnya; sumber aslinya biasanya langsung muncul.',
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
      title: 'Klaim vaksin sebabkan autisme masih beredar',
      summary:
          'Klaim ini sudah dibantah banyak penelitian besar dan dokter anak. Kalau ragu soal jadwal imunisasi, tanya puskesmas atau dokter yang merawat.',
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
      title: 'Loker gaji besar minta biaya daftar dulu',
      summary:
          'Lowongan ini minta biaya pendaftaran atau data KTP di awal. Perusahaan resmi tidak memungut biaya pendaftaran.',
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

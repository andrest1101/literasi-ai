import '../../../quick_check/domain/entities/verification_result.dart';
import '../../domain/entities/trending_item.dart';

/// Feed curated 7 hoaks Indonesia: statis lokal, tanpa network.
///
/// Ditulis sebagai ringkasan jurnalistik nyata: judul natural, kategori,
/// tanggal cek, dan rujukan verifikasi. Tanpa login, tanpa API key, tanpa
/// Firebase: guest offline tetap melihat feed penuh.
class TrendingLocalDatasource {
  // Non-const karena DateTime bukan constant expression.
  List<TrendingItem> items() => [
    TrendingItem(
      id: 'bantuan-tunai-berantai',
      title: 'Pesan bantuan tunai Rp 5 juta minta data rekening',
      summary:
          'Pesan berantai mengklaim bantuan tunai cair hari ini bila mengisi data rekening lewat link. Pola link + urgensi + data pribadi adalah ciri penipuan bantuan sosial.',
      verdict: Verdict.hoaks,
      confidence: 93,
      category: 'Penipuan',
      isHot: true,
      checkedAt: DateTime(2026, 9, 20),
      reference: 'TurnBackHoax',
    ),
    TrendingItem(
      id: 'libur-nasional-tambahan',
      title: 'Viral kabar libur nasional tambahan minggu ini',
      summary:
          'Broadcast menyebut ada libur tambahan tanpa surat keputusan resmi. Kalender libur nasional hanya sah bila diumumkan pemerintah lewat Keppres atau SKB menteri.',
      verdict: Verdict.perluDicek,
      confidence: 71,
      category: 'Kebijakan',
      isHot: true,
      checkedAt: DateTime(2026, 9, 19),
      reference: 'Setkab RI',
    ),
    TrendingItem(
      id: 'air-rebusan-sembuh-total',
      title: 'Air rebusan daun disebut sembuhkan semua penyakit',
      summary:
          'Klaim menyembuhkan semua penyakit tanpa dosis, uji klinis, atau sumber medis. Klaim kesehatan absolut tanpa bukti adalah bendera merah klasik hoaks kesehatan.',
      verdict: Verdict.hoaks,
      confidence: 91,
      category: 'Kesehatan',
      isHot: true,
      checkedAt: DateTime(2026, 9, 18),
      reference: 'Kemenkes RI',
    ),
    TrendingItem(
      id: 'undian-telepon-seluler',
      title: 'Undian berhadiah telepon seluler dari nomor tak dikenal',
      summary:
          'SMS undian meminta pajak kemenangan ditransfer dulu. Penyelenggara undian resmi tidak memungut biaya di muka lewat nomor pribadi.',
      verdict: Verdict.hoaks,
      confidence: 95,
      category: 'Penipuan',
      isHot: false,
      checkedAt: DateTime(2026, 9, 17),
      reference: 'TurnBackHoax',
    ),
    TrendingItem(
      id: 'foto-banjir-daur-ulang',
      title: 'Foto banjir lama disebar sebagai banjir kemarin',
      summary:
          'Foto yang sama pernah muncul di peristiwa 2019 dan disebar ulang dengan narasi baru. Pencarian gambar terbalik menemukan sumber aslinya dalam hitungan detik.',
      verdict: Verdict.perluDicek,
      confidence: 78,
      category: 'Visual',
      isHot: false,
      checkedAt: DateTime(2026, 9, 16),
      reference: 'Cek Fakta Media',
    ),
    TrendingItem(
      id: 'vaksin-autisme',
      title: 'Vaksin disebut sebabkan autisme pada anak',
      summary:
          'Klaim lama yang sudah dibantah banyak studi besar. Konsensus medis: tidak ada kaitan vaksin dan autisme. Khawatir soal jadwal imunisasi, konsultasikan ke dokter anak.',
      verdict: Verdict.hoaks,
      confidence: 94,
      category: 'Kesehatan',
      isHot: false,
      checkedAt: DateTime(2026, 9, 15),
      reference: 'WHO Indonesia',
    ),
    TrendingItem(
      id: 'lowongan-kerja-palsu',
      title: 'Lowongan kerja gaji besar tanpa seleksi via chat',
      summary:
          'Tawaran kerja instan meminta biaya administrasi atau data KTP di awal. Rekrutmen resmi selalu lewat kanal perusahaan dan tidak memungut biaya pendaftaran.',
      verdict: Verdict.perluDicek,
      confidence: 74,
      category: 'Penipuan',
      isHot: false,
      checkedAt: DateTime(2026, 9, 14),
      reference: 'Disnaker',
    ),
  ];
}

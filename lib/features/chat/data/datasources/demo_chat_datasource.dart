/// Jawaban demo offline Chat — edukatif dan jujur, bukan AI.
///
/// Dipakai saat tidak ada kunci API. Tidak menjawab isi pertanyaan secara
/// spesifik (agar tidak mengarang), melainkan memberi kerangka berpikir
/// kritis + arahan ke Quick Check dan sumber resmi.
class DemoChatDatasource {
  String reply(String message) {
    final lower = message.toLowerCase();
    final topic = _detectTopic(lower);
    return 'Mode demo tanpa kunci API, jadi aku belum bisa menjawab spesifik. '
        'Untuk $topic, coba kerangka ini: siapa yang mengklaim, apa buktinya, '
        'kapan dan di mana diterbitkan, lalu bandingkan dengan TurnBackHoax atau '
        'media arus utama. Tempel klaimnya lewat tombol Verifikasi ini atau tab '
        'Cek setelah kunci API tersambung untuk hasil live.';
  }

  String _detectTopic(String lower) {
    if (lower.contains('vaksin') ||
        lower.contains('obat') ||
        lower.contains('penyakit') ||
        lower.contains('kesehatan')) {
      return 'klaim kesehatan';
    }
    if (lower.contains('clickbait') || lower.contains('judul')) {
      return 'judul yang mencurigakan';
    }
    if (lower.contains('gambar') ||
        lower.contains('foto') ||
        lower.contains('video')) {
      return 'konten visual yang viral';
    }
    if (lower.contains('link') ||
        lower.contains('berita') ||
        lower.contains('artikel') ||
        lower.contains('sumber')) {
      return 'sumber berita';
    }
    if (lower.contains('bantuan') ||
        lower.contains('undian') ||
        lower.contains('hadiah') ||
        lower.contains('pinjam')) {
      return 'pesan berantai Hadiah atau bantuan';
    }
    return 'informasi yang kamu tanyakan';
  }
}

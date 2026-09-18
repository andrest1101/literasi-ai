import '../../domain/entities/course_module.dart';
import '../../domain/entities/quiz_question.dart';

/// Konten 3 modul PRD §4.2 — statis lokal Bahasa Indonesia.
///
/// Ditulis sebagai materi edukasi nyata (bukan lorem ipsum): tiap modul 4
/// seksi artikel + 3 soal kuis dengan penjelasan. Tanpa network agar bisa
/// dibaca offline oleh guest sekalipun.
class LearnContentDatasource {
  List<CourseModule> modules() => const [_clickbait, _manipulatedImage, _verifySource];

  CourseModule? byId(String id) {
    for (final module in modules()) {
      if (module.id == id) return module;
    }
    return null;
  }
}

const _clickbait = CourseModule(
  id: 'clickbait',
  title: 'Kenali Judul Clickbait',
  subtitle: 'Bedakan judul provokatif dan informasi sungguhan.',
  minutes: 5,
  accentSeed: 0,
  sections: [
    CourseSection(
      heading: 'Ciri judul clickbait',
      body:
          'Judul clickbait memakai huruf kapital berlebihan, kata seperti HEBOH atau VIRAL, dan janji yang terlalu muluk. Tujuannya satu: membuatmu mengklik sebelum berpikir. Judul berita sungguhan justru tenang, spesifik, dan bisa diverifikasi isinya.',
    ),
    CourseSection(
      heading: 'Uji 3 detik sebelum klik',
      body:
          'Tanyakan tiga hal: siapa penerbitnya, kapan diterbitkan, dan apakah judul didukung isi. Kalau salah satunya tidak jelas, jangan sebarkan dulu. Buka artikelnya dan baca minimal dua paragraf pertama sebelum menilai.',
    ),
    CourseSection(
      heading: 'Jebakan emosi',
      body:
          'Hoaks clickbait menyerang emosi: takut, marah, atau penasaran berlebihan. Pesan berantai yang diawali Ancaman atau Kabar gembira biasanya memakai pola ini. Emosi yang meledak adalah sinyal untuk berhenti dan memeriksa, bukan meneruskan.',
    ),
    CourseSection(
      heading: 'Latihan mandiri',
      body:
          'Ambil tiga judul viral minggu ini. Tandai mana yang clickbait dan tulis alasannya dalam satu kalimat. Bandingkan dengan teman atau cek lewat tab Cek di aplikasi ini untuk melatih instingmu.',
    ),
  ],
  quiz: [
    QuizQuestion(
      question: 'Manakah yang paling mirip judul clickbait?',
      options: [
        'HEBOH! Minum ini sembuh total dalam semalam, sebarkan!',
        'Studi 2024: konsumsi gula berlebih terkait risiko diabetes',
        'BMKG: prakiraan cuaca Jawa Barat 12 Mei 2026',
        'TurnBackHoax: klarifikasi pesan bantuan tunai berantai',
      ],
      correctIndex: 0,
      explanation:
          'Huruf kapital, klaim instan, dan ajakan menyebar adalah tiga ciri clickbait sekaligus. Judul lain tenang dan terverifikasi.',
    ),
    QuizQuestion(
      question: 'Langkah pertama saat melihat judul mencurigakan?',
      options: [
        'Langsung teruskan ke grup keluarga',
        'Periksa penerbit, tanggal, dan isi artikel',
        'Komentari bahwa itu hoaks tanpa membaca',
        'Cari judul yang lebih sensasional',
      ],
      correctIndex: 1,
      explanation:
          'Verifikasi selalu mulai dari sumber, waktu, dan isi. Tiga cek cepat ini menyaring sebagian besar hoaks.',
    ),
    QuizQuestion(
      question: 'Kenapa emosi meledak jadi sinyal bahaya?',
      options: [
        'Karena emosi membuat kuota internet habis',
        'Karena hoaks dirancang memicu reaksi sebelum berpikir',
        'Karena berita baik selalu hoaks',
        'Karena emosi merusak ponsel',
      ],
      correctIndex: 1,
      explanation:
          'Penyebar hoaks mengeksploitasi takut, marah, dan penasaran agar korban mengklik dan menyebar tanpa verifikasi.',
    ),
  ],
);

const _manipulatedImage = CourseModule(
  id: 'gambar-manipulasi',
  title: 'Ciri Gambar Manipulasi',
  subtitle: 'Deteksi foto editan dan konteks yang dipelintir.',
  minutes: 5,
  accentSeed: 1,
  sections: [
    CourseSection(
      heading: 'Edit vs konteks palsu',
      body:
          'Ada dua jenis: gambar yang diedit (crop, filter, tempelan) dan gambar asli dengan konteks palsu (foto lama diberi narasi baru). Jenis kedua lebih sering lolos karena gambarnya memang nyata, hanya ceritanya yang bohong.',
    ),
    CourseSection(
      heading: 'Periksa tepi dan cahaya',
      body:
          'Perbesar gambar dan perhatikan tepi objek yang terlalu tajam atau blur tidak wajar, bayangan yang arahnya beda, serta teks yang font-nya tidak konsisten. Tanda-tanda ini mengindikasikan tempelan atau editan kasar.',
    ),
    CourseSection(
      heading: 'Pencarian gambar terbalik',
      body:
          'Simpan gambar lalu cari lewat pencarian gambar terbalik di mesin pencari. Kalau foto yang sama muncul di peristiwa tahun lalu atau negara lain, narasi yang menyertainya patut dicurigai.',
    ),
    CourseSection(
      heading: 'Latihan mandiri',
      body:
          'Ambil satu gambar viral dan lakukan tiga cek: cahaya, konteks tanggal, dan pencarian terbalik. Catat temuanmu sebelum memutuskan percaya atau menyebar.',
    ),
  ],
  quiz: [
    QuizQuestion(
      question: 'Mana yang termasuk konteks palsu?',
      options: [
        'Foto banjir 2019 diberi narasi banjir kemarin di kotamu',
        'Foto blur karena kamera goyang',
        'Foto resolusi rendah karena dikompres WhatsApp',
        'Foto hitam putih karena filter estetik',
      ],
      correctIndex: 0,
      explanation:
          'Gambarnya asli tapi waktunya dipelintir. Ini jenis hoaks visual paling umum dan paling sulit dideteksi sekilas.',
    ),
    QuizQuestion(
      question: 'Tanda tempelan paling mudah dilihat?',
      options: [
        'Tepi objek dan arah bayangan yang tidak konsisten',
        'Ukuran file yang besar',
        'Jumlah like yang banyak',
        'Caption yang panjang',
      ],
      correctIndex: 0,
      explanation:
          'Editan kasar meninggalkan jejak fisik: tepi tajam, cahaya beda arah, dan teks tidak menyatu dengan gambar.',
    ),
    QuizQuestion(
      question: 'Fungsi pencarian gambar terbalik?',
      options: [
        'Memperbagus kualitas foto',
        'Menemukan kemunculan foto di peristiwa lain',
        'Menambah filter otomatis',
        'Menghapus watermark',
      ],
      correctIndex: 1,
      explanation:
          'Dengan menemukan sumber asli foto, kamu bisa membuktikan apakah narasi yang menyertainya benar atau daur ulang lama.',
    ),
  ],
);

const _verifySource = CourseModule(
  id: 'verifikasi-sumber',
  title: 'Verifikasi Sumber Berita',
  subtitle: 'Nilai penerbit sebelum percaya isinya.',
  minutes: 5,
  accentSeed: 2,
  sections: [
    CourseSection(
      heading: 'Kenali penerbitnya',
      body:
          'Cek nama media, alamat redaksi, dan rekam jejaknya. Media arus utama mencantumkan penanggung jawab dan koreksi terbuka. Blog tanpa identitas atau domain mirip media besar dengan satu huruf beda adalah bendera merah.',
    ),
    CourseSection(
      heading: 'Lacak penulis dan tanggal',
      body:
          'Artikel kredibel mencantumkan penulis dan tanggal terbit yang masuk akal. Waspadai artikel tanpa penulis, tanggal masa depan, atau peristiwa yang diklaim baru padahal foto dan datanya lama.',
    ),
    CourseSection(
      heading: 'Bandingkan tiga sumber',
      body:
          'Jangan percaya satu sumber. Cari peristiwa yang sama di minimal dua media independen. Kalau hanya satu blog yang memberitakan klaim besar, kemungkinan itu belum terverifikasi atau karangan.',
    ),
    CourseSection(
      heading: 'Latihan mandiri',
      body:
          'Pilih satu berita viral hari ini. Catat penerbit, penulis, tanggal, dan dua pembandingnya. Nilai 1 sampai 4, dan putuskan: layak sebar atau perlu dicek lagi.',
    ),
  ],
  quiz: [
    QuizQuestion(
      question: 'Tanda penerbit patut dicurigai?',
      options: [
        'Mencantumkan alamat redaksi dan koreksi',
        'Domain mirip media besar dengan satu huruf beda',
        'Penulis jelas dengan profil redaksi',
        'Tanggal terbit konsisten dengan peristiwa',
      ],
      correctIndex: 1,
      explanation:
          'Domain tiruan adalah taktik klasik situs hoaks untuk menumpang kredibilitas media sungguhan.',
    ),
    QuizQuestion(
      question: 'Aturan praktis jumlah pembanding?',
      options: [
        'Cukup satu blog yang meyakinkan',
        'Minimal dua media independen selain sumber awal',
        'Tidak perlu pembanding kalau viral',
        'Tanya grup keluarga saja',
      ],
      correctIndex: 1,
      explanation:
          'Triangulasi dua sumber independen memangkas risiko terjebak narasi tunggal yang belum terverifikasi.',
    ),
    QuizQuestion(
      question: 'Artikel tanpa penulis dan tanggal sebaiknya?',
      options: [
        'Disebar cepat agar orang waspada',
        'Dianggap valid karena anonim itu netral',
        'Ditahan dulu dan diverifikasi sumbernya',
        'Diedit tanggalnya sendiri',
      ],
      correctIndex: 2,
      explanation:
          'Anonimitas total menghilangkan akuntabilitas. Prinsipnya: tahan, verifikasi, baru putuskan.',
    ),
  ],
);

import '../../domain/entities/course_module.dart';
import '../../domain/entities/quiz_question.dart';
import 'learn_extra_modules.dart';
import 'learn_more_modules.dart';

/// Konten modul literasi digital: statis lokal Bahasa Indonesia.
///
/// Ditulis sebagai materi edukasi nyata (bukan lorem ipsum): tiap modul 4
/// seksi artikel + 3–4 soal kuis dengan penjelasan. Tanpa network agar bisa
/// dibaca offline oleh guest sekalipun.
class LearnContentDatasource {
  List<CourseModule> modules() => const [
    _clickbait,
    _manipulatedImage,
    _verifySource,
    ...extraLearnModules,
    ...moreLearnModules,
  ];

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
      question:
          'Kamu melihat judul “HEBOH! Minum ini sembuh total dalam semalam, sebarkan!”. Apa yang membuat judul itu mencurigakan?',
      options: [
        'Memakai nama tanaman yang sulit diucapkan',
        'Ditulis pada malam hari',
        'Huruf kapital berlebihan, janji instan, dan ajakan menyebar',
        'Tidak mencantumkan harga produk',
      ],
      correctIndex: 2,
      explanation:
          'Tiga ciri itu muncul bersamaan: kapital berlebihan, janji sembuh instan, dan dorongan menyebarkan. Judul berita yang baik biasanya lebih tenang dan spesifik.',
    ),
    QuizQuestion(
      question:
          'Kamu ragu pada sebuah judul berita. Pemeriksaan pertama yang paling masuk akal?',
      options: [
        'Cek penerbit, tanggal terbit, dan kesesuaian judul dengan isi',
        'Teruskan ke grup keluarga supaya ada yang menilai',
        'Lihat berapa banyak komentar yang marah',
        'Cari judul lain yang lebih menarik',
      ],
      correctIndex: 0,
      explanation:
          'Tiga cek cepat ini menyaring sebagian besar hoaks: siapa penerbitnya, kapan terbit, dan apakah isinya benar-benar mendukung judul.',
    ),
    QuizQuestion(
      question:
          'Kamu merasa marah dan ingin langsung membagikan sebuah unggahan. Mengapa perasaan itu justru perlu diwaspadai?',
      options: [
        'Karena marah membuat koneksi internet melambat',
        'Karena berita baik selalu hoaks',
        'Karena unggahan emosional biasanya lebih pendek',
        'Karena hoaks sering dirancang memicu reaksi sebelum orang sempat berpikir',
      ],
      correctIndex: 3,
      explanation:
          'Penyebar hoaks memanfaatkan rasa takut, marah, atau penasaran. Emosi yang meledak adalah tanda untuk berhenti dan memeriksa, bukan alasan mempercepat penyebaran.',
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
      question:
          'Sebuah foto banjir dari 2019 diberi keterangan “banjir kemarin di kotaku”. Jenis manipulasi apa ini?',
      options: [
        'Gambar diedit total hingga objeknya hilang',
        'Gambar asli dengan konteks waktu yang dipalsukan',
        'Gambar buram karena kamera bergoyang',
        'Gambar hitam putih karena filter',
      ],
      correctIndex: 1,
      explanation:
          'Fotonya bisa jadi asli, tetapi waktu dan lokasinya dipelintir. Jenis ini paling sering lolos karena tidak ada objek yang jelas-jelas diedit.',
    ),
    QuizQuestion(
      question:
          'Kamu memperbesar foto dan melihat tepi objek terlalu tajam serta arah bayangan tidak cocok. Apa arti temuan ini?',
      options: [
        'Foto pasti diambil dengan kamera mahal',
        'Foto pasti berasal dari media resmi',
        'Foto tidak mungkin diedit',
        'Ada indikasi tempelan atau editan yang perlu diperiksa lebih lanjut',
      ],
      correctIndex: 3,
      explanation:
          'Tepi yang terlalu tajam dan bayangan yang berbeda arah adalah jejak editan kasar. Tetap perlu pembanding sebelum menyimpulkan.',
    ),
    QuizQuestion(
      question:
          'Kamu ingin memastikan sebuah foto pernah muncul di peristiwa lain. Cara paling tepat?',
      options: [
        'Gunakan pencarian gambar terbalik, lalu bandingkan tanggal dan sumbernya',
        'Tambahkan filter agar gambar lebih tajam',
        'Hitung jumlah komentar pada unggahan',
        'Simpan gambar dan unggah ulang tanpa keterangan',
      ],
      correctIndex: 0,
      explanation:
          'Pencarian gambar terbalik membantu menemukan kemunculan paling awal. Tanggal dan sumber pertama itulah yang menentukan konteks aslinya.',
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
      question:
          'Kamu menemukan situs bernama “kompas-news24.example” yang mirip media besar. Apa yang paling perlu dicurigai?',
      options: [
        'Situs itu mencantumkan alamat redaksi',
        'Situs itu memuat koreksi pembaca',
        'Situs itu menulis nama penulis',
        'Domainnya meniru media besar dengan ejaan berbeda',
      ],
      correctIndex: 3,
      explanation:
          'Domain tiruan adalah taktik umum untuk menumpang kredibilitas media sungguhan. Periksa ejaan domain sebelum percaya isinya.',
    ),
    QuizQuestion(
      question:
          'Sebuah klaim besar hanya diberitakan satu blog. Langkah verifikasi yang paling masuk akal?',
      options: [
        'Percaya karena sudah ada yang menulis',
        'Tunggu sampai beritanya viral',
        'Cari laporan dari minimal dua sumber independen lain',
        'Tanyakan pendapat di grup keluarga',
      ],
      correctIndex: 2,
      explanation:
          'Satu sumber belum cukup untuk klaim besar. Dua sumber independen membantu memastikan peristiwa itu benar-benar terjadi.',
    ),
    QuizQuestion(
      question:
          'Artikel viral tidak mencantumkan penulis maupun tanggal terbit. Apa respons terbaik?',
      options: [
        'Sebarkan cepat agar orang lain waspada',
        'Tahan dulu dan verifikasi sumbernya sebelum membagikan',
        'Anggap netral karena penulisnya anonim',
        'Tambahkan tanggal sendiri agar terlihat baru',
      ],
      correctIndex: 1,
      explanation:
          'Tanpa penulis dan tanggal, tidak ada pihak yang bisa dimintai tanggung jawab. Prinsipnya: tahan, verifikasi, baru putuskan.',
    ),
  ],
);

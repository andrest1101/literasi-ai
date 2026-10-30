import '../../domain/entities/course_module.dart';
import '../../domain/entities/quiz_question.dart';

/// Modul tambahan gelombang kedua: privasi, jejak digital, dan algoritma.
///
/// Fokusnya keterampilan harian yang belum tercakup modul sebelumnya. Gaya
/// bahasa tetap formal, tetapi pertanyaan ditulis sebagai skenario yang wajar
/// dialami pengguna agar tidak terasa seperti daftar istilah mesin.
const moreLearnModules = <CourseModule>[
  CourseModule(
    id: 'privasi-data',
    title: 'Jaga Data Pribadi di Internet',
    subtitle: 'Kenali data sensitif dan batasi pemberian izin.',
    minutes: 6,
    accentSeed: 9,
    sections: [
      CourseSection(
        heading: 'Data pribadi bukan sekadar nama',
        body:
            'Nomor induk kependudukan, nomor telepon, alamat, foto kartu identitas, dan data biometrik termasuk informasi yang sensitif. Jika jatuh ke pihak yang salah, data itu bisa dipakai untuk membuka akun, mengajukan pinjaman, atau menyusun penipuan yang meyakinkan.',
      ),
      CourseSection(
        heading: 'Beri izin sesuai kebutuhan',
        body:
            'Aplikasi sering meminta akses kontak, lokasi, kamera, atau mikrofon. Sebelum menekan izinkan, tanyakan apakah fungsi yang kamu pakai benar-benar membutuhkannya. Izin bisa diberikan saat diperlukan dan dicabut kembali lewat pengaturan ponsel.',
      ),
      CourseSection(
        heading: 'Waspadai formulir yang meminta terlalu banyak',
        body:
            'Pendaftaran hadiah, survei, atau undian kadang meminta foto identitas dan nomor rekening. Permintaan seperti itu tidak sebanding dengan imbalan yang dijanjikan. Semakin sedikit data yang kamu berikan, semakin kecil dampaknya jika terjadi kebocoran.',
      ),
      CourseSection(
        heading: 'Langkah awal jika data sudah bocor',
        body:
            'Ganti kata sandi akun yang terdampak, aktifkan verifikasi dua langkah, dan pantau aktivitas transaksi. Jika menyangkut layanan keuangan, hubungi penyedia resminya. Laporkan pula jika kamu menemukan penyalahgunaan data.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question:
            'Aplikasi galeri foto meminta akses ke seluruh kontakmu. Apa respons yang paling masuk akal?',
        options: [
          'Izinkan semua agar aplikasi tidak error',
          'Tolak dulu; beri izin hanya jika fungsinya memang membutuhkan',
          'Kirim tangkapan layarnya ke pengembang',
          'Matikan ponsel setiap kali membuka aplikasi',
        ],
        correctIndex: 1,
        explanation:
            'Izin sebaiknya sesuai fungsi. Aplikasi galeri tidak membutuhkan daftar kontak untuk menampilkan foto.',
      ),
      QuizQuestion(
        question:
            'Kamu menerima pesan berhadiah yang meminta foto KTP dan nomor rekening. Apa yang sebaiknya kamu lakukan?',
        options: [
          'Abaikan dan jangan kirim data sensitif',
          'Kirim KTP tetapi sensor nama',
          'Kirim rekening saja agar aman',
          'Balas dengan data keluarga sebagai bukti',
        ],
        correctIndex: 0,
        explanation:
            'Data seperti KTP dan rekening bisa disalahgunakan untuk penipuan atau pembukaan akun. Tidak ada hadiah yang sebanding dengan risikonya.',
      ),
      QuizQuestion(
        question:
            'Kamu menduga data akunmu bocor. Tindakan mana yang paling tepat?',
        options: [
          'Diamkan sampai ada masalah',
          'Pakai kata sandi yang sama di semua akun',
          'Bagikan kode OTP ke teman agar bisa memantau',
          'Ganti kata sandi, aktifkan verifikasi dua langkah, dan pantau aktivitas akun',
        ],
        correctIndex: 3,
        explanation:
            'Mengganti kata sandi dan mengaktifkan verifikasi dua langkah mengurangi risiko akses lanjutan.',
      ),
      QuizQuestion(
        question:
            'Prinsip “minimal data” saat mengisi formulir online berarti…',
        options: [
          'Mengisi semua kolom agar pendaftaran cepat',
          'Memakai data palsu untuk semua layanan',
          'Hanya memberikan data yang benar-benar diperlukan layanan itu',
          'Mengunggah KTP di setiap formulir',
        ],
        correctIndex: 2,
        explanation:
            'Semakin sedikit data yang dibagikan, semakin kecil dampaknya jika terjadi kebocoran.',
      ),
    ],
  ),
  CourseModule(
    id: 'jejak-digital',
    title: 'Jejak Digital dan Reputasi',
    subtitle: 'Kelola jejak online yang bisa dilihat orang lain.',
    minutes: 6,
    accentSeed: 10,
    sections: [
      CourseSection(
        heading: 'Jejak digital terbentuk otomatis',
        body:
            'Setiap unggahan, komentar, suka, dan lokasi yang kamu bagikan meninggalkan jejak. Jejak itu tidak hanya tersimpan di akunmu, tetapi juga di perangkat dan arsip layanan lain.',
      ),
      CourseSection(
        heading: 'Yang dihapus belum tentu hilang',
        body:
            'Menghapus unggahan dari akun sendiri tidak menghapus tangkapan layar atau salinan yang sudah diambil orang lain. Karena itu, keputusan untuk mengunggah sebaiknya dibuat dengan asumsi konten bisa bertahan lama.',
      ),
      CourseSection(
        heading: 'Audit jejakmu secara berkala',
        body:
            'Cari namamu di mesin pencari, periksa pengaturan privasi, dan tinjau unggahan lama. Pisahkan akun pribadi dari akun yang mewakili pekerjaan atau organisasi agar audiensnya jelas.',
      ),
      CourseSection(
        heading: 'Unggah dengan mempertimbangkan audiens',
        body:
            'Sebelum mengunggah, bayangkan reaksi keluarga, guru, atau perekrut yang mungkin melihatnya. Pertanyaan sederhana ini membantu menahan unggahan yang berisiko bagi reputasimu di kemudian hari.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question:
            'Kamu menghapus unggahan lama yang memalukan. Apakah unggahan itu benar-benar hilang dari internet?',
        options: [
          'Ya, tombol hapus langsung menghapus semua salinan',
          'Ya, selama tidak ada yang memberi komentar',
          'Belum tentu; tangkapan layar dan arsip pihak lain bisa menyimpannya',
          'Tidak, semua unggahan otomatis disimpan selamanya',
        ],
        correctIndex: 2,
        explanation:
            'Menghapus dari akun sendiri tidak menghapus salinan yang sudah diambil orang lain atau tersimpan di arsip.',
      ),
      QuizQuestion(
        question:
            'Sebelum mengunggah foto yang memperlihatkan lokasi dan jam, apa yang sebaiknya kamu pertimbangkan?',
        options: [
          'Apakah fotonya cukup terang',
          'Berapa banyak filter yang dipakai',
          'Apakah unggahan itu akan viral',
          'Siapa yang bisa melihat dan apakah informasi itu aman dibagikan',
        ],
        correctIndex: 3,
        explanation:
            'Lokasi dan waktu bisa mengungkap rutinitas. Pikirkan audiens dan risikonya sebelum mengunggah.',
      ),
      QuizQuestion(
        question: 'Cara paling praktis memeriksa jejak digitalmu?',
        options: [
          'Cari namamu di mesin pencari dan periksa pengaturan privasi akun',
          'Hapus semua akun media sosial',
          'Ganti nomor telepon setiap bulan',
          'Minta teman menghapus semua fotomu',
        ],
        correctIndex: 0,
        explanation:
            'Pencarian nama dan peninjauan pengaturan privasi membantu melihat apa yang sudah terbuka untuk publik.',
      ),
      QuizQuestion(
        question:
            'Kamu ingin membangun reputasi profesional secara online. Kebiasaan mana yang paling membantu?',
        options: [
          'Mengunggah semua pendapat pribadi tanpa filter',
          'Menjaga konsistensi unggahan publik dan memisahkan hal pribadi',
          'Membuat banyak akun anonim untuk berdebat',
          'Menghapus seluruh riwayat unggahan lama',
        ],
        correctIndex: 1,
        explanation:
            'Konsistensi dan batas antara ruang pribadi serta publik membantu membangun jejak yang bisa dipertanggungjawabkan.',
      ),
    ],
  ),
  CourseModule(
    id: 'algoritma-filter-bubble',
    title: 'Algoritma dan Gelembung Informasi',
    subtitle: 'Pahami mengapa beranda menampilkan hal yang itu-itu saja.',
    minutes: 6,
    accentSeed: 11,
    sections: [
      CourseSection(
        heading: 'Algoritma memilih apa yang kamu lihat',
        body:
            'Beranda media sosial disusun oleh sistem yang mempelajari interaksimu: apa yang dibuka, ditonton lama, dan dibagikan. Karena itu, dua orang bisa menerima urutan konten yang sangat berbeda meski memakai aplikasi yang sama.',
      ),
      CourseSection(
        heading: 'Gelembung informasi',
        body:
            'Ketika sistem terus menampilkan hal yang mirip dengan kebiasaanmu, pandangan tertentu terasa lebih umum daripada kenyataannya. Lama-kelamaan kamu jarang bertemu bukti atau sudut pandang yang menantang asumsi awal.',
      ),
      CourseSection(
        heading: 'Cari sudut pandang di luar kebiasaan',
        body:
            'Ikuti beberapa sumber yang berbeda, baca berita dari penerbit lain, dan sesekali periksa topik yang tidak muncul di beranda. Perbandingan aktif membantu kamu melihat konteks yang tidak dipilih algoritma.',
      ),
      CourseSection(
        heading: 'Personalisasi bukan verifikasi',
        body:
            'Rekomendasi dibuat untuk menjaga perhatian, bukan untuk memastikan kebenaran. Konten yang sering muncul belum tentu akurat, dan konten yang jarang muncul belum tentu salah. Sumber asli tetap menjadi acuan.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question:
            'Beranda media sosialmu terus menampilkan topik yang sama. Mengapa hal itu bisa terjadi?',
        options: [
          'Algoritma mempelajari interaksimu dan menampilkan konten yang mirip',
          'Semua pengguna menerima urutan yang sama',
          'Topik itu satu-satunya yang ada di internet',
          'Topik itu pasti paling benar',
        ],
        correctIndex: 0,
        explanation:
            'Algoritma memakai pola interaksi untuk memilih konten. Itu personalisasi, bukan jaminan kebenaran.',
      ),
      QuizQuestion(
        question: 'Apa risiko utama berada dalam gelembung informasi?',
        options: [
          'Kuota internet cepat habis',
          'Iklan menjadi lebih mahal',
          'Kamu jarang melihat sudut pandang atau bukti yang berbeda',
          'Semua berita menjadi bohong',
        ],
        correctIndex: 2,
        explanation:
            'Gelembung informasi membuat pandangan tertentu terasa lebih umum daripada kenyataannya.',
      ),
      QuizQuestion(
        question: 'Cara sehat menyikapi rekomendasi algoritma?',
        options: [
          'Percaya penuh karena dipilih khusus untukmu',
          'Sesekali cari sumber lain di luar kebiasaan dan bandingkan',
          'Matikan internet selamanya',
          'Hanya membaca konten yang menyenangkan',
        ],
        correctIndex: 1,
        explanation:
            'Membandingkan beberapa sumber membantu kamu melihat konteks yang tidak muncul di beranda.',
      ),
      QuizQuestion(
        question:
            'Rekomendasi “Untukmu” menampilkan klaim yang belum pernah kamu dengar. Apa artinya?',
        options: [
          'Klaim itu pasti benar karena belum diketahui banyak orang',
          'Klaim itu pasti hoaks karena tidak populer',
          'Algoritma sudah memverifikasi klaim tersebut',
          'Klaim tetap perlu diperiksa ke sumber aslinya',
        ],
        correctIndex: 3,
        explanation:
            'Rekomendasi dibuat untuk menjaga perhatian, bukan untuk memverifikasi fakta. Sumber asli tetap acuan.',
      ),
    ],
  ),
];

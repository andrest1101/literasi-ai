import '../../domain/entities/course_module.dart';
import '../../domain/entities/quiz_question.dart';

/// Additional offline-first learning modules focused on practical Indonesian
/// digital-literacy scenarios. Keep examples educational, not live claims.
const extraLearnModules = <CourseModule>[
  CourseModule(
    id: 'cek-konteks-media',
    title: 'Cek Konteks Foto dan Video',
    subtitle: 'Telusuri asal, waktu, dan lokasi sebelum percaya narasinya.',
    minutes: 6,
    accentSeed: 3,
    sections: [
      CourseSection(
        heading: 'Media asli belum tentu berkonteks benar',
        body:
            'Foto atau video bisa benar-benar asli, tetapi dipasangkan dengan tanggal, lokasi, atau peristiwa yang keliru. Karena itu, jangan berhenti pada pertanyaan “asli atau editan”; periksa juga cerita yang menyertainya.',
      ),
      CourseSection(
        heading: 'Cari jejak publikasi awal',
        body:
            'Gunakan pencarian gambar terbalik atau potongan gambar video untuk mencari kemunculan terdahulu. Perhatikan tanggal unggahan, sumber pertama yang bisa ditemukan, dan apakah sumber itu benar-benar berada dekat dengan peristiwa.',
      ),
      CourseSection(
        heading: 'Uji petunjuk tempat dan waktu',
        body:
            'Bandingkan bangunan, rambu, cuaca, bahasa, dan kondisi sekitar dengan klaim lokasi. Petunjuk visual membantu menyusun pertanyaan, tetapi satu petunjuk saja tidak cukup untuk memastikan tempat atau tanggal.',
      ),
      CourseSection(
        heading: 'Simpulkan dengan batas bukti',
        body:
            'Catat apa yang sudah diketahui, apa yang belum, dan sumber pembandingnya. Jika tanggal atau lokasi belum dapat dipastikan, sampaikan ketidakpastian itu dan tahan penyebaran.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question:
            'Video banjir yang beredar tampak nyata. Langkah apa yang paling tepat?',
        options: [
          'Langsung percaya karena videonya terlihat jelas',
          'Periksa unggahan terdahulu dan cocokkan lokasi serta tanggal',
          'Menilai kebenaran hanya dari jumlah penonton',
          'Menganggap semua video lama pasti palsu',
        ],
        correctIndex: 1,
        explanation:
            'Video dapat asli tetapi berasal dari peristiwa lain. Asal, waktu, dan lokasi perlu diperiksa terpisah.',
      ),
      QuizQuestion(
        question: 'Apa kegunaan pencarian gambar terbalik?',
        options: [
          'Memastikan semua klaim dalam caption benar',
          'Menemukan kemunculan gambar dan kemungkinan sumber lebih awal',
          'Mengetahui niat pembuat gambar dengan pasti',
          'Menghapus bagian gambar yang menyesatkan',
        ],
        correctIndex: 1,
        explanation:
            'Pencarian membantu menemukan jejak gambar, tetapi hasilnya tetap perlu dinilai dan dibandingkan dengan sumber lain.',
      ),
      QuizQuestion(
        question:
            'Satu rambu terlihat cocok dengan lokasi klaim. Kesimpulan terbaik?',
        options: [
          'Lokasi pasti benar',
          'Lokasi pasti salah',
          'Itu petunjuk awal; cari bukti dan pembanding tambahan',
          'Abaikan tanggal dan sumber unggahan',
        ],
        correctIndex: 2,
        explanation:
            'Satu petunjuk bisa kebetulan atau tidak lengkap. Verifikasi yang baik memakai beberapa bukti yang saling mendukung.',
      ),
      QuizQuestion(
        question:
            'Jika tanggal asli belum ditemukan, bagaimana sebaiknya membagikan hasil cek?',
        options: [
          'Tulis tanggal perkiraan sebagai fakta',
          'Nyatakan bagian yang belum pasti dan tahan penyebaran',
          'Hapus sumber yang tidak mendukung dugaan',
          'Pilih tanggal dari komentar terbanyak',
        ],
        correctIndex: 1,
        explanation:
            'Kesimpulan harus sebanding dengan bukti. Menyebut batas informasi lebih bertanggung jawab daripada menebak.',
      ),
    ],
  ),
  CourseModule(
    id: 'statistik-menyesatkan',
    title: 'Memahami Statistik Menyesatkan',
    subtitle: 'Baca angka, pembanding, dan grafik dengan lebih kritis.',
    minutes: 6,
    accentSeed: 4,
    sections: [
      CourseSection(
        heading: 'Angka perlu konteks',
        body:
            'Angka dapat benar tetapi memberi kesan keliru jika tanpa satuan, periode, populasi, atau sumber. Tanyakan “berapa dibanding apa?” sebelum menarik kesimpulan dari persentase atau jumlah besar.',
      ),
      CourseSection(
        heading: 'Periksa pembanding dan rentang waktu',
        body:
            'Kenaikan dari 2 menjadi 4 memang naik 100 persen, tetapi jumlah awalnya tetap penting. Pastikan dua angka membahas kelompok dan rentang waktu yang sebanding.',
      ),
      CourseSection(
        heading: 'Baca sumbu grafik',
        body:
            'Sumbu yang tidak dimulai dari nol atau rentang yang dipotong dapat membesar-besarkan perbedaan. Periksa label, skala, satuan, serta apakah interval sumbu konsisten.',
      ),
      CourseSection(
        heading: 'Tanyakan cara data dikumpulkan',
        body:
            'Survei dengan sedikit responden atau kelompok yang tidak mewakili populasi tidak otomatis menggambarkan semua orang. Cari ukuran sampel, metode, tanggal, dan lembaga yang mengumpulkan data.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question:
            'Sebuah unggahan menyebut “naik 100%”. Apa yang perlu diketahui dahulu?',
        options: [
          'Warna grafik yang digunakan',
          'Nilai awal, pembanding, periode, dan satuannya',
          'Jumlah tanda suka unggahan',
          'Apakah judulnya memakai huruf kapital',
        ],
        correctIndex: 1,
        explanation:
            'Persentase tanpa nilai awal dan pembanding mudah disalahartikan. Periode dan satuan juga menentukan makna angka.',
      ),
      QuizQuestion(
        question:
            'Grafik batang dimulai dari angka 95, bukan nol. Apa tindakan yang tepat?',
        options: [
          'Anggap otomatis palsu',
          'Periksa skala karena perbedaan visual mungkin tampak lebih besar',
          'Baca tinggi batang saja tanpa label',
          'Sebarkan karena grafik selalu objektif',
        ],
        correctIndex: 1,
        explanation:
            'Sumbu yang dipotong dapat memperbesar kesan selisih. Ini alasan untuk membaca skala, bukan bukti tunggal bahwa datanya palsu.',
      ),
      QuizQuestion(
        question:
            'Survei daring di satu grup disebut mewakili seluruh Indonesia. Apa yang perlu diperiksa?',
        options: [
          'Apakah sampel dan metode mewakili populasi yang diklaim',
          'Apakah poster surveinya menarik',
          'Apakah responden memiliki ponsel baru',
          'Apakah hasilnya sesuai pendapat kita',
        ],
        correctIndex: 0,
        explanation:
            'Cara memilih responden menentukan apakah hasil dapat digeneralisasi. Sampel satu grup bisa memiliki bias.',
      ),
      QuizQuestion(
        question: 'Dua angka hanya layak dibandingkan jika…',
        options: [
          'Ditampilkan dengan warna yang sama',
          'Memiliki definisi, satuan, dan konteks pengukuran yang sebanding',
          'Berjumlah sama besar',
          'Diambil dari unggahan yang viral',
        ],
        correctIndex: 1,
        explanation:
            'Perbandingan bermakna jika yang diukur dan cara pengukurannya sepadan.',
      ),
    ],
  ),
  CourseModule(
    id: 'literasi-kesehatan',
    title: 'Saring Hoaks Kesehatan',
    subtitle: 'Periksa klaim kesehatan tanpa mengganti nasihat profesional.',
    minutes: 6,
    accentSeed: 5,
    sections: [
      CourseSection(
        heading: 'Waspadai janji kesembuhan instan',
        body:
            'Klaim “pasti sembuh”, “tanpa efek samping”, atau anjuran menghentikan terapi adalah tanda untuk berhenti dan memeriksa. Testimoni pribadi bukan bukti bahwa cara yang sama aman atau efektif bagi semua orang.',
      ),
      CourseSection(
        heading: 'Cari sumber dan bukti',
        body:
            'Periksa siapa yang membuat klaim, apakah ada rujukan yang dapat ditelusuri, dan apakah informasi sejalan dengan lembaga kesehatan tepercaya. Bedakan hasil penelitian awal dari panduan medis yang sudah ditinjau.',
      ),
      CourseSection(
        heading: 'Periksa tanggal dan konteks penelitian',
        body:
            'Temuan pada hewan, kelompok kecil, atau kondisi laboratorium tidak otomatis membuktikan manfaat klinis pada semua orang. Baca batas penelitian dan tanggal publikasinya.',
      ),
      CourseSection(
        heading: 'Jangan mengganti perawatan sendiri',
        body:
            'Materi ini mengajarkan pemeriksaan informasi, bukan diagnosis atau pengobatan. Jangan menghentikan obat atau menunda pertolongan berdasarkan pesan viral; konsultasikan keputusan kesehatan dengan tenaga kesehatan.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question:
            'Pesan viral menjanjikan obat yang “pasti sembuh untuk semua orang”. Respons terbaik?',
        options: [
          'Mencoba karena ada testimoni',
          'Periksa sumber dan bukti; konsultasikan keputusan medis dengan tenaga kesehatan',
          'Berhenti minum obat yang diresepkan',
          'Meneruskan agar semua orang mencoba',
        ],
        correctIndex: 1,
        explanation:
            'Janji mutlak dan testimoni bukan bukti yang cukup. Jangan mengubah perawatan tanpa konsultasi profesional.',
      ),
      QuizQuestion(
        question:
            'Penelitian awal pada hewan menunjukkan hasil positif. Kesimpulan yang aman?',
        options: [
          'Pengobatan terbukti aman untuk semua manusia',
          'Temuan menarik, tetapi belum membuktikan manfaat klinis pada manusia',
          'Semua penelitian hewan tidak berguna',
          'Produk yang dijual pasti disetujui regulator',
        ],
        correctIndex: 1,
        explanation:
            'Jenis penelitian menentukan batas kesimpulannya. Hasil awal perlu penelitian lanjutan dan tidak otomatis berlaku pada manusia.',
      ),
      QuizQuestion(
        question:
            'Apa yang sebaiknya dilakukan sebelum meneruskan klaim kesehatan?',
        options: [
          'Cek sumber, tanggal, bukti, dan konteksnya',
          'Percaya jika dikirim keluarga',
          'Hanya membaca judul',
          'Mengandalkan jumlah share',
        ],
        correctIndex: 0,
        explanation:
            'Sumber, waktu, bukti, dan konteks memberi dasar lebih kuat daripada popularitas pesan.',
      ),
      QuizQuestion(
        question:
            'Pesan meminta pembaca menghentikan obat resep. Langkah paling aman?',
        options: [
          'Ikuti karena pesannya mendesak',
          'Tanyakan kepada tenaga kesehatan sebelum mengubah perawatan',
          'Ganti dengan produk yang dipromosikan',
          'Sebarkan dahulu baru cek nanti',
        ],
        correctIndex: 1,
        explanation:
            'Perubahan perawatan perlu dibahas dengan tenaga kesehatan yang memahami kondisi pasien.',
      ),
    ],
  ),
  CourseModule(
    id: 'anti-phishing',
    title: 'Kenali Penipuan dan Phishing',
    subtitle: 'Lindungi akun dan uang dari pesan serta tautan jebakan.',
    minutes: 6,
    accentSeed: 6,
    sections: [
      CourseSection(
        heading: 'Kenali tekanan dan iming-iming',
        body:
            'Pesan penipuan sering membuat panik atau tergesa-gesa: akun akan diblokir, hadiah segera hangus, atau keluarga mengalami keadaan darurat. Tekanan waktu adalah alasan untuk berhenti, bukan mengklik lebih cepat.',
      ),
      CourseSection(
        heading: 'Periksa alamat dan kanal resmi',
        body:
            'Lihat alamat situs secara teliti, termasuk ejaan domain dan subdomain. Jangan masuk melalui tautan pesan yang tidak diminta; buka aplikasi atau situs resmi dengan mengetik alamat sendiri.',
      ),
      CourseSection(
        heading: 'Rahasiakan kode dan kata sandi',
        body:
            'OTP, PIN, kata sandi, dan kode pemulihan tidak boleh dibagikan kepada orang yang menghubungi secara tiba-tiba. Pihak resmi tidak membutuhkan kode rahasia untuk “membatalkan” transaksi melalui chat.',
      ),
      CourseSection(
        heading: 'Jika terlanjur mengklik',
        body:
            'Jangan masukkan data lanjutan. Jika kredensial terlanjur diberikan, segera ganti kata sandi melalui kanal resmi, aktifkan pengamanan tambahan, hubungi penyedia layanan atau bank, dan pantau transaksi.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question:
            'Pesan mengaku dari bank dan meminta OTP untuk membatalkan transaksi. Apa tindakan terbaik?',
        options: [
          'Kirim OTP agar transaksi batal',
          'Jangan bagikan kode; hubungi bank lewat kanal resmi',
          'Kirim hanya jika nama pengirim terlihat resmi',
          'Minta tautan lain melalui pesan yang sama',
        ],
        correctIndex: 1,
        explanation:
            'OTP adalah rahasia untuk mengotorisasi akses atau transaksi. Hubungi bank melalui aplikasi atau nomor resmi yang dicari sendiri.',
      ),
      QuizQuestion(
        question: 'Cara lebih aman membuka layanan yang disebut dalam pesan?',
        options: [
          'Klik tautan dan masukkan data secepatnya',
          'Buka aplikasi atau ketik alamat resmi secara mandiri',
          'Gunakan tautan dengan banyak tanda seru',
          'Minta teman meneruskan tautan yang sama',
        ],
        correctIndex: 1,
        explanation:
            'Mengakses layanan lewat kanal yang dibuka sendiri mengurangi risiko halaman tiruan.',
      ),
      QuizQuestion(
        question:
            'Apa yang patut dicurigai dari pesan “hadiah hangus dalam 5 menit”?',
        options: [
          'Tekanan waktu yang mendorong tindakan tanpa pemeriksaan',
          'Penggunaan angka dalam pesan',
          'Panjang pesan yang pendek',
          'Waktu pengiriman pada siang hari',
        ],
        correctIndex: 0,
        explanation:
            'Urgensi palsu sering dipakai agar korban tidak sempat memeriksa sumber dan alamat tautan.',
      ),
      QuizQuestion(
        question:
            'Jika kata sandi sudah dimasukkan pada situs yang mencurigakan, apa langkah awal?',
        options: [
          'Tunggu sampai ada transaksi',
          'Ganti kata sandi melalui kanal resmi dan amankan akun',
          'Kirim OTP kepada pengirim untuk konfirmasi',
          'Gunakan kata sandi yang sama di tempat lain',
        ],
        correctIndex: 1,
        explanation:
            'Segera amankan akun melalui aplikasi atau situs resmi dan hubungi penyedia layanan jika ada risiko transaksi.',
      ),
    ],
  ),
  CourseModule(
    id: 'konten-ai-deepfake',
    title: 'Kenali Konten AI dan Deepfake',
    subtitle: 'Periksa asal konten; jangan mengandalkan satu ciri visual.',
    minutes: 6,
    accentSeed: 7,
    sections: [
      CourseSection(
        heading: 'Konten sintetis makin meyakinkan',
        body:
            'Gambar, suara, dan video buatan AI dapat tampak nyata, sementara konten asli juga bisa memiliki artefak akibat kompresi. Karena itu, kejanggalan visual hanya petunjuk awal, bukan bukti pasti.',
      ),
      CourseSection(
        heading: 'Amati, tetapi jangan berhenti di sana',
        body:
            'Perhatikan ketidakselarasan suara dan gerak, detail yang berubah, atau pencahayaan yang tidak konsisten. Namun, kualitas rendah dan proses penyuntingan biasa juga dapat menimbulkan tanda serupa.',
      ),
      CourseSection(
        heading: 'Telusuri asal dan konfirmasi independen',
        body:
            'Cari sumber unggahan pertama, pernyataan pihak terkait, dan laporan dari sumber independen. Metadata atau label asal konten dapat membantu jika tersedia, tetapi ketiadaannya tidak otomatis membuktikan konten palsu.',
      ),
      CourseSection(
        heading: 'Bagikan secara bertanggung jawab',
        body:
            'Jangan menuduh seseorang membuat deepfake tanpa bukti yang memadai. Jika belum terverifikasi, jelaskan bahwa statusnya belum pasti dan jangan menyebarkannya sebagai fakta.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question:
            'Video memiliki gerak bibir yang tampak janggal. Apa kesimpulan paling bertanggung jawab?',
        options: [
          'Pasti deepfake',
          'Petunjuk untuk diperiksa lebih lanjut, bukan bukti tunggal',
          'Pasti rekaman asli',
          'Tidak perlu memeriksa sumbernya',
        ],
        correctIndex: 1,
        explanation:
            'Kompresi dan penyuntingan juga dapat menimbulkan artefak. Verifikasi asal dan pembanding independen sebelum menyimpulkan.',
      ),
      QuizQuestion(
        question: 'Cara paling kuat untuk memeriksa video tokoh yang viral?',
        options: [
          'Mengandalkan satu aplikasi deteksi saja',
          'Menelusuri sumber dan mencari konfirmasi independen',
          'Menghitung komentar yang menyebut palsu',
          'Memastikan video terlihat tajam',
        ],
        correctIndex: 1,
        explanation:
            'Alat deteksi dapat keliru. Asal konten dan konfirmasi independen memberi konteks yang lebih dapat diuji.',
      ),
      QuizQuestion(
        question:
            'Tidak ada label AI pada sebuah gambar. Apakah itu membuktikan gambar asli?',
        options: [
          'Ya, label selalu wajib ada',
          'Tidak; ketiadaan label bukan bukti asal gambar',
          'Ya, jika gambarnya beresolusi tinggi',
          'Tidak, semua gambar tanpa label adalah palsu',
        ],
        correctIndex: 1,
        explanation:
            'Penanda asal tidak selalu tersedia atau dipertahankan. Periksa sumber dan konteks dengan beberapa cara.',
      ),
      QuizQuestion(
        question:
            'Konten belum bisa dipastikan asli atau buatan AI. Apa yang sebaiknya dilakukan?',
        options: [
          'Sebarkan dengan caption “pasti asli”',
          'Nyatakan belum terverifikasi dan tahan penyebaran',
          'Tuduh pembuatnya tanpa bukti',
          'Hapus konteks sumber agar lebih meyakinkan',
        ],
        correctIndex: 1,
        explanation:
            'Sampaikan batas bukti secara jujur dan jangan mengubah dugaan menjadi kepastian.',
      ),
    ],
  ),
  CourseModule(
    id: 'fakta-opini-satire',
    title: 'Fakta, Opini, dan Satire',
    subtitle: 'Bedakan klaim yang bisa diuji dari pendapat dan humor.',
    minutes: 5,
    accentSeed: 8,
    sections: [
      CourseSection(
        heading: 'Apa yang bisa diverifikasi?',
        body:
            'Fakta menyatakan sesuatu yang dapat diuji dengan bukti, misalnya tanggal atau isi dokumen. Opini adalah penilaian atau tafsiran. Keduanya dapat muncul bersama dalam satu tulisan, jadi pisahkan klaimnya.',
      ),
      CourseSection(
        heading: 'Opini tetap perlu konteks',
        body:
            'Pendapat tidak selalu benar atau salah dengan cara yang sama seperti data faktual, tetapi dasar dan konteksnya tetap dapat diperiksa. Cari bukti yang dipakai dan bedakan bukti dari kesimpulan penulis.',
      ),
      CourseSection(
        heading: 'Kenali satire dan parodi',
        body:
            'Satire memakai humor, ironi, atau pembesaran untuk mengkritik. Saat potongan satire dibagikan tanpa konteks, pembaca bisa mengiranya sebagai berita. Periksa akun penerbit, format, dan konteks lengkapnya.',
      ),
      CourseSection(
        heading: 'Periksa klaim, bukan hanya nada',
        body:
            'Tulisan yang terdengar serius tetap bisa keliru; humor pun dapat memuat rujukan nyata. Ambil kalimat yang dapat diuji, cari sumbernya, lalu nilai konteks sebelum membagikan.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question:
            '“Acara dimulai pukul 10.00” dan “acaranya sangat membosankan” adalah…',
        options: [
          'Keduanya opini',
          'Pernyataan pertama dapat diuji; kedua merupakan penilaian',
          'Keduanya pasti fakta',
          'Pernyataan pertama satire',
        ],
        correctIndex: 1,
        explanation:
            'Waktu mulai bisa dicocokkan dengan catatan. “Membosankan” adalah penilaian subjektif.',
      ),
      QuizQuestion(
        question:
            'Sebuah unggahan lucu dikutip sebagai berita tanpa sumber aslinya. Apa yang perlu dilakukan?',
        options: [
          'Periksa akun dan konteks publikasi lengkapnya',
          'Anggap benar karena banyak dibagikan',
          'Menilai hanya dari banyaknya emoji',
          'Hapus bagian yang menunjukkan humor',
        ],
        correctIndex: 0,
        explanation:
            'Konteks sumber membantu mengenali apakah unggahan merupakan satire, parodi, atau laporan faktual.',
      ),
      QuizQuestion(
        question: 'Bagaimana memeriksa artikel yang mencampur fakta dan opini?',
        options: [
          'Tolak seluruh isi tanpa membaca',
          'Pisahkan klaim yang bisa diuji dari tafsiran, lalu cek bukti klaim',
          'Anggap semua kalimat sebagai data',
          'Percaya jika penulis terdengar yakin',
        ],
        correctIndex: 1,
        explanation:
            'Memisahkan klaim dan tafsiran membuat pemeriksaan lebih terarah dan adil.',
      ),
      QuizQuestion(
        question: 'Apakah gaya bahasa serius menjamin sebuah klaim benar?',
        options: [
          'Ya, gaya serius selalu akurat',
          'Tidak; klaim faktual tetap perlu bukti dan sumber',
          'Ya, jika artikelnya panjang',
          'Tidak; semua tulisan serius adalah satire',
        ],
        correctIndex: 1,
        explanation:
            'Nada tulisan tidak menggantikan bukti. Periksa klaim dan sumbernya secara langsung.',
      ),
    ],
  ),
];

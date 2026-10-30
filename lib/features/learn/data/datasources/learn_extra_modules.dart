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
            'Video banjir terlihat sangat nyata. Apa langkah paling tepat sebelum kamu membagikannya?',
        options: [
          'Cari unggahan terdahulu, lalu cocokkan lokasi dan tanggalnya',
          'Percaya karena gambarnya terlihat jelas',
          'Nilai kebenarannya dari jumlah penonton',
          'Anggap semua video lama pasti palsu',
        ],
        correctIndex: 0,
        explanation:
            'Video bisa asli tetapi berasal dari peristiwa lain. Asal, waktu, dan lokasi perlu diperiksa secara terpisah.',
      ),
      QuizQuestion(
        question:
            'Kamu menemukan gambar yang sama di unggahan tiga tahun lalu. Apa gunanya temuan ini?',
        options: [
          'Memastikan semua isi caption benar',
          'Menghapus bagian gambar yang salah',
          'Menunjukkan bahwa narasi “baru” mungkin mendaur ulang peristiwa lama',
          'Membuktikan pembuat gambar punya niat jahat',
        ],
        correctIndex: 2,
        explanation:
            'Kemunculan lebih awal menunjukkan konteks aslinya. Narasi yang mengklaim peristiwa baru jadi patut dicurigai.',
      ),
      QuizQuestion(
        question:
            'Satu rambu jalan di video cocok dengan lokasi yang diklaim. Kesimpulan paling jujur?',
        options: [
          'Lokasi pasti benar',
          'Lokasi pasti salah',
          'Tanggal dan sumber tidak perlu diperiksa lagi',
          'Itu petunjuk awal; masih perlu bukti dan pembanding lain',
        ],
        correctIndex: 3,
        explanation:
            'Satu petunjuk bisa kebetulan atau tidak lengkap. Verifikasi yang baik memakai beberapa bukti yang saling mendukung.',
      ),
      QuizQuestion(
        question:
            'Tanggal asli video belum ditemukan. Bagaimana cara menyampaikan hasil penelusuranmu?',
        options: [
          'Tulis perkiraan tanggal sebagai fakta',
          'Sebutkan bagian yang belum pasti dan tahan penyebaran',
          'Pilih tanggal dari komentar terbanyak',
          'Hapus sumber yang tidak mendukung dugaan',
        ],
        correctIndex: 1,
        explanation:
            'Kesimpulan harus sepadan dengan bukti. Menyatakan batas informasi lebih bertanggung jawab daripada menebak.',
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
            'Sebuah unggahan menyebut “kenaikan 100%”. Informasi apa yang perlu kamu cari lebih dulu?',
        options: [
          'Warna grafik yang dipakai',
          'Jumlah suka pada unggahan',
          'Nilai awal, pembanding, periode, dan satuannya',
          'Apakah judulnya memakai huruf kapital',
        ],
        correctIndex: 2,
        explanation:
            'Naik 100% dari 2 menjadi 4 berbeda maknanya dari 1.000 menjadi 2.000. Nilai awal, pembanding, periode, dan satuan menentukan arti angka.',
      ),
      QuizQuestion(
        question:
            'Grafik batang dimulai dari angka 95, bukan nol. Apa yang sebaiknya kamu lakukan?',
        options: [
          'Periksa skala karena selisih visual bisa tampak lebih besar dari kenyataan',
          'Anggap grafik otomatis palsu',
          'Baca tinggi batang tanpa melihat label',
          'Sebarkan karena grafik selalu objektif',
        ],
        correctIndex: 0,
        explanation:
            'Sumbu yang dipotong dapat memperbesar kesan selisih. Itu alasan membaca skala dengan hati-hati, bukan langsung menuduh data palsu.',
      ),
      QuizQuestion(
        question:
            'Survei daring di satu grup WhatsApp diklaim mewakili seluruh Indonesia. Apa yang perlu diperiksa?',
        options: [
          'Apakah poster surveinya menarik',
          'Apakah sampel dan metodenya mewakili populasi yang diklaim',
          'Apakah responden memakai ponsel baru',
          'Apakah hasilnya sesuai pendapat kita',
        ],
        correctIndex: 1,
        explanation:
            'Cara memilih responden menentukan apakah hasil bisa digeneralisasi. Satu grup punya bias yang belum tentu mewakili semua orang.',
      ),
      QuizQuestion(
        question: 'Dua angka baru layak dibandingkan jika…',
        options: [
          'Ditampilkan dengan warna yang sama',
          'Jumlahnya sama besar',
          'Diambil dari unggahan yang viral',
          'Definisi, satuan, dan konteks pengukurannya sebanding',
        ],
        correctIndex: 3,
        explanation:
            'Perbandingan bermakna hanya jika yang diukur dan cara mengukurnya sepadan.',
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
            'Pesan viral menjanjikan obat yang “pasti sembuh untuk semua orang”. Apa respons paling bijak?',
        options: [
          'Mencobanya karena ada testimoni',
          'Berhenti minum obat yang diresepkan',
          'Meneruskannya agar orang lain mencoba',
          'Periksa sumber dan buktinya, lalu konsultasikan keputusan medis dengan tenaga kesehatan',
        ],
        correctIndex: 3,
        explanation:
            'Janji mutlak dan testimoni pribadi bukan bukti yang cukup. Keputusan pengobatan tetap perlu dibahas dengan tenaga kesehatan.',
      ),
      QuizQuestion(
        question:
            'Sebuah penelitian awal pada hewan menunjukkan hasil positif. Kesimpulan yang aman?',
        options: [
          'Obat itu sudah terbukti aman untuk semua manusia',
          'Temuannya menarik, tetapi belum membuktikan manfaat pada manusia',
          'Semua penelitian hewan tidak berguna',
          'Produk yang dijual pasti sudah disetujui regulator',
        ],
        correctIndex: 1,
        explanation:
            'Jenis penelitian menentukan batas kesimpulan. Temuan awal perlu penelitian lanjutan sebelum berlaku untuk manusia.',
      ),
      QuizQuestion(
        question:
            'Sebelum meneruskan klaim kesehatan, apa yang paling perlu kamu periksa?',
        options: [
          'Sumber, tanggal, bukti, dan konteks klaimnya',
          'Apakah pengirimnya keluarga sendiri',
          'Apakah judulnya sudah cukup meyakinkan',
          'Berapa banyak orang yang sudah membagikan',
        ],
        correctIndex: 0,
        explanation:
            'Sumber, waktu, bukti, dan konteks memberi dasar yang lebih kuat daripada popularitas atau kedekatan pengirim.',
      ),
      QuizQuestion(
        question:
            'Pesan meminta pembaca menghentikan obat resep. Langkah paling aman?',
        options: [
          'Ikuti karena pesannya mendesak',
          'Ganti dengan produk yang dipromosikan',
          'Tanyakan kepada tenaga kesehatan sebelum mengubah perawatan',
          'Sebarkan dulu, diperiksa nanti',
        ],
        correctIndex: 2,
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
            'Seseorang mengaku dari bank dan meminta kode OTP untuk membatalkan transaksi. Apa yang kamu lakukan?',
        options: [
          'Kirim kode agar transaksinya batal',
          'Tolak membagikan kode dan hubungi bank lewat kanal resmi',
          'Kirim hanya jika nama pengirim terlihat resmi',
          'Minta tautan lain dari pengirim yang sama',
        ],
        correctIndex: 1,
        explanation:
            'OTP adalah kunci untuk mengotorisasi akses atau transaksi. Hubungi bank lewat aplikasi atau nomor resmi yang kamu cari sendiri.',
      ),
      QuizQuestion(
        question:
            'Kamu menerima pesan berisi tautan layanan. Cara paling aman membukanya?',
        options: [
          'Klik tautannya dan isi data secepat mungkin',
          'Gunakan tautan yang dikirim berulang kali',
          'Minta teman meneruskan tautan yang sama',
          'Buka aplikasi atau ketik alamat resmi secara mandiri',
        ],
        correctIndex: 3,
        explanation:
            'Mengakses layanan lewat kanal yang kamu buka sendiri mengurangi risiko halaman tiruan.',
      ),
      QuizQuestion(
        question:
            'Pesan menulis “hadiah hangus dalam 5 menit”. Bagian mana yang paling mencurigakan?',
        options: [
          'Penggunaan angka dalam pesan',
          'Panjang pesan yang pendek',
          'Tekanan waktu yang mendorong tindakan tanpa pemeriksaan',
          'Waktu pengiriman pada siang hari',
        ],
        correctIndex: 2,
        explanation:
            'Urgensi palsu dibuat agar kamu tidak sempat memeriksa sumber dan alamat tautan.',
      ),
      QuizQuestion(
        question:
            'Kamu terlanjur memasukkan kata sandi di situs mencurigakan. Langkah pertama?',
        options: [
          'Ganti kata sandi lewat kanal resmi dan amankan akun',
          'Tunggu sampai ada transaksi mencurigakan',
          'Kirim OTP kepada pengirim untuk konfirmasi',
          'Pakai kata sandi yang sama di layanan lain',
        ],
        correctIndex: 0,
        explanation:
            'Amankan akun segera lewat aplikasi atau situs resmi. Jika ada risiko transaksi, hubungi penyedia layanan atau bank.',
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
            'Video seorang tokoh tampak janggal di bagian gerak bibirnya. Kesimpulan paling bertanggung jawab?',
        options: [
          'Itu petunjuk untuk diperiksa lebih lanjut, bukan bukti tunggal',
          'Pasti deepfake',
          'Pasti rekaman asli',
          'Sumbernya tidak perlu diperiksa',
        ],
        correctIndex: 0,
        explanation:
            'Kompresi dan penyuntingan juga bisa menimbulkan artefak. Verifikasi asal dan pembanding independen sebelum menyimpulkan.',
      ),
      QuizQuestion(
        question: 'Cara paling kuat memeriksa video tokoh yang sedang viral?',
        options: [
          'Mengandalkan satu aplikasi deteksi',
          'Menghitung komentar yang menyebut palsu',
          'Memastikan videonya terlihat tajam',
          'Menelusuri sumber dan mencari konfirmasi independen',
        ],
        correctIndex: 3,
        explanation:
            'Alat deteksi bisa keliru. Asal konten dan konfirmasi independen memberi konteks yang lebih dapat diuji.',
      ),
      QuizQuestion(
        question:
            'Sebuah gambar tidak memiliki label AI. Apakah itu membuktikan gambar tersebut asli?',
        options: [
          'Ya, label AI selalu wajib ada',
          'Tidak; ketiadaan label bukan bukti asal gambar',
          'Ya, asalkan resolusinya tinggi',
          'Tidak; semua gambar tanpa label pasti palsu',
        ],
        correctIndex: 1,
        explanation:
            'Penanda asal tidak selalu tersedia atau ikut tersimpan. Periksa sumber dan konteksnya lewat beberapa cara.',
      ),
      QuizQuestion(
        question:
            'Konten belum bisa dipastikan asli atau buatan AI. Apa yang sebaiknya kamu lakukan?',
        options: [
          'Sebarkan dengan caption “pasti asli”',
          'Tuduh pembuatnya tanpa bukti',
          'Nyatakan belum terverifikasi dan tahan penyebarannya',
          'Hapus konteks sumber agar lebih meyakinkan',
        ],
        correctIndex: 2,
        explanation:
            'Sampaikan batas bukti secara jujur. Dugaan tidak boleh diubah menjadi kepastian.',
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
            '“Acara dimulai pukul 10.00” dan “acaranya sangat membosankan”. Bagaimana kamu membedakan keduanya?',
        options: [
          'Keduanya opini',
          'Keduanya pasti fakta',
          'Pernyataan pertama bisa diuji; kedua adalah penilaian',
          'Pernyataan pertama satire',
        ],
        correctIndex: 2,
        explanation:
            'Waktu mulai bisa dicocokkan dengan catatan atau saksi. “Membosankan” adalah penilaian yang bergantung pada pengalaman orang.',
      ),
      QuizQuestion(
        question:
            'Unggahan lucu dikutip sebagai berita tanpa sumber aslinya. Apa langkah yang paling tepat?',
        options: [
          'Anggap benar karena banyak dibagikan',
          'Periksa akun dan konteks publikasi lengkapnya',
          'Nilai hanya dari banyaknya emoji',
          'Hapus bagian yang menunjukkan humor',
        ],
        correctIndex: 1,
        explanation:
            'Konteks sumber membantu mengenali apakah unggahan itu satire, parodi, atau laporan faktual.',
      ),
      QuizQuestion(
        question: 'Artikel mencampur fakta dan opini. Cara memeriksanya?',
        options: [
          'Tolak seluruh isi tanpa membacanya',
          'Anggap semua kalimat sebagai data',
          'Percaya karena penulisnya terdengar yakin',
          'Pisahkan klaim yang bisa diuji dari tafsiran, lalu periksa buktinya',
        ],
        correctIndex: 3,
        explanation:
            'Memisahkan klaim dan tafsiran membuat pemeriksaan lebih terarah dan adil.',
      ),
      QuizQuestion(
        question: 'Apakah gaya bahasa yang serius menjamin sebuah klaim benar?',
        options: [
          'Tidak; klaim faktual tetap perlu bukti dan sumber',
          'Ya, gaya serius selalu akurat',
          'Ya, asalkan artikelnya panjang',
          'Tidak; semua tulisan serius adalah satire',
        ],
        correctIndex: 0,
        explanation:
            'Nada tulisan tidak menggantikan bukti. Periksa klaim dan sumbernya secara langsung.',
      ),
    ],
  ),
];

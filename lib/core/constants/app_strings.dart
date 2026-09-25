import '../errors/failures.dart';

// String terpusat — Bahasa Indonesia (PRD: AI response santai tapi informatif).
abstract final class AppStrings {
  static const String appName = 'LiterasiAI';
  static const String tagline =
      'Cek dulu sebelum sebar. Hasil dalam hitungan detik.';

  static const String onboardingTitle1 = 'Cek Hoaks Instan dengan AI';
  static const String onboardingEyebrow1 = 'VERIFIKASI TEKS';
  static const String onboardingDesc1 =
      'Tempel teks dari mana saja: chat, medsos, atau berita. AI beri verdict jelas dalam hitungan detik.';
  static const String onboardingTitle2 = 'Analisis Gambar & Link';
  static const String onboardingEyebrow2 = 'MULTI-FORMAT';
  static const String onboardingDesc2 =
      'Upload screenshot atau tempel link berita. AI baca dan verifikasi multi-format.';
  static const String onboardingTitle3 = 'Riwayat Terpercaya, Akses Mudah';
  static const String onboardingEyebrow3 = 'RIWAYAT AMAN';
  static const String onboardingDesc3 =
      'Semua hasil tersimpan rapi dan siap dibagikan ke WhatsApp untuk lawan hoaks.';

  static const String onboardingNext = 'Lanjut';
  static const String onboardingStart = 'Mulai Sekarang';
  static const String onboardingBack = 'Kembali';
  static const String onboardingSkip = 'Lewati';

  static const String authTitle = 'Masuk ke LiterasiAI';
  static const String authSubtitle =
      'Masuk untuk menyimpan riwayat cek faktamu di semua perangkat.';
  static const String authEmailLabel = 'Email';
  static const String authEmailHint = 'nama@email.com';
  static const String authEmailError = 'Masukkan alamat email yang valid.';
  static const String authPasswordLabel = 'Kata sandi';
  static const String authPasswordHint = 'Minimal 6 karakter';
  static const String authPasswordError = 'Kata sandi minimal 6 karakter.';
  static const String authSubmit = 'Masuk';
  static const String authFormTitle = 'Masuk dengan email';
  static const String authFormSubtitle =
      'Validasi dulu, lalu lanjut ke jalur yang tersedia.';
  static const String authNoAccount =
      'Belum punya akun email? Coba masuk dengan Google atau lanjut tanpa akun.';
  static const String authDivider = 'atau';
  static const String authGoogle = 'Masuk dengan Google';
  static const String authAnonymous = 'Lanjut tanpa akun';
  static const String authOfflineNote =
      'Mode tanpa akun. Riwayat hanya tersimpan di perangkat ini.';
  static const String authEmailSent =
      'Tautan masuk dikirim. Cek kotak masuk emailmu.';
  static const String authGoogleFailed =
      'Masuk Google gagal. Periksa koneksi atau lanjut tanpa akun.';
  static const String authAnonymousFailed =
      'Mode offline. Firebase belum dikonfigurasi.';
  static const String authGoRegisterPrefix = 'Belum punya akun?';
  static const String authGoRegisterAction = 'Daftar';
  static const String authGoLoginPrefix = 'Sudah punya akun?';
  static const String authGoLoginAction = 'Masuk';
  static const String authForgotLink = 'Lupa kata sandi?';

  static const String registerTitle = 'Buat Akun LiterasiAI';
  static const String registerSubtitle =
      'Satu akun untuk menyimpan semua riwayat cek faktamu.';
  static const String registerNameLabel = 'Nama lengkap';
  static const String registerNameHint = 'Nama kamu';
  static const String registerNameError = 'Masukkan namamu.';
  static const String registerConfirmLabel = 'Ulangi kata sandi';
  static const String registerConfirmHint = 'Ketik ulang kata sandi';
  static const String registerMismatch = 'Kata sandi tidak sama. Coba lagi.';
  static const String registerFormTitle = 'Data akun baru';
  static const String registerFormSubtitle =
      'Syarat sandi diperiksa otomatis saat kamu mengetik.';
  static const String registerReqLength = 'Minimal 6 karakter';
  static const String registerReqDigit = 'Mengandung angka';
  static const String registerSubmit = 'Daftar';
  static const String registerPending =
      'Pendaftaran email segera dibuka. Untuk sekarang, masuk dengan Google atau lanjut tanpa akun.';

  static const String forgotTitle = 'Lupa Kata Sandi';
  static const String forgotSubtitle =
      'Masukkan email terdaftar. Kami kirim tautan atur ulang ke sana.';
  static const String forgotSubmit = 'Kirim Tautan';
  static const String forgotFormTitle = 'Kirim tautan atur ulang';
  static const String forgotFormSubtitle =
      'Periksa juga folder spam setelah tautan dikirim.';
  static const String forgotSent =
      'Tautan terkirim. Cek kotak masuk dan folder spam emailmu.';
  static const String forgotFailed =
      'Gagal mengirim. Pastikan email benar dan koneksi stabil.';
  static const String forgotBack = 'Kembali masuk';

  static const String quickCheckTitle = 'Quick Check';
  static const String quickCheckSubtitle =
      'Periksa satu informasi dalam satu sesi yang fokus. Hasilnya tersusun rapi dan mudah dibaca.';
  static const String quickCheckStartSession = 'Mulai Pemeriksaan';
  static const String quickCheckCtaTitle = 'Siap memeriksa informasi?';
  static const String quickCheckCtaSubtitle =
      'Masuk ke sesi fokus untuk teks, gambar, atau link. Hasil keluar dalam hitungan detik.';
  static const String quickCheckBackLabel = 'Kembali';
  static const String quickCheckSessionTitle1 = 'Sesi ';
  static const String quickCheckSessionTitle2 = 'pemeriksaan.';
  static const String quickCheckSessionEyebrow = 'SESI FOKUS';
  static const String quickCheckSessionSubtitle =
      'Fokus pada satu informasi dalam satu sesi. Kamu bisa kembali kapan pun tanpa kehilangan konteks tab utama.';
  static const String quickCheckModePickerTitle = 'Pilih cara memeriksa';
  static const String quickCheckModePickerSubtitle =
      'Langsung masuk ke sesi yang sesuai tanpa langkah tambahan.';
  static const String quickCheckTileTextTitle = 'Cek teks';
  static const String quickCheckTileTextSubtitle = 'Tempel tulisan 10-2.000';
  static const String quickCheckTileImageTitle = 'Cek gambar';
  static const String quickCheckTileImageSubtitle = 'Screenshot maks 5 MB';
  static const String quickCheckExampleTitle = 'Coba contoh sekali ketuk';
  static const String quickCheckExampleSubtitle =
      'Ketuk salah satu contoh untuk langsung mengisi sesi pemeriksaan.';
  static const String quickCheckExampleCta = 'Cek ini';
  static const String quickCheckExample1 =
      'Apakah benar minum air rebusan daun tertentu dapat menyembuhkan semua penyakit?';
  static const String quickCheckExample2 =
      'Beredar pesan berantai tentang bantuan tunai yang meminta data rekening. Apakah ini penipuan?';
  static const String quickCheckExample3 =
      'Viral kabar libur nasional tambahan minggu ini. Apakah informasi ini valid?';
  static const String quickCheckExample4 =
      'Ada broadcast yang mengklaim gempa besar akan terjadi besok di kota tertentu. Apakah informasi ini bisa dipercaya?';
  static const String quickCheckExample5 =
      'Beredar kabar lowongan kerja bergaji besar yang meminta biaya pendaftaran di awal. Apakah ini modus penipuan?';
  static const String trendingTitle = 'Trending hoaks';
  static const String trendingSubtitle =
      'Hoaks viral yang dikurasi manual. Ketuk untuk detail dan verifikasi serupa.';
  static const String trendingHot = 'HOT';
  static const String trendingReference = 'Rujukan';
  static const String trendingVerifySimilar = 'Verifikasi serupa';
  static const String trendingRelatedTitle = 'Konteks terkait';
  static const String quickCheckBackToHome = 'Kembali ke Beranda';
  static const String navCheck = 'Cek';
  static const String navHistory = 'Riwayat';
  static const String navLearn = 'Belajar';
  static const String navProfile = 'Profil';
  static const String homeCheckTitle1 = 'Cek kebenaran';
  static const String homeCheckTitle2 = 'sebelum sebar.';
  static const String homeCheckSubtitle =
      'Satu sesi fokus untuk teks, gambar, atau link — hasil dan saran verifikasi langsung keluar.';
  static const String homeHistoryEyebrow = 'AKTIVITAS';
  static const String homeHistoryTitle1 = 'Jejak';
  static const String homeHistoryTitle2 = 'pemeriksaanmu.';
  static const String homeHistorySubtitle =
      'Semua hasil yang tersimpan, siap ditinjau kembali.';
  static const String historyFilterAll = 'Semua';
  static const String historyFilterHoaks = 'Hoaks';
  static const String historyFilterValid = 'Valid';
  static const String historyFilterNeedCheck = 'Perlu Dicek';
  static const String historyEmptyTitle = 'Belum ada riwayat';
  static const String historyEmptySubtitle =
      'Mulai pemeriksaan pertama dari tab Cek. Hasilmu akan tersimpan di sini.';
  static const String historyEmptyCta = 'Mulai pemeriksaan';
  static const String historyEmptyFilteredTitle = 'Belum ada hasil di filter ini';
  static const String historyEmptyFilteredSubtitle =
      'Coba pilih filter lain untuk melihat pemeriksaan sebelumnya.';
  static const String historyDeleted = 'Riwayat dihapus.';
  static const String historyDeleteFailed =
      'Riwayat tidak dapat dihapus. Coba lagi.';
  static const String historyUndo = 'Urungkan';
  static const String historyRetryTitle = 'Riwayat tidak dapat dimuat';
  static const String historyLoading = 'Memuat riwayat...';
  static const String historySearchHint = 'Cari informasi yang pernah dicek...';
  static const String historyStatsTitle = 'Ringkasan';
  static const String historyDetailTitle = 'Detail Riwayat';
  static const String homeLearnEyebrow = 'EDUKASI';
  static const String homeLearnTitle1 = 'Naikkan';
  static const String homeLearnTitle2 = 'literasimu.';
  static const String homeLearnSubtitle =
      'Tiga modul singkat plus kuis untuk melatih insting cek fakta.';
  static const String learnProgressSuffix = 'modul selesai';
  static const String learnProgressLoading = 'Memuat progres belajar...';
  static const String learnPointsNote =
      'Selesaikan modul +20 poin, tiap jawaban kuis benar +5.';
  static const String learnModuleDone = 'Selesai';
  static const String learnDetailTitle = 'Modul belajar';
  static const String learnReadingProgress = 'Progres baca modul';
  static const String learnStartQuiz = 'Mulai kuis';
  static const String learnReadArticle = 'Baca modul';
  static const String learnMarkDone = 'Tandai selesai +20';
  static const String learnMarkedDone = 'Modul selesai. +20 poin diklaim.';
  static const String learnQuizTitle = 'Kuis pemahaman';
  static const String learnQuizOf = 'Soal';
  static const String learnQuizNext = 'Lanjut';
  static const String learnQuizFinish = 'Lihat hasil';
  static const String learnQuizCorrect = 'Benar!';
  static const String learnQuizWrong = 'Kurang tepat.';
  static const String learnQuizScoreTitle = 'Hasil kuismu';
  static const String learnQuizReviewTitle = 'Tinjau jawabanmu';
  static const String learnQuizClaim = 'Klaim poin';
  static const String learnQuizClaimed = 'poin kuis diklaim.';
  static const String learnQuizNoNew = 'Tidak ada poin baru. Skor terbaikmu bertahan.';
  static const String learnQuizRetry = 'Ulangi kuis';
  static const String learnQuizBack = 'Kembali ke modul';
  static const String learnGuestNote =
      'Masuk untuk menyimpan progres ke semua perangkat. Tanpa login progres hanya sesi ini.';
  static const String homeProfileEyebrow = 'AKUN';
  static const String homeProfileTitle1 = 'Kelola';
  static const String homeProfileTitle2 = 'profilmu.';
  static const String homeProfileSubtitle =
      'Skor literasi bertambah dari setiap pemeriksaan dan modul yang selesai.';
  static const String scoreLevelPrefix = 'Level';
  static const String scorePointsSuffix = 'poin';
  static const String scoreToNextPrefix = 'poin lagi ke';
  static const String scoreMaxLevel = 'Level tertinggi tercapai.';
  static const String scoreBreakdownTitle = 'Sumber poin';
  static const String scoreVerifyRow = 'Verifikasi';
  static const String scoreModuleRow = 'Modul selesai';
  static const String scoreQuizRow = 'Kuis benar';
  static const String scoreModuleSoon =
      'Poin dihitung dari skor terbaik: modul +20 sekali klaim, kuis +5 per jawaban benar baru.';
  static const String scoreGuestLabel = 'Tamu LiterasiAI';
  static const String scoreLoginCta = 'Masuk untuk sinkron';
  static const String scoreAnonymousNote =
      'Kamu masuk tanpa akun. Skor tersimpan lokal sesi ini; masuk untuk sinkron ke semua perangkat.';
  static const String scoreSyncedNote =
      'Skor tersinkron ke akunmu dan bertambah otomatis setiap verifikasi.';
  static const String scoreLoading = 'Memuat skor...';
  static const String scoreLoadFailed = 'Skor tidak dapat dimuat.';
  static const String scoreLoadFailedSubtitle =
      'Ini soal penyimpanan skor, bukan kunci API. Periksa koneksi atau aturan Firestore, lalu coba lagi.';
  static const String chatEyebrow = 'ASISTEN AI';
  static const String chatTitle1 = 'Tanya';
  static const String chatTitle2 = 'apa saja.';
  static const String chatHeaderSubtitle =
      'Diskusi santai soal hoaks dan literasi digital dalam Bahasa Indonesia.';
  static const String chatFabLabel = 'Chat dengan AI Literasi';
  static const String chatPresenceName = 'Asisten LiterasiAI';
  static const String chatPresenceStatus = 'Siap membantu verifikasi';
  static const String chatCancel = 'Batal';
  static const String chatKeyBannerTitle =
      'Mode pratinjau: kunci API belum tersambung';
  static const String chatKeyBannerSubtitle =
      'Jawaban live butuh kunci Gemini. Tempel kunci di Pengaturan atau salin perintah run untuk mode developer.';
  static const String chatKeyCopy = 'Salin perintah';
  static const String chatKeyCopied =
      'Perintah disalin. Tempel di terminal lalu jalankan ulang.';
  static const String chatRunCommand =
      'flutter run --dart-define=GEMINI_API_KEY=ISI_KUNCI_ANDA';
  static const String apiKeySettingsTitle = 'Kunci API Gemini';
  static const String apiKeySettingsSubtitle =
      'Tempel kunci pribadi untuk hasil live tanpa terminal. Tersimpan aman di perangkat ini saja.';
  static const String apiKeyFieldLabel = 'Kunci API';
  static const String apiKeyFieldHint = 'AIza...';
  static const String apiKeySave = 'Simpan kunci';
  static const String apiKeySaved = 'Kunci tersimpan. AI kini live.';
  static const String apiKeyRemoved = 'Kunci dihapus. Kembali ke mode demo.';
  static const String apiKeyRemove = 'Hapus kunci';
  static const String apiKeyRemoveConfirm =
      'Hapus kunci API dari perangkat ini? AI kembali ke mode demo.';
  static const String apiKeyInvalid =
      'Kunci API tidak valid. Tempel kunci lengkap tanpa spasi.';
  static const String apiKeySaveFailed = 'Gagal menyimpan kunci. Coba lagi.';
  static const String apiKeyActiveCompile = 'Aktif via dart-define developer.';
  static const String apiKeyActiveUser = 'Aktif via kunci perangkat.';
  static const String apiKeyInactive = 'Belum ada kunci. Mode demo aktif.';
  static const String apiKeyOpenSettings = 'Buka Pengaturan';
  static const String apiKeyHowToTitle = 'Dari mana dapat kunci?';
  static const String apiKeyHowToBody =
      'Buat gratis di Google AI Studio, salin kuncinya, lalu tempel di sini. Kunci tidak pernah dikirim ke mana pun selain API Gemini.';
  static const String demoBadge = 'DEMO';
  static const String demoResultNote =
      'Hasil demo offline — bukan penilaian AI live. Sambungkan kunci API untuk verifikasi sungguhan.';
  static const String chatGreetingTitle = 'Halo, aku asisten literasimu.';
  static const String chatGreetingSubtitle =
      'Tanya soal hoaks, clickbait, atau cara verifikasi sumber. Jawabanku santai tapi tetap kritis.';
  static const String chatSuggestion1 = 'Apakah vaksin menyebabkan autisme?';
  static const String chatSuggestion2 = 'Cara kenali judul clickbait?';
  static const String chatSuggestion3 = 'Cara verifikasi sumber berita?';
  static const String chatInputHint = 'Tulis pertanyaanmu...';
  static const String chatTyping = 'AI sedang mengetik...';
  static const String chatVerifyThis = 'Verifikasi ini';
  static const String chatRetry = 'Kirim ulang';
  static const String chatClear = 'Mulai baru';
  static const String chatClearConfirm = 'Hapus semua pesan?';
  static const String chatTooLong =
      'Pertanyaan terlalu panjang. Batasi maksimal 1.000 karakter.';
  static const String chatSendFailed = 'Pesan gagal dikirim. Coba lagi.';
  static const String quickCheckModeText = 'Teks';
  static const String quickCheckModeImage = 'Gambar';
  static const String quickCheckModeUrl = 'Link';
  static const String quickCheckModeHint =
      'Pilih Teks untuk tulisan, Gambar untuk tangkapan layar, atau Link untuk artikel berita.';
  static const String quickCheckTileUrlTitle = 'Cek link';
  static const String quickCheckTileUrlSubtitle = 'Artikel maks 2.000';
  static const String quickCheckImageTitle = 'Gambar yang diperiksa';
  static const String quickCheckImageSubtitle =
      'JPG, PNG, atau WebP maksimal 5 MB. AI membaca isi gambar terlebih dahulu.';
  static const String quickCheckImageEmptyTitle = 'Belum ada gambar';
  static const String quickCheckImageEmptySubtitle =
      'Pilih tangkapan layar percakapan atau berita dari galeri, atau ambil foto langsung.';
  static const String quickCheckPickGallery = 'Galeri';
  static const String quickCheckPickCamera = 'Kamera';
  static const String quickCheckReplaceImage = 'Ganti gambar';
  static const String quickCheckRemoveImage = 'Hapus gambar';
  static const String quickCheckCaptionLabel = 'Caption opsional';
  static const String quickCheckCaptionHint =
      'Contoh: tangkapan layar grup WhatsApp tentang vaksin, 12 Mei 2026.';
  static const String quickCheckPrivacyNote =
      'Jangan upload KTP, dokumen pribadi, atau data sensitif. Gambar dikirim ke AI untuk analisis.';
  static const String quickCheckImageCancelled = 'Pemilihan gambar dibatalkan.';
  static const String quickCheckUrlTitle = 'Link artikel yang diperiksa';
  static const String quickCheckUrlSubtitle =
      'Tempel link berita http(s). AI memuat judul dan ringkasannya dulu, lalu menilai klaim utamanya.';
  static const String quickCheckUrlFieldLabel = 'Tempel link berita';
  static const String quickCheckUrlHint = 'https://contoh.id/berita-penting';
  static const String quickCheckUrlPaste = 'Tempel';
  static const String quickCheckUrlPasteEmpty =
      'Clipboard kosong. Salin dulu link artikelnya.';
  static const String quickCheckUrlPrivacyNote =
      'AI memuat judul dan ringkasan artikel dari link ini. Jangan tempel link yang butuh login atau berisi data pribadi.';
  static const String quickCheckUrlTooShort =
      'Tempel link artikel yang valid agar AI bisa memuat isinya.';
  static const String quickCheckUrlTooLong =
      'Link terlalu panjang. Batasi maksimal 2.000 karakter.';
  static const String quickCheckUrlInvalid =
      'Link tidak valid. Pakai link http(s), contoh: https://contoh.id/berita.';
  static const String quickCheckSourceText = 'Sumber: Teks';
  static const String quickCheckSourceImage = 'Sumber: Gambar';
  static const String quickCheckSourceUrl = 'Sumber: Link';
  static const String quickCheckImageAttached = 'Gambar terlampir';
  static const String quickCheckUrlAttached = 'Link diperiksa';
  static const String quickCheckFormTitle = 'Informasi yang diperiksa';
  static const String quickCheckFormSubtitle =
      'Tulis satu informasi secara lengkap agar konteksnya jelas.';
  static const String quickCheckInputLabel = 'Tulis atau tempel informasi';
  static const String quickCheckInputHint =
      'Contoh: Apakah benar minum air rebusan daun ini dapat menyembuhkan semua penyakit?';
  static const String quickCheckTooShort =
      'Tulis informasi minimal 10 karakter agar AI memiliki konteks yang cukup.';
  static const String quickCheckTooLong =
      'Informasi terlalu panjang. Batasi maksimal 2.000 karakter.';
  static const String quickCheckVerify = 'Verifikasi Sekarang';
  static const String quickCheckClear = 'Bersihkan';
  static const String quickCheckAnalyzingTitle = 'AI sedang menganalisis';
  static const String quickCheckAnalyzingSubtitle =
      'Biasanya selesai dalam beberapa detik di koneksi normal.';
  static const String quickCheckResultTitle = 'Hasil verifikasi';
  static const String quickCheckClaimLabel = 'Informasi yang diperiksa';
  static const String quickCheckExplanationLabel = 'Penjelasan hasil';
  static const String quickCheckSuggestionLabel = 'Saran tindak lanjut';
  static const String quickCheckConfidenceLabel = 'Tingkat keyakinan AI';
  static const String quickCheckNewCheck = 'Periksa informasi lain';
  static const String quickCheckRetry = 'Coba lagi';
  static const String quickCheckShare = 'Bagikan Hasil';
  static const String quickCheckCopy = 'Salin hasil';
  static const String quickCheckCopied =
      'Hasil disalin. Tempel ke WhatsApp atau catatanmu.';
  static const String quickCheckSharing = 'Menyiapkan gambar...';
  static const String quickCheckShareFailed =
      'Gagal menyiapkan gambar. Mencoba bagikan sebagai teks.';
  static const String quickCheckTipsTitle = 'Cara dapat hasil terbaik';
  static const String quickCheckTip1 =
      'Tempel kalimat secara utuh, bukan potongan yang ambigu.';
  static const String quickCheckTip2 =
      'Hindari data pribadi seperti NIK atau informasi sensitif.';
  static const String quickCheckTip3 =
      'Bandingkan hasil AI dengan sumber resmi sebelum menyebarkan.';
  static const String quickCheckDisclaimer =
      'Hasil ini adalah bantuan literasi AI, bukan kebenaran mutlak. Bandingkan dengan sumber resmi sebelum menyebarkan informasi.';

  static const String connectionSlow = NetworkFailure.defaultMessage;
  static const String connectionTestTitle = 'Tes koneksi AI';
  static const String connectionTestRun = 'Tes koneksi sekarang';
  static const String connectionTestRunning = 'Menghubungi server AI...';
  static const String connectionTestOk =
      'Koneksi AI OK. Server menjawab dalam hitungan detik — kunci dan jaringan beres.';
  static const String connectionTestSlow =
      'Server tidak menjawab. Periksa koneksi, matikan VPN/ad-block, atau izinkan aplikasi di firewall/antivirus.';
  static const String connectionTestKeyInvalid =
      'Kunci API ditolak server. Salin ulang kunci dari Google AI Studio tanpa spasi.';
  static const String connectionTestFail =
      'Tes gagal. Coba lagi atau ganti jaringan (Wi-Fi/data seluler).';
  static const String imageUnreadable =
      'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.';

  static const String geminiApiKeyMissing =
      'GEMINI_API_KEY belum dikonfigurasi. Jalankan dengan --dart-define=GEMINI_API_KEY=...';
}

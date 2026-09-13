/// String terpusat — Bahasa Indonesia (PRD: AI response santai tapi informatif).
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
  static const String quickCheckLandingBadge = 'VERIFIKASI AI';
  static const String quickCheckLandingTitle = 'Cek kebenaran sebelum sebar';
  static const String quickCheckLandingSubtitle =
      'Tempel teks atau lampirkan tangkapan layar. AI memberikan hasil pemeriksaan, tingkat keyakinan, dan langkah lanjutan.';
  static const String quickCheckStartSession = 'Mulai Pemeriksaan';
  static const String quickCheckSessionTitle = 'Sesi pemeriksaan';
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
  static const String quickCheckBackToHome = 'Kembali ke Beranda';
  static const String navCheck = 'Cek';
  static const String navHistory = 'Riwayat';
  static const String navLearn = 'Belajar';
  static const String navProfile = 'Profil';
  static const String chatTitle = 'Chat AI';
  static const String chatFabLabel = 'Chat dengan AI Literasi';
  static const String chatPlaceholderTitle = 'Chat AI segera hadir';
  static const String chatPlaceholderSubtitle =
      'Layanan tanya jawab literasi digital sedang disiapkan. Untuk sekarang, gunakan sesi pemeriksaan untuk verifikasi cepat.';
  static const String quickCheckModeText = 'Teks';
  static const String quickCheckModeImage = 'Gambar';
  static const String quickCheckModeHint =
      'Pilih Teks untuk menempelkan tulisan, atau Gambar untuk tangkapan layar.';
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
  static const String quickCheckSourceText = 'Sumber: Teks';
  static const String quickCheckSourceImage = 'Sumber: Gambar';
  static const String quickCheckImageAttached = 'Gambar terlampir';
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
  static const String quickCheckTipsTitle = 'Cara dapat hasil terbaik';
  static const String quickCheckTip1 =
      'Tempel kalimat secara utuh, bukan potongan yang ambigu.';
  static const String quickCheckTip2 =
      'Hindari data pribadi seperti NIK atau informasi sensitif.';
  static const String quickCheckTip3 =
      'Bandingkan hasil AI dengan sumber resmi sebelum menyebarkan.';
  static const String quickCheckDisclaimer =
      'Hasil ini adalah bantuan literasi AI, bukan kebenaran mutlak. Bandingkan dengan sumber resmi sebelum menyebarkan informasi.';

  static const String connectionSlow = 'Koneksi lambat, coba lagi.';
  static const String imageUnreadable =
      'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.';

  static const String geminiApiKeyMissing =
      'GEMINI_API_KEY belum dikonfigurasi. Jalankan dengan --dart-define=GEMINI_API_KEY=...';
}

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
      'Verifikasi satu klaim dalam satu sesi fokus. Hasil terstruktur, tanpa gangguan.';
  static const String quickCheckLandingBadge = 'VERIFIKASI AI';
  static const String quickCheckLandingTitle = 'Cek kebenaran sebelum sebar';
  static const String quickCheckLandingSubtitle =
      'Tempel klaim teks atau lampirkan screenshot. AI memberi verdict, keyakinan, dan langkah lanjutan.';
  static const String quickCheckStartSession = 'Mulai Pemeriksaan';
  static const String quickCheckSessionTitle = 'Sesi pemeriksaan';
  static const String quickCheckSessionSubtitle =
      'Fokus pada satu klaim. Kamu bisa kembali kapan pun tanpa kehilangan konteks tab utama.';
  static const String quickCheckStepsTitle = 'Alur yang jelas';
  static const String quickCheckStep1Title = 'Teks atau gambar';
  static const String quickCheckStep1Subtitle = 'Teks 10-2.000 • gambar 5 MB';
  static const String quickCheckStep2Title = 'AI menganalisis';
  static const String quickCheckStep2Subtitle = 'Beberapa detik';
  static const String quickCheckStep3Title = 'Terima verdict';
  static const String quickCheckStep3Subtitle = 'HOAKS, VALID, dsb.';
  static const String quickCheckBackToHome = 'Kembali ke Beranda';
  static const String quickCheckModeText = 'Teks';
  static const String quickCheckModeImage = 'Gambar';
  static const String quickCheckModeHint =
      'Pilih teks untuk tempel klaim, atau gambar untuk screenshot.';
  static const String quickCheckImageTitle = 'Gambar klaim';
  static const String quickCheckImageSubtitle =
      'JPG, PNG, atau WebP maksimal 5 MB. AI membaca isi gambar dulu.';
  static const String quickCheckImageEmptyTitle = 'Belum ada gambar';
  static const String quickCheckImageEmptySubtitle =
      'Pilih screenshot chat atau berita dari galeri, atau potret langsung.';
  static const String quickCheckPickGallery = 'Galeri';
  static const String quickCheckPickCamera = 'Kamera';
  static const String quickCheckReplaceImage = 'Ganti';
  static const String quickCheckRemoveImage = 'Hapus gambar';
  static const String quickCheckCaptionLabel = 'Caption opsional';
  static const String quickCheckCaptionHint =
      'Contoh: screenshot grup WA tentang vaksin, 12 Mei 2026.';
  static const String quickCheckPrivacyNote =
      'Jangan upload KTP, dokumen pribadi, atau data sensitif. Gambar dikirim ke AI untuk analisis.';
  static const String quickCheckImageCancelled = 'Pemilihan gambar dibatalkan.';
  static const String quickCheckSourceText = 'SUMBER: TEKS';
  static const String quickCheckSourceImage = 'SUMBER: GAMBAR';
  static const String quickCheckImageAttached = 'Gambar terlampir';
  static const String quickCheckFormTitle = 'Klaim yang dicek';
  static const String quickCheckFormSubtitle =
      'Tulis utuh satu klaim agar konteksnya jelas.';
  static const String quickCheckInputLabel = 'Tulis atau tempel klaim';
  static const String quickCheckInputHint =
      'Contoh: Benarkah minum air rebusan daun ini bisa menyembuhkan semua penyakit?';
  static const String quickCheckTooShort =
      'Tulis klaim minimal 10 karakter agar AI punya konteks yang cukup.';
  static const String quickCheckTooLong =
      'Klaim terlalu panjang. Batasi maksimal 2.000 karakter.';
  static const String quickCheckVerify = 'Verifikasi Sekarang';
  static const String quickCheckClear = 'Bersihkan';
  static const String quickCheckAnalyzingTitle = 'AI sedang menganalisis';
  static const String quickCheckAnalyzingSubtitle =
      'Biasanya selesai dalam beberapa detik di koneksi normal.';
  static const String quickCheckResultTitle = 'Hasil verifikasi';
  static const String quickCheckClaimLabel = 'Klaim';
  static const String quickCheckExplanationLabel = 'Kenapa dinilai begitu?';
  static const String quickCheckSuggestionLabel = 'Langkah berikutnya';
  static const String quickCheckConfidenceLabel = 'Tingkat keyakinan AI';
  static const String quickCheckNewCheck = 'Cek klaim lain';
  static const String quickCheckRetry = 'Coba lagi';
  static const String quickCheckTipsTitle = 'Cara dapat hasil terbaik';
  static const String quickCheckTip1 =
      'Tempel kalimat utuh, bukan potongan yang ambigu.';
  static const String quickCheckTip2 =
      'Hindari data pribadi seperti NIK atau info sensitif.';
  static const String quickCheckTip3 =
      'Bandingkan hasil AI dengan sumber resmi sebelum menyebar.';
  static const String quickCheckDisclaimer =
      'Hasil ini adalah bantuan literasi AI, bukan kebenaran mutlak. Bandingkan dengan sumber resmi sebelum menyebarkan informasi.';

  static const String connectionSlow = 'Koneksi lambat, coba lagi.';
  static const String imageUnreadable =
      'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.';

  static const String geminiApiKeyMissing =
      'GEMINI_API_KEY belum dikonfigurasi. Jalankan dengan --dart-define=GEMINI_API_KEY=...';
}

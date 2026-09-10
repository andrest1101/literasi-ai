/// String terpusat — Bahasa Indonesia (PRD: AI response santai tapi informatif).
abstract final class AppStrings {
  static const String appName = 'LiterasiAI';
  static const String tagline = 'Cek dulu sebelum sebar. Hasil dalam hitungan detik.';

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
  static const String authEyebrow = 'MASUK GRATIS';
  static const String authEmailLabel = 'Email';
  static const String authEmailHint = 'nama@email.com';
  static const String authEmailError = 'Masukkan alamat email yang valid.';
  static const String authPasswordLabel = 'Kata sandi';
  static const String authPasswordHint = 'Minimal 6 karakter';
  static const String authPasswordError = 'Kata sandi minimal 6 karakter.';
  static const String authSubmit = 'Masuk';
  static const String authNoAccount =
      'Belum punya akun email? Coba masuk dengan Google atau lanjut tanpa akun.';
  static const String authDivider = 'atau';
  static const String authGoogle = 'Masuk dengan Google';
  static const String authAnonymous = 'Lanjut tanpa akun';
  static const String authOfflineNote =
      'Tanpa akun pun bisa. Riwayat hanya tersimpan di perangkat ini.';
  static const String authTrust = 'Data privat, tersimpan per akun';
  static const String authEmailSent =
      'Tautan masuk dikirim. Cek kotak masuk emailmu.';
  static const String authGoogleFailed =
      'Masuk Google gagal. Periksa koneksi atau lanjut tanpa akun.';
  static const String authAnonymousFailed =
      'Mode offline. Firebase belum dikonfigurasi.';
  static const String authGoRegister = 'Belum punya akun? Daftar';
  static const String authGoLogin = 'Sudah punya akun? Masuk';
  static const String authForgotLink = 'Lupa kata sandi?';

  static const String registerTitle = 'Buat Akun LiterasiAI';
  static const String registerSubtitle =
      'Satu akun untuk menyimpan semua riwayat cek faktamu.';
  static const String registerEyebrow = 'DAFTAR GRATIS';
  static const String registerNameLabel = 'Nama lengkap';
  static const String registerNameHint = 'Nama kamu';
  static const String registerNameError = 'Masukkan namamu.';
  static const String registerConfirmLabel = 'Ulangi kata sandi';
  static const String registerConfirmHint = 'Ketik ulang kata sandi';
  static const String registerMismatch = 'Kata sandi tidak sama. Coba lagi.';
  static const String registerReqLength = 'Minimal 6 karakter';
  static const String registerReqDigit = 'Mengandung angka';
  static const String registerSubmit = 'Daftar';
  static const String registerPending =
      'Pendaftaran email segera dibuka. Untuk sekarang, masuk dengan Google atau lanjut tanpa akun.';

  static const String forgotTitle = 'Lupa Kata Sandi';
  static const String forgotSubtitle =
      'Masukkan email terdaftar. Kami kirim tautan atur ulang ke sana.';
  static const String forgotEyebrow = 'ATUR ULANG';
  static const String forgotSubmit = 'Kirim Tautan';
  static const String forgotSent =
      'Tautan terkirim. Cek kotak masuk dan folder spam emailmu.';
  static const String forgotFailed =
      'Gagal mengirim. Pastikan email benar dan koneksi stabil.';
  static const String forgotBack = 'Kembali masuk';

  static const String connectionSlow = 'Koneksi lambat, coba lagi.';
  static const String imageUnreadable =
      'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.';

  static const String geminiApiKeyMissing =
      'GEMINI_API_KEY belum dikonfigurasi. Jalankan dengan --dart-define=GEMINI_API_KEY=...';
}

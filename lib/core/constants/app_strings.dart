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

  static const String connectionSlow = 'Koneksi lambat, coba lagi.';
  static const String imageUnreadable =
      'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.';

  static const String geminiApiKeyMissing =
      'GEMINI_API_KEY belum dikonfigurasi. Jalankan dengan --dart-define=GEMINI_API_KEY=...';
}

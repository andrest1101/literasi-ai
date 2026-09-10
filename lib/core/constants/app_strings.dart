/// String terpusat — Bahasa Indonesia (PRD: AI response santai tapi informatif).
abstract final class AppStrings {
  static const String appName = 'LiterasiAI';
  static const String tagline = 'Cek dulu sebelum sebar — dalam hitungan detik.';

  static const String onboardingTitle1 = 'Cek Hoaks Instan dengan AI';
  static const String onboardingDesc1 =
      'Tempel teks mencurigakan dari grup chat, AI beri verdict jelas dalam hitungan detik.';
  static const String onboardingTitle2 = 'Analisis Gambar & Link';
  static const String onboardingDesc2 =
      'Upload screenshot atau tempel link berita — AI baca dan verifikasi multi-format.';
  static const String onboardingTitle3 = 'Riwayat Terpercaya, Akses Mudah';
  static const String onboardingDesc3 =
      'Semua hasil tersimpan rapi dan siap dibagikan ke WhatsApp untuk lawan hoaks.';

  static const String onboardingNext = 'Lanjut';
  static const String onboardingStart = 'Mulai Sekarang';
  static const String onboardingBack = 'Kembali';
  static const String onboardingSkip = 'Lewati';

  static const String authTitle = 'Masuk ke LiterasiAI';
  static const String authGoogle = 'Masuk dengan Google';
  static const String authAnonymous = 'Lanjut tanpa akun';

  static const String connectionSlow = 'Koneksi lambat, coba lagi.';
  static const String imageUnreadable =
      'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.';

  static const String geminiApiKeyMissing =
      'GEMINI_API_KEY belum dikonfigurasi. Jalankan dengan --dart-define=GEMINI_API_KEY=...';
}

/// String terpusat — Bahasa Indonesia (PRD: AI response santai tapi informatif).
abstract final class AppStrings {
  static const String appName = 'LiterasiAI';
  static const String tagline = 'Cek dulu sebelum sebar — dalam hitungan detik.';

  static const String onboardingTitle1 = 'Cek Fakta Instan';
  static const String onboardingDesc1 =
      'Verifikasi teks, gambar, atau link dalam hitungan detik.';
  static const String onboardingTitle2 = 'Chat dengan AI';
  static const String onboardingDesc2 =
      'Tanya-jawab seputar literasi digital dalam Bahasa Indonesia.';
  static const String onboardingTitle3 = 'Sebar Edukasi';
  static const String onboardingDesc3 =
      'Bagikan hasil verifikasi ke WhatsApp untuk lawan hoaks.';

  static const String authTitle = 'Masuk ke LiterasiAI';
  static const String authGoogle = 'Masuk dengan Google';
  static const String authAnonymous = 'Lanjut tanpa akun';

  static const String connectionSlow = 'Koneksi lambat, coba lagi.';
  static const String imageUnreadable =
      'Gambar tidak terbaca, upload ulang dengan pencahayaan lebih baik.';

  static const String geminiApiKeyMissing =
      'GEMINI_API_KEY belum dikonfigurasi. Jalankan dengan --dart-define=GEMINI_API_KEY=...';
}

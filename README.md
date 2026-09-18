# LiterasiAI — Cek dulu sebelum sebar

Aplikasi mobile verifikasi fakta berbasis AI untuk masyarakat Indonesia:
tempel teks, gambar, atau link → verdict dalam hitungan detik → bagikan ke
WhatsApp. Dilengkapi asisten chat literasi, riwayat Firestore, mini-course,
skor literasi, dan feed trending hoaks. Target: portfolio Apple Developer
Academy 2026.

## Purpose

Indonesia termasuk negara dengan penyebaran hoaks tertinggi — mayoritas lewat
WhatsApp, Instagram, dan Facebook (Kominfo). Masyarakat tidak punya alat yang
mudah, cepat, dan tepercaya untuk verifikasi mandiri. LiterasiAI hadir sebagai
solusi: verifikasi fakta AI dalam hitungan detik langsung dari smartphone,
plus edukasi literasi digital yang ringkas.

## Fitur

- **Quick Check** — 3 mode: teks (10–2.000 karakter), gambar (JPG/PNG/WebP
  maks 5 MB via Gemini Vision), link artikel (fetch judul + deskripsi lalu
  nilai klaim). Output: verdict HOAKS / VALID / PERLU DICEK /
  TIDAK DAPAT DIPASTIKAN + confidence + penjelasan + saran.
- **AI Chat Assistant** — tanya-jawab literasi Bahasa Indonesia santai,
  bubble WhatsApp-style, tombol "Verifikasi ini" ke Quick Check.
- **History** — Firestore per user `users/{uid}/verifications`, filter 4
  verdict, swipe delete + Undo, detail reuse kartu hasil + Share.
- **Share Hasil** — render kartu verdict ke PNG via `screenshot`, kirim via
  `share_plus` (WhatsApp/medsos), fallback teks bila capture gagal.
- **Trending Hoaks** — 7 hoaks curated offline + badge HOT, tap ke detail.
- **Mini-Course** — 3 modul 5 menit (clickbait, gambar manipulasi, verifikasi
  sumber): artikel 4 seksi + kuis 3 soal berpenjelasan + badge.
- **Literacy Score** — +10 verifikasi, +20 modul, +5 kuis benar. Level Pemula
  (0–49) → Waspada (50–149) → Kritis (150–299) → Ahli (300+).
- **BYOK + Mode Demo** — tanpa kartu/blaze: tempel kunci Gemini di Pengaturan
  (secure storage OS) untuk hasil live, atau pakai mode demo offline yang
  jujur berlabel DEMO. Guest tanpa login tetap bisa cek, chat, baca modul.

## Process

Clean Architecture feature-based + Riverpod (`Notifier`/`AsyncNotifier` +
`ConsumerWidget`): domain murni Dart, data (Gemini `gemini-3.5-flash-lite` +
Firestore), presentation (screens/widgets/providers). Setiap request AI jujur
soal kegagalan: timeout 30 dtk, kuota/safety/key-invalid mapping ramah, dan
fallback `TIDAK_DAPAT_DIPASTIKAN` sebagai sukses bukan error. Riwayat dan skor
auto-save best-effort tanpa menahan hasil AI. `firestore.rules` owner-only
`users/{uid}/**` (deploy manual via console, tanpa Blaze).

## Outcome

- `flutter analyze` bersih, `flutter test` lolos 138 test.
- Demo 60 detik tanpa setup: contoh sekali-ketuk → sesi → verdict → share;
  Chat saran → Verifikasi ini; Learn kuis → klaim poin.
- Klaim <5 detik didukung instrumentasi durasi di kartu hasil + cache klaim
  identik + rate limit per sesi (hemat kuota free tier).

## Cara menjalankan

```bash
flutter pub get
# Mode developer (kunci saat compile):
flutter run --dart-define=GEMINI_API_KEY=ISI_KUNCI_ANDA
# Atau jalankan biasa lalu tempel kunci di Profil → Kunci API Gemini:
flutter run
flutter analyze
flutter test
```

Butuh: Flutter 3.32+, Firebase project (`flutterfire configure`,
Auth Google + Anonymous, Firestore), kunci Gemini dari Google AI Studio
(gratis). Deploy `firestore.rules` via Firebase Console → Firestore → Rules.

## Arsitektur

```
lib/
├── app/home_screen.dart          # 4 tab + FAB Chat
├── core/{constants,errors,utils} # colors/strings/styles, failures,
│                                 # api_key_store/resolver, share_service
├── features/
│   ├── auth/                     # onboarding flag + login/Google/anonim
│   ├── quick_check/              # teks/gambar/link + share + demo
│   ├── chat/                     # asisten literasi + demo edukatif
│   ├── history/                  # Firestore per user + filter + undo
│   ├── trending/                 # feed curated offline
│   ├── learn/                    # 3 modul + kuis + progres
│   └── score/                    # level + ring + BYOK Pengaturan
└── shared/widgets/               # header editorial, navbar, error/loading
```

Lihat `PRD.md` (spesifikasi) dan `progress.md` (riwayat pengerjaan).

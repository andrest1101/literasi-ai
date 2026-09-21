# LiterasiAI — Cek dulu sebelum sebar

[![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-DD2C00?logo=firebase&logoColor=white)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Gemini-3.5--flash--lite-1A73E8?logo=google&logoColor=white)](https://ai.google.dev)
[![Tests](https://img.shields.io/badge/tests-153%20passed-34A853?logo=flutter&logoColor=white)](#-pengujian)
[![Analyze](https://img.shields.io/badge/flutter%20analyze-clean-34A853)](#-pengujian)

Aplikasi mobile verifikasi fakta berbasis AI untuk masyarakat Indonesia.
Tempel teks, gambar, atau link → verdict dalam hitungan detik → bagikan ke
WhatsApp. Dilengkapi asisten chat literasi, riwayat Firestore, mini-course,
skor literasi, dan feed trending hoaks. Target: portfolio Apple Developer
Academy 2026.

> **Purpose.** Indonesia termasuk negara dengan penyebaran hoaks tertinggi —
> mayoritas lewat WhatsApp, Instagram, dan Facebook (Kominfo). Masyarakat
> tidak punya alat yang mudah, cepat, dan tepercaya untuk verifikasi mandiri.
> LiterasiAI hadir sebagai solusi: verifikasi fakta AI dalam hitungan detik
> langsung dari smartphone, plus edukasi literasi digital yang ringkas.

## Daftar isi

- [Fitur](#-fitur)
- [Demo 60 detik](#-demo-60-detik)
- [Mulai cepat](#-mulai-cepat)
- [Konfigurasi](#️-konfigurasi)
- [Arsitektur](#️-arsitektur)
- [Pengujian](#-pengujian)
- [Status & roadmap](#-status--roadmap)
- [Troubleshooting](#-troubleshooting)
- [Dokumentasi](#-dokumentasi)

## ✨ Fitur

| Fitur | Ringkasan |
| ----- | --------- |
| **Quick Check** | 3 mode: teks (10–2.000 karakter), gambar (JPG/PNG/WebP maks 5 MB via Gemini Vision), link artikel (fetch judul + deskripsi lalu nilai klaim). Output: verdict `HOAKS` / `VALID` / `PERLU DICEK` / `TIDAK DAPAT DIPASTIKAN` + confidence + penjelasan + saran. |
| **AI Chat Assistant** | Tanya-jawab literasi Bahasa Indonesia yang santai, bubble WhatsApp-style, tombol **Verifikasi ini** untuk meneruskan pesan ke Quick Check. |
| **History** | Firestore per user (`users/{uid}/verifications`), filter 4 verdict, swipe-to-delete + Undo, tap untuk detail reuse kartu hasil + Share. |
| **Share Hasil** | Render kartu verdict ke PNG via `screenshot`, kirim via `share_plus` (WhatsApp/medsos), fallback teks bila capture gagal. |
| **Trending Hoaks** | 7 hoaks curated offline + badge `HOT`, tap untuk detail. |
| **Mini-Course** | 3 modul 5 menit (clickbait, gambar manipulasi, verifikasi sumber): artikel 4 seksi + kuis 3 soal berpenjelasan + badge. |
| **Literacy Score** | +10 verifikasi, +20 modul, +5 kuis benar. Level Pemula (0–49) → Waspada (50–149) → Kritis (150–299) → Ahli (300+). |
| **BYOK + Mode Demo** | Tanpa kartu/Blaze: tempel kunci Gemini di Pengaturan (secure storage OS) untuk hasil live, atau pakai mode demo offline yang jujur berlabel `DEMO`. Guest tanpa login tetap bisa cek, chat, dan baca modul. |

## 🎬 Demo 60 detik

1. Buka tab **Cek** → ketuk salah satu contoh sekali-ketuk.
2. Sesi terbuka → verdict + confidence tampil → ketuk **Bagikan Hasil**.
3. Buka **Chat** → ketuk saran → **Verifikasi ini**.
4. Buka **Belajar** → selesaikan kuis → klaim poin.

Tanpa setup: mode demo berjalan offline dan selalu berlabel `DEMO`.

## 🚀 Mulai cepat

### Prasyarat

- Flutter 3.32+ (Dart 3.8+) — cek dengan `flutter doctor`
- Firebase project + kunci Gemini gratis dari Google AI Studio
- **Linux desktop:** `sudo apt-get install -y libsecret-1-dev` (wajib untuk plugin secure storage)

### Install & run

```bash
flutter pub get

# Mode developer (kunci dipakai saat compile):
flutter run --dart-define=GEMINI_API_KEY=ISI_KUNCI_ANDA

# Atau: jalankan biasa, lalu tempel kunci di Profil → Kunci API Gemini
flutter run

# Desktop Linux / macOS / Windows juga didukung:
flutter run -d linux
```

### Verifikasi

```bash
flutter analyze   # harus: No issues found!
flutter test      # 153 test, semua lolos
```

## ⚙️ Konfigurasi

| Kebutuhan | Cara |
| --------- | ---- |
| Firebase project | `flutterfire configure` → hasilkan `lib/firebase_options.dart` |
| Auth | Aktifkan **Google** + **Anonymous** di Firebase Console |
| Database | Aktifkan **Firestore**, lalu deploy `firestore.rules` via Console → Firestore → Rules (owner-only `users/{uid}/**`, tanpa Blaze) |
| Kunci Gemini | Opsi A: `--dart-define=GEMINI_API_KEY=...` saat run. Opsi B (BYOK): tempel di **Profil → Kunci API Gemini**, tersimpan di secure storage OS |
| Android Google Sign-In | Daftarkan SHA-1 debug di Firebase Console agar `oauth_client` terisi |

> `apiKey` di `firebase_options.dart` adalah client key publik hasil
> FlutterFire — aman di repo. Kunci Gemini tidak pernah di-hardcode.

## 🏗️ Arsitektur

Clean Architecture feature-based + Riverpod (`Notifier`/`AsyncNotifier` +
`ConsumerWidget`): domain murni Dart, data (Gemini `gemini-3.5-flash-lite` +
Firestore), presentation (screens/widgets/providers).

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

Prinsip yang dijaga:

- Setiap request AI jujur soal kegagalan: timeout 30 dtk, mapping ramah
  untuk kuota/safety/key-invalid, dan fallback `TIDAK_DAPAT_DIPASTIKAN`
  sebagai **sukses**, bukan error.
- Riwayat dan skor auto-save **best-effort** tanpa menahan hasil AI.
- Klaim `<5 detik` didukung instrumentasi durasi di kartu hasil + cache
  klaim identik (LRU 20) + rate limit per sesi (hemat kuota free tier).
- Copy user-facing terpusat di `AppStrings`; token visual di
  `AppColors`/`AppStyles` (grid 8pt, radius terpusat).

## ✅ Pengujian

- **153 test** (`flutter test`): domain, datasource, repository, provider,
  dan widget — termasuk render aset logo, alur auth, sesi Quick Check,
  share, dan regresi performa (cache + rate limit).
- **Analyze bersih**: `flutter analyze` → `No issues found!`
- Konvensi: setiap perubahan perilaku wajib ditemani/update test
  regresi; file test per tema (`*_test.dart`).

## 🗺️ Status & roadmap

- [x] MVP: Quick Check 3 mode, Chat, History Firestore, Share, Trending, Mini-Course, Score, BYOK/Demo, Onboarding, Polish premium
- [ ] UI polish lanjutan (micro-interactions terkurasi)
- [ ] Video demo 60 detik
- [ ] Merge final `dev` → `main` + publikasi GitHub

## 🛠️ Troubleshooting

| Gejala | Solusi |
| ------ | ------ |
| `libsecret-1>=0.18.4 not found` saat build Linux | `sudo apt-get install -y libsecret-1-dev` |
| `Permission denied → /usr/local/...` saat `flutter run -d linux` | Hapus cache CMake basi: `rm -rf build/linux`, lalu run ulang |
| Error login Google di Android | SHA-1 debug belum didaftarkan di Firebase Console |
| Skor/history gagal tersimpan | `firestore.rules` belum di-deploy (owner-only `users/{uid}/**`) |
| `文字`/`TIDAK_DAPAT_DIPASTIKAN` selalu muncul | Kunci Gemini kosong/invalid — cek **Profil → Kunci API Gemini** atau pakai mode demo |

## 📚 Dokumentasi

- `PRD.md` — spesifikasi produk (fitur, screen map, prompt AI, fase)
- `progress.md` — riwayat pengerjaan per batch + hasil verifikasi
- `agents.md` — aturan main AI agent (arsitektur, commit policy)

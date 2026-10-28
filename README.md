<div align="center">

# LiterasiAI — Cek dulu sebelum sebar

Aplikasi mobile verifikasi fakta berbasis AI untuk masyarakat Indonesia.
Tempel teks, gambar, atau link, dapatkan verdict dalam hitungan detik,
lalu bagikan ke WhatsApp. Dilengkapi asisten chat literasi, riwayat
Firestore per pengguna, mini-course, skor literasi, dan feed trending
hoaks. Dibangun sebagai portfolio Apple Developer Academy 2026.

[![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-DD2C00?logo=firebase&logoColor=white)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Gemini-3.6--flash%20%2B%20failover-1A73E8?logo=google&logoColor=white)](https://ai.google.dev)
[![Tests](https://img.shields.io/badge/tests-399%20passed-34A853?logo=flutter&logoColor=white)](#-pengujian)
[![Analyze](https://img.shields.io/badge/flutter%20analyze-clean-34A853)](#-pengujian)

> **Purpose.** Indonesia termasuk negara dengan penyebaran hoaks tertinggi,
> mayoritas lewat WhatsApp, Instagram, dan Facebook (Kominfo). Masyarakat
> tidak punya alat yang mudah, cepat, dan tepercaya untuk verifikasi
> mandiri. LiterasiAI menjawabnya: verifikasi fakta AI dalam hitungan detik
> langsung dari smartphone, plus edukasi literasi digital yang ringkas.

</div>

---

## Daftar isi

- [Fitur](#-fitur)
- [Demo 60 detik](#-demo-60-detik)
- [Mulai cepat](#-mulai-cepat)
- [Konfigurasi](#-konfigurasi)
- [Arsitektur](#-arsitektur)
- [Arsitektur data](#-arsitektur-data)
- [Keamanan](#-keamanan)
- [Mekanisme BYOK](#-mekanisme-byok)
- [Pengujian](#-pengujian)
- [Status dan roadmap](#-status-dan-roadmap)
- [Troubleshooting](#-troubleshooting)
- [Dokumentasi](#-dokumentasi)

## ✨ Fitur

| Fitur | Ringkasan |
| ----- | --------- |
| Quick Check | Tiga mode input: teks (10–2.000 karakter), gambar (JPG/PNG/WebP maks 5 MB via Gemini Vision), link artikel (fetch judul dan deskripsi, lalu nilai klaim). Output: verdict `HOAKS` / `VALID` / `PERLU DICEK` / `TIDAK_DAPAT_DIPASTIKAN` plus confidence, penjelasan, dan saran. |
| AI Chat Assistant | Tanya-jawab literasi digital Bahasa Indonesia dengan gaya santai, bubble ala WhatsApp, dan tombol **Verifikasi ini** yang meneruskan pesan ke Quick Check. |
| History | Riwayat per pengguna di Firestore (`users/{uid}/verifications`), filter empat verdict, swipe-to-delete dengan Undo, dan layar detail yang memakai ulang kartu hasil plus tombol Share. |
| Share Hasil | Kartu verdict di-render ke PNG via `screenshot`, dikirim via `share_plus` (WhatsApp/medsos), dengan fallback teks bila capture gagal. |
| Trending Hoaks | Tujuh hoaks curated offline plus badge `HOT`; ketuk untuk masuk ke detail verifikasi. |
| Mini-Course | Tiga modul lima menit (clickbait, gambar manipulasi, verifikasi sumber): artikel empat seksi, kuis tiga soal berpenjelasan, dan badge kelulusan. |
| Literacy Score | Poin +10 per verifikasi, +20 per modul, +5 per jawaban kuis benar. Level Pemula (0–49), Waspada (50–149), Kritis (150–299), Ahli (300+). |
| BYOK dan Mode Demo | Tanpa kartu kredit dan tanpa Blaze: tempel kunci Gemini milik sendiri di Pengaturan untuk hasil live, atau pakai mode demo offline yang selalu berlabel `DEMO`. Tamu tanpa login tetap bisa cek, chat, dan membaca modul. |

## 🎬 Demo 60 detik

1. Buka tab **Cek**, ketuk salah satu contoh sekali-ketuk.
2. Sesi terbuka, verdict dan confidence tampil, ketuk **Bagikan Hasil**.
3. Buka **Chat**, ketuk saran, lalu **Verifikasi ini**.
4. Buka **Belajar**, selesaikan kuis, klaim poin.

Tanpa setup apa pun, mode demo berjalan offline dan selalu berlabel `DEMO`.

## 🚀 Mulai cepat

### Prasyarat

- Flutter 3.32+ (Dart 3.8+) — verifikasi dengan `flutter doctor`
- Project Firebase (Auth dan Firestore) — lihat [Konfigurasi](#-konfigurasi)
- Kunci Gemini gratis dari Google AI Studio (untuk hasil live; opsional bila memakai mode demo)
- Android: `minSdk` 23+ (syarat `firebase-auth` / `cloud_firestore`)
- Desktop Linux: `sudo apt-get install -y libsecret-1-dev` (wajib untuk plugin secure storage)

### Instalasi dan run

```bash
flutter pub get

# Opsi A — kunci dibakar saat compile (mode developer):
flutter run --dart-define=GEMINI_API_KEY=ISI_KUNCI_ANDA

# Opsi B — BYOK: jalankan biasa, lalu tempel kunci di Profil → Kunci API Gemini
flutter run

# Desktop juga didukung:
flutter run -d linux     # atau: -d macos, -d windows
```

### Verifikasi instalasi

```bash
flutter analyze   # ekspektasi: No issues found!
flutter test      # ekspektasi: All tests passed! (399 test, 44 file)
```

## ⚙️ Konfigurasi

| Kebutuhan | Cara |
| --------- | ---- |
| Project Firebase | `flutterfire configure`, hasilnya `lib/firebase_options.dart` |
| Auth | Aktifkan provider **Google** dan **Anonymous** di Firebase Console |
| Firestore | Aktifkan database, lalu deploy `firestore.rules` via Console → Firestore → Rules (lihat [Keamanan](#-keamanan)) |
| Kunci Gemini | Opsi A `--dart-define`, atau opsi B BYOK di **Profil → Kunci API Gemini** (lihat [Mekanisme BYOK](#-mekanisme-byok)) |
| Google Sign-In Android | Daftarkan SHA-1 debug di Firebase Console agar `oauth_client` terisi penuh |

> `apiKey` di `firebase_options.dart` adalah client key publik hasil
> FlutterFire — aman disimpan di repo. Kunci Gemini tidak pernah
> di-hardcode dan tidak pernah masuk repo.

## 🏗️ Arsitektur

Clean Architecture berbasis fitur plus Riverpod (`Notifier` /
`AsyncNotifier` / `ConsumerWidget`):

- **Domain** — entity Dart murni, interface repository, use case. Tanpa dependensi Flutter.
- **Data** — model JSON, datasource (pool Gemini `gemini-3.6-flash` dengan failover otomatis, Firestore), implementasi repository.
- **Presentation** — screen, widget reusable, dan provider Riverpod untuk state UI.

```
lib/
├── app/home_screen.dart            # Shell 4 tab (IndexedStack malas) + FAB Chat
├── core/
│   ├── constants/                  # app_colors, app_strings, app_styles
│   ├── errors/                     # failures (sealed class)
│   └── utils/                      # url_fetcher, image_processor,
│                                   # api_key_store/resolver, share_service
├── features/
│   ├── auth/                       # onboarding flag + login/Google/anonim
│   ├── quick_check/                # teks/gambar/link + share + demo
│   ├── chat/                       # asisten literasi + demo edukatif
│   ├── history/                    # Firestore per user + filter + undo
│   ├── trending/                   # feed curated offline
│   ├── learn/                      # 3 modul + kuis + progres
│   └── score/                      # level + ring + Pengaturan BYOK
├── firebase_options.dart           # hasil flutterfire configure
├── main.dart                       # ProviderScope + init best-effort
└── shared/widgets/                 # header editorial, navbar, error/loading
```

Di luar `lib/`:

```
assets/branding/                    # app_icon_1024 (master) + app_mark (splash)
tool/generate_brand_assets.ps1      # sumber kebenaran ikon iOS/Android + launch mark
test/                               # 44 file, 399 test regresi
```

Prinsip yang dijaga di seluruh codebase:

- Copy user-facing terpusat di `AppStrings`; token visual di `AppColors` / `AppStyles` (grid 8pt, radius terpusat).
- Setiap request AI jujur soal kegagalan: timeout 30 detik, pesan ramah untuk kuota/safety/key-invalid, dan fallback `TIDAK_DAPAT_DIPASTIKAN` sebagai **hasil sukses**, bukan error.
- Klaim respons `<5 detik` ditopang instrumentasi durasi di kartu hasil, cache klaim identik (LRU 20), dan rate limit per sesi untuk hemat kuota free tier.
- Penulisan kode mengikuti `agents.md`: Riverpod ketat (tanpa GetX/Provider/BLoC), tanpa stub `TODO` untuk logika inti.

## 🗄️ Arsitektur data

### Firestore (cloud, per pengguna)

| Path | Isi | Pola tulis |
| ---- | --- | ---------- |
| `users/{uid}/verifications/{id}` | Entri riwayat: input (teks/thumbnail/URL), verdict, confidence, timestamp UTC ISO8601 | Auto-save best-effort setelah hasil AI tampil; gagal simpan hanya `debugPrint`, tidak menggagalkan verifikasi. Baca via `orderBy checkedAt desc limit 50` |
| `users/{uid}/score/summary` | Total skor, modul selesai (`arrayUnion` idempoten), best-score kuis | Increment atomik; mapping toleran terhadap dokumen korup |
| `users/{uid}/learn/progress` | Modul selesai dan best-score per kuis (anti-farming: hanya skor terbaik yang dihitung) | Tulis idempoten, baca stream dengan timeout |

Semua path di atas berada di bawah `users/{uid}` sehingga tercakup rules owner-only. Progres belajar tamu disimpan lokal di perangkat melalui SharedPreferences (modul selesai + skor kuis terbaik), tetapi tidak dihitung sebagai poin cloud. Saat pengguna masuk dengan akun, progres guest lokal tidak otomatis disinkronkan; sinkronisasi/konversi akun harus dilakukan secara eksplisit agar tidak menggabungkan atau menggandakan skor tanpa persetujuan.

### Lokal (perangkat)

| Penyimpanan | Isi | Mekanisme |
| ----------- | --- | --------- |
| Secure storage OS | Kunci Gemini milik pengguna (`gemini_api_key`) | `flutter_secure_storage` → Keychain (iOS), Keystore (Android), Credential Locker (Windows), libsecret (Linux). Tidak pernah di SharedPreferences |
| SharedPreferences | Flag `onboarding_completed_v1` | Onboarding tampil sekali per install; gagal baca diperlakukan sebagai belum selesai |
| Memori (LRU 20) | Cache klaim identik | Verifikasi berulang atas klaim sama dijawab instan tanpa request baru |
| Rate limit sesi | Timestamp request terakhir | Jeda minimum 2 detik antar request di lapisan repository |

## 🔐 Keamanan

### Firestore rules owner-only

File `firestore.rules` (deploy manual via Console, tanpa Blaze):

```js
match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

Alur yang dijamin aturan ini:

1. Pengguna login (Google atau anonim) → Firebase Auth menerbitkan UID.
2. Setiap baca/tulis di bawah `users/{uid}` ditolak kecuali UID pada token sama dengan `{userId}` di path.
3. Tanpa login (`request.auth == null`) → semua ditolak di server; aplikasi sudah menangani ini sebagai empty state, bukan crash.
4. Tidak ada koleksi publik tulis-bebas; tidak ada leaderboard lintas pengguna (sengaja dipangkas di PRD demi privasi).

Gejala klasik salah konfigurasi: skor/history gagal tersimpan padahal kunci API valid — artinya rules belum di-deploy, bukan masalah kunci.

### Verifikasi kepemilikan email

Pendaftaran email tidak langsung membuka aplikasi. Setelah akun dibuat,
Firebase mengirim tautan verifikasi dan pengguna ditahan di `VerifyEmailScreen`
sampai `emailVerified` bernilai benar:

1. Login/daftar email yang belum terverifikasi → layar verifikasi (bukan Home).
2. Splash juga memeriksa status ini, sehingga menutup aplikasi tidak melewati gerbang.
3. Tiga jalan keluar tersedia: "Saya sudah verifikasi" (memuat ulang profil), "Kirim ulang email" (jeda 60 detik), dan "Batalkan pendaftaran" (menghapus akun agar email salah ketik tidak menjadi akun yatim).
4. Google dan sesi anonim tidak digerbangi: Google sudah terverifikasi pemiliknya, anonim memang tanpa email.

Batasnya jujur: ini membuktikan penguasaan inbox, **bukan** nama asli atau KTP. Yang dicegah adalah pendaftaran memakai alamat email orang lain.

Sesi email yang dibuat sebelum aturan ini berlaku juga ikut digerbangi; pengguna cukup mengirim ulang tautan dari layar tersebut.

### Rahasia vs publik

| Klasifikasi | Contoh | Penanganan |
| ----------- | ------ | ---------- |
| Publik, aman di repo | `apiKey` di `firebase_options.dart`, Application ID, `google-services.json` client info | Hasil `flutterfire configure`, dibatasi via Firebase Console (SHA-1, App Check bila perlu) |
| Rahasia, tidak boleh masuk repo | Kunci Gemini | `--dart-define` saat compile, atau BYOK di secure storage; validasi format ringan sebelum simpan |

## 🔑 Mekanisme BYOK

BYOK (Bring Your Own Key) memungkinkan reviewer menjalankan fitur live tanpa kartu kredit dan tanpa backend token broker. Implementasi di `lib/core/utils/`:

**Prioritas resolusi** (`api_key_resolver.dart`, tanpa tebakan):

1. `ApiKeySource.compileDefine` — `String.fromEnvironment('GEMINI_API_KEY')`. Bila tidak kosong, selalu menang. Cocok untuk mode developer.
2. `ApiKeySource.userKey` — dibaca async dari secure storage sekali saat provider dibuat. Diatur lewat **Profil → Kunci API Gemini**.
3. `ApiKeySource.none` — tidak ada kunci. Aplikasi masuk mode demo/jujur: banner mengarahkan ke Pengaturan, request AI tidak dikirim.

**Siklus simpan** (`api_key_controller.dart` via `ApiKeyController`):

- Validasi ringan: minimal 20 karakter, tanpa spasi; pesan error mengarah ke Pengaturan, bukan ke terminal.
- Simpan ke secure storage (`ApiKeyStore.write`), lalu `ref.invalidate(apiKeyStatusProvider)` sehingga repository Quick Check dan Chat memakai kunci baru **pada request berikutnya tanpa restart**.
- Hapus kunci (`clearUserKey`) mengikuti pola invalidate yang sama.

**Propagasi live:** datasource varian `*WithKey` menerima `resolveApiKey` per request, sehingga ganti kunci di tengah sesi langsung efektif. Guest tanpa login tetap bisa BYOK karena kunci disimpan per perangkat, bukan per akun.

## ✅ Pengujian

Kondisi terakhir terverifikasi: `flutter analyze` → `No issues found!`,
`flutter test` → `All tests passed!` (**399 test**, 44 file), dan
`flutter build apk --debug` → sukses. Suite berjalan offline (network
diinjeksi lewat fake), jadi hasilnya deterministik di mesin mana pun.

| Area | File test (jumlah test) | Total |
| ---- | ----------------------- | ----- |
| Quick Check | `quick_check_url_share` 18, `quick_check_verification` 14, `quick_check_image` 12, `quick_check_screen` 7, `verify_performance` 6, `hero_verdict` 5, `verdict_spine` 4, `check_heading` 4, `quick_check_redesign` 4, `mode_identity` 2 | 76 |
| Gemini & BYOK | `gemini_model_pool` 22, `api_key_demo` 20, `gemini_error_mapper` 16, `gemini_probe` 9 | 67 |
| Chat | `chat_room` 15, `chat_test` 11, `chat_polish` 7 | 33 |
| History | `history_test` 18, `history_dedup` 8, `history_refined` 8 | 34 |
| Learn | `learn_library` 12, `learn_test` 8, `learn_detail_contents` 5 | 25 |
| Score & profil | `score_test` 15, `profile_menu` 9 | 24 |
| Auth & onboarding | `auth_repository` 29, `auth_controller` 10, `email_verification` 4, `auth_android_config` 4, `onboarding_persistence` 5, `widget_test` 4 | 56 |
| Shell, nav, brand | `native_brand` 15, `nav_pill` 9, `home_nav_chat` 5, `home_tab_state` 5, `tab_headers` 4 | 38 |
| Polish & identitas UI | `premium_upgrade` 9, `ui_u1_polish` 9, `ui_u2_identity` 8, `font_bundle` 5, `header_compact` 4, `section_header` 4, `hero_pattern` 2 | 41 |
| Trending | `trending_test` 5 | 5 |

Suite auth memverifikasi pemetaan error Firebase dan Google Play Services ke
pesan aman, state sesi Riverpod, sign-in/registrasi, reset kata sandi, gerbang
verifikasi email, jeda kirim ulang, penghapusan akun, dan logout memakai fake
repository (tanpa request ke akun sungguhan). `auth_android_config_test.dart`
membaca manifest dan `google-services.json` langsung untuk mengunci izin
`INTERNET` dan keberadaan OAuth client Android.

Test `native_brand_test.dart` mengunci kontrak native tanpa perlu Xcode:
nama aplikasi, 15 ikon iOS (dimensi + tanpa alpha), ikon legacy/adaptive
Android, dan launch screen kedua platform. `home_tab_state_test.dart`
mengunci state tab: scroll, kata kunci pencarian, lazy mount, dan back.

### Cara menjalankan

```bash
flutter test                          # semua 399 test
flutter test test/score_test.dart     # satu file
flutter test --plain-name "cache"     # filter berdasarkan nama
```

### Konvensi pengujian

- Setiap perubahan perilaku wajib ditemani atau memutakhirkan test regresi; file test dikelompokkan per tema (`*_test.dart`).
- Test yang butuh network memakai injeksi fungsi/fake (contoh: `verifyTextFn`), sehingga suite berjalan offline dan deterministik.
- Test widget memakai mock (clipboard, SharedPreferences) agar tidak hang; bug layout dikunci sebagai regresi (contoh: overlap FAB vs navbar, overflow stepper).

## 🗺️ Status dan roadmap

- [x] MVP: Quick Check tiga mode, Chat, History Firestore, Share, Trending, Mini-Course, Score, BYOK/Demo, Onboarding, polish premium
- [x] Brand pack native: ikon iOS/Android (adaptive + monochrome), launch screen brand, nama `LiterasiAI`, splash Flutter satu identitas
- [x] Shell: tab state preservation lewat `IndexedStack` malas + back-to-tab-0
- [x] Auth Android: email/password, daftar, reset sandi, anonymous, sesi persisten, dan logout
- [x] Keamanan akun: verifikasi kepemilikan email, gerbang sesi belum terverifikasi, hapus akun, dan pemetaan error Google yang spesifik
- [ ] UI polish lanjutan (micro-interactions terkurasi)
- [ ] Parity iOS: build di Mac, Google Sign-In URL scheme, validasi TestFlight
- [ ] Video demo 60 detik
- [ ] Merge final `dev` → `main` dan publikasi GitHub

## 🛠️ Troubleshooting

| Gejala | Solusi |
| ------ | ------ |
| `libsecret-1>=0.18.4 not found` saat build Linux | `sudo apt-get install -y libsecret-1-dev` |
| `Permission denied` ke `/usr/local/...` saat `flutter run -d linux` | Hapus cache CMake basi: `rm -rf build/linux`, lalu run ulang |
| Login Google gagal di Android | Pastikan SHA-1 keystore yang dipakai (debug dan release berbeda) terdaftar di Firebase Console → Project settings → Android app, lalu unduh ulang `google-services.json`. Cek `build/app/generated/res/processDebugGoogleServices/values/values.xml` harus memuat `default_web_client_id`. Pesan error aplikasi kini menyebut konfigurasi OAuth, bukan pesan generik |
| Skor/history gagal tersimpan padahal kunci valid | `firestore.rules` belum di-deploy (bukan masalah kunci API) |
| Selalu `TIDAK_DAPAT_DIPASTIKAN` | Kunci Gemini kosong/invalid — cek **Profil → Kunci API Gemini**, atau pakai mode demo |
| `flutter` CLI macet di terminal | Biasanya terkunci daemon VS Code yang sedang berjalan; tunggu atau tutup run aktif, lalu ulangi |

## 📚 Dokumentasi

- `PRD.md` — spesifikasi produk: fitur, screen map, strategi prompt AI, fase pengembangan
- `progress.md` — riwayat pengerjaan per batch beserta hasil verifikasi
- `agents.md` — aturan main AI agent: arsitektur, standar koding, commit policy

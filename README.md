<div align="center">

# LiterasiAI: Cek dulu sebelum sebar

**Aplikasi mobile literasi digital berbasis AI untuk masyarakat Indonesia.**

Periksa teks, gambar, atau tautan, pahami verdict beserta alasannya, lalu bagikan hasilnya. LiterasiAI juga dilengkapi asisten chat, riwayat pemeriksaan, materi belajar, skor literasi, dan contoh klaim yang dikurasi.

[![Flutter](https://img.shields.io/badge/Flutter-3.32%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-DD2C00?logo=firebase&logoColor=white)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Gemini%20API-AI-4285F4?logo=google&logoColor=white)](https://ai.google.dev)
[![Unduh APK](https://img.shields.io/badge/Android%20APK-Unduh%201.0.0-1A73E8?logo=android&logoColor=white)](https://www.mediafire.com/file/aqwg9jk2sa7zqei/LiterasiAI.apk/file)

<p><strong>Purpose:</strong> Informasi menyebar cepat melalui media sosial dan aplikasi pesan. LiterasiAI membantu pengguna berhenti sejenak, memeriksa klaim, dan memahami konteks sebelum membagikannya. Tujuannya bukan menggantikan sumber tepercaya, melainkan mendukung kebiasaan literasi digital yang lebih baik.</p>

</div>

<p align="center">
  <img src="assets/image/LiterasiAI_Presentation.jpg" alt="Cuplikan aplikasi LiterasiAI yang menampilkan halaman Cek, hasil verifikasi, dan Asisten LiterasiAI" width="100%" />
</p>

<p align="center"><sub>Cuplikan aplikasi: Cek, hasil verifikasi, dan Asisten LiterasiAI</sub></p>

---

## Daftar isi

- [Fitur](#fitur)
- [Demo singkat](#demo-singkat)
- [Unduh & instal APK](#unduh--instal-apk)
- [Mulai dari source](#mulai-dari-source)
- [Konfigurasi layanan](#konfigurasi-layanan)
- [Arsitektur](#arsitektur)
- [Arsitektur data](#arsitektur-data)
- [Keamanan dan privasi](#keamanan-dan-privasi)
- [Mekanisme BYOK](#mekanisme-byok)
- [Status dan batasan](#status-dan-batasan)
- [Troubleshooting](#troubleshooting)
- [Dokumentasi](#dokumentasi)

## Fitur

| Fitur | Ringkasan |
| --- | --- |
| **Cek teks** | Masukkan klaim untuk mendapatkan verdict `HOAKS`, `VALID`, `PERLU_DICEK`, atau `TIDAK_DAPAT_DIPASTIKAN`, beserta confidence, penjelasan, dan saran. |
| **Cek gambar** | Pilih gambar untuk dianalisis dengan Gemini Vision. Layar pratinjau mendukung zoom, rotasi, reset, dan berbagi lampiran. |
| **Cek tautan** | Masukkan tautan artikel. Aplikasi mengambil metadata halaman yang tersedia sebagai konteks pemeriksaan; hasil dapat terbatas bila situs membatasi pengambilan metadata. |
| **Android Share Target** | Bagikan teks, tautan, atau gambar dari aplikasi Android lain ke LiterasiAI. Pengguna meninjau konten dan memulai pemeriksaan secara manual. |
| **Asisten literasi** | Ajukan pertanyaan seputar pemeriksaan informasi dalam Bahasa Indonesia. Pesan dapat diteruskan ke alur Cek untuk ditinjau. |
| **Riwayat** | Simpan dan lihat pemeriksaan pada akun Firebase, dengan filter verdict, detail hasil, serta opsi hapus. Penyimpanan memerlukan autentikasi dan Firestore rules yang aktif. |
| **Bagikan hasil** | Buat kartu hasil sebagai gambar untuk dibagikan melalui aplikasi lain, dengan fallback teks jika pembuatan gambar gagal. |
| **Trending** | Jelajahi tujuh contoh klaim yang dikurasi secara lokal. Konten ini bukan feed berita real-time. |
| **Belajar** | Pelajari tiga modul literasi digital melalui materi dan kuis singkat. Progres guest tersimpan lokal; progres akun tersimpan di Firestore. |
| **Skor literasi** | Dapatkan poin dari aktivitas pemeriksaan dan belajar. Skor cloud memerlukan akun dan koneksi ke Firestore. |
| **BYOK dan mode demo** | Gunakan kunci Gemini sendiri di **Profil → Kunci API Gemini**: simpan kunci di bagian "Kelola kunci", lalu uji koneksinya dengan probe bertahap (DNS → TCP → HTTPS → generate) di bagian "Tes koneksi". Tanpa kunci, aplikasi tetap dapat dicoba melalui mode demo offline yang hasilnya diberi penanda demo. |

## Demo singkat

1. Buka tab **Cek**, lalu pilih salah satu contoh atau masukkan klaim sendiri.
2. Tinjau hasil pemeriksaan, penjelasan, dan saran tindak lanjut.
3. Coba **Bagikan Hasil** untuk membagikan kartu verdict.
4. Buka **Chat** atau **Belajar** untuk menjelajahi fitur edukasi.

> Mode demo tidak mengirim permintaan ke Gemini. Hasilnya bersifat ilustratif, bukan pemeriksaan faktual. Untuk hasil live, masukkan kunci Gemini melalui **Profil → Kunci API Gemini**.

## Unduh & instal APK

**[Unduh LiterasiAI untuk Android (APK 1.0.0)](https://www.mediafire.com/file/aqwg9jk2sa7zqei/LiterasiAI.apk/file)**

| | |
| --- | --- |
| Nama file | `literasi-ai-v1.0.0.apk` |
| Versi | `1.0.0+1` |
| Ukuran | 53,6 MB |
| Dibangun | 9 November 2026 (release) |
| SHA-256 | `5ccf4469bc52d1b97b8d90c7679b9e6a3bdcc7a31d10d13675feff1a7df2a3cf` |

### Cara instal

1. Unduh APK dari tautan di atas (Android 6.0+ / `minSdk` 23).
2. Buka file APK; bila diminta, izinkan instal dari sumber tersebut.
3. Buka LiterasiAI. Mode demo dapat langsung digunakan tanpa login dan tanpa kunci Gemini.
4. Untuk pemeriksaan live, masukkan kunci Gemini milik sendiri di **Profil → Kunci API Gemini**.

Google Sign-In memerlukan SHA-1 signing certificate yang digunakan APK terdaftar di Firebase Console. Sertifikat debug dan release dapat berbeda. Bila SHA-1 tidak cocok, Google Sign-In mungkin gagal meskipun fitur demo tetap dapat digunakan.

> LiterasiAI didistribusikan sebagai APK untuk instalasi manual dan **belum tersedia di Google Play Store**. Integritas file dapat diperiksa dengan membandingkan SHA-256 di atas.

## Mulai dari source

### Prasyarat

- Flutter 3.32 atau lebih baru, dengan Dart 3.8 atau lebih baru.
- Android SDK untuk menjalankan aplikasi pada Android.
- Project Firebase untuk autentikasi dan penyimpanan cloud.
- Kunci Gemini untuk menggunakan pemeriksaan dan chat live. Kunci bersifat opsional untuk mode demo.
- Android `minSdk` 23.

### Instalasi dan menjalankan

```bash
flutter pub get

# Mode demo, tanpa kunci Gemini
flutter run

# Mode live dengan kunci untuk proses run lokal
flutter run --dart-define=GEMINI_API_KEY=KUNCI_ANDA
```

Alternatifnya, jalankan tanpa `--dart-define`, lalu atur kunci melalui **Profil → Kunci API Gemini**. Jangan commit kunci pribadi ke repository atau membagikannya di log maupun screenshot. Kunci yang disertakan dalam binary aplikasi tidak dapat dianggap sebagai rahasia server.

## Konfigurasi layanan

| Kebutuhan | Cara konfigurasi |
| --- | --- |
| Firebase project | Hubungkan project menggunakan `flutterfire configure`; konfigurasi aplikasi dibuat pada `lib/firebase_options.dart`. |
| Firebase Auth | Aktifkan metode autentikasi yang digunakan aplikasi pada Firebase Console. Google Sign-In Android memerlukan OAuth client dan SHA-1 yang sesuai. |
| Firestore | Aktifkan database dan deploy `firestore.rules` melalui Firebase Console sebelum mengandalkan riwayat dan skor cloud. |
| Gemini API | Masukkan kunci melalui **Profil → Kunci API Gemini**, atau gunakan `--dart-define` untuk pengembangan lokal. |

`apiKey` Firebase pada konfigurasi client bukan secret autentikasi. Keamanan data harus ditegakkan melalui Firebase Authentication, Firestore Security Rules, serta pengaturan project yang sesuai. Kunci Gemini berbeda dan tidak boleh ditambahkan langsung ke source code.

## Arsitektur

LiterasiAI menggunakan Clean Architecture berbasis fitur. UI, aturan aplikasi, dan integrasi layanan dipisahkan ke lapisan Presentation, Domain, dan Data. State UI dikelola dengan Riverpod.

```text
lib/
├── app/
│   └── home_screen.dart             # shell aplikasi, empat tab, dan akses Chat
├── core/
│   ├── constants/                   # warna, string, dan tema
│   ├── errors/                      # representasi kegagalan
│   └── utils/                       # pemrosesan URL/gambar, storage, dan sharing
├── features/
│   ├── auth/                        # onboarding dan autentikasi Firebase
│   ├── quick_check/                 # teks, gambar, URL, hasil, dan share target
│   ├── chat/                        # asisten literasi
│   ├── history/                     # riwayat pemeriksaan
│   ├── trending/                    # konten kurasi lokal
│   ├── learn/                       # modul, kuis, dan progres
│   └── score/                       # skor, profil, dan pengaturan kunci API
├── shared/widgets/                  # komponen UI lintas fitur
├── firebase_options.dart            # konfigurasi Firebase client
└── main.dart                        # bootstrap aplikasi dan ProviderScope

assets/
├── branding/                        # ikon dan aset brand aplikasi
├── fonts/                           # font Inter lokal
└── image/                           # logo dan gambar presentasi

test/                                # unit test dan widget test
```

Tiap fitur mengikuti pemisahan lapisan yang sama:

- **Domain:** entity, kontrak repository, dan aturan aplikasi tanpa dependensi Flutter.
- **Data:** model, datasource Gemini/Firebase, serta implementasi repository.
- **Presentation:** screen, widget, dan provider Riverpod untuk state UI.

Prinsip implementasi yang digunakan:

- State aplikasi dikelola dengan Riverpod, bukan GetX, Provider, atau BLoC.
- Copy UI dan token visual dipusatkan agar konsisten.
- Kegagalan Gemini seperti timeout, kuota, atau kunci tidak valid ditangani dengan pesan yang sesuai dan fallback verdict `TIDAK_DAPAT_DIPASTIKAN`.
- Kunci Gemini pengguna disimpan melalui secure storage sistem operasi, bukan SharedPreferences.

## Arsitektur data

### Firestore per pengguna

| Path | Isi | Perilaku |
| --- | --- | --- |
| `users/{uid}/verifications/{id}` | Klaim, verdict, confidence, penjelasan, saran, waktu pemeriksaan, dan sumber | Hasil disimpan secara best-effort setelah pemeriksaan. Kegagalan simpan tidak membatalkan hasil yang sudah tampil. |
| `users/{uid}/score/summary` | Ringkasan skor, modul selesai, dan progres kuis | Diperbarui secara idempoten sesuai aktivitas pengguna. |
| `users/{uid}/learn/progress` | Modul selesai dan skor terbaik kuis | Menyimpan progres belajar akun. |

Semua data cloud ditempatkan di bawah UID pengguna dan dibatasi oleh Firestore rules. Pengguna guest dapat mencoba fitur tanpa akun, tetapi progres belajarnya tersimpan lokal dan tidak otomatis digabungkan dengan progres akun setelah login.

### Penyimpanan lokal

| Penyimpanan | Isi | Catatan |
| --- | --- | --- |
| Secure storage sistem operasi | Kunci Gemini pengguna | Menggunakan penyimpanan aman platform, bukan SharedPreferences. |
| SharedPreferences | Status onboarding dan progres belajar guest | Bersifat lokal pada perangkat dan tidak otomatis tersinkron ke akun. |
| Memori aplikasi | Cache klaim yang baru diperiksa dan pembatasan jeda permintaan | Cache bersifat sementara dan hilang saat aplikasi dimulai ulang. |

## Keamanan dan privasi

### Firestore rules

Aturan pada `firestore.rules` membatasi akses data berdasarkan UID pemilik. Ringkasnya:

```js
allow read, write: if request.auth != null
  && request.auth.uid == userId;
```

Aturan repository juga memvalidasi koleksi riwayat dan progres. Deploy rules ke Firebase project sebelum menggunakan fitur cloud. Tanpa autentikasi atau rules yang sesuai, riwayat dan skor akun tidak akan tersimpan; aplikasi tetap menyediakan pengalaman guest untuk fitur yang mendukungnya.

### Autentikasi email

Akun email harus menyelesaikan verifikasi email sebelum masuk ke aplikasi. Pengguna dapat mengirim ulang tautan verifikasi, memeriksa ulang status, atau membatalkan pendaftaran. Google Sign-In dan akun anonim mengikuti alur autentikasi Firebase masing-masing.

Verifikasi email membuktikan akses ke inbox, bukan identitas resmi seseorang.

### Data yang dikirim ke layanan AI

Pada mode live, materi pemeriksaan dan prompt percakapan dikirim ke Gemini untuk diproses. Jangan memasukkan informasi pribadi, kredensial, atau data rahasia. Hasil AI dapat keliru atau kekurangan konteks; verifikasi klaim penting melalui sumber primer dan sumber tepercaya.

Mode demo berjalan secara lokal dan tidak membuat permintaan Gemini. Demo bukan pengganti mode live maupun pemeriksaan manusia.

## Mekanisme BYOK

BYOK berarti pengguna membawa kunci Gemini sendiri. Aplikasi tidak menyediakan proxy backend untuk menyembunyikan kunci atau mengelola kuota pengguna.

Prioritas pemilihan kunci:

1. `GEMINI_API_KEY` yang diberikan melalui `--dart-define`, untuk kebutuhan pengembangan atau build terkontrol.
2. Kunci yang dimasukkan pengguna melalui **Profil → Kunci API Gemini**, disimpan di secure storage perangkat.
3. Jika tidak ada kunci, aplikasi menggunakan mode demo dan tidak mengirim request Gemini.

Layar **Profil → Kunci API Gemini** disusun berurutan agar mudah dipantau:

1. **Banner status** — langsung menunjukkan AI Live (kunci aktif) atau Mode Demo, beserta sumber kunci.
2. **Kelola kunci** — kolom dengan aksi tempel dan tampilkan/sembunyikan, tombol Simpan (primer) dan Hapus (outlined).
3. **Tes koneksi** — probe bertahap **DNS → TCP 443 → HTTPS → generate**, dengan hasil per tahap dan banner kesimpulan. Tes selalu menggunakan kunci yang tersimpan, jadi pengguna bisa memastikan kuncinya benar-benar bekerja.
4. **Cara mendapatkan kunci** — tiga langkah menuju Google AI Studio.

Mengubah atau menghapus kunci akan memengaruhi request berikutnya tanpa harus memulai ulang aplikasi. Kunci yang ditanam di build yang dibagikan dapat diekstrak; BYOK lebih sesuai untuk distribusi portfolio.

## Status dan batasan

**Sudah tersedia:**

- Cek teks, gambar, dan tautan, lengkap dengan tampilan hasil serta opsi berbagi.
- Android Share Target untuk menerima teks, tautan, dan gambar dari aplikasi lain.
- Asisten chat, riwayat akun, progres belajar, skor, dan konten trending terkurasi.
- Mode demo offline dan penggunaan kunci Gemini milik pengguna.

**Belum tersedia atau masih perlu validasi:**

- Offline queue untuk mengantrekan pemeriksaan live ketika koneksi terputus.
- Alur `Open with` pada Windows dan split-view untuk tablet.
- Validasi parity iOS dan distribusi TestFlight.
- Pengujian menyeluruh pada berbagai perangkat fisik.

APK tersedia untuk instalasi manual melalui tautan di [Unduh & instal APK](#unduh--instal-apk), bukan Play Store. Dukungan sistem operasi, aplikasi pengirim Share Target, dan perilaku URL dapat berbeda menurut perangkat serta layanan pihak ketiga.

## Troubleshooting

| Gejala | Yang perlu diperiksa |
| --- | --- |
| Google Sign-In gagal pada Android | Daftarkan SHA-1 signing certificate yang benar untuk build debug atau release di Firebase Console. Pastikan OAuth client pada konfigurasi Android sudah diperbarui. |
| Riwayat atau skor tidak tersimpan | Pastikan pengguna sudah login, Firestore aktif, koneksi tersedia, dan `firestore.rules` sudah dideploy ke project yang benar. |
| Hasil selalu `TIDAK_DAPAT_DIPASTIKAN` | Periksa koneksi dan kunci Gemini melalui **Profil → Kunci API Gemini**. Tanpa kunci valid, aplikasi memakai mode demo. |
| Tautan tidak menghasilkan konteks yang cukup | Sebagian situs membatasi pengambilan metadata. Periksa klaim menggunakan teks atau sumber lain. |
| Konten Share Target tidak terbaca | Periksa tipe konten dan izin file dari aplikasi pengirim. Pengguna dapat membuka LiterasiAI lalu memasukkan klaim secara manual. |
| APK ditolak/diblokir saat instal | Izinkan instal dari sumber MediaFire di pengaturan Android. Peringatan Play Protect wajar untuk APK sideload; verifikasi file dengan SHA-256 di [Unduh & instal APK](#unduh--instal-apk). |

## Dokumentasi

- [`PRD.md`](PRD.md): tujuan produk dan spesifikasi.
- [`progress.md`](progress.md): catatan perkembangan implementasi.
- [`firestore.rules`](firestore.rules): aturan akses data Firestore.
- [`agents.md`](agents.md): panduan arsitektur dan standar pengembangan.

---

<p align="center"><sub>LiterasiAI · Proyek portofolio literasi digital</sub></p>

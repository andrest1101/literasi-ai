# LiterasiAI — Panduan Arsitektur dan Rekayasa

Dokumen ini menjelaskan bagaimana aplikasi LiterasiAI disusun dan beroperasi dari sudut pandang engineering. Fokusnya adalah batas tanggung jawab, aliran data, integrasi, dan keputusan desain—bukan sintaksis per baris.

> **Ringkasan:** LiterasiAI adalah aplikasi Flutter/Dart untuk Android, iOS, Web, Windows, dan macOS. Kode memakai struktur feature-based dengan lapisan Presentation, Domain, dan Data. Riverpod menghubungkan UI ke use case/repository. Firebase menyediakan autentikasi dan penyimpanan cloud per pengguna; Google Gemini menjadi engine AI untuk verifikasi dan chat. Tersedia fallback demo, progres belajar lokal untuk guest, serta penyimpanan preferensi perangkat.

---

## 1. Arsitektur Sistem dan Direktori

### Pola arsitektur

Pola utama adalah **Clean Architecture per feature**. Feature menjadi batas konteks: `auth`, `quick_check`, `history`, `learn`, `score`, `chat`, dan `trending`. Secara konseptual alirannya:

```text
Screen/Widget → Riverpod Provider/Controller → Domain Use Case/Repository contract
                                                   ↓
                            Data Repository → Data Source → Firebase/Gemini/HTTP/local
```

UI adalah loket yang menerima intent dan menyajikan hasil; Domain adalah aturan layanan; Repository adalah kontrak; Data Source adalah adaptor ke layanan eksternal. UI idealnya tidak mengetahui format dokumen Firestore atau detail request Gemini.

Penerapan tidak sepenuhnya seragam. Lapisan Domain/use case paling eksplisit pada Quick Check, Chat, History, Learn, dan Score. Beberapa feature sederhana merangkai dependency lebih langsung melalui provider. Dokumentasi ini mendeskripsikan pola nyata, bukan mengklaim semua feature memiliki abstraksi sama.

### Entry point dan shared code

- `lib/main.dart`: menyiapkan Flutter, menginisialisasi Firebase secara best-effort, memasang `ProviderScope`, tema, dan routes. Firebase gagal init tidak selalu menghentikan shell; beberapa fitur dapat beroperasi dalam mode offline/demo.
- `lib/firebase_options.dart`: opsi Firebase per platform hasil FlutterFire. Ini konfigurasi client, bukan aturan akses data.
- `lib/app/home_screen.dart`: shell aplikasi utama dan navigasi tab.
- `lib/core/constants/`: warna, gaya/tema, dan teks global.
- `lib/core/errors/`: tipe kegagalan lintas feature.
- `lib/core/utils/`: helper lintas feature, antara lain resolver/secure store API key, pool model dan mapper error Gemini, probe konektivitas, fetch metadata URL, pemrosesan gambar, dan sharing.

### Feature directories

| Folder | Tanggung jawab |
|---|---|
| `lib/features/auth/` | Onboarding lokal, login/register, Google Sign-In, guest/anonymous, reset password, dan verifikasi email. Auth Firebase dibungkus datasource dan repository. |
| `lib/features/quick_check/` | Pemeriksaan klaim teks, gambar, dan URL; validasi, datasource Gemini text/vision dan demo, pemetaan hasil ke entity. |
| `lib/features/history/` | Riwayat verifikasi per user: stream, pencarian/filter, detail, hapus, dan pemetaan dokumen Firestore. |
| `lib/features/learn/` | Katalog dan materi/kuis lokal, progres guest di perangkat, progres user login di Firestore. |
| `lib/features/score/` | Skor, level literasi, award poin, profil, dan UI pengaturan API key. |
| `lib/features/chat/` | Percakapan Gemini atau demo, state chat, dan penyimpanan sesi lokal. |
| `lib/features/trending/` | Konten edukasi/topik lokal dan tautan rujukan; bukan feed real-time. |

Struktur di dalam feature mengikuti peran berikut:

- `presentation/screens`: layar dan komposisi alur UI.
- `presentation/widgets`: komponen UI lokal feature.
- `presentation/providers`: graph dependency, state, serta controller Riverpod.
- `domain/entities`: objek dan konsep bisnis yang tidak bergantung pada Flutter UI.
- `domain/repositories`: kontrak operasi data yang dibutuhkan Domain.
- `domain/usecases`: aksi bisnis yang dapat diuji terpisah.
- `data/models`: mapping struktur eksternal ke entity.
- `data/repositories`: implementasi kontrak dan orkestrasi sumber data.
- `data/datasources`: batas langsung ke SDK, cloud, HTTP, storage, atau katalog lokal.

Aturan dependensi yang perlu dijaga: UI mengirim intent ke controller; Domain tidak mengimpor SDK Firebase/Gemini; repository implementation menerjemahkan data eksternal; provider menjadi composition root. Untuk feature kecil, jangan menambah lapisan tanpa kebutuhan nyata.

---

## 2. Alur Data dan Logika Inti

### Boot dan autentikasi

1. `main()` menyiapkan binding Flutter dan mencoba `Firebase.initializeApp` dengan opsi platform.
2. Aplikasi berjalan di `ProviderScope`; MaterialApp membuka Splash.
3. Status onboarding sederhana dibaca dari `SharedPreferences`; splash mengarahkan pengguna ke onboarding atau alur auth/home.
4. Firebase Auth menangani email/password dan Google Sign-In; guest/anonymous mengikuti alur auth yang tersedia.
5. Repository memetakan hasil/error Firebase ke bentuk domain. Provider auth menyediakan sesi reaktif ke UI.

### Quick Check teks

1. Pengguna mengisi klaim dan mengirimkannya dari layar Quick Check.
2. `AsyncNotifier` menolak request ganda ketika loading, menyimpan konteks klaim, lalu menerbitkan `AsyncLoading`.
3. Use case memvalidasi input dan memanggil `VerificationRepository`.
4. Repository memilih Gemini bila key tersedia, atau datasource demo bila tidak.
5. Datasource Gemini mengirim prompt/config melalui Google Generative AI SDK. Pool model dan mapper error membantu menangani quota, model busy/retired, timeout, output kosong, dan format yang tidak valid.
6. Respons terstruktur dipetakan dari model data ke entity `VerificationResult` (verdict, confidence, explanation, suggestion, sumber, waktu).
7. Controller menerbitkan data ke UI dan menyimpan durasi pemeriksaan. Error menjadi `AsyncError`, bukan crash.
8. Hasil disimpan ke riwayat cloud secara best-effort untuk UID login; kegagalan menyimpan tidak semestinya menghilangkan hasil yang telah diterima.

Jangan mengubah error layanan menjadi verdict faktual. Hasil tidak pasti harus dinyatakan tidak pasti, terpisah dari kegagalan koneksi/API.

### Quick Check gambar dan URL

- **Gambar:** image picker dipanggil melalui service interface; attachment/caption diteruskan lewat use case ke Gemini Vision atau datasource demo. Data gambar tidak semestinya dicetak ke log. Riwayat dapat menyimpan metadata pilihan seperti nama file, bukan database gambar.
- **URL:** use case menerima URL HTTP(S), `UrlFetcher` mengunduh HTML dengan timeout 10 detik, memeriksa status dan content type, membatasi pemrosesan body sampai 512 KB, kemudian mengekstrak judul/deskripsi Open Graph/meta/title. Metadata ringkas dikirim ke jalur verifikasi. Halaman anti-bot, redirect, metadata buruk, atau host yang tidak dapat dijangkau dapat membuat fetch gagal.

Fetch URL saat ini dilakukan client-side. Jika kelak dipindahkan ke backend, perlu proteksi SSRF, pembatasan redirect/host, timeout, ukuran respons, dan rate limit.

### Riwayat, Belajar, dan skor

- Riwayat Firestore berada di `users/{uid}/verifications/{entryId}`. Datasource menangani stream/tambah/hapus; model memetakan dokumen ke entity. Pencarian/filter dilakukan lokal pada data stream yang diterima.
- Katalog Belajar dan materi/kuis berada di source Dart lokal. Guest membaca/menulis progres melalui `SharedPreferences`; user login menggunakan `users/{uid}/learn/progress` di Firestore.
- Modul selesai atau skor kuis baru dapat memicu award pada feature Score. Progres utama ditulis lebih dahulu; pemberian poin best-effort supaya kegagalan award tidak membatalkan penyelesaian. Score summary berada di `users/{uid}/score/summary`.
- Guest tidak memiliki riwayat cloud. Progres guest lokal dan progres akun adalah ruang data berbeda; migrasi/merge tidak terjadi otomatis.

### Chat dan Trending

Chat controller memanggil repository/use case; repository memilih datasource Gemini atau demo. Sesi chat disimpan lokal dengan `SharedPreferences`, bukan sinkronisasi lintas perangkat. Trending saat ini berupa daftar lokal dengan tautan rujukan, bukan integrasi berita live.

---

## 3. Manajemen Status dan Reaktivitas UI

State management yang dipakai adalah **Riverpod** (`flutter_riverpod`), bukan BLoC/GetX/Provider klasik. `ProviderScope` dipasang di root.

Riverpod melakukan dua pekerjaan: **dependency injection** (datasource → repository → use case/controller) dan **reaktivitas UI**. `ref.watch` digunakan untuk nilai yang harus memicu rebuild; `ref.read` untuk menjalankan aksi atau membaca dependency tanpa subscribe.

- `Provider`: dependency atau data sinkron, misalnya katalog.
- `FutureProvider`: pembacaan async sekali, misalnya resolusi API key.
- `StreamProvider`: data yang terus berubah, misalnya progres/history cloud.
- `AsyncNotifier`/`AsyncValue`: aksi dan state loading/data/error.
- Nilai `null` dapat berarti idle/belum ada hasil, bukan error.

Widget merender cabang loading/success/error dan memanggil retry/invalidation yang diperlukan. Provider dapat dioverride dengan fake pada test, sehingga test tidak perlu mengirim request ke Gemini/Firebase. Hindari request otomatis yang berulang akibat invalidasi terlalu luas.

---

## 4. Keamanan, Environment, dan Rahasia

### API key Gemini

Resolver memilih `GEMINI_API_KEY` compile-time (`--dart-define`) lebih dahulu, kemudian key BYOK milik user. Placeholder ditolak. Key user disimpan melalui `flutter_secure_storage` pada fasilitas OS (Android Keystore/iOS Keychain dan platform terkait), bukan SharedPreferences. Log diagnostik tidak mencetak key penuh.

Contoh lokal:

```powershell
flutter run --dart-define=GEMINI_API_KEY=<key-lokal>
```

Jangan commit key asli, menaruhnya di README, atau membagikannya di log/command history. `--dart-define` mencegah key masuk source code, tetapi **bukan secret vault**: key yang ditanam di binary client masih dapat diekstrak. Untuk produksi publik dengan kontrol terpusat, pertimbangkan backend/proxy terautentikasi dan rate limiting. BYOK juga mengharuskan pengguna menjaga key mereka sendiri.

### Firebase dan data pribadi

- Firebase client config bukan izin akses. `firestore.rules` membatasi path `users/{uid}` kepada user yang UID auth-nya sama, dan memvalidasi sebagian field.
- Jika schema/path berubah, update dan deploy Security Rules serta uji sebagai owner dan non-owner. UI tidak dapat menggantikan security rules server.
- Klaim pengguna dapat sensitif; kirim konteks minimum ke Gemini. Jangan log klaim mentah, prompt, gambar, token, atau key.
- `SharedPreferences` hanya untuk data kecil non-rahasia. Jangan simpan kredensial di sana.
- Konfigurasi Android saat ini memakai debug signing untuk run lokal; sebelum distribusi, siapkan signing release dengan secret di luar repository.

---

## 5. Penyimpanan Lokal dan Caching

| Data | Penyimpanan dan perilaku |
|---|---|
| Flag onboarding | `SharedPreferences`, persisten lokal. |
| Key BYOK | `flutter_secure_storage`, lokal/OS-protected, tidak disinkronkan aplikasi. |
| Sesi chat | `SharedPreferences`, lokal, tidak lintas perangkat. |
| Progres guest | `SharedPreferences`, lokal, tidak otomatis merge ke akun. |
| Progres akun | Firestore per UID. |
| History dan skor | Firestore per UID. |
| Modul belajar dan trending | Data statis di source Dart, berubah lewat rilis aplikasi. |
| Gambar | Input picker untuk proses verifikasi; tidak ada database media khusus. |

Firestore SDK mungkin memiliki cache platform, tetapi aplikasi tidak mendefinisikan database offline khusus seperti SQLite/Drift/Hive. Jangan menjanjikan offline-first untuk history/skor tanpa menguji konfigurasi cache dan resolusi konflik.

---

## 6. Troubleshooting dan Kesalahan Umum

Perintah diagnosis dasar:

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
```

### Flutter dan dependency

- SDK Dart di `pubspec.yaml` meminta `^3.8.1`; cocokkan versi Flutter aktif sebelum menyelidiki error package.
- Jika pub solver gagal, periksa constraint dan `pubspec.lock`. Hindari `pub upgrade --major-versions` sebagai langkah awal karena dapat mengubah banyak API.
- `flutter clean` hanya untuk indikasi cache build stale; ia menghapus output lokal dan menyebabkan build ulang.

### Android/Gradle

App module meminta `compileSdk 36`, `minSdk 23`, NDK `27.0.12077973`, dan Java/Kotlin target 17. Pasang Android SDK Platform 36, NDK sesuai versi, JDK 17, serta setujui Android licenses. Untuk `SDK location not found`, periksa `ANDROID_HOME`/`ANDROID_SDK_ROOT` atau SDK path Android Studio. Untuk error NDK/JVM mismatch, samakan versi dengan konfigurasi Gradle; jangan menurunkan versi tanpa cek persyaratan plugin. Peringatan target x86 yang deprecated bukan otomatis kegagalan build. Build debug tidak membuktikan release signing siap.

### Firebase/Auth

- Firebase init gagal: cek opsi platform, package/bundle ID, `google-services.json`/konfigurasi iOS, plugin Google Services, project Firebase, dan jaringan.
- `permission-denied`: periksa UID login, path dokumen, whitelist field/tipe/ukuran data, dan rules yang sudah dipublish.
- Google Sign-In Android: pastikan package ID, OAuth client, serta SHA-1/SHA-256 untuk sertifikat debug dan release benar.
- Guest tanpa data cloud bisa merupakan perilaku yang disengaja; cloud membutuhkan UID.

### Gemini

- Tidak ada key: aplikasi dapat berjalan dalam demo mode; tambahkan key via UI atau compile define untuk development.
- Key invalid: cek key Google AI Studio, spasi/potongan, status pencabutan, API dan region.
- 429: cek kuota/limit. Failover model tidak menghapus batas kuota project.
- 502/503: biasanya sementara; coba lagi kemudian, jangan menganggapnya verdict.
- 404 model: cek kandidat model aktif.
- Respons kosong/JSON invalid/terpotong: periksa schema, prompt, generation config dan batas output. Pastikan parser mengembalikan error terkontrol.
- Gunakan connectivity probe/UI key settings untuk membedakan masalah jaringan, key, dan server.

### Storage dan state

Plugin SharedPreferences mungkin tidak tersedia pada widget test; override dependency dengan fake. Jika UI tidak berubah setelah mutasi, cek emisi state controller atau invalidasi provider. Untuk AsyncError, tampilkan pesan/retry terbatas dan hindari loop request.

Urutan diagnosis yang efektif: reproduksi → `flutter analyze` → test feature terfokus → fake dependency eksternal → periksa log yang sudah disanitasi → suite test penuh dan build platform terdampak.

---

## 7. Pertimbangan dan Keputusan Arsitektur

- **Flutter + feature-based structure:** satu codebase multi-platform dan kode dikelompokkan menurut capability produk. Trade-off: lebih banyak folder/lapisan; pertahankan abstraksi sesuai kompleksitas feature.
- **Clean Architecture:** kontrak domain memisahkan aturan bisnis dari SDK dan memudahkan fake/test. Jangan menjadikan setiap fungsi sederhana sebagai use case tanpa manfaat.
- **Riverpod:** dependency injection dan reaktivitas dengan provider yang dapat dioverride; lebih sedikit boilerplate daripada BLoC untuk alur ini. Business logic tetap perlu berada di controller/domain/repository yang tepat.
- **Firebase Auth/Firestore:** mempercepat auth, stream dan CRUD cloud per user; trade-off berupa vendor coupling, kuota, Security Rules, serta kebutuhan memikirkan offline.
- **Gemini + demo fallback:** AI text/vision dipetakan ke schema hasil; fallback memungkinkan pengembangan/test tanpa biaya dan key. Demo tidak boleh disajikan sebagai pemeriksaan faktual nyata.
- **BYOK + secure storage:** menghindari hanya mengandalkan key developer dan menyimpan key pengguna di fasilitas OS. Key client tetap berisiko diekstrak; backend proxy lebih kuat untuk kontrol produksi.
- **SharedPreferences:** tepat untuk flag dan data kecil. Jika data menjadi besar, butuh query/migrasi/transaksi, pertimbangkan database lokal dengan strategi migrasi.
- **Fetch metadata URL di client:** sederhana tanpa backend tambahan, tetapi rentan terhadap blokir host dan kualitas metadata. Backend extraction cocok bila dukungan URL menjadi kebutuhan kritis.

---

## 8. Panduan Perubahan dan Peta File

Saat menambah fitur: tentukan feature pemiliknya; definisikan entity/kontrak jika ada aturan/domain boundary; letakkan SDK di datasource; rangkai dependency melalui provider; uji domain/repository dengan fake dan perilaku penting di widget test; ubah Firestore Rules jika schema cloud berubah; jalankan format, analyze, test, serta build platform terkait. Jangan pernah commit API key, Firebase Admin credential, signing key, atau file rahasia.

File orientasi utama:

- Bootstrap/routes: `lib/main.dart`
- Shell: `lib/app/home_screen.dart`
- Quick Check: `lib/features/quick_check/`
- Resolver/secure key: `lib/core/utils/api_key_resolver.dart`, `lib/core/utils/api_key_store.dart`
- Auth: `lib/features/auth/`
- History: `lib/features/history/`
- Learn: `lib/features/learn/`
- Chat: `lib/features/chat/`
- Score: `lib/features/score/`
- Firestore security: `firestore.rules`
- Dependencies/assets: `pubspec.yaml`
- Android build: `android/app/build.gradle.kts`

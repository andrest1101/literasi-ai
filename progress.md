_project ini adalah dokumen hidup — update sesuai perkembangan development._
_Last updated: 14 September 2026_

## Status: FAB Chat Melayang + Ikon Shield — SELESAI

### Yang dikerjakan
- FAB Chat dipisah ke `chat_fab.dart`: ikon opsi A `verified_user` +
  badge sparkle AI, ring putih, shadow ganda, ukuran 60px.
- FAB dipindah ke `Scaffold.floatingActionButton` dengan gap 16px di atas
  navbar; navbar steril tanpa overlap maupun gangguan area sentuh.
- Padding bawah landing 28 ke 96 agar tips tidak tertutup FAB.
- Ikon diselaraskan: placeholder chat dan chip onboarding memakai bahasa
  ikon yang sama, robot generik dihapus.
- Test diperketat: cek tidak ada overlap rect FAB vs nav.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 48 test.

## Status: Navbar 4 + FAB Chat & Landing Fungsional — SELESAI

### Yang dikerjakan
- Navbar dipangkas 5 ke 4 destinasi (Cek, Riwayat, Belajar, Profil) model
  docked edge-to-edge: hairline atas, indikator pill biru, bukan floating.
- Chat AI keluar dari tab menjadi FAB bulat 56px kanan-atas nav (gradien biru,
  ikon robot, badge online) menuju route `/chat` placeholder Phase 3.
- Landing Quick Check: 3 kartu statis `Alur yang jelas` dihapus, diganti mode
  picker 2 tile berdampingan, carousel contoh sekali ketuk, dan tips bullet.
- Session screen dukung `initialMode` + `initialClaim` (plus `didUpdateWidget`)
  agar tile dan contoh langsung membuka sesi yang sesuai.
- Test baru `home_nav_chat_test.dart`: 4 destinasi, FAB ke chat, tile ke mode
  gambar, contoh mengisi sesi, switch tab. Bug listener ganda sisa edit
  ditemukan dan diperbaiki sebelum finalisasi.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 48 test.

## Status: Onboarding Sekali-Per-Install — SELESAI

### Yang dikerjakan
- Tambah flag lokal `onboarding_completed_v1` via SharedPreferences agar
  onboarding hanya tampil sekali per install, bukan setiap refresh/restart.
- Bangun slice Clean Architecture auth: repository domain, datasource lokal,
  repository impl, dan controller Riverpod AsyncNotifier yang testable.
- Splash menunggu branding minimum lalu routing ke Auth bila flag selesai dan
  ke Onboarding bila belum/gagal baca. Onboarding menyimpan flag saat
  `Mulai Sekarang` maupun `Lewati`.
- Tambah test datasource, controller, splash dua arah, dan persistensi skip.
  Test startup lama memakai mock SharedPreferences agar tidak hang.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 44 test.

## Status: Quick Check Copy Formal — SELESAI

### Yang dikerjakan
- Ganti istilah user-facing yang membingungkan seperti “klaim” menjadi
  “informasi”, “pesan”, “berita”, atau “gambar” dengan nada formal profesional.
- Pertahankan sesuai permintaan: tanpa kalimat arti verdict, label
  “Caption opsional”, catatan privasi KTP/data sensitif, serta judul dan
  subjudul “AI sedang menganalisis”.
- Selaraskan pesan validasi domain dan pesan error ramah Gemini agar konsisten
  dengan AppStrings tanpa mengubah kontrak JSON, verdict, batas, atau provider.
- Sesuaikan test sumber gambar ke label “Sumber: Gambar”.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 39 test.

## Status: Quick Check Status Flat Tanpa Panel — SELESAI

### Yang dikerjakan
- Hapus `_SessionStatusPanel` agar bagian Input-Analisis-Hasil tidak lagi memakai
  kartu putih bertumpuk. Status kini menjadi progress rail flat: subtitle,
  stepper, divider, lalu mode selector.
- Pertahankan kartu input dan kartu hasil karena keduanya punya peran berbeda:
  kartu kerja untuk field/CTA dan hero card untuk verdict. Tidak ada kartu baru.
- Alignment stepper tetap full-width terhadap kontainer input; track tetap dari
  pusat dot pertama ke pusat dot terakhir.
- Tidak ada perubahan domain/data/Gemini/Riverpod, validasi teks, atau mode gambar.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 39 test.

## Status: Quick Check Header A & Stepper Separation Fix — SELESAI

### Yang dikerjakan
- Terapkan opsi A untuk tombol kembali: satu lingkaran tonal 40px dengan border
  biru lembut, shadow rendah, panah gelap, tooltip, dan Semantics. Slot AppBar
  dirapikan ke 56px dengan title spacing 4px agar proporsional dan tidak kotak besar.
- Perbaiki akar masalah stepper: Stack kini memakai top alignment agar track
  benar-benar sejajar dengan pusat dot. Dot memakai ukuran tetap plus animasi
  warna tanpa perubahan dimensi; ikon internal disesuaikan agar tidak terlihat membesar.
- Pisahkan label dari baris dot dengan jarak 12px dan alur kiri-tengah-kanan.
  Label aktif memakai teks gelap tebal, label lain memakai teks sekunder agar
  tidak menyatu dengan warna biru track/dot.
- Tambah panel status tenang berisi subtitle dan stepper di atas permukaan putih
  dengan border halus dan shadow rendah, tanpa gradien atau blok warna mencolok.
- Perkuat regression test: AppBar putih, satu aksi kembali, tooltip, target
  sentuh, alignment label, dan status semantik stepper.
- Tidak ada perubahan domain/data/Gemini/Riverpod, validasi teks, atau mode gambar.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 39 test.

## Status: Quick Check Header & Stepper Polish — SELESAI

### Yang dikerjakan
- Hapus aksi kembali ganda di header sesi. Teks `Kembali ke Beranda` dihapus;
  satu tombol back reusable memakai surface biru muda, border, shadow halus,
  tooltip, dan Semantics dengan target sentuh minimal 44px.
- App bar kini memakai surface putih dengan garis bawah neutral tipis. Judul
  dirapikan sebagai application toolbar tanpa gradien atau blok warna berlebih.
- Stepper Input-Analisis-Hasil disusun ulang: track membentang dari pusat dot
  pertama hingga pusat dot terakhir, dot memiliki ukuran tetap pada semua state,
  dan label diposisikan terpisah dengan jarak aman sehingga tidak tertutup dot.
- Tambah regression test untuk satu aksi kembali, label stepper, target sentuh,
  dan render tanpa exception. Tidak ada perubahan domain/data/Gemini/Riverpod.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 39 test.

## Status: Quick Check Session Alignment & Counter Polish — SELESAI

### Yang dikerjakan
- Stepper Input-Analisis-Hasil ditulis ulang dengan track dari pusat dot pertama
  ke pusat dot terakhir. Dot dan label kini memakai layout terpisah agar batas
  stepper sejajar dengan kontainer input tanpa overflow di viewport sempit.
- Ritme jarak subtitle, stepper, divider, selector mode, dan hint dirapikan ke
  grid 8pt agar komposisi sesi terasa lebih seimbang.
- Counter teks dipindahkan dari header ke pojok kanan bawah di dalam area input.
  Format baru memakai pemisah ribuan Indonesia: `0 / 2.000 karakter` dan track
  progres halus. Counter caption gambar memakai komponen yang sama.
- Tambah ruang vertikal sebelum CTA Verifikasi agar tombol tidak menempel pada
  kontainer input; state disabled/enabled biru tetap dipertahankan.
- Test format counter Indonesia ditambahkan. Bug overflow stepper pada widget
  test ditemukan dan diperbaiki sebelum finalisasi.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 38 test.

## Status: Quick Check Mode Gambar + Session Upgrade — SELESAI

### Yang dikerjakan
- Tambah mode pemeriksaan `Teks | Gambar` lewat segmented control di session.
  Caption gambar boleh kosong; bila diisi, validasi 10-2.000 karakter tetap berlaku.
- Domain baru: `ImageAttachment` (JPG/PNG/WebP, maksimal 5 MB), interface
  `ImagePickerService`, use case `VerifyImageClaim`, dan method repository gambar.
- Data baru: `GeminiVisionDatasource` multimodal (`TextPart + DataPart`),
  implementasi picker nyata, dan repository terpadu teks/gambar.
- Permission platform: kamera/galeri Android dan usage description iOS.
- UI session ditingkatkan: panel picker/preview profesional, metadata file,
  catatan privasi, auto-scroll hasil, transisi `AnimatedSwitcher`, analyzing
  khusus gambar, label sumber `TEKS/GAMBAR`, dan landing yang menyebut teks+gambar.
- Hapus `verdict_card.dart` lama yang tidak dipakai setelah result section baru.
- Test baru: validasi attachment, use case gambar, provider gambar/retry,
  dan widget pick-verify-source tanpa network/key.
- Perbaiki bug `GlobalKey` ganda pada transisi `AnimatedSwitcher` dan lint async context.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 37 test.

## Status: Quick Check UI Redesign Total — SELESAI

### Yang dikerjakan
- Tab Quick Check di Home diubah menjadi landing ringkas dengan CTA `Mulai
  Pemeriksaan`. Pemeriksaan berjalan di dedicated session screen via push route
  agar punya ruang fokus penuh.
- Session memakai stepper Input-Analisis-Hasil, input section satu permukaan
  filled kontras, analyzing timeline tiga tahap + progress linear, dan result
  section satu alur vertikal (verdict, confidence, klaim, analisis, saran).
- Hilangkan pola kartu bertumpuk: hanya satu kartu hasil utama, sisanya divider,
  catatan kaki, dan daftar tips ringan.
- Perbaiki jarak berlebih akibat reuse `AuthFormCard` dengan padding overlay
  medallion; input section kini punya komposisi sendiri yang proporsional.
- Warna tetap palet resmi LiterasiAI tanpa ungu referensi; status memakai pita
  tinted + badge, teks tetap gelap agar kontras.
- Domain, datasource Gemini 3.5 Flash-Lite, validasi 10-2.000 karakter, dan
  controller AsyncNotifier tidak berubah. API `verify/retry/reset` dipertahankan.
- Route lama `/quick-check` dipertahankan sebagai wrapper kompatibilitas ke
  session screen.
- Test: landing CTA ke session, analyzing ke result, semua verdict render aman,
  dan test lama disesuaikan ke struktur baru.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 24 test.

## Status: Phase 2 Quick Check Teks — SELESAI

### Yang dikerjakan
- Domain Quick Check teks: enum `Verdict`, entity `VerificationResult` murni Dart,
  repository interface, dan use case `VerifyClaim` dengan batas 10-2.000 karakter.
- Data layer Gemini `gemini-3.5-flash-lite`: parsing JSON toleran code fence,
  clamp confidence 0-100, timeout 30 detik untuk free tier, dan pesan error jujur
  (timeout, invalid key, kuota, safety, model tidak ditemukan).
- Verdict `TIDAK_DAPAT_DIPASTIKAN` dikembalikan sebagai hasil sukses, bukan error.
- Presentation: `QuickCheckController` Riverpod `AsyncNotifier` dengan aksi verify,
  retry, reset, dan cegah request ganda. Controller memakai raw claim untuk retry
  agar gagal validasi ulang tetap bisa mencoba lagi.
- UI profesional: hero Quick Check, kartu form dengan counter + tombol hapus,
  status analyzing inline, kartu verdict dengan hierarki kuat, error card retry,
  tips hasil terbaik, dan disclaimer AI. Terhubung ke tab Home dan route baru.
- Sinkronkan model final ke `PRD.md`, `agents.md`, dan `pubspec.yaml` agar tidak
  lagi menyebut `gemini-1.5-flash`.
- API key tidak ditulis ke repo; datasource hanya memakai `--dart-define`.
- Firebase `apiKey` di `firebase_options.dart` adalah client key publik hasil
  FlutterFire, bukan Gemini key yang sempat bocor dan sudah di-revoke.
- Test baru: parsing JSON, batas validasi, mapping failure, transisi provider,
  alur widget input-loading-hasil-error-retry, dan verdict uncertain sebagai sukses.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 21 test.

## Status: Auth Hero Medallion Verifikasi — SELESAI

### Yang dikerjakan
- Ganti header balok gradien penuh dengan hero terpusat: judul, subtitle,
  medallion verifikasi lingkaran berlapis, lalu card form yang overlap ringan.
- Medallion memakai ikon verified-user + badge centang hijau sebagai focal point
  tema cek-fakta, bukan orb AI generik dari referensi travel.
- Tombol kembali dipindah ke baris atas latar terang untuk Daftar dan Lupa Sandi.
- Card form diberi padding atas lebih besar agar medallion overlap tanpa menutup
  judul seksi atau field pertama.
- Test baru mengunci overlap medallion-card di Masuk, tombol kembali di Daftar,
  dan ketahanan keyboard di Lupa Sandi.
- Perubahan hanya di presentation layer; domain/data dan logika Firebase tidak
  berubah, sesuai Clean Architecture.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 4 test.

## Status: Auth Proporsi dan Hierarki Card Opsi A — SELESAI

### Yang dikerjakan
- `AuthPageShell` memakai header brand intrinsik berbasis `SafeArea`, bukan tinggi
  tetap. Header berisi emblem 44px, nama LiterasiAI, tagline singkat, dan tombol
  kembali bila tersedia di layar Daftar dan Lupa Sandi.
- Judul halaman dipindah ke area konten shell agar tidak duplikat dengan brand.
  Struktur menjadi brand, judul, card primer, panel sekunder, lalu tautan bawah.
- Hapus badge `MASUK GRATIS`, `DAFTAR GRATIS`, dan `ATUR ULANG` dari semua layar.
  Hapus widget `AuthEyebrow` dan `AuthHeading` yang sudah tidak dipakai.
- `AuthFormCard` mendapat judul seksi dan subtitle agar form tidak terlihat kosong.
  Card memakai border lebih tegas dan dua lapis shadow yang terkontrol.
- Input memakai latar abu kebiruan muda agar kontras terhadap card putih. State
  fokus tetap biru dan error tetap merah.
- Tambah `AuthSecondaryPanel` untuk Google dan anonim agar aksi sekunder terasa
  dikelompokkan tanpa membuat card kedua yang menyaingi CTA primer.
- Terapkan spacing grid 8pt di Masuk, Daftar, dan Lupa Sandi. Konten dibatasi
  lebar 520 agar proporsional di layar besar.
- Pindahkan copy judul card ke `AppStrings` agar tidak hardcoded di widget UI.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 5 test.

## Status: Auth Redesign Clean Header + Form Card — SELESAI ✅

### Yang dikerjakan
- Hapus maskot besar dari layar Masuk, Daftar, dan Lupa Sandi karena memakan
  hampir setengah viewport dan terasa terlalu playful untuk aplikasi cek-fakta.
- `AuthPageShell` diganti menjadi header brand kompak: gradien biru,
  ikon verified-user, wordmark LiterasiAI, dan tagline singkat. Tidak memakai
  ilustrasi onboarding agar onboarding tetap jadi tempat utama menjelaskan app.
- Hilangkan sumber garis tengah/hairline dari header lama dengan menghapus
  curve custom + transisi maskot compact. Header baru memakai edge sederhana
  dengan radius bawah, tanpa boundary animasi yang rentan retak pixel.
- Tambah `AuthFormCard`: email/sandi/tombol primer dibungkus satu card surface
  dengan border halus dan shadow. Hierarki CTA jadi lebih jelas dan profesional:
  aksi primer di card, Google/anonim/tautan sebagai aksi sekunder di bawah.
- `auth_screen.dart`, `register_screen.dart`, `forgot_password_screen.dart`:
  hapus state `MascotMood`, focus listener maskot, lookAt, dan import maskot.
  Flow validasi, Google Sign-In, anonim, forgot password Firebase tetap sama.
- Hapus `login_mascot.dart` karena tidak lagi dipakai, tidak menyisakan kode mati.
- Test regresi diperbarui: mengunci header brand di luar scroll, `AuthFormCard`
  tampil, keyboard tidak overflow, navigasi Masuk-Daftar-Lupa tetap aman.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 5 test.

## Status: Pin Header Auth di Luar Scroll (HP Fisik) — SELESAI ✅

### Yang dikerjakan
- Baru `widgets/auth_page_shell.dart`: header maskot dipin DI LUAR scroll
  (`Column[Flexible(header), Expanded(scroll form)]`), jadi auto-scroll
  keyboard tidak bisa lagi mendorong maskot keluar viewport.
  Deteksi keyboard via viewInsets tetap picu mode compact, Back overlay aman
  notch via `MediaQuery.paddingOf`, header dibatasi `Flexible + ClipRect`
  agar frame animasi tidak overflow di viewport sempit.
- `auth_screen.dart`, `register_screen.dart`, `forgot_password_screen.dart`:
  refactor ke `AuthPageShell`, form dipindah jadi child tanpa ubah validasi
  atau wiring Firebase. Logika mood cover dan peek tidak berubah.
- `login_mascot.dart`: shadow bawah saat compact sebagai batas tegas
  header pinned dan form scroll.
- Bug ditemukan saat verifikasi: simulasi keyboard 400 di test membuat
  viewport sisa 200px lalu header expanded 232px overflow 80px di Column
  shell (diagnostik penuh menunjuk `auth_page_shell.dart:39`).
  Diperbaiki dengan `Flexible + ClipRect`, terbukti nol exception di debug.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 5 test
  (3 lama + compact + pinned baru).

## Status: Mini Sticky Mascot Header saat Keyboard — SELESAI ✅

### Yang dikerjakan
- `LoginMascotHeader`: param `compact` baru, animasi 250ms expanded 232px
  ke compact 84px. Orb dan sparkle diganti kilau ringkas agar tidak berisik.
  Curve dipertahankan tipis 14px supaya transisi ke form tetap mulus.
- `LoginMascot`: param `size` baru (default 168, compact 56). Layout absolut
  internal tetap 168 dan diskala via FittedBox, napas ikut proporsional.
  Reaksi cover dan peek tetap terbaca di ukuran kecil.
- `auth_screen.dart`, `register_screen.dart`, `forgot_password_screen.dart`:
  deteksi `MediaQuery.viewInsetsOf(context).bottom > 0` lalu kirim
  `compact: keyboardOpen` ke header. Logika mood dan focus tidak berubah.
  Tombol Back Daftar dan Lupa Sandi tetap muat di header compact.
- Test regresi: header expanded 168 tanpa keyboard, compact 56 saat keyboard,
  mood cover render tanpa exception di mode compact.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 4 test.

## Status: Penataan Footer Auth — SELESAI ✅

### Yang dikerjakan
- Baru `AuthBottomLink`: tautan penutup satu baris, awalan abu dan aksi biru
  tebal. Dipakai Masuk ("Belum punya akun? Daftar") dan Daftar
  ("Sudah punya akun? Masuk") sebagai elemen paling bawah.
- Hapus catatan offline permanen dan trust row dari footer. Catatan offline
  pindah jadi snackbar sekali tampil saat anonim sukses. Klaim privasi tanpa
  bukti dihapus agar tidak menurunkan kepercayaan reviewer.
- "Lanjut tanpa akun" tetap teks tanpa kartu agar tidak menyaingi tombol
  Masuk dan Google. Hierarki CTA: primer, sekunder, tersier, penutup.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 3 test.

## Status: Refinement Auth (Spacing, Checklist, Footer, Bug Maskot) — SELESAI ✅

### Yang dikerjakan
- `authInputDecoration`: contentPadding vertikal 18, prefixIcon 20 dengan
  constraints 48x48. Label floating dan hint tidak lagi mepet border.
- `AuthHeading` dimigrasikan ke `AppStyles.heading` dan `AppStyles.body`.
- Indikator sandi ditulis ulang: checklist polos tanpa kotak (ikon 16 +
  teks 13, AnimatedSwitcher dan warna abu ke hijau). Tidak lagi mirip input.
- Skala spacing 8/12/16/20/24/28 diterapkan konsisten di Masuk, Daftar,
  dan Lupa Sandi. Footer Masuk diringankan tanpa menghapus teks apapun.
- Fix bug: maskot kini menutup mata saat kolom Ulangi Kata Sandi fokus
  (FocusNode sendiri + mood cover atau peek ikut toggle tampil).
  Ada test regresi yang mengunci perilaku ini.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 3 test.

## Status: Halaman Daftar dan Lupa Sandi — SELESAI ✅

### Yang dikerjakan
- Baru `register_screen.dart`: Nama, Email, Sandi, Konfirmasi, indikator syarat
  live (6+ karakter, ada angka), maskot happy, tombol Back, validasi jujur.
  Provider email belum aktif di backend, jadi Daftar mengarahkan ke jalur tersedia.
- Baru `forgot_password_screen.dart`: kirim `sendPasswordResetEmail` asli Firebase,
  banner sukses hijau, maskot happy setelah terkirim, tombol Back.
- Baru `auth_form_parts.dart`: dekorasi input, eyebrow, heading, tombol utama,
  tombol back, trust row, snackbar. Dipakai ketiga halaman, nol duplikasi.
- Baru `password_requirement_list.dart`: indikator syarat sandi live reusable.
- `auth_screen.dart` (refactor): pakai widget bersama, tambah tautan Daftar
  dan Lupa Sandi. Posisi tombol Google dan anonim tidak berubah.
- `main.dart`: daftarkan route `/register` dan `/forgot-password`.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 3 test
  (termasuk segitiga Masuk ke Daftar ke Lupa Sandi dan kembali).

## Status: Logo Google Resmi — SELESAI ✅

### Yang dikerjakan
- Daftarkan `assets/image/` dan `assets/animation/` di `pubspec.yaml`
  (animation disiapkan kosong untuk Rive di masa depan).
- `google_g_logo.dart` (rewrite): `Image.asset(logo_google.png)` resmi 4 warna
  gantikan CustomPainter manual yang membuat huruf G terlihat menyatu.
  Fallback lingkaran G bila aset gagal load. Posisi tombol tidak berubah.
- Keputusan Rive: ditunda. File `.riv` belum ada (folder animation kosong),
  maskot custom dipertahankan karena sudah mencakup semua state yang diminta.
- Tech debt: PNG 190KB untuk ikon 20px, idealnya dikompres saat polish.
- Verifikasi: `flutter pub get` OK, `flutter analyze` bersih,
  `flutter test` lolos (termasuk render aset tanpa exception).

## Status: Auth Redesign Total (Maskot Interaktif) — SELESAI ✅

### Yang dikerjakan
- Hapus `auth_hero_card.dart` yang kaku. Header diganti maskot perisai bermata
  (`login_mascot.dart`, Flutter murni tanpa Rive/Lottie): idle napas, typing melirik,
  cover saat sandi fokus, peek saat sandi ditampilkan, happy/sad ikut hasil masuk.
  Header gradien + curve lembut menyatu ke form.
- Form email dan kata sandi real (validasi regex + min 6, toggle tampil, autofill).
  Tombol Masuk memberi umpan balik jujur karena backend email belum ada.
- Logo Google 4 warna resmi via CustomPainter (`google_g_logo.dart`, tanpa aset).
  Tombol Google + divider "atau" + "Lanjut tanpa akun" + catatan offline + trust row.
- Copy dibersihkan: tidak ada em dash di semua string user-facing.
  Tidak ada kartu ganda, padding lega, tipografi Inter.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos
  (maskot cover/peek, validasi form, anonim ke Home).

## Status: Auth Screen Premium — SELESAI ✅

### Yang dikerjakan
- Baru `auth_hero_card.dart`: kartu hero gradien biru + mock verdict HOAKS 87% + chip "AI Aktif".
- Rewrite `auth_screen.dart`: eyebrow MASUK • GRATIS, judul, 3 checklist manfaat + centang,
  tombol anonim primary 56px + tombol Google putih berlogo, catatan offline, trust row gembok.
- Wiring Google Sign-In asli (google_sign_in 6.x + Firebase credential); gagal → snackbar error,
  user tetap bisa lanjut anonim — demo tidak buntu.
- Anti-overflow via SingleChildScrollView, spinner per-tombol, Semantics label.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos (auth tampil + anonim → Home).
- Catatan: SHA-1 debug `9B:B1:5F:...:5E:09` perlu didaftar di Firebase console
  agar Google Sign-In Android berfungsi penuh (oauth_client masih kosong).

## Status: Onboarding Interaction Upgrade — SELESAI ✅

### Yang dikerjakan
- `agents.md`: tambah §6 Git & Commit Policy — AI dilarang commit/push, hanya beri deskripsi; file banyak dipecah per tema.
- `app_strings.dart`: desc slide 1 digeneralisasi (chat/medsos/berita, tetap singkat) + eyebrow `VERIFIKASI TEKS / MULTI-FORMAT / RIWAYAT AMAN`.
- `onboarding_visual.dart` (rewrite): `StatefulWidget` press-glow (scale 0.96x + glow + border aksen, ~180ms, Semantics+Tooltip),
  responsif via LayoutBuilder+FittedBox (skala 0.72–1.0, anti-overflow layar kecil),
  visual premium: dot-grid + orb gradien, slide 1 tumpukan kartu WA + medsos + strip sumber Chat/Medsos/Berita,
  slide 2 scan-frame + orbit dots, slide 3 avatar stack + tombol gradien + glowing dots.
- `onboarding_slide.dart`: tambah eyebrow pill + batasi deskripsi maxWidth 340.
- `onboarding_screen.dart`: logo gradien + shadow, haptic di navigasi, tombol Next AnimatedSwitcher (panah→roket),
  Semantics label di Back/Next, Back surface putih.
- `pill_page_indicator.dart`: halaman lampau biru 0.5 (progres terasa).
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos (swipe, press-glow tap, back, start→auth).

## Status: Onboarding Redesign — SELESAI ✅

### Yang dikerjakan
- `core/constants/app_strings.dart`: konten baru 3 slide (verifikasi teks, gambar+URL, riwayat)
  + label `Lanjut / Mulai Sekarang / Kembali / Lewati`.
- Baru `presentation/widgets/pill_page_indicator.dart`: pill animasi (aktif w=28 gelap, nonaktif w=8 abu).
- Baru `presentation/widgets/onboarding_visual.dart`: 3 ilustrasi Flutter murni
  (verdict card HOAKS 87% + confidence bar, kartu gambar+URL + chip floating, mini history list).
- Baru `presentation/widgets/onboarding_slide.dart`: visual atas + heading 26px + deskripsi.
- Rewrite `onboarding_screen.dart`: header brand + Lewati (fade di slide terakhir),
  PageView swipe BouncingScrollPhysics, nav bawah [Back ikon panah lingkaran | Next→Mulai Sekarang].
- Semua teks dibungkus ellipsis agar anti-overflow di font lebar.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos (swipe, back, start→auth).

## Status: Phase 1 Foundation — SELESAI ✅

### Step 0 — Restruktur Clean Architecture (sesuai PRD §8)
- Hapus `domain/data_sources/` di chat/history/learn/quick_check (pelanggaran CA).
- Rename `data_sources/` → `datasources/`, `use_cases/` → `usecases/` (samakan PRD).
- Pangkas chat/history/learn ke `presentation/` saja (PRD hanya kasih data+domain penuh ke quick_check).
- Tambah `lib/core/{constants,errors,utils}/`, `lib/shared/widgets/`, `lib/features/auth/` (full 3-layer).
- Tambah `lib/app/home_screen.dart` (shell 5 tab).

### Phase 1a — Dependencies
- `flutter_riverpod, firebase_core, firebase_auth, cloud_firestore, google_sign_in`
- `google_generative_ai` (gemini-1.5-flash), `http, image_picker, share_plus, screenshot`
- `flutter pub get` OK, `flutter analyze` bersih, `flutter test` lolos.

### Phase 1b — Design System
- `core/constants/app_colors.dart` (warna PRD §7.2), `app_strings.dart` (ID),
  `app_styles.dart` (Material 3 + Inter), `core/errors/failures.dart` (sealed Failure).
- `core/utils/url_fetcher.dart` (fetch title/description, timeout 10s),
  `core/utils/image_processor.dart` (gallery/camera wrapper).
- `shared/widgets/`: `loading_overlay, error_widget (AppErrorWidget), bottom_nav_bar` (5 tab).

### Phase 1c — App Shell & Routing
- `main.dart`: ProviderScope + Material3, Firebase init best-effort (mode offline jika belum setup).
- Routing: Splash (2s) → Onboarding (3 page) → Auth (Google placeholder + Anonymous) → Home (5 tab placeholder).
- API key Gemini via `--dart-define=GEMINI_API_KEY=...` (tanpa hardcode, tanpa .env).
- Test: `test/widget_test.dart` — Splash → Onboarding navigation.

### Keputusan arsitektur
- Konflik skill vs agents.md dimenangkan agents.md/PRD: Riverpod `Notifier/AsyncNotifier + ConsumerWidget`, bukan ChangeNotifier/get_it.
- History: Firestore per-user (bukan lokal), dikerjakan Phase 3 setelah Firebase user siap.
- Font: Inter (Google Sans tidak publik).

## Next: Phase 2 — Quick Check (belum mulai)
- [ ] Domain: `Verdict` enum + `verification_result.dart` entity
- [ ] Data: `verification_result_model.dart` (fromJson/toJson) + `gemini_datasource.dart` (prompt PRD §6.1, dart-define key, fallback TIDAK_DAPAT_DIPASTIKAN)
- [ ] Repo impl + `verify_claim.dart` usecase + `verification_provider.dart` (AsyncNotifier)
- [ ] UI: input/analyzing/result + verdict_card/share_card + share via screenshot+share_plus
- [ ] Mode gambar (image_picker + Gemini Vision) + mode URL (UrlFetcher)

## Menunggu user: Setup Firebase
- [ ] `flutterfire configure` untuk project literasi-ai → hasilkan `lib/firebase_options.dart`
- [ ] Aktifkan Auth (Google + Anonymous) & Firestore di console
- [ ] Kasih `google-services.json` / `GoogleService-Info.plist`

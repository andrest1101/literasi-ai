_project ini adalah dokumen hidup — update sesuai perkembangan development._
_Last updated: 23 September 2026_

## Status: UI/UX U2 P1 Identitas + Hierarki — SELESAI

### Yang dikerjakan
- Header per-tab beraksen (`SectionAccent`: Cek biru brand, Riwayat biru
  tua arsip, Belajar hijau tumbuh, Profil biru sedang) di
  `app_section_header.dart` — param opsional, kompatibel mundur. Eyebrow
  + baris judul kedua mengikuti aksen; tipografi + hairline tetap.
- Filter Riwayat jadi pill animasi (`AnimatedContainer` 200ms) dengan
  aksen per verdict + suffix hitung per filter dari daftar yang sama
  (tanpa query baru) + semantics `selected`. Bukan ChoiceChip default.
- Strip ringkasan jadi 3 kolom angka 20px tabular + label + top-bar aksen
  + divider hairline + semantics gabungan. Selaras dengan angka pill.
- Detail trending: `Verifikasi serupa` naik jadi Filled primer 54,
  box rujukan tegas (medallion + label eyebrow + shadow), seksi `Konteks
  terkait` 2 item se-kategori (reuse `VerdictPresentation`, sembunyi bila
  <2 item). `TrendingDetailScreen` jadi `ConsumerWidget`.
- Hasil kuis dapat `Tinjau jawabanmu`: 3 baris review (lingkar
  benar/salah + kunci jawaban) dari `_answers` + `module.quiz` yang ada.
- Profil: baris sumber poin beraksen (biru/hijau/amber), kartu akun
  avatar gradien inisial + CTA `Masuk untuk sinkron` bagi tamu (route
  `/auth` yang ada), catatan skor best-score yang jujur (ganti copy
  Phase-3b kedaluwarsa). String baru terpusat (`scoreGuestLabel`,
  `scoreLoginCta`, `trendingRelatedTitle`, `learnQuizReviewTitle`,
  `learnDetailTitle` sudah U1).
- Test `ui_u2_identity_test.dart` 8 case + selaraskan 3 test lama
  (premium ringkasan baru, score akun baru, hero detail butuh
  ProviderScope di luar MaterialApp).
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 175 test.

## Status: UI/UX U1 P0 Anti-Polos — SELESAI

### Yang dikerjakan
- `AppShimmer` bersama di `lib/shared/widgets/app_shimmer.dart`:
  denyut alpha 1200ms (tanpa dep baru) + `ShimmerBar`/`ShimmerCircle` +
  semantics label. Satu sumber untuk semua skeleton.
- Skeleton Riwayat meniru bentuk `HistoryCard` (badge 44 + verdict +
  confidence + klaim 2 baris + footer sumber-tanggal); skeleton Belajar
  meniru `_ProgressSummary` (ring 56 + 2 baris). Loading tidak lagi kotak
  putih polos, transisi tanpa layout shift besar.
- Empty state Riwayat dapat CTA `Mulai pemeriksaan` (Filled + ikon
  verified) yang push `QuickCheckSessionScreen`. Varian filtered tetap
  tanpa CTA (masalahnya filter, bukan data kosong).
- Detail modul ditulis ulang: hero gradien `heroBegin/heroEnd` (satu
  keluarga dengan kartu daftar) + bilah progres baca di bawah AppBar
  via ScrollController (dispose benar) + sticky bottom bar (Kuis Filled
  54 primer, klaim Outlined 46 sekunder). Seksi 1 featured aksen primer
  agar 4 kartu tidak identik. Logika `_claim()` + `_openQuiz()` utuh.
- String baru terpusat di `AppStrings` (`historyLoading`,
  `historyEmptyCta`, `learnProgressLoading`, `learnDetailTitle`,
  `learnReadingProgress`) — tanpa hardcode di widget.
- Test `ui_u1_polish_test.dart` 9 case: denyut shimmer, skeleton riwayat,
  bentuk skeleton belajar, CTA tampil + navigasi sesi, hero + meta,
  progres + sticky CTA, klaim idempoten + kuis terbuka.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 167 test.

## Status: Hero Badge Verdict List ke Detail — SELESAI

### Yang dikerjakan
- `QuickCheckResultSection` terima param opsional `heroTag`; badge ikon
  verdict 52px dibungkus `Hero` hanya bila tag non-null. Layar sesi tanpa
  tag = perilaku lama utuh, ShareCard off-screen dikecualikan.
- Pasangan Hero: `HistoryCard` (badge 44px) ke `HistoryDetailScreen` via
  `HistoryCard.heroTagFor(entry.id)`, dan pita ikon `TrendingRail` ke
  `TrendingDetailScreen` via `TrendingRail.heroTagFor(item.id)` — tag unik
  per id, satu sumber kebenaran, anti crash duplicate-tag.
- Test `hero_verdict_test.dart` 5 case: tag unik, tap-terbang-balik
  riwayat, tanpa tag = tanpa Hero (regresi), pasangan trending.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 158 test.

## Status: Sapu Tech-Debt Linux + README Profesional — SELESAI

### Yang dikerjakan
- Warning terakhir hilang: `await repository.isCompleted()` di
  `onboarding_provider.dart` (unawaited_return_in_try_block). `dart analyze`
  kini `No issues found!`.
- Logo Google 3840px/190KB dipangkas ke 96px/6KB (-97%) via PIL LANCZOS +
  optimize; test `GoogleGLogo renders official asset` tetap lolos.
- README rewrite: badges stack, daftar isi, tabel fitur, demo 60 detik,
  quickstart (+ catatan `libsecret-1-dev` Linux), konfigurasi Firebase/BYOK,
  arsitektur, pengujian (153 test), roadmap, troubleshooting, dokumentasi.
- Recon UI via screenshot dibatalkan jujur: tidak ada display aktif
  (sesi di login screen), jadi tidak ada edit visual buta. Perbaikan UI
  berikutnya butuh screenshot user atau scoping animasi terkurasi.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 153 test.

## Status: Premium Upgrade (Sistem + UI/UX + Fitur) — SELESAI

### Yang dikerjakan
- Design tokens: varian warna gelap/hero/disabled/shadow di
  `app_colors.dart`, `AppRadii` + `AppSpacing` + theme
  Filled/Outlined/Chip/Divider/Snackbar di `app_styles.dart`.
- Verdict 1-detik aksesibel: `VerdictPresentation` punya headline aksi
  per verdict (ikon + teks + warna), confidence bar animasi 650ms,
  entrance fade+slide 320ms, tombol Salin hasil + snackbar.
- Analyzing jujur: persen palsu berulang diganti detik berjalan +
  bar indeterminate + tahap monoton naik.
- Sistem: sanitasi prompt-injection + blok KLAIM/SELESAI + aturan
  anti-confidence-100 di prompt teks; `UrlFetcher` dukung og:title/
  og:description, User-Agent, batas 512 KB, decode entity HTML.
- Fitur: search riwayat lokal (klaim + URL, gabung filter verdict),
  ringkasan Hoaks/Valid/Perlu dicek, 2 contoh demo baru (gempa, loker).
- Test `premium_upgrade_test.dart` 9 case baru.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 153 test.

## Status: Phase 4 Readiness P2 — SELESAI

### Yang dikerjakan
- README rewrite Purpose → Process → Outcome + cara run BYOK/demo +
  arsitektur + 138 test + demo 60 detik. PRD checklist MVP dicentang +
  amandemen history Firestore vs lokal.
- Bukti <5 detik: Stopwatch di controller (teks/gambar/link + debugPrint),
  teks durasi `2,1 dtk` di kartu hasil, cache klaim identik LRU 20, rate
  limit 2 detik lapisan repository.
- Tech debt: hapus `_PlaceholderTab` mati + 6 string kedaluwarsa. Kompres
  logo ditunda (tanpa Pillow di Windows).
- Test `verify_performance_test.dart` 6 case. Hook injeksi `verifyTextFn`
  agar cache teruji tanpa network.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 144 test.

## Status: Trending Hoaks Phase 3c — SELESAI

### Yang dikerjakan
- Domain Trending murni Dart: `TrendingItem` + konversi ke hasil verifikasi,
  kontrak repository sync lokal.
- Data curated 7 hoaks ID (kategori, tanggal, rujukan, HOT) + impl offline.
- Provider sync tanpa Firebase agar guest offline tetap melihat feed.
- UI heterogen: rail vertikal 228px + badge HOT + detail reuse hasil/share +
  verifikasi serupa. Wiring di bawah carousel tab Cek.
- Test `trending_test.dart` 4 case. Bug const DateTime dan assertion ganda
  diperbaiki.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 138 test.

## Status: Learn Mini-Course Phase 3b — SELESAI

### Yang dikerjakan
- Domain Learn murni Dart: `QuizQuestion` + penjelasan, `CourseModule` 3
  modul, `CourseProgress` best-score anti farming, kontrak repository.
- Data: `LearnContentDatasource` 3 modul ID (4 seksi + 3 soal), Firestore
  `users/{uid}/learn/progress` (arrayUnion modul, map best kuis), mapping
  toleran korup.
- Provider: konten statis, stream progres + timeout, aksi complete (+20) dan
  submit kuis (+5 per benar baru) dengan hook Score best-effort. Guest baca
  dan kuis lokal tanpa login.
- UI heterogen: 3 varian kartu (hero gradien, split kolom, strip nomor),
  detail artikel bernomor + klaim idempoten, kuis terkunci per halaman +
  penjelasan + hasil + klaim best-score. Tab Belajar ganti placeholder.
- Test `learn_test.dart` 7 case + selaraskan header test. Bug cast, scroll,
  dan snackbar ganda diperbaiki.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 134 test.

## Status: Merge remote rewrite email 16 Sep — SELESAI

### Yang dikerjakan
- Remote hanya berisi rewrite author 4 commit 16 Sep ke identitas benar.
  Konflik diselesaikan dengan mempertahankan sisi lokal (BYOK/demo/shimmer
  lebih baru); sisi remote tidak membawa perubahan fitur.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos.

## Status: Entry Pengaturan + Rules + Mailmap — SELESAI

### Yang dikerjakan
- `firestore.rules` owner-only `users/{uid}/**` + panduan deploy manual ke
  console (tanpa Blaze, tanpa kartu). Retry skor gagal terus = rules belum
  dipasang, bukan soal API key.
- Kartu kunci API di Profil + chip status di Cek menuju `/api-key`. Guest
  tanpa login tetap bisa BYOK karena kunci per-perangkat.
- Invalidate rantai datasource/repository setelah save/hapus agar banner dan
  request sinkron instan tanpa restart.
- `.mailmap` samakan typo email 16 Sep tanpa rewrite history yang merusak.
  Config lokal/global diperbaiki ke identitas benar.
- Test kartu profil + chip cek + propagasi instan.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 127 test.

## Status: Propagasi BYOK Instan + Pesan Skor Jujur — SELESAI

### Yang dikerjakan
- Kunci BYOK langsung aktif tanpa restart: repository Quick Check dan Chat
  menerima `resolveApiKey` live + datasource `*WithKey` per request. Simpan
  key di Pengaturan langsung dipakai request berikutnya.
- Pesan error key diseragamkan ke Pengaturan (bukan cuma terminal).
- Error skor dibedakan tegas dari kunci API: pesan menyebut penyimpanan
  skor/Firestore agar tidak tertukar dengan error Gemini.
- Test propagasi instan ditambah untuk kedua repository.
- Perbaiki error lib pasca sentuhan terminal: pubspec secure storage,
  string BYOK/demo, flag isDemo, fallback repository, route ApiKey.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 125 test.

## Status: Literacy Score Phase 3a — SELESAI

### Yang dikerjakan
- Domain Score murni Dart: `LiteracyLevel` ambang Standar (0/50/150/300),
  `LiteracyScore` (+10 verifikasi, +20 modul, +5 kuis), kontrak repository dan
  3 use case award. Warna/ikon level di presentation extension agar domain
  bebas Flutter.
- Data Firestore `users/{uid}/score/summary`: increment atomik, arrayUnion
  modul idempoten, mapping toleran dokumen korup.
- Provider stream skor + aksi award; hook best-effort di `QuickCheckController`
  bersamaan auto-save History tanpa menahan hasil AI.
- UI: `ScoreRing` gradien animasi 600ms, `ScoreBreakdown` 3 sumber + catatan
  Phase 3b jujur, `ProfileScreen` fungsional pertama, `ScoreCheckChip` pill di
  tab Cek menuju Profil.
- Modul/kuis bernilai 0 jujur sampai Phase 3b; slot award sudah siap colok.
- Test `score_test.dart` 13 case + selaraskan 2 test lama. Bug cast model
  korup dan tap tile tertutup chip diperbaiki.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 112 test.

## Status: Header Chat Gabung + Banner Setup Key — SELESAI

### Yang dikerjakan
- AppBar Chat digabung: back + avatar shield + nama + status + aksi mulai
  baru. Teks `Kembali` dan presence bar ganda dihapus, hemat ~76px vertikal.
- Dot online palsu dihapus; status jujur berupa kesiapan, bukan koneksi.
- Banner pratinjau sekali-lihat saat key kosong: ikon kunci + tombol salin
  perintah run. Error Quick Check key hilang dapat tombol salin yang sama.
- Provider `chatKeyConfiguredProvider` baca key saat compile tanpa request.
- Test tambah banner + clipboard mock + provider key; selaraskan header lama.
  Bug tap saran tertutup banner dan snackbar timing diperbaiki.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 99 test.

## Status: AI Chat Assistant P0 — SELESAI

### Yang dikerjakan
- Domain chat: `ChatMessage` (role user/ai, status sent/failed, verifySeed),
  kontrak `ChatRepository`, dan `SendChatMessage` (validasi 1-1.000 karakter).
- Data: `GeminiChatDatasource` (model `gemini-3.5-flash-lite`, prompt literasi
  santai ID, konteks 10 pesan, timeout 30 detik, error ramah konsisten) dan
  `ChatRepositoryImpl`.
- Controller `ChatState/ChatController` (Riverpod Notifier): pesan optimistis,
  bubble mengetik, retry per pesan gagal, clear, cegah kirim ganda.
- UI profesional: presence bar ramping, bubble kanan gradien/kiri putih,
  typing dots, timestamp, tombol `Verifikasi ini` ke sesi Quick Check dengan
  seed benar, sapaan kosong + 3 saran sekali ketuk, input bar oval + counter.
- Placeholder lama dihapus; FAB dan route `/chat` tetap sebagai entry point.
- Test `chat_test.dart` 9 case + selaraskan 2 test lama. Bug timer scroll sisa
  diperbaiki agar test-safe.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 97 test.

## Status: History Firestore + Auto-Save — SELESAI

### Yang dikerjakan
- Slice Clean Architecture History penuh: `HistoryEntry`, `HistoryFilter`,
  kontrak `watch/save/delete`, use case `SaveHistory`/`DeleteHistory`,
  `HistoryRemoteDatasource` (Firestore `users/{uid}/verifications`,
  `orderBy checkedAt desc limit 50`), `HistoryDocModel`
  (fromDocument/fromMap/toDocument UTC ISO8601), dan `HistoryRepositoryImpl`.
- Provider Riverpod: `historyUserIdProvider` aman-test (tanpa Firebase init
  tetap jalan), `historyEntriesProvider` StreamProvider, filter StateProvider,
  `historyActionProvider` AsyncNotifier untuk delete terpantau UI.
- Auto-save best-effort: `QuickCheckController.verify/verifyImage/verifyUrl`
  menyimpan setelah AsyncData tanpa menahan hasil; gagal simpan hanya
  debugPrint, tidak menggagalkan verifikasi.
- UI tab Riwayat ganti placeholder: header kontekstual, chip filter 4
  (Semua/Hoaks/Valid/Perlu Dicek), skeleton loading, kartu (badge verdict,
  confidence tabular, klaim 2 baris, host URL, tanggal relatif), swipe delete
  + Snackbar Undo 4 detik, detail reuse QuickCheckResultSection + Bagikan,
  error card + retry. Semua copy terpusat di AppStrings.
- Test `history_test.dart` 18 case: model round-trip + fallback corrupt,
  usecase save/delete, provider stream/delete-error, filter, card, empty,
  filter tap, list filter, empty tanpa login, error retry, swipe + undo,
  tap detail, auto-save verify. Regresi lama disesuaikan (Riwayat kini
  fungsional, Belajar/Profil tetap placeholder).
- Verifikasi: `flutter analyze` bersih (sisa 1 warning lama onboarding tak
  terkait), `flutter test` lolos 88 test.

## Status: Quick Check URL + Share Hasil — SELESAI

### Yang dikerjakan
- Mode URL penuh Clean Architecture: `VerifyUrlClaim` (validasi http/https +
  authority, normalisasi, helper `isParsable` terpusat), `VerificationSource.url`
  + field `sourceUrl/sourceTitle`, kontrak `verifyUrlClaim`, dan repo impl yang
  mengorkestrasi `UrlFetcher` (judul + deskripsi truncate 500 char) lalu
  `GeminiTextDatasource` dengan klaim terstruktur URL/Judul/Deskripsi.
- Controller: `verifyUrl(url)`, retry prioritas image → url → teks, reset
  bersihkan `_lastUrl`. `UrlFetcher` yang lama menganggur kini terpakai.
- UI sesi 3 mode: selector Teks/Gambar/Link, `QuickCheckUrlSection` (field
  satu baris + tombol Tempel clipboard + pratinjau host hijau + privacy note),
  analyzing khusus URL (`Memuat link`), badge `Sumber: Link` + baris lampiran
  URL di result. Tombol aktif selama ada teks agar error lokal menjelaskan.
- Landing: banner Link full-width aksen hijau di bawah 2 tile, ritme tetap
  heterogen (hero, tile, banner, carousel). Route lama dukung mode url.
- Share hasil (PRD §4.1): `ShareCard` portrait off-screen (pita brand gradien,
  hero verdict + confidence, kutipan klaim, footer ajakan), `ShareService`
  (`captureFromWidget` → PNG `SharePlus.instance.share`, fallback teks bila
  capture gagal), tombol `Bagikan Hasil` dengan state loading + snackbar.
  `VerdictPresentation` dipisah ke file sendiri anti circular import.
- Fake repository 4 file test lama dilengkapi `verifyUrlClaim` agar kontrak baru
  tidak merusak regresi. Copy lama "teks atau gambar" diselaraskan jadi
  "teks, gambar, atau link".
- Test baru `quick_check_url_share_test.dart` 18 test: validasi URL, controller
  url + retry, ShareService (teks, file PNG, tolak bytes kosong), landing banner,
  sesi url analyzing→result, error lokal link invalid, share via injeksi,
  render ShareCard. Bug tombol-mati-misterius ditemukan dan diperbaiki.
- Verifikasi: `flutter analyze` bersih (sisa 1 warning lama onboarding tak
  terkait), `flutter test` lolos 70 test.

## Status: Header Ramping Tanpa Brand Ganda — SELESAI

### Yang dikerjakan
- Hapus AppBar Home + `_BrandBar` + pill `AI Aktif` (status dekoratif tanpa
  state nyata). Tiap tab pegang judul kontekstualnya sendiri via SafeArea body.
- `AppSectionHeader` murni tipografi: emblem gradien dihapus, eyebrow
  diperkecil, judul 30 ke 26px. Pembeda tab dari konten, bukan dekorasi sama.
- Wordmark kecil hanya di tab Cek. Placeholder jujur: judul ekspektasi +
  deskripsi phase tanpa klaim fungsi palsu.
- Session dan Chat: AppBar tinggal tombol kembali + label kecil; judul tunggal
  di body, tidak ada judul ganda.
- Test rewrite: wordmark khusus Cek, tanpa AI Aktif, tanpa judul ganda.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 52 test.

## Status: Header Editorial Two-Tone Semua Tab — SELESAI

### Yang dikerjakan
- Widget baru `AppSectionHeader`: eyebrow pill + judul two-tone (baris 1
  gelap, baris 2 biru italic) + subtitle + emblem gradien + hairline.
- Home: AppBar slim brand bar (logo + status AI Aktif), 4 tab memakai header
  editorial dengan copy masing-masing. Hero tab Cek dihapus jadi CTA ringkas.
- Session: header compact `SESI FOKUS` two-tone + stepper tetap. Chat: header
  `Tanya apa saja.` + kartu status ringkas.
- Test baru `section_header_test.dart` 4 test + selaraskan 2 test lama yang
  merujuk hero lama. Bug tap CTA tertutup FAB diperbaiki via ensureVisible.
- Verifikasi: `flutter analyze` bersih, `flutter test` lolos 52 test.

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

# CHANGELOG UI — Overhaul Tab Cek (25 Sep 2026)

Overhaul visual tab Cek agar tidak polos/template-ish: hierarchy tegas,
satu signature element, tanpa mengubah logic bisnis (provider, repository,
datasource tidak tersentuh). Aturan anti-AI-slop: tanpa emoji baru, tanpa
gradient norak, tanpa dependensi icon/font eksternal, animasi 1x calm.

## U1 — Font Inter riil (offline-safe)

- **Masalah:** `AppStyles.fontFamily = 'Inter'` dideklarasikan tapi file
  TTF tidak ada di repo → Flutter fallback diam-diam ke font sistem.
- **Perubahan:** bundel `assets/fonts/Inter-{400,500,700,800}.ttf`
  (magic bytes TTF terverifikasi), daftarkan di `pubspec.yaml`.
- **File:** `assets/fonts/`, `pubspec.yaml`, `test/font_bundle_test.dart`
  (6 test: family di tema + keberadaan/validitas tiap weight).
- **Rationale:** tanpa file biner, seluruh skala tipografi hanya teori.

## U2 — Header compact sebaris

- **Masalah:** dua pil full-width bertumpuk (`ScoreCheckChip` +
  `_ApiKeyStatusChip`) memboroskan ±100px vertikal sebelum konten.
- **Perubahan:** satu baris — kiri ring progres level
  (`progressInLevel` dari entity, tanpa logic baru) + label/poin; kanan
  dot status AI + label ringkas; divider pemisah; dua zona tap terpisah
  (Profil vs Pengaturan). Guest tetap jujur "Pemula · 0 poin · 50 ke
  Waspada" / "Demo". Kelas `_ApiKeyStatusChip` + `_KeyChipContent` lama
  dihapus (±115 baris mati).
- **File:** `score_check_chip.dart`, `quick_check_home_tab.dart`,
  `test/header_compact_test.dart` (4 test), update `api_key_demo_test`
  + `score_test` (teks lama `Status AI` / `Pemula - 0 poin` diganti).
- **Rationale:** info sama, setengah tinggi; sesuai PRD (progress
  indicator level di Home).

## U3 — Signature: spine aksen verdict 6px

- **Masalah:** kartu hasil memakai border tipis warna aksen — nyaris tak
  terlihat sebagai identitas.
- **Perubahan:** garis penuh 6px warna verdict di tepi kiri kartu hasil
  (`_VerdictSpine`: lapisan belakang, bukan `Border.left`, agar sudut
  membulat rapi), konsisten dengan spine `ShareCard`. Border kartu jadi
  netral agar spine yang bicara.
- **File:** `quick_check_result_section.dart`,
  `test/verdict_spine_test.dart` (3 test: warna per verdict + render
  360/412px).
- **Bonus fix:** test lebar menemukan 2 overflow laten di layar 360px
  (label confidence, badge sumber, tombol sesi) — diperbaiki dengan
  `Expanded`/`Flexible` + ellipsis.
- **Rationale:** satu elemen khas yang konsisten di hasil, share, dan
  rail — bukan warna saja (ikon + teks tetap ada untuk buta warna).

## U4 — Tekstur pola hero

- **Masalah:** hero gradient diagonal bagus tapi permukaannya kosong.
- **Perubahan:** `_HeroPattern` via CustomPainter murni (tanpa aset):
  garis diagonal putih alpha 7% + outline perisai raksasa alpha 8% +
  check samar di kanan. `ExcludeSemantics` (dekoratif), CTA tetap di
  atas (Stack) dan bisa di-tap.
- **File:** `quick_check_home_tab.dart`, `test/hero_pattern_test.dart`
  (2 test: painter ada + CTA tidak tertutup).
- **Rationale:** kedalaman tanpa gambar, tanpa emoji, tanpa biaya unduh.

## U5 — Identitas mode + entrance + haptic

- **Masalah:** kedua tile mode memakai tint biru identik; hero muncul
  statis; CTA tanpa umpan balik taktil.
- **Perubahan:** tint per mode (teks biru brand, gambar biru-tua;
  link hijau sudah ada di banner), `_HeroEntrance` fade+slide 380ms
  sekali jalan (terisolasi, tanpa rebuild tab), `HapticFeedback`
  ringan di `_openSession` (pola sama dengan onboarding & navbar).
  Teks tombol TIDAK diubah (dikunci banyak test).
- **File:** `quick_check_home_tab.dart`, `test/mode_identity_test.dart`
  (2 test: warna medallion + entrance/CTA).
- **Rationale:** karakter per mode tanpa icon set baru; animasi calm.

## Ditolak dengan alasan (jangan dikerjakan ulang)

- **Grid 3 kolom mode input:** tile 2+1 asimetris lebih baik; grid 3
  sempit di layar kecil, subtitle hilang.
- **Chips contoh:** kartu rail menampilkan klaim 3 baris — chips
  ellipsis menghilangkan pratinjau yang justru fungsi utamanya.
- **Image card trending:** `TrendingItem` murni Dart offline-first tanpa
  URL gambar; placeholder palsu menurunkan kredibilitas. Rail saat ini
  (pita verdict + HOT + Hero) sudah signature.
- **Ganti icon set (Lucide/Phosphor):** dependensi + stroke tak bercampur
  Material bawaan di layar lain; perbaikan dalam batas Material icons.
- **Scale-down global / animasi loop:** bertentangan InkWell+Semantics
  yang ada; animasi dibatasi entrance 1x + haptic aksi primer.

## P1 — Heading compact (26 Sep 2026)

- **Masalah:** header tab Cek (wordmark + pill `VERIFIKASI AI` + judul 26px
  + subtitle 3 baris) memakan ±230px (±30% viewport 360×800) sebelum
  konten. Pill redundan ganda dengan label "AI live" di kartu status.
- **Perubahan:** hapus `_Wordmark` + pill eyebrow; judul two-tone 24px +
  subtitle padat 2 baris + hairline (±110px). Kartu status 60→52px
  (padding 10→8, ring 40→36). String yatim
  (`quickCheckLandingBadge/Title/Subtitle`, `homeCheckEyebrow`) dihapus
  dari `AppStrings`.
- **File:** `quick_check_home_tab.dart`, `app_strings.dart`,
  `score_check_chip.dart`, `test/check_heading_test.dart` (4 test:
  tanpa wordmark/pill, tinggi heading <150px, hero masuk lipatan 360px,
  CTA buka sesi), update `section_header_test` + `widget_test`.
- **Bonus fix:** test lipatan menemukan overflow laten Row hero 29px di
  360px (tombol CTA fixed-width mendorong teks) → hero responsif via
  `LayoutBuilder`: <380px tombol full-width di bawah teks, normal tetap
  berdampingan. Teks tombol `Flexible` agar tak terjepit font lebar.
- **Rationale:** konten fungsional naik ±120px; judul gelap-di-terang
  dipertahankan (hierarki benar); subtitle dipertahankan 1 kalimat
  orientasi untuk user baru.

## Headline status definitif (26 Sep 2026)

- **Masalah:** headline HOAKS "Jangan disebar" adalah perintah perilaku
  yang campur aduk dengan tiga headline status lainnya ("Aman dengan
  konteks", "Cek sumber lain dulu", "Belum bisa dipastikan") — dan
  kontradiktif dengan tombol Bagikan hasil pemeriksaan di layar yang
  sama. User benar: edukasi tentang hoaks justru boleh (dan perlu)
  disebarkan; yang tidak boleh adalah meneruskan pesan hoaks mentahnya.
- **Perubahan:** keempat headline diseragamkan menjadi kalimat status
  definitif — HOAKS "Informasi ini tidak benar", VALID "Informasi ini
  benar", PERLU DICEK "Kebenarannya belum pasti", TIDAK PASTI tetap.
  Perilaku spesifik tetap ditangani "Saran tindak lanjut" per kasus
  (ditulis AI, mis. jangan beri data rekening). Keempat string pindah
  ke `AppStrings` (`verdictHeadline*`) sesuai aturan copy-terpusat.
- **File:** `app_strings.dart`, `verdict_presentation.dart`,
  `test/verdict_spine_test.dart` (assert keempat headline + pastikan
  frasa perintah lama hilang total).
- **Rationale:** status kini dinyatakan tiga kali (badge warna + angka
  + kalimat) — aksesibilitas buta warna tetap terjaga; satu callsite
  render, risiko nol.

## R1–R3 — Header compact Riwayat/Belajar/Profil (26 Sep 2026)

- **Masalah:** header editorial penuh (±190px: pill + judul 26px 2 baris
  + subtitle + hairline) di 3 tab mendorong konten fungsional ke bawah
  lipatan: Riwayat ±320px (search+filter ikut menumpuk), Belajar ±300px
  (modul 1 kepotong), Profil ±410px (ring + akun jauh di bawah).
- **Perubahan per tab (UI-only, provider/domain tidak tersentuh):**
  - Riwayat: judul toolbar 20px two-tone "Jejak pemeriksaanmu." +
    search + filter menyatu (±150px). Subtitle generik dihapus.
  - Belajar: judul 20px "Naikkan literasimu." menempel ringkasan
    progres (±170px). Info modul/poin tetap dari daftar + catatan.
  - Profil: judul 20px "Kelola profilmu." + 1 baris cara skor bertambah;
    ScoreRing + Breakdown + Akun + Kunci TIDAK disentuh (±280px).
  - Aksen identitas per tab dipertahankan pada kata kedua judul
    (riwayat biru-tua, belajar hijau, profil biru-personal).
  - 5 string yatim dihapus dari `AppStrings` (eyebrow ×3, subtitle ×2);
    subtitle Profil dipadatkan.
- **File:** `history_list_screen.dart`, `course_list_screen.dart`,
  `profile_screen.dart`, `app_strings.dart`,
  `test/tab_headers_test.dart` (3 test: tanpa editorial, aksen per tab,
  konten masuk lipatan 360px), update sadar 6 file test lama
  (`section_header`, `nav_pill`, `learn`, `score`, `api_key_demo`,
  `ui_u2_identity` — judul rich cocok via `textContaining`, warna aksen
  dibaca dari span italic).
- **Rationale:** komponen `AppSectionHeader` TIDAK dihapus (masih dipakai
  pola generik + test aksen); yang diubah hanya callsite 3 tab.

## Token skala judul tab (26 Sep 2026)

- **Masalah:** judul Cek 24px vs tiga tab 20px terlihat seperti kebetulan,
  bukan keputusan: angka duplikat manual di 4 file, gap judul-konten
  12/14 campur, hairline hanya di Cek tanpa rationale tertulis.
- **Perubahan:** token `AppTabTitles` di `app_styles.dart` sebagai satu
  sumber kebenaran (Display 24 two-tone 2 baris + subtitle + hairline
  khusus landing Cek; Compact 20 two-tone 1 baris untuk tab utilitas;
  gap 12 konsisten; hairline didokumentasikan milik Display). Keempat
  screen di-refactor ke token dengan **nol piksel berubah**.
- **File:** `app_styles.dart`, 4 screen tab, `test/tab_headers_test.dart`
  (test kunci nilai token anti-drift).
- **Rationale:** beda ukuran per peran dipertahankan (landing boleh
  lebih besar), tapi kini sistematis dan tidak akan drift lagi.
  Opsi menyamakan rata ditolak: landing kehilangan presence, atau tiga
  tab boros vertikal kembali.

## Sapuan em-dash (26 Sep 2026)

- Seluruh `—` (U+2014) dihapus dari `lib/` + `test/`: 206 kemunculan
  ` — ` → `: ` via script terkontrol + 2 kasus tepi ditulis ulang
  manual + 4 string user-facing diganti kalimat setara tanpa dash.
- Nol em-dash tersisa (terverifikasi via grep). Markdown docs memang
  sudah nol. Aturan: pakai titik dua, koma, atau kurung — bukan dash
  panjang yang menjadi ciri khas tulisan AI.

## Refined Riwayat H1-H5 (26 Sep 2026)

- **Masalah:** toolbar gundul tanpa konteks; search generik; stat bar
  seperti tabel putih; kartu 100% seragam tanpa signature; tidak ada
  titik orientasi di daftar panjang.
- **Perubahan (UI-only, provider/domain tidak tersentuh):**
  - Sub-konteks data-driven: "N pemeriksaan · terakhir X" dari stream
    yang sama (tanpa query baru), konsisten dengan statistik.
  - Search: focus ring + ikon tint biru-arsip saat dipakai; hint kiri
    dan tombol clear yang sudah benar tidak diubah (dua klaim saran
    luar terbukti salah setelah verifikasi kode, tidak dieksekusi).
  - Stat bar: tint latar per kolom verdict (strip aksen tetap).
  - Kartu: spine verdict 6px kiri (signature kartu hasil, border
    dinetralkan) + badge TERBARU hanya entri pertama saat daftar utuh
    (>1, tanpa filter/search). Hero badge ke detail tidak disentuh.
  - Helper `historyTimeAgo` bersama (kartu + sub-konteks, anti-drift).
- **Ditolak:** variasi ukuran kartu per verdict (merusak scanability +
  mengeditorialisasi keliru), thumbnail placeholder, chart statistik,
  entrance staggered (risiko jank + Dismissible).
- **File:** `history_list_screen.dart`, `history_card.dart`,
  `history_time_ago.dart` (baru), `app_strings.dart`
  (`historySubEmpty`), `test/history_refined_test.dart` (8 test).
- **Rationale:** hierarki tanpa merusak keseragaman baris daftar.

## Anti-duplikasi Riwayat (26 Sep 2026)

- **Masalah:** angka komposisi verdict tampil dua kali (kartu statistik
  + pill filter) dari sumber hitung yang sama; kartu statistik dead-end
  (tidak bisa diklik); swipe hapus satu arah tanpa affordance sehingga
  tidak ditemukan user.
- **Perubahan (provider/domain tidak tersentuh):**
  - Hapus `_HistoryStats` + kolom + divider (±90 baris) dan string
    `historyStatsTitle`; pill filter menjadi satu-satunya representasi
    angka (angka diperbesar, tint idle ringan, angka 0 selalu tampil
    sebagai info utuh, Semantics menyebut fungsi saring).
  - Daftar + filter naik ±110px ke lipatan (efek samping penghapusan).
  - Swipe dua arah (`horizontal` + `secondaryBackground` cermin) memakai
    jalur hapus + Urungkan yang sama persis.
  - Aksi hapus di `HistoryDetailScreen` (dialog konfirmasi + guard
    ketuk ganda + snackbar + Urungkan + kembali): jalur discoverable
    kedua selain swipe.
- **File:** `history_list_screen.dart`, `history_detail_screen.dart`,
  `history_filter_bar.dart`, `app_strings.dart` (4 string dialog +
  hapus 1 yatim), `test/history_dedup_test.dart` (6 test), update sadar
  `history_test`, `premium_upgrade_test`, `ui_u2_identity_test`.
- **Rationale:** gabungkan, jangan gandakan. Halaman overview baru
  ditolak (masalahnya kelebihan permukaan); variasi kartu per verdict
  ditolak (merusak scanability + mengeditorialisasi keliru).

## Polish Chat C1-C4 (26 Sep 2026)

- **Masalah:** subtitle AppBar generik; tanpa disclaimer model; hero
  68px kurang presence; AppBar penuh (lingkaran back + squircle avatar
  + squircle aksi bertarung); overflow laten banner kunci 29px di 360px.
- **Perubahan (UI-only, provider/domain tidak tersentuh):**
  - Subtitle kontekstual dari `chatKeyConfiguredProvider`: "AI live ·
    Siap menjawab" vs "Mode pratinjau". Tanpa dot hijau palsu dan tanpa
    angka kuota (tidak bisa diketahui client).
  - Disclaimer compact di bawah chips (empty state saja): "Didukung
    Gemini AI · Jawaban bisa keliru, cek ulang info penting." Tanpa
    ikon, tanpa versi model yang bisa usang.
  - Hero 68→80px + kompresi gap (16→14, padding 32→28, chips 20→16).
  - AppBar: lingkaran tonal → panah polos bawaan; avatar 38→34px.
    `SessionBackButton` tetap untuk layar sesi.
  - Banner kunci responsif (`LayoutBuilder` <340px: aksi full-width di
    bawah teks): memperbaiki overflow laten, pola sama dengan hero Cek.
- **Ditolak:** mic voice input (plugin + permission), persistensi
  welcome-back (lapisan data baru), full-width cards + emoji (AI slop),
  pulse loop (baterai + calm), dot "Online" palsu, angka kuota palsu.

## Header chat tanpa avatar (26 Sep 2026)

- **Masalah:** shield muncul 3x dalam satu viewport (header + tiap
  bubble AI): pengulangan identitas, header terasa penuh.
- **Perubahan:** avatar shield dihapus dari AppBar (identitas milik
  bubble AI + hero empty-state + FAB); panah kembali dipertegas
  22→24px sebagai kompensasi visual; pola panah polos dipertahankan
  (bukan lingkaran: konvensi chat WhatsApp/Telegram/iMessage).
- **File:** `chat_screen.dart` (hapus `_IdentityAvatar` yatim),
  `test/chat_polish_test.dart` (assert tanpa shield di AppBar +
  shield tetap di bubble).
- **Rationale:** koreksi rekomendasi sebelumnya yang benar untuk empty
  state tapi redundan saat percakapan berjalan.
- **Revisi (permintaan user):** tombol kembali lingkaran tonal
  dikembalikan. Keberatan "bentuk bertarung" hanya valid saat avatar
  masih ada; tanpa avatar, lingkaran kiri + squircle aksi kanan justru
  membingkai teks seimbang, dan lingkaran 40px memberi jarak napas
  alami ke teks (vs panah polos yang menempel). `leadingWidth` 40→56.
- **File:** `chat_screen.dart`, `app_strings.dart` (3 string baru,
  1 yatim dihapus), `test/chat_polish_test.dart` (6 test),
  update sadar `chat_test` + `section_header_test`.
- **Rationale:** klaim saran luar diverifikasi ke kode dulu: typing
  indicator, press state chip, tombol kirim adaptif, tombol clear dan
  hint kiri SUDAH benar (tidak diubah); angka ukuran klaimnya ngawur.

## Jalur Belajar L1-L3 (28 Sep 2026)

- **Masalah:** 3 kartu modul + kotak catatan poin terbaca sebagai 4
  persegi membulat berurutan: radius mirip, meta pills identik, kotak
  poin memakai gaya info biru generik. Mata tidak menangkap peran:
  mana pembuka, lanjutan, dan hadiah.
- **Perubahan (UI-only, provider/domain/kuis tidak tersentuh):**
  - Rail jalur pembelajaran: nomor ghost `01/02/03` + konektor vertikal
    di sisi kiri daftar. Status per node dari `CourseProgress` yang sama
    (tanpa query baru): selesai = centang hijau penuh, langkah saat ini
    = lingkar primer, berikutnya = nomor ghost netral. Label semantics
    "Langkah N dari 3, ..." per node. `IntrinsicHeight` dipakai karena
    daftar di dalam scroll view (stretch butuh tinggi bounded dan crash
    `BoxConstraints forces an infinite height`).
  - Kartu keempat didesain ulang total: kotak info biru menjadi strip
    hadiah hijau pekat (`AppColors.learnRewardSurface`, sengaja beda
    dari kartu strip 03 agar dua permukaan gelap tidak menyatu) dengan
    medallion trofi + judul + hint + divider + dua kolom angka
    `+20`/`+5` yang dibaca dari `LiteracyScore.modulePoints/quizPoints`
    (sinkron domain, bukan hardcode). Satu label semantics gabungan.
    String lama `learnPointsNote` dihapus; 4 string baru
    (`learnPathCurrent/Next/Start/Final`, `learnRewardTitle/Hint/
    ModuleLabel/QuizLabel`).
  - Kartu 1 dan 3 mendapat penanda peran di dalam kartu (bukan
    mengandalkan rail semata): pill "Mulai dari sini" (play) di hero,
    pill status "Langkah akhir"/"Selesai" di strip (status dibaca dari
    `completed` yang sudah ada). Angka raksasa `03` dihapus (duplikat
    dengan nomor rail). Medallion kartu split diselaraskan amber ke
    keluarga hijau sukses (`successDark`, token resmi).
- **Bonus fix:** test render 360px menemukan overflow laten 7.5px di
  pill hero kartu 1 (font test Ahem lebih lebar; font aksesibilitas
  besar di device nyata bisa memicu hal sama): Row `Spacer` diganti
  `Flexible` + ellipsis di pill kartu 1 dan 3. Bug nyata, bukan artefak.
- **Ditolak:** membongkar struktur 3 varian kartu (sudah heterogen,
  risiko regresi tanpa nilai tambah), thumbnail ilustrasi (offline,
  placeholder palsu menurunkan kredibilitas), entrance staggered
  (prinsip calm), variasi ukuran kartu per status (merusak scanability).
- **File:** `course_list_screen.dart` (`_LearningPath`, `_PathRow`,
  `_PathNode`, `_RewardStrip`, `_RewardCell`), `course_card.dart`
  (pill peran + Flexible + aksen hijau split), `app_colors.dart`
  (`learnRewardSurface/InkSoft`), `app_strings.dart` (4 yatim dihapus,
  8 baru), `test/learn_path_test.dart` (6 test: nomor + status,
  strip sinkron domain, kotak biru lama hilang, render 360/412px),
  update sadar `tab_headers_test` + `ui_u2_identity_test` (helper
  aksen kini memilih kandidat Text.rich beranak span agar tahan
  terhadap konten baru yang memakai kata mirip).

## Library Belajar M1-M5 (28 Sep 2026)

- **Masalah:** rail + 3 kartu berat + strip gelap memakai 4 bahasa warna
  (biru hero, amber medallion, hijau-gelap 03, hijau-pekat strip) dalam
  satu layar; kartu berteriak minta perhatian, hierarki dari kotak bukan
  tipografi; tidak ada affordance "ketuk untuk masuk".
- **Perubahan (UI-only, data/provider/kuis/skor tidak tersentuh):**
  - Hapus total: rail `_LearningPath`/`_PathRow`/`_PathNode`, 3 varian
    `CourseCard` (hero/split/numbered), pill peran rail
    (`learnPathCurrent/Next/Start/Final`). Dead code removal ±380 baris.
  - `ModuleRow` baru (`course_card.dart` ditulis ulang): satu baris
    terang senada per modul: thumbnail prosedural 64px (tint satu
    keluarga biru-teal-hijau + ikon identitas + pola diagonal samar
    CustomPainter, tanpa aset/offline-safe) + judul 16 + subtitle 2
    baris + meta pills netral + tombol panah lingkaran (selesai =
    centang hijau penuh) + bilah progres kuis jujur `best/quizCount`
    dari provider yang sama. Badge "Selesai" + thumbnail redup untuk
    status, bukan kartu berbeda.
  - `ModuleMotif` + `motifForModule` di `module_motif.dart` baru: satu
    sumber kebenaran motif dari `accentSeed` data (bukan posisi list).
  - Hero detail disambungkan: medallion generik `menu_book` diganti
    motif modul versi besar (tint + ikon sama) dengan pola samar;
    gradien biru hero dipertahankan (satu keluarga hero Cek).
  - Header seksi "Modulku" + hitungan "N dari 3 modul selesai" dari
    stream yang sama (pola Riwayat). Ringkasan ring + strip hadiah
    hijau pekat dipertahankan: satu-satunya titik fokal gelap di akhir
    daftar sehingga kontrasnya berfungsi.
  - 4 string rail yatim dihapus; 5 baru (`learnMyModules/ModulesOf/
    ModulesDone/OpenModule/QuizProgressLabel`).
- **Ditolak:** search + filter level (over-engineering untuk 3 modul),
  activity bars dekoratif (klaim palsu), thumbnail foto/aset, entrance
  staggered, variasi ukuran kartu per status.
- **File:** `course_card.dart` (rewrite), `module_motif.dart` (baru),
  `course_list_screen.dart` (`_ModuleSectionHeader`, `_ModuleList`),
  `course_detail_screen.dart` (hero motif + `_HeroMotifPattern`),
  `app_strings.dart`, `test/learn_library_test.dart` (8 test: motif
  satu sumber, 3 rows + header + hitungan, selesai, progres jujur,
  strip, hero 3 ikon, render 360/412px). `learn_path_test.dart`
  dihapus (digantikan). Test lama Belajar/headers tanpa ubahan, hijau.

## Hierarki Belajar v2 N1-N7 (28 Sep 2026)

- **Masalah:** daftar baris tanpa focal point (user baru bingung mulai
  dari mana); hitungan loading "0 dari 0 modul selesai" (bug copy);
  CTA panah generik tidak status-aware; reward terkubur di bawah.
- **Perubahan (UI-only, data/provider/kuis/skor tidak tersentuh):**
  - Hierarki baru: judul toolbar → ringkasan ring → strip hadiah
    (dipindah ke atas, satu-satunya fokal gelap) → featured row →
    daftar compact.
  - Featured = modul pertama yang belum selesai (derivable dari
    progress, tanpa ubah domain): thumbnail 84px, judul 20px, CTA teks
    full-width "Mulai"/"Lanjutkan" dengan label jujur "Mulai dari
    sini"/"Lanjutkan belajarmu". Semua selesai: featured hilang,
    tampil strip kompak "Semua modul selesai" (dorong ulang kuis).
  - CTA teks 3-status di baris compact: Selesai (centang hijau),
    Dikerjakan (Lanjutkan primer), Belum mulai (Mulai primer).
    Tinggi 44px, ellipsis anti-overflow. Status terkunci ditolak:
    tidak ada di model (butuh domain baru).
  - Pill "Selesai" dihapus dari meta: status kini dinyatakan sekali
    (CTA + thumbnail redup + hitungan seksi), tanpa pengulangan.
  - Bar kuis 5→7px. Circular ganda + animasi fill ditolak (calm +
    determinisme test).
  - Loading: skeleton seksi (tanpa hitungan palsu). 6 string baru,
    tanpa yatim.
- **Bonus fix:** pill meta tanpa ellipsis overflow di baris sempit
  (font test lebar): tambah `Flexible` + ellipsis.
- **Ditolak dari saran luar (dengan alasan):** rating/foto guru/grid
  2 kolom/label populer (data tidak ada = klaim palsu), search/filter
  (over-engineering 3 modul), emoji, radius retroaktif, 5 commit AI,
  screenshot manual (tanpa display; verifikasi via test render).
- **File:** `course_list_screen.dart` (`_ModuleSections`,
  `_SectionSkeleton`, `_AllDoneStrip`, reorder reward),
  `course_card.dart` (`ModuleCta`, `_RowShell`, `_CompactRow`,
  `_FeaturedRow`, `_CtaButton`, `_MetaRow` tanpa pill selesai, bar
  7px, pill ellipsis), `app_strings.dart`,
  `test/learn_library_test.dart` (11 test: motif, bug loading,
  featured rule ×3, CTA 3-status, progres jujur, strip, hero,
  render 360/412px). Test lama tanpa ubahan isi, hijau.

## Refactor Belajar v3 P1-P8 (28 Sep 2026)

- **Masalah:** daftar baris satu pola berulang tanpa variasi peran;
  reward deep green tabrakan brand biru; label hijau di luar status;
  CTA panah generik tidak status-aware; hitungan seksi 2 baris boros
  vertikal.
- **Perubahan (UI-only, data/provider/kuis/skor tidak tersentuh):**
  - Hierarki baru: judul toolbar → ringkasan hero (subtitle agregat
    "3 modul · 9 soal · ±15 mnt" dari data, bar 8px primer, CTA
    "Mulai Modul N" buka first-incomplete, hilang bila semua selesai)
    → reward strip → "Modul populer" (1 featured) → "Semua modul".
  - Featured vertikal: banner motif 110px (tint + pola + medallion
    ikon 64px) + judul 20px + meta + bar 8px + FilledButton 48px.
    Satu-satunya tombol besar di tab; compact tanpa FilledButton.
  - Compact horizontal: thumbnail 56px + teks + kolom kanan 56px
    (circular progress 40px fill primer/track abu/label "0/3" + teks
    status Mulai/Lanjutkan/Selesai). Bar tipis dihapus dari compact
    (tanpa triple-encoding).
  - Reward: deep green → tint biru primer + rim biru + medallion
    primer + angka display 26px primer + label hijau sukses.
    Hijau kini hanya untuk status selesai, bukan permukaan/label.
  - Header seksi 1 baris ("Semua modul · 0/3 selesai"). Skeleton
    diselaraskan. 6 string baru, 4 yatim dihapus.
- **Ditolak (dengan alasan):** hero kedua (duplikat judul/progres/
  CTA), rating/foto guru/grid/label populer (klaim palsu), search/
  filter (overkill 3 modul), modul 2-4 (data hanya 3), emoji, radius
  >20, animasi fill, 5 commit AI, screenshot manual (tanpa display;
  verifikasi via test render 360/412px).
- **File:** `course_list_screen.dart` (`_HeroSummary`,
  `_HeroSummaryBody`, reward tint, `_ModuleSectionHeader` 1 baris,
  `_FeaturedSectionHeader`, `_ModuleSections`), `course_card.dart`
  (rewrite: `_RowShell`, `_CompactRow`, `_FeaturedCard`,
  `_MotifBanner`, `_StatusText`, `_QuizRing`, `_QuizBar`,
  `_MetaRow`, `_Pill`, `_ModuleThumb`), `module_motif.dart` (tetap),
  `app_colors.dart` (`learnRewardTint/Rim`, hapus deep green),
  `app_strings.dart`, `test/learn_library_test.dart` (12 test P1-P8),
  update sadar `tab_headers_test` (lipatan: CTA hero sebagai aksi
  fungsional utama). Test lama lain tanpa ubahan isi, hijau.

## Polish Belajar v4 Q1-Q8 (29 Sep 2026)

- **Masalah:** judul hijau tabrakan identitas; copy login duplikat;
  pattern diagonal berisik di banner 110px; featured tidak radikal;
  compact masih pola kartu; reward blok biru kedua bertumpuk featured.
- **Perubahan (UI-only, data/provider/kuis/skor tidak tersentuh):**
  - Judul kata kedua hijau → biru primer. Badge navbar Belajar
    SENGAJA tetap hijau (identitas navigasi vs konten boleh beda:
    pola yang dipakai semua tab); hijau tersisa untuk badge +
    status selesai. `nav_pill_test` tidak disentuh.
  - Guest note dihapus dari hero (duplikat CTA profil); 5 string
    yatim dibersihkan (`learnGuestNote/QuizTotalLabel/HeroCtaPrefix/
    MyModules/RewardHint`) + 2 token warna reward lama.
  - Reward digabung ke hero: ring + agregat + bar 8px + divider +
    label "Hadiah" + dua angka display dari domain. Blok
    `_RewardStrip`/`_RewardCell` dihapus. Tab tinggal 3 blok:
    hero-gabungan, featured, daftar. CTA hero dihapus total (peran
    aksi milik featured/strip).
  - Featured biru solid: banner gradien `heroBegin→heroEnd` 120px +
    medallion putih 68px + ikon identitas, tanpa pattern (alpha 0).
    Satu-satunya kartu biru di tab. Meta 12px/w700 kompensasi
    kontras di atas gradien.
  - Compact borderless: tanpa border/shadow, divider hairline antar
    baris (pola daftar, bukan kartu). Thumbnail pertahankan pattern
    kecil (tint polos di 56px terlihat seperti placeholder kosong).
    Ring 40px + status teks tetap.
  - Spacing seksi 20-22px (pemisah dua biru), skeleton selaras.
- **Ditolak (dengan alasan):** full-bleed + overlay hitam (premis
  trending-card salah: rail Cek kartu putih radius 22; full-bleed
  tabrak padding/maxWidth; tanpa aset = kartu gelap keempat),
  accent stripe warna-warni (kembalikan 3 bahasa warna), hero kedua
  (judul/progres/CTA ganda), badge ikut biru (scope creep, merusak
  sistem 4 tab), hapus pattern thumb (placeholder kosong),
  grid 2 kolom, emoji, radius >20, animasi fill, screenshot manual.
- **File:** `course_list_screen.dart` (hero gabungan, judul biru,
  divider compact, hapus reward strip), `course_card.dart` (rewrite:
  `_RowShell` borderless, `_CompactRow` borderless,
  `_FeaturedCard` biru solid, thumb pattern dipertahankan),
  `app_colors.dart` (hapus token reward lama),
  `app_strings.dart` (5 yatim dihapus),
  `test/learn_library_test.dart` (11 test Q1-Q8),
  update sadar `tab_headers_test` (judul biru + lipatan CTA
  featured) + `ui_u2_identity_test` (judul biru).

## Polish Belajar v5 V1-V4 (29 Sep 2026)

- **Masalah:** tab masih terasa polos: hero putih besar berisi teks abu
  (kesan pertama lemah), featured setengah-setengah (hanya strip 120px
  biru, badan tetap putih → terbaca kartu biasa), reward gabungan hero
  membuatnya kotak status pucat. Terpisah: overlap FAB nyata (zona FAB
  = navbar+gap+badan ≈144px > padding 120px lama).
- **V4 Fix zona FAB:** padding bawah 120 → **160px** (clearance ujung
  scroll + margin; test mengunci angka). `learn_fab_clearance_test.dart`
  baru **mengukur rect nyata** di 360×800 & 412×915: (a) scroll-0 CTA
  featured vs FAB tidak beririsan, (b) baris terakhir di ujung scroll
  berhenti di atas zona FAB. Keduanya hijau (overlap saat istirahat
  terbukti tidak terjadi pada layout baru; FAB hide-on-scroll jadi tidak
  perlu).
- **V3 Featured = kartu hero keluarga tab Cek:** seluruh badan gradien
  `heroBegin→heroEnd` radius 20 + glow `primary 32%` + pattern garis
  diagonal putih 7% (duplikat sadar dari `_HeroPattern` Cek tanpa
  perisai: motif modul sudah focal); medallion motif putih 52px
  kanan-atas (slot ilustrasi prosedural); judul putih 22px + subtitle
  `#D6E5FE` (pola kontras hero Cek, bukan abu); pill meta varian
  transparan putih; bar progres track putih 30% + isi putih; **CTA
  putih teks primer** (persis bahasa CTA `_SessionCtaCard`). Overlay
  hitam 60% ditolak (bahasa app media, app ini trustworthy-bright);
  full-bleed tanpa radius ditolak (bahasa kartu campur di tengah
  halaman; token gradien #0D47A1 bukan token app).
- **V2 Reward = kartu achievement terpisah:** keluar dari hero; tint
  `primary 7%` + rim `primary 20%` radius 20, medallion trofi, angka
  display **+20 `successDark` / +5 `warningDark`** (warna makna sama
  dengan breakdown Profil: modul hijau, kuis amber; `warningDark` token
  sudah ada). Hero kembali ramping ~110px: ring + agregat + bar, tanpa
  CTA (keputusan v4 tetap: aksi milik featured). Urutan struktur
  dipertahankan: hero → reward → featured → compact.
- **Ditolak (dengan alasan):** accent stripe tosca/sage (premis basi:
  compact kini borderless, tak ada sudut untuk stripe; motif thumbnail
  sudah membawa warna per modul → stripe = sinyal ganda; mundur ke
  keputusan M1-M5 yang membuang multi-bahasa warna), CTA hero
  "Mulai Modul 1" (rangkap dengan CTA featured), overlay hitam,
  full-bleed, ilustrasi aset (offline).
- **File:** `course_list_screen.dart` (padding 160, hero ramping, baru
  `_RewardCard`/`_RewardCell`, skeleton 230), `course_card.dart`
  (rewrite `_FeaturedCard` gradien + `_FeaturedMotif` +
  `_FeaturedPatternPainter`, varian `onGradient` di `_MetaRow`/`_Pill`/
  `_QuizBar`, `_RowShell` disederhanakan jadi shell compact saja),
  `test/learn_library_test.dart` (P4 struktur gradien+CTA putih, P6
  reward kartu tint + warna makna + urutan, helper
  `_hasHeroGradient` via `visitAncestorElements`),
  `test/learn_fab_clearance_test.dart` (baru, 4 test ukur rect).

## Selaraskan Test-Test Belajar ke Kode v4 (2 Okt 2026)

- **Masalah:** 2 test gagal sejak commit `5b49c35` (campuran v4/v5):
  Q4 menuntut featured full-gradien + CTA putih padahal kode =
  banner 120px + CTA primer; lipatan headers menuntut CTA featured
  masuk 800px padahal di 808px.
- **Perubahan (test + spacing, tanpa ubah desain):**
  - Q4 ditulis ulang mengikuti kode v4 aktual (banner 120px, CTA
    primer biru, subtitle abu); helper `_hasHeroGradient` yatim
    dihapus; grup diganti "featured biru solid".
  - Spacing vertikal tab Belajar dihemat 12px (14 ke 10, 22 ke 16,
    20 ke 16): CTA masuk lipatan 360x800 tanpa ubah struktur/hierarki.
- **File:** `test/learn_library_test.dart`,
  `lib/features/learn/presentation/screens/course_list_screen.dart`.
- **Status verifikasi saat tulis:** `flutter analyze` bersih;
  full suite **312 lulus, nol gagal**; em-dash 0.

## Thumbnail Tanpa Pola Diagonal (2 Okt 2026)

- **Masalah:** garis diagonal thumbnail 56px terbaca sebagai
  coretan/kesalahan, bukan tekstur (observasi user, valid).
- **Perubahan:** hapus `_ThumbPattern` + `CustomPaint` total; thumbnail
  jadi medallion bersih (tint + border + ikon). Tanpa ubah ukuran,
  warna, ikon, atau struktur.
- **File:** `course_card.dart` saja (-43/+7 baris).

## Hasil Kuis: klaim persisten + count-up + hero varian (2 Okt 2026)

- **Masalah:** bukti klaim menguap (snackbar hilang, label tombol jadi
  kalimat); lingkaran hasil biru generik untuk semua skor; tidak ada
  momen perayaan saat klaim sukses.
- **Perubahan (UI-only, provider/domain tidak tersentuh):**
  - Status klaim persisten nonaktif: trofi hijau + angka count-up
    0 ke N (600ms, pola ScoreRing) + haptic medium sekali saat
    selesai + sublabel "masuk ke skormu"; tombol Klaim diganti
    status, Ulangi nonaktif permanen (backend idempoten best-score).
  - Hero varian: sempurna = hijau + medallion trofi + catatan;
    parsial = biru + hint belajar lagi (tanpa string merendahkan).
  - 3 string baru terpusat; tombol Kembali tetap TextButton tersier.
- **Ditolak:** confetti/partikel (jank + tidak calm), suara
  (permission + aset), badge baru (tidak ada sistem badge), animasi
  loop (baterai + determinisme test).
- **File:** `quiz_screen.dart` (`_ResultHero`, `_ClaimedStatus`,
  guard `_claim`, Ulangi nonaktif), `app_strings.dart` (+3),
  `test/learn_test.dart` (+status persisten, +hasil parsial).
- **Status verifikasi saat tulis:** `flutter analyze` bersih;
  test learn 8/8 hijau; em-dash 0; full suite 310 lulus 2 gagal
  bawaan commit (Q4 gradien + lipatan headers, gagal juga di commit
  murni).

## Anti-hardcode Detail Modul (2 Okt 2026)

- **Masalah:** `_SectionRail` memakai `number >= 4` hardcode dan tidak ada
  guard jumlah ikon vs seksi: tambah/kurangi seksi data merusak rel
  konektor tanpa peringatan.
- **Perubahan (UI-only, data tidak tersentuh):** `_ArticleSection`
  terima `last` dari `sections.length` (tanpa angka 4 di widget);
  `assert` ikon vs seksi di build (gagal cepat di debug bila data
  berubah). Tanpa ubah tampilan/logika.
- **File:** `course_detail_screen.dart` saja.
- **Status verifikasi saat tulis:** `flutter analyze` bersih;
  test learn 21/21 hijau; em-dash 0; full suite 309 lulus 2 gagal
  bawaan commit (Q4 gradien + lipatan headers, gagal juga di commit
  murni).

## Dialog Profil satu keluarga + haptic Keluar (2 Okt 2026)

- **Masalah:** 3 dialog inline `AlertDialog` generik (konfirmasi keluar,
  gagal keluar, Tentang): judul + body + tombol tanpa identitas, tidak
  satu keluarga satu sama lain maupun dengan bahasa kartu tab.
- **Perubahan (UI-only, teks + alur + provider tidak tersentuh):**
  - `_ProfileDialog` baru: medallion ikon 52px tint aksen + judul 17px
    + body + tombol primer penuh (danger untuk aksi destruktif) +
    sekunder teks opsional. Dipakai ketiga callsite; copy dikunci
    test, tidak berubah satu huruf.
  - `HapticFeedback.mediumImpact` di tap baris Keluar saja (pola yang
    dipakai navbar/onboarding/hero Cek); baris biasa tanpa haptic.
- **Ditolak:** shadow/glow tambahan kartu (hierarki sudah benar),
  animasi entrance (prinsip calm), baris menu jadi kartu terpisah
  (mundur ke pola yang baru dirapikan), ikon custom/emoji (AI slop).
- **File:** `profile_screen.dart` (`_ProfileDialog`, 3 callsite,
  haptic), `test/profile_menu_test.dart` (struktur dialog Tentang).
- **Status verifikasi saat tulis:** `flutter analyze` bersih; test
  profil 56/56 hijau; em-dash 0; full suite 309 lulus 2 gagal bawaan
  commit (Q4 gradien + lipatan headers, gagal juga di commit murni).

## Polish Profil P1-P6 + Fix Skor Merah Alt+Tab (2 Okt 2026)

- **Masalah:** kartu identitas tanpa nama; judul ganda ("Skor & sumber
  poin" + "Sumber poin"); pill "Tersinkron" hijau padahal stream skor
  error (sumbernya UID, bukan status data); stream Firestore putus
  saat Alt+Tab dan tidak reconnect (kartu merah sampai user tekan
  Coba lagi).
- **Perubahan (UI + provider, domain/data tidak tersentuh):**
  - P1 nama user: displayName Firebase (Google) → prefix email →
    label tamu, via `resolveProfileName` murni teruji unit; avatar
    56px; email baris kedua bila ada.
  - P2 grup skor: judul ganda dihapus (2 string yatim dibersihkan);
    divider hairline ring-rincian; ikon makna dipertahankan
    (biru/hijau/amber); hint best-score inline sudah ada sejak dulu.
  - P6 error jujur: copy dipertajam tapi tetap diagnostik (bedakan
    skor vs kunci API); pill "Tersinkron" hijau hanya bila data ada,
    netral "Offline" bila error; provider retry 2x backoff (1s, 2s)
    via listener manual sebelum error final (percobaan `yield*`
    terbukti tidak bisa menahan error generator).
- **Ditolak (dengan alasan, terverifikasi ke kode):** rename heading
  (dikunci 5+ file test + menyesatkan karena tab berisi Pengaturan),
  hapus FAB (tidak ada FAB user; satu-satunya FAB = Chat),
  ikon seragam biru (hancurkan encoding makna), ring 80px
  (hero gradien identitas tab), copy error generik (hilangkan nilai
  diagnostik), heading Belajar (di luar scope).
- **File:** `profile_screen.dart` (nama + avatar 56 + `scoreOk` +
  divider grup), `score_breakdown.dart` (hapus judul),
  `score_providers.dart` (`_watchWithRetry`), `app_strings.dart`
  (+`profileOfflineLabel`, copy error, -2 yatim),
  `test/profile_menu_test.dart` (+nama unit, offline, retry-sukses,
  render 360), `test/score_test.dart` (retry 2x + error final +
  selaras judul), `test/section_header_test.dart` +
  `test/ui_u2_identity_test.dart` (selaras judul).
- **Status verifikasi saat tulis:** `flutter analyze` bersih; em-dash
  0; full suite 309 lulus 2 gagal bawaan commit (Q4 gradien + lipatan
  headers, gagal juga di commit murni, bukan akibat kerjaan ini).

## Refactor Profil S1-S3 (1 Okt 2026)

- **Masalah:** tab Profil = judul + 3 kartu gaya beda bertumpuk (ring,
  breakdown, akun, kunci): polos, tanpa pola menu; user login tidak
  bisa keluar (tidak ada `signOut` di seluruh app).
- **Perubahan (UI-only + 1 aksi auth yang bolong, domain/skor/kuis
  tidak tersentuh):**
  - S1 kartu identitas: avatar inisial + email/label tamu + pill level
    + status Tersinkron/Tamu + CTA masuk (guest). Satu kartu, bukan
    judul + kartu gaya beda.
  - S2 grup skor: `ScoreRing` + `ScoreBreakdown` dipertahankan utuh
    dalam satu kartu berjudul (tanpa permukaan ganda).
  - S3 grup menu "Pengaturan" ala settings profesional (baris ikon +
    chevron + divider, destruktif terpisah): Kunci API (navigasi ke
    layar yang sudah ada), Keluar (konfirmasi + signOut aman-test +
    invalidate agar UI ikut logout; gagal ramah via dialog karena tab
    tanpa Scaffold), Tentang (dialog versi, bukan layar baru).
- **Ditolak (dengan alasan):** password/notifikasi/dark-mode (tidak ada
  backend = tombol palsu), Help/FAQ/deactivate (dead-end), avatar foto
  (tidak ada data; inisial sudah jujur), palet referensi (tabrakan
  identitas biru), varian dark (scope sistem-wide).
- **File:** `profile_screen.dart` (rewrite: `_IdentityCard`,
  `_MiniPill`, `_ScoreGroup`, `_SettingsGroup`, `_SettingsRow`,
  `_safeSignOut`), `app_strings.dart` (16 string profil),
  `test/profile_menu_test.dart` (baru, 7 test: struktur, navigasi
  kunci, dialog Tentang, konfirmasi + batal keluar, render 360/412px),
  update sadar `api_key_demo_test` (tap baris menu, bukan tombol lama).
- **Status verifikasi saat tulis:** `flutter analyze` bersih; test
  profil 38/38 hijau (menu 7 + score + api_key); em-dash 0; full suite
  303 lulus 2 gagal bawaan commit (Q4 gradien + lipatan headers, gagal
  juga di commit murni, bukan akibat refactor Profil).
- **Bonus fix:** test menemukan bug nyata `showSnackBar` tanpa Scaffold
  (tab Profil memang tanpa Scaffold) → kegagalan keluar kini dialog.

## Lanjutan Profil: avatar + Keluar jujur + layar Kunci API (2 Okt 2026)

- **Masalah:** avatar tamu huruf "T" tanpa penjelasan (membingungkan);
  baris "Bersihkan sesi tamu" menjanjikan aksi yang tidak ada (tamu
  tidak punya sesi Firebase); layar Kunci API 4 kartu putih identik
  bertumpuk tanpa hierarki; hasil tes koneksi dibuang jadi satu string
  panjang padahal data per tahap tersedia.
- **Perubahan (UI-only, resolver/controller/probe tidak tersentuh):**
  - Avatar tamu → ikon person netral (placeholder akun yang jelas);
    login tetap inisial email. Status pill ke string terpusat.
  - Baris Keluar hanya bila login ("Keluar akun", berfungsi penuh);
    tamu tanpa baris destruktif (menampilkannya = dishonest UI; aksi
    akun tamu cukup CTA masuk di kartu identitas). String yatim
    `profileGuestLogoutRow` dihapus.
  - Layar Kunci API: hero status (ikon besar + label AI Live/Mode Demo
    + sublabel sumber) sebagai fokal; hasil Tes koneksi dirender per
    tahap probe (DNS/TCP/HTTPS/generate + ikon OK/GAGAL + durasi
    tabular) + ringkasan kesimpulan; kartu form berjudul; 7 string baru
    terpusat (tooltip tampil/sembunyi, judul form, label status,
    judul rincian tahap).
- **File:** `profile_screen.dart` (avatar ikon, `if (synced)` destruktif),
  `api_key_screen.dart` (rewrite: `_StatusHero`, `_TestCard`,
  `_ProbeStepRow`, `_KeyFormCard`, state `_testSteps`), `app_strings.dart`
  (+9, -1 yatim), `test/profile_menu_test.dart` (avatar ikon + tanpa
  huruf T + tamu tanpa baris keluar), `test/ui_u2_identity_test.dart`
  (avatar ikon), `test/api_key_demo_test.dart` (+2: hero demo + tes
  tanpa kunci tanpa request).
- **Status verifikasi saat tulis:** `flutter analyze` bersih; test
  profil + api_key hijau; em-dash 0.

## Detail Modul D1-D2 (30 Sep 2026)

- **Masalah:** 4 kartu artikel `_ArticleSection` identik berulang (radius,
  ikon, label sama; hanya seksi pertama berborder biru): monoton dan tidak
  profesional. Tidak ada peta isi: user harus scroll 4 kartu untuk tahu
  struktur modul.
- **Perubahan (UI-only, data/provider/kuis/skor tidak tersentuh):**
  - D1 kartu "Isi modul": satu kartu putih di bawah hero berisi 4 baris
    judul seksi nyata dari data + nomor tint motif modul (fungsi =
    kolom "The Course includes" pada referensi, isi = data jujur, tanpa
    rating/guru/video). 1 string baru (`learnContentsTitle`); tanpa CTA
    (aksi milik sticky bottom bar).
  - D2 ritme seksi: rel nomor ghost + konektor vertikal di sisi kiri
    (alur baca 1-4, dekoratif `ExcludeSemantics`); medallion ikon tiap
    seksi memakai tint motif modul (biru/teal/hijau sesuai modul, bukan
    4 warna acak); seksi pertama tetap aksen primer. Label `Bagian N`,
    heading, body, CTA, hero tidak berubah (dikunci test lama).
- **Ditolak (dengan alasan):** header ungu + avatar/sapaan (tidak ada
  profil user di konteks ini + tabrakan identitas biru), rating Bintang /
  Teacher / video / template (tidak ada di data = klaim palsu), grid
  2 kolom "For You" (hanya 3 modul), palet pink-ungu (merusak sistem
  4 tab), ubah radius hero 26px (scope creep, follow-up terpisah).
- **File:** `course_detail_screen.dart` (`_ContentsCard`, `_ContentsRow`,
  `_ArticleSection` + `ink`, `_SectionRail`), `app_strings.dart`
  (`learnContentsTitle`), `test/learn_detail_contents_test.dart` (baru,
  5 test: isi dari data, urutan hero-isi-artikel-CTA, tint motif,
  render 360/412px). Test lama tanpa ubahan isi, hijau.
- **Status verifikasi saat tulis:** `flutter analyze` 1 warning bawaan
  (`assets/animation/` tidak ada, pubspec tidak tersentuh);
  test baru + `learn_test` + `ui_u1_polish` hijau; full suite 296 lulus
  2 gagal bawaan commit (Q4 gradien + lipatan tab_headers, gagal juga
  di commit murni, bukan akibat D1/D2).

## Verifikasi

- `flutter analyze --no-pub`: bersih.
- `flutter test`: **297 lulus**, nol gagal (292 sebelumnya + 4 FAB +
  1 struktur featured).
- Render 360×800 & 412×915 via test (termasuk ukur rect FAB vs konten
  di scroll-0 dan ujung scroll).
- `flutter build windows --debug`: sukses, app relaunch hidup.
- Commit manual oleh user (kebijakan repo): pecah per tema bila perlu.

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

## Verifikasi

- `flutter analyze --no-pub`: bersih.
- `flutter test`: 256 lulus, nol gagal.
- Render 360×800 & 412×915 via test (spine + header + home + hero).
- `flutter build windows --debug`: sukses.
- Commit manual oleh user (kebijakan repo): pecah per tema bila perlu.

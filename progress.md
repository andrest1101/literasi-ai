_project ini adalah dokumen hidup — update sesuai perkembangan development._
_Last updated: 15 september 2026_

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

_project ini adalah dokumen hidup — update sesuai perkembangan development._
_Last updated: 10 september 2026_

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

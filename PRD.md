# PRD — LiterasiAI

**Product Requirements Document**
**Version:** 1.0
**Platform:** Flutter (Android & iOS)
**Developer:** Andre Robert Silitonga
**Target:** Apple Developer Academy Portfolio 2026

---

## 1. Overview

### 1.1 Problem Statement

Indonesia adalah salah satu negara dengan tingkat penyebaran hoaks tertinggi di dunia. Berdasarkan data Kominfo, ribuan konten hoaks teridentifikasi setiap tahunnya — mayoritas menyebar melalui WhatsApp, Instagram, dan Facebook. Masyarakat umum tidak memiliki alat yang mudah, cepat, dan dapat dipercaya untuk memverifikasi informasi secara mandiri.

### 1.2 Solution

LiterasiAI adalah aplikasi mobile berbasis AI yang membantu pengguna memverifikasi kebenaran informasi secara instan — melalui teks, gambar, atau URL — sekaligus meningkatkan literasi digital mereka melalui edukasi yang ringkas dan engaging.

### 1.3 Core Value Proposition

> "Cek dulu sebelum sebar — dalam hitungan detik."

### 1.4 Tech Stack

- **Framework:** Flutter (Dart)
- **AI Engine:** Google Gemini API (gemini-1.5-flash)
- **Backend & Auth:** Firebase (Firestore, Authentication, Storage)
- **State Management:** Riverpod
- **Architecture:** Clean Architecture (Feature-based)

---

## 2. Goals & Success Metrics

### 2.1 MVP Goals

- [ ] User bisa verifikasi teks dalam < 5 detik
- [ ] User bisa verifikasi gambar (screenshot berita/pesan)
- [ ] User bisa verifikasi URL artikel
- [ ] History verifikasi tersimpan lokal
- [ ] Hasil bisa di-share ke WhatsApp sebagai gambar

### 2.2 Success Metrics untuk Portfolio

- App bisa didemonstrasikan live kepada reviewer dalam 60 detik
- Akurasi verifikasi yang dapat dijelaskan secara teknis
- UI yang terlihat profesional dan tidak generik
- Dokumentasi Purpose → Process → Outcome yang kuat

---

## 3. User Persona

**Persona Utama: Budi, 35 tahun**

- Pengguna aktif WhatsApp grup keluarga dan RT
- Sering menerima forwarded message yang mencurigakan
- Tidak punya waktu untuk riset manual
- Ingin cara cepat untuk verifikasi sebelum meneruskan pesan

**Persona Sekunder: Sari, 20 tahun (mahasiswa)**

- Aktif di media sosial
- Sadar pentingnya literasi digital
- Butuh alat untuk edukasi diri tentang cara identifikasi hoaks

---

## 4. Features — MVP Scope

### 4.1 CORE FEATURES (Wajib ada sebelum demo)

---

#### Feature 1: Quick Check

**Deskripsi:** Fitur utama untuk verifikasi informasi secara instan.

**3 Mode Input:**

1. **Teks** — User paste atau ketik klaim yang ingin diverifikasi
2. **Gambar** — User upload screenshot dari WhatsApp/media sosial, AI baca teks dari gambar lalu verifikasi
3. **URL** — User paste link artikel, AI fetch judul/konten lalu verifikasi

**Output Verifikasi:**

```
Verdict:     [HOAKS] / [PERLU DICEK] / [VALID] / [TIDAK DAPAT DIPASTIKAN]
Confidence:  87%
Penjelasan:  Paragraf singkat 2-3 kalimat kenapa AI menilai demikian
Saran:       "Cek di Snopes.com / Turnbackhoax.id untuk konfirmasi lebih lanjut"
```

**UI Requirements:**

- Loading state dengan animasi AI "sedang menganalisis"
- Verdict ditampilkan dengan warna tegas: Merah (Hoaks), Kuning (Perlu Dicek), Hijau (Valid), Abu (Tidak Pasti)
- Card hasil yang bisa di-share langsung ke WhatsApp

---

#### Feature 2: AI Chat Assistant

**Deskripsi:** Chat langsung dengan AI untuk tanya-jawab seputar literasi digital dan verifikasi.

**Use Cases:**

- "Apakah vaksin menyebabkan autisme itu benar?"
- "Bagaimana cara mengenali hoaks dari judulnya?"
- "Siapa yang membuat berita ini?"

**UI Requirements:**

- Chat bubble style seperti WhatsApp
- AI response dalam Bahasa Indonesia yang santai tapi informatif
- Tombol "Verifikasi ini" di tiap response untuk lanjut ke Quick Check

---

#### Feature 3: History

**Deskripsi:** Riwayat semua verifikasi yang pernah dilakukan.

**Data yang disimpan:**

- Input yang diverifikasi (teks/gambar thumbnail/URL)
- Verdict dan confidence score
- Timestamp
- Disimpan ke Firestore per user

**UI Requirements:**

- List dengan filter: Semua / Hoaks / Valid / Perlu Dicek
- Swipe to delete
- Tap untuk lihat detail hasil verifikasi

---

#### Feature 4: Share Hasil

**Deskripsi:** User bisa share hasil verifikasi sebagai gambar ke WhatsApp atau media sosial lain.

**Format Share:**

```
┌─────────────────────────────┐
│  🔍 LiterasiAI              │
│                             │
│  VERDICT: ⚠️ HOAKS          │
│  Confidence: 87%            │
│                             │
│  "Klaim: [teks yang dicek]" │
│                             │
│  Cek sendiri di LiterasiAI  │
└─────────────────────────────┘
```

**Implementasi:** Generate gambar dari Widget menggunakan `screenshot` package, lalu share via `share_plus`.

---

### 4.2 SECONDARY FEATURES (Dikerjakan setelah Core selesai)

---

#### Feature 5: Trending Hoaks

**Deskripsi:** Feed 5-10 hoaks yang sedang viral hari ini — curated content yang diupdate manual oleh developer atau dari API publik Kominfo.

**Tujuan:** Membuat app terasa "hidup" meski user tidak aktif input. Meningkatkan engagement pasif.

**UI Requirements:**

- Card horizontal scroll di Home Screen
- Badge "HOT" untuk yang trending
- Tap untuk langsung lihat detail verifikasi

---

#### Feature 6: Literacy Mini-Course

**Deskripsi:** 3 modul edukasi singkat tentang literasi digital.

**Modul:**

1. "Cara Mengenali Judul Clickbait" — 5 menit baca
2. "Ciri-ciri Gambar yang Dimanipulasi" — 5 menit baca
3. "Cara Verifikasi Sumber Berita" — 5 menit baca

**Format:** Artikel pendek dengan ilustrasi, quiz 3 soal di akhir, badge setelah selesai.

---

#### Feature 7: Literacy Score

**Deskripsi:** Skor personal yang merepresentasikan tingkat literasi digital user.

**Cara hitung:**

- +10 poin setiap verifikasi dilakukan
- +20 poin setiap modul edukasi diselesaikan
- +5 poin setiap quiz benar

**UI:** Circular progress indicator di Home Screen dengan level: Pemula → Waspada → Kritis → Ahli

---

### 4.3 FITUR YANG TIDAK DIBANGUN (Sengaja dipangkas)

| Fitur                  | Alasan Dipangkas                                      |
| ---------------------- | ----------------------------------------------------- |
| RAG on-device          | Overhead teknis sangat tinggi, Gemini API sudah cukup |
| Community Verification | Butuh moderation system, risiko abuse                 |
| Leaderboard            | Privacy concern, kompleksitas tinggi                  |
| Adaptive Learning AI   | Scope terlalu besar untuk solo developer              |

---

## 5. Screen Map

```
App Launch
    ↓
Splash Screen
    ↓
Onboarding (3 screen) → hanya tampil saat pertama install
    ↓
Auth Screen (Google Sign In / Anonymous)
    ↓
Home Screen
├── Quick Check Tab
│   ├── Input Screen (Teks / Gambar / URL)
│   ├── Loading / Analyzing Screen
│   └── Result Screen → Share Sheet
├── Chat Tab
│   └── AI Chat Screen
├── History Tab
│   ├── History List Screen
│   └── History Detail Screen
├── Learn Tab (Secondary)
│   ├── Course List Screen
│   ├── Course Detail Screen
│   └── Quiz Screen
└── Profile Tab
    ├── Profile Screen
    └── Settings Screen
```

**Total screens MVP:** 12 screens
**Total screens full:** 16 screens

---

## 6. AI Integration Details

### 6.1 Gemini API Prompting Strategy

**Untuk Quick Check (Teks):**

```
System: Kamu adalah AI spesialis verifikasi fakta untuk masyarakat Indonesia.
Analisis klaim berikut dan berikan verdict dalam format JSON yang diminta.
Gunakan Bahasa Indonesia yang mudah dipahami.
Jangan tambahkan teks di luar format JSON.

User: Verifikasi klaim ini: [input_user]

Response format:
{
  "verdict": "HOAKS" | "VALID" | "PERLU_DICEK" | "TIDAK_DAPAT_DIPASTIKAN",
  "confidence": 0-100,
  "explanation": "penjelasan 2-3 kalimat",
  "suggestion": "saran untuk verifikasi lebih lanjut"
}
```

**Untuk Quick Check (Gambar):**

- Gunakan Gemini Vision capability
- Extract teks dari gambar dulu, lalu verifikasi teks tersebut

**Untuk Quick Check (URL):**

- Fetch metadata URL (title, description) menggunakan http package
- Kirim metadata ke Gemini untuk verifikasi

### 6.2 Error Handling

- API timeout → tampilkan pesan "Koneksi lambat, coba lagi"
- Gemini tidak bisa memverifikasi → return verdict "TIDAK_DAPAT_DIPASTIKAN"
- Gambar tidak terbaca → minta user upload ulang dengan pencahayaan lebih baik

---

## 7. UI/UX Guidelines

### 7.1 Design Principles

- **Trustworthy** — UI harus terkesan kredibel dan profesional, bukan playful
- **Fast** — Setiap interaksi harus terasa responsif, loading state harus ada
- **Clear** — Verdict harus langsung terbaca dalam 1 detik tanpa perlu baca penjelasan

### 7.2 Color System

```
Primary:     #1A73E8  (Google Blue — kesan teknologi dan kepercayaan)
Success:     #34A853  (Hijau — VALID)
Warning:     #FBBC04  (Kuning — PERLU DICEK)
Danger:      #EA4335  (Merah — HOAKS)
Neutral:     #9AA0A6  (Abu — TIDAK DAPAT DIPASTIKAN)
Background:  #F8F9FA  (Off-white, bukan putih polos)
Surface:     #FFFFFF
Text Primary: #202124
Text Secondary: #5F6368
```

### 7.3 Typography

- Font: Google Sans atau Inter
- Heading: Bold, 24px
- Body: Regular, 16px
- Caption: Regular, 12px

### 7.4 UI Anti-Patterns yang Harus Dihindari

- Jangan pakai warna flat polos tanpa depth
- Jangan pakai card tanpa shadow atau border
- Jangan pakai icon default Flutter tanpa customisasi
- Verdict card harus punya visual hierarchy yang kuat — bukan hanya teks biasa

---

## 8. Technical Architecture

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_styles.dart
│   ├── errors/
│   │   └── failures.dart
│   └── utils/
│       ├── url_fetcher.dart
│       └── image_processor.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── quick_check/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── gemini_datasource.dart
│   │   │   └── repositories/
│   │   │       └── verification_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── verification_result.dart
│   │   │   ├── repositories/
│   │   │   │   └── verification_repository.dart
│   │   │   └── usecases/
│   │   │       └── verify_claim.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── input_screen.dart
│   │       │   ├── analyzing_screen.dart
│   │       │   └── result_screen.dart
│   │       ├── widgets/
│   │       │   ├── verdict_card.dart
│   │       │   ├── input_mode_selector.dart
│   │       │   └── share_card.dart
│   │       └── providers/
│   │           └── verification_provider.dart
│   ├── chat/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── chat_screen.dart
│   │       └── widgets/
│   │           └── chat_bubble.dart
│   ├── history/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── history_list_screen.dart
│   │           └── history_detail_screen.dart
│   └── learn/
│       └── presentation/
│           └── screens/
│               ├── course_list_screen.dart
│               ├── course_detail_screen.dart
│               └── quiz_screen.dart
└── shared/
    └── widgets/
        ├── loading_overlay.dart
        ├── error_widget.dart
        └── bottom_nav_bar.dart
```

---

## 9. Development Phases

### Phase 1 — Foundation (Minggu 1)

- [ ] Setup Flutter project dengan Clean Architecture
- [ ] Setup Firebase (Auth, Firestore)
- [ ] Setup Gemini API
- [ ] Buat design system (colors, typography, components)
- [ ] Auth screen (Google Sign In + Anonymous)

### Phase 2 — Core Feature (Minggu 2-3)

- [ ] Quick Check — mode Teks
- [ ] Analyzing screen dengan animasi
- [ ] Result screen dengan Verdict Card
- [ ] Share functionality
- [ ] Quick Check — mode Gambar
- [ ] Quick Check — mode URL

### Phase 3 — Supporting Features (Minggu 4)

- [ ] History screen + Firestore integration
- [ ] AI Chat screen
- [ ] Home screen dengan Literacy Score
- [ ] Trending Hoaks section

### Phase 4 — Polish & Portfolio (Minggu 5)

- [ ] Mini-course (3 modul)
- [ ] UI polish — animasi, micro-interactions
- [ ] Onboarding screens
- [ ] Record demo video 60 detik
- [ ] Tulis dokumentasi portfolio
- [ ] Upload ke GitHub dengan README

---

## 10. Portfolio Documentation Template

### Purpose

_LiterasiAI lahir dari keprihatinan terhadap tingginya angka penyebaran hoaks di Indonesia — [data konkret dari Kominfo]. Saya melihat bahwa kebanyakan masyarakat tidak memiliki alat yang mudah dan cepat untuk memverifikasi informasi sebelum menyebarkannya. LiterasiAI hadir sebagai solusi: verifikasi fakta berbasis AI dalam hitungan detik, langsung dari smartphone._

### Development Process

_[Isi dengan tantangan nyata yang dihadapi selama development, keputusan teknis yang dibuat, dan iterasi berdasarkan feedback]_

### Outcome

_[Isi dengan metric konkret: jumlah user yang test, akurasi verifikasi dalam testing, feedback yang diterima]_

---

## 11. Risks & Mitigations

| Risk                                                | Likelihood | Mitigation                                                                  |
| --------------------------------------------------- | ---------- | --------------------------------------------------------------------------- |
| Gemini API tidak akurat untuk hoaks lokal Indonesia | Tinggi     | Tambahkan disclaimer bahwa ini AI assistant, bukan sumber kebenaran mutlak  |
| API cost membengkak                                 | Sedang     | Implementasi rate limiting, cache hasil verifikasi yang sama                |
| User menyalahgunakan untuk spread disinformasi      | Rendah     | App hanya verifikasi, tidak generate konten baru                            |
| App store rejection karena klaim "deteksi hoaks"    | Sedang     | Framing sebagai "AI literacy assistant", bukan "hoax detector" yang absolut |

---

_PRD ini adalah dokumen hidup — update sesuai perkembangan development._
_Last updated: 2026_

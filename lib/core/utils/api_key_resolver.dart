import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_key_store.dart';

/// Sumber kunci API yang aktif — prioritas jelas, tanpa tebakan.
enum ApiKeySource { compileDefine, userKey, none }

/// Status kunci gabungan untuk UI: sumber + apakah tersedia.
class ApiKeyStatus {
  const ApiKeyStatus({required this.source, required this.key});

  final ApiKeySource source;
  final String key;

  bool get configured => key.isNotEmpty;
  bool get isUserKey => source == ApiKeySource.userKey;
}

final apiKeyStoreProvider = Provider<ApiKeyStore>((ref) => ApiKeyStore());

/// True bila kunci tampak seperti contoh/placeholder (mis. disalin dari
/// perintah contoh README tanpa diganti kunci asli).
///
/// Hanya pola utuh yang ditandai — substring umum seperti "CONTOH" di
/// dalam kunci valid TIDAK ditolak agar tidak false positive. Pola yang
/// ditolak: `KODE`, `ISI_KUNCI`, `YOUR_KEY`, `PLACEHOLDER`, `EXAMPLE`,
/// `CHANGEME`, `XXXX` beruntun, `KUNCI_ANDA/KAMU`, `GANTI`, `MASUKKAN`,
/// `TEMPEL`. Placeholder lolos validasi panjang sehingga tanpa saringan
/// ini ia dipakai request dan server selalu menolak — user mengganti
/// kunci berkali-kali tetap gagal karena slot compile-define menimpa
/// kunci asli.
bool isPlaceholderKey(String rawKey) {
  final upper = rawKey.trim().toUpperCase();
  if (upper.isEmpty) return false;
  const markers = [
    'KODE',
    'ISI_KUNCI',
    'ISI-KUNCI',
    'YOUR_KEY',
    'YOUR-KEY',
    'YOURKEY',
    'PLACEHOLDER',
    'EXAMPLE',
    'CHANGEME',
    'XXXX',
    'GANTI',
    'MASUKKAN',
    'TEMPEL',
    'KUNCI_ANDA',
    'KUNCI-KAMU',
    'KUNCIKAMU',
  ];
  for (final marker in markers) {
    if (upper.contains(marker)) return true;
  }
  return false;
}

/// Resolver: dart-define (compile) menang atas kunci user (runtime).
/// Kunci user dari secure storage dibaca async sekali saat provider dibuat.
///
/// Pengecualian: dart-define yang berupa placeholder (contoh README yang
/// tidak diganti) DIABAIKAN agar jatuh ke kunci user asli — bukan dipakai
/// request lalu ditolak server selamanya.
final apiKeyStatusProvider = FutureProvider<ApiKeyStatus>((ref) async {
  const compiled = String.fromEnvironment('GEMINI_API_KEY');
  if (compiled.isNotEmpty && !isPlaceholderKey(compiled)) {
    debugPrint(
      'API key: pakai dart-define (${compiled.length} char, '
      '${_keyFingerprint(compiled)}).',
    );
    return const ApiKeyStatus(
      source: ApiKeySource.compileDefine,
      key: compiled,
    );
  }
  if (compiled.isNotEmpty) {
    debugPrint(
      'API key: dart-define berupa placeholder, diabaikan → pakai kunci user.',
    );
  }
  final stored = (await ref.watch(apiKeyStoreProvider).read())?.trim() ?? '';
  if (stored.isNotEmpty && !isPlaceholderKey(stored)) {
    debugPrint(
      'API key: pakai kunci user (${stored.length} char, '
      '${_keyFingerprint(stored)}).',
    );
    return ApiKeyStatus(source: ApiKeySource.userKey, key: stored);
  }
  debugPrint('API key: tidak ada kunci valid (mode demo).');
  return const ApiKeyStatus(source: ApiKeySource.none, key: '');
});

/// Sidik kunci untuk log — 4 char awal + panjang saja, TIDAK PERNAH
/// kunci penuh. Cukup untuk tahu kunci mana yang dipakai tanpa bocor.
String _keyFingerprint(String key) {
  final head = key.length >= 4 ? key.substring(0, 4) : '??';
  return '$head… (${key.length} char)';
}

/// Controller BYOK: simpan/hapus kunci user + refresh status.
/// Validasi format ringan: minimal 20 karakter, tanpa spasi.
class ApiKeyController extends AsyncNotifier<ApiKeyStatus> {
  @override
  Future<ApiKeyStatus> build() => ref.watch(apiKeyStatusProvider.future);

  Future<String?> save(String rawKey) async {
    final key = rawKey.trim();
    if (key.length < 20 || key.contains(RegExp(r'\s'))) {
      return 'Kunci API tidak valid. Tempel kunci lengkap tanpa spasi.';
    }
    if (isPlaceholderKey(key)) {
      return 'Itu kunci contoh, bukan kunci asli. Salin kunci asli dari '
          'Google AI Studio (diawali AIza...) lalu tempel di sini.';
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiKeyStoreProvider).write(key);
      // Invalidate di sini saja; consumer lain mendengar perubahan status.
      ref.invalidate(apiKeyStatusProvider);
      return ref.watch(apiKeyStatusProvider.future);
    });
    return state.hasError ? 'Gagal menyimpan kunci. Coba lagi.' : null;
  }

  Future<void> clearUserKey() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiKeyStoreProvider).clear();
      ref.invalidate(apiKeyStatusProvider);
      return ref.watch(apiKeyStatusProvider.future);
    });
  }
}

final apiKeyControllerProvider =
    AsyncNotifierProvider<ApiKeyController, ApiKeyStatus>(
      ApiKeyController.new,
    );

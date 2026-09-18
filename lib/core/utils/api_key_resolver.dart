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

/// Resolver: dart-define (compile) menang atas kunci user (runtime).
/// Kunci user dari secure storage dibaca async sekali saat provider dibuat.
final apiKeyStatusProvider = FutureProvider<ApiKeyStatus>((ref) async {
  const compiled = String.fromEnvironment('GEMINI_API_KEY');
  if (compiled.isNotEmpty) {
    return const ApiKeyStatus(
      source: ApiKeySource.compileDefine,
      key: compiled,
    );
  }
  final stored = (await ref.watch(apiKeyStoreProvider).read())?.trim() ?? '';
  if (stored.isNotEmpty) {
    return ApiKeyStatus(source: ApiKeySource.userKey, key: stored);
  }
  return const ApiKeyStatus(source: ApiKeySource.none, key: '');
});

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

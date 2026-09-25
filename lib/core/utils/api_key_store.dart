import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan kunci Gemini milik pengguna (BYOK) di secure storage OS.
///
/// Keychain iOS / Keystore Android / Credential Locker Windows: tidak pernah
/// di SharedPreferences, tidak pernah di-hardcode, tidak pernah masuk repo.
class ApiKeyStore {
  ApiKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String keyName = 'gemini_api_key';

  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: keyName);

  Future<void> write(String key) => _storage.write(key: keyName, value: key);

  Future<void> clear() => _storage.delete(key: keyName);
}

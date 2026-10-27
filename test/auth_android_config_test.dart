import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regresi konfigurasi Android untuk autentikasi.
///
/// Dua kegagalan pernah terjadi dan tidak tertangkap test mana pun:
/// 1. `INTERNET` hanya dideklarasikan di manifest debug/profile sehingga APK
///    release tidak bisa menghubungi Firebase maupun Gemini.
/// 2. `google-services.json` tidak memuat OAuth client, sehingga Google
///    Sign-In tidak menerbitkan ID token dan login Google selalu gagal.
///
/// Test ini membaca file konfigurasi langsung agar regresi tidak lolos tanpa
/// membangun APK.
void main() {
  test('manifest utama mendeklarasikan izin INTERNET untuk build release', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(
      manifest,
      contains('android.permission.INTERNET'),
      reason: 'Tanpa izin ini APK release tidak bisa memanggil Firebase.',
    );
  });

  group('google-services.json', () {
    late Map<String, dynamic> config;
    late Map<String, dynamic> client;

    setUpAll(() {
      config =
          jsonDecode(
                File('android/app/google-services.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      client = ((config['client'] as List).first as Map)
          .cast<String, dynamic>();
    });

    test('memuat OAuth client Android dengan certificate hash', () {
      final oauthClients = (client['oauth_client'] as List)
          .cast<Map<String, dynamic>>();
      final androidClient = oauthClients.where(
        (entry) => entry['client_type'] == 1,
      );

      expect(
        androidClient,
        isNotEmpty,
        reason:
            'Daftarkan SHA-1 debug di Firebase Console lalu unduh ulang '
            'google-services.json. Tanpa ini Google Sign-In gagal.',
      );
      final hash =
          (androidClient.first['android_info'] as Map)['certificate_hash']
              as String;
      expect(hash.replaceAll(':', ''), hasLength(40));
    });

    test('memuat web client sebagai sumber default_web_client_id', () {
      final oauthClients = (client['oauth_client'] as List)
          .cast<Map<String, dynamic>>();

      expect(
        oauthClients.where((entry) => entry['client_type'] == 3),
        isNotEmpty,
        reason:
            'Plugin google_sign_in membaca default_web_client_id untuk '
            'meminta ID token.',
      );
    });

    test('mengarah ke paket yang terpasang di perangkat', () {
      final packageName =
          (client['client_info'] as Map)['android_client_info']['package_name'];

      expect(packageName, 'com.example.literasi_ai');
    });
  });
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Regresi brand native: nama aplikasi, ikon, dan launch screen adalah hal
/// pertama yang dilihat reviewer.
///
/// Sebelum perubahan ini kedua platform masih memakai aset default Flutter
/// (logo Flutter + layar putih) dan label `literasi_ai` / `Literasi Ai`.
/// Test ini mengunci kontrak file native supaya regresi tidak lolos tanpa
/// harus membuka Xcode/Android Studio.
void main() {
  const iosIconDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  const androidRes = 'android/app/src/main/res';

  group('Identitas aplikasi', () {
    test('Android memakai label LiterasiAI + ikon bulat', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, contains('android:label="LiterasiAI"'));
      expect(manifest, isNot(contains('android:label="literasi_ai"')));
      expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
      expect(
        manifest,
        contains('android:roundIcon="@mipmap/ic_launcher_round"'),
      );
    });

    test('iOS memakai CFBundleDisplayName LiterasiAI', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(
        plist,
        matches(
          RegExp(
            r'<key>CFBundleDisplayName</key>\s*<string>LiterasiAI</string>',
          ),
        ),
      );
      expect(
        plist,
        matches(
          RegExp(r'<key>CFBundleName</key>\s*<string>LiterasiAI</string>'),
        ),
      );
      expect(plist, isNot(contains('Literasi Ai')));
    });
  });

  group('Ikon iOS', () {
    test('setiap ukuran di Contents.json ada dengan dimensi yang benar', () {
      final catalog =
          jsonDecode(File('$iosIconDir/Contents.json').readAsStringSync())
              as Map<String, dynamic>;
      final images = (catalog['images'] as List).cast<Map<String, dynamic>>();

      for (final image in images) {
        final filename = image['filename'] as String;
        final size = double.parse((image['size'] as String).split('x').first);
        final scale = double.parse(
          (image['scale'] as String).replaceAll('x', ''),
        );
        final expected = (size * scale).round();
        final header = _readPngHeader('$iosIconDir/$filename');

        expect(
          header.width,
          expected,
          reason: '$filename lebar harus $expected px',
        );
        expect(
          header.height,
          expected,
          reason: '$filename tinggi harus $expected px',
        );
      }
    });

    test('semua ikon iOS tanpa alpha (syarat App Store)', () {
      final catalog =
          jsonDecode(File('$iosIconDir/Contents.json').readAsStringSync())
              as Map<String, dynamic>;
      final images = (catalog['images'] as List).cast<Map<String, dynamic>>();
      final filenames = images
          .map((image) => image['filename'] as String)
          .toSet();

      expect(filenames, hasLength(15));
      for (final filename in filenames) {
        final header = _readPngHeader('$iosIconDir/$filename');
        // PNG color type 4/6 menyimpan alpha; App Store menolak ikon iOS
        // yang punya kanal transparansi.
        expect(
          header.colorType,
          isNot(anyOf(4, 6)),
          reason: '$filename masih punya kanal alpha',
        );
      }
    });

    test('tidak ada PNG yatim di AppIcon.appiconset', () {
      final catalog =
          jsonDecode(File('$iosIconDir/Contents.json').readAsStringSync())
              as Map<String, dynamic>;
      final referenced = (catalog['images'] as List)
          .cast<Map<String, dynamic>>()
          .map((image) => image['filename'] as String)
          .toSet();
      final onDisk = Directory(iosIconDir)
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .where((name) => name.endsWith('.png'))
          .toSet();

      expect(onDisk, referenced);
    });
  });

  group('Ikon Android', () {
    const densities = {
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };

    for (final entry in densities.entries) {
      test('mipmap-${entry.key} punya ikon legacy + round + launch mark', () {
        for (final name in ['ic_launcher.png', 'ic_launcher_round.png']) {
          final header = _readPngHeader(
            '$androidRes/mipmap-${entry.key}/$name',
          );
          expect(header.width, entry.value, reason: '$name lebar');
          expect(header.height, entry.value, reason: '$name tinggi');
          // Rounded squircle dengan sudut transparan: alpha diizinkan agar
          // Android < 26 tidak menampilkan baji hitam di belakang ikon.
          expect(header.colorType, 6, reason: '$name harus RGBA');
        }

        final mark = _readPngHeader(
          '$androidRes/mipmap-${entry.key}/launch_mark.png',
        );
        expect(mark.width, mark.height);
        expect(mark.colorType, 6, reason: 'launch mark harus transparan');
      });
    }

    test('adaptive icon memakai layer vector + monochrome', () {
      for (final name in ['ic_launcher.xml', 'ic_launcher_round.xml']) {
        final xml = File(
          '$androidRes/mipmap-anydpi-v26/$name',
        ).readAsStringSync();
        expect(xml, contains('@drawable/ic_launcher_background'));
        expect(xml, contains('@drawable/ic_launcher_foreground'));
        expect(xml, contains('@drawable/ic_launcher_monochrome'));
      }
      for (final name in [
        'ic_launcher_background.xml',
        'ic_launcher_foreground.xml',
        'ic_launcher_monochrome.xml',
      ]) {
        expect(
          File('$androidRes/drawable/$name').existsSync(),
          isTrue,
          reason: '$name hilang',
        );
      }
    });
  });

  group('Launch screen', () {
    test('launch background Android memakai bidang brand + mark', () {
      for (final folder in ['drawable', 'drawable-v21']) {
        final xml = File(
          '$androidRes/$folder/launch_background.xml',
        ).readAsStringSync();
        expect(xml, contains('@color/brand_primary'), reason: folder);
        expect(xml, contains('@mipmap/launch_mark'), reason: folder);
        expect(
          xml,
          isNot(contains('@android:color/white')),
          reason: '$folder masih default putih',
        );
      }

      final colors = File('$androidRes/values/colors.xml').readAsStringSync();
      expect(colors, contains('#1A73E8'));
    });

    test('splash Android 12 memakai bidang brand + ikon vector', () {
      final xml = File('$androidRes/values-v31/styles.xml').readAsStringSync();

      expect(xml, contains('android:windowSplashScreenBackground'));
      expect(xml, contains('@color/brand_primary'));
      expect(
        xml,
        contains(
          '<item name="android:windowSplashScreenAnimatedIcon">'
          '@drawable/ic_launcher_foreground</item>',
        ),
      );
    });

    test('storyboard iOS memakai bidang brand + mark 120pt', () {
      final xml = File(
        'ios/Runner/Base.lproj/LaunchScreen.storyboard',
      ).readAsStringSync();

      expect(xml, isNot(contains('red="1" green="1" blue="1"')));
      expect(xml, contains('red="0.10196078431372549"'));
      expect(
        xml,
        contains('<image name="LaunchImage" width="120" height="120"/>'),
      );

      final header = _readPngHeader(
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png',
      );
      expect(header.width, 360);
      expect(header.colorType, 6, reason: 'mark launch harus transparan');
    });

    test('splash Flutter memakai mark brand yang terdaftar di pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('assets/branding/app_mark.png'));

      final header = _readPngHeader('assets/branding/app_mark.png');
      expect(header.width, 384);
      expect(header.colorType, 6);

      final splash = File(
        'lib/features/auth/presentation/screens/splash_screen.dart',
      ).readAsStringSync();
      expect(splash, contains('assets/branding/app_mark.png'));
      expect(splash, isNot(contains('Icons.fact_check')));
    });
  });
}

/// Membaca header IHDR PNG tanpa dependensi image package.
///
/// Layout: 8 byte signature, 4 byte chunk length, 4 byte "IHDR", lalu
/// 4 byte width, 4 byte height, 1 byte bit depth, 1 byte color type.
class _PngHeader {
  const _PngHeader({
    required this.width,
    required this.height,
    required this.colorType,
  });

  final int width;
  final int height;
  final int colorType;
}

_PngHeader _readPngHeader(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: '$path tidak ditemukan');

  final bytes = file.readAsBytesSync();
  expect(bytes.length, greaterThan(32), reason: '$path bukan PNG utuh');
  expect(
    String.fromCharCodes(bytes.sublist(12, 16)),
    'IHDR',
    reason: '$path bukan PNG valid',
  );

  final data = ByteData.sublistView(bytes);
  return _PngHeader(
    width: data.getUint32(16),
    height: data.getUint32(20),
    colorType: bytes[25],
  );
}

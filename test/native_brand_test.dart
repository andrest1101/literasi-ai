import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

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

    test('ikon utama iOS memakai artwork logo berwarna', () {
      final header = _readPngHeader('$iosIconDir/Icon-App-1024x1024@1x.png');
      expect(header.width, 1024);
      expect(header.colorType, isNot(anyOf(4, 6)));
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

    test('adaptive launcher foreground memakai logo berwarna', () {
      final header = _readPngHeader(
        '$androidRes/drawable-xxxhdpi/ic_launcher_foreground_glyph.png',
      );
      expect(header.width, 432);
      expect(header.colorType, 6);
    });

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

    test('splash Android 12 memakai bidang brand + mark putih', () {
      final xml = File('$androidRes/values-v31/styles.xml').readAsStringSync();

      expect(xml, contains('android:windowSplashScreenBackground'));
      expect(xml, contains('@color/brand_primary'));
      expect(
        xml,
        contains(
          '<item name="android:windowSplashScreenAnimatedIcon">'
          '@drawable/splash_mark</item>',
        ),
      );
      expect(
        xml,
        isNot(contains('@drawable/ic_launcher_foreground')),
        reason: 'splash tidak boleh memakai glyph berwarna launcher',
      );

      final splashMark = File(
        '$androidRes/drawable/splash_mark.xml',
      ).readAsStringSync();
      expect(splashMark, contains('@drawable/splash_mark_glyph'));

      // Kualifikasi `night` mengalahkan `v31`; tanpa override ini Android 12
      // mode gelap kembali memakai ikon launcher.
      final nightXml = File(
        '$androidRes/values-night-v31/styles.xml',
      ).readAsStringSync();
      expect(nightXml, contains('@color/brand_primary'));
      expect(nightXml, contains('@drawable/splash_mark'));
    });

    testWidgets('mark splash putih, transparan, dan proporsional', (
      tester,
    ) async {
      const marks = [
        (path: 'assets/branding/app_mark.png', widthRatio: 0.98),
        (
          path: 'android/app/src/main/res/mipmap-xxxhdpi/launch_mark.png',
          widthRatio: 0.82,
        ),
        (
          path:
              'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png',
          widthRatio: 0.82,
        ),
        (
          path:
              'android/app/src/main/res/drawable-xxxhdpi/splash_mark_glyph.png',
          widthRatio: 0.20,
        ),
      ];

      for (final entry in marks) {
        final path = entry.path;
        // Decoding PNG memakai mesin asli, bukan fake async widget test.
        final stats = await tester.runAsync(() async {
          final codec = await ui.instantiateImageCodec(
            File(path).readAsBytesSync(),
          );
          final image = (await codec.getNextFrame()).image;
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          final pixels = data!.buffer.asUint8List();

          var minX = image.width, minY = image.height, maxX = -1, maxY = -1;
          var worstChannelDelta = 0;
          for (var i = 0; i < pixels.length; i += 4) {
            final alpha = pixels[i + 3];
            if (alpha == 0) continue;

            // rawRgba premultiplied: glyph putih berarti RGB == alpha.
            for (var channel = 0; channel < 3; channel++) {
              final delta = alpha - pixels[i + channel];
              if (delta > worstChannelDelta) worstChannelDelta = delta;
            }

            final index = i ~/ 4;
            final x = index % image.width;
            final y = index ~/ image.width;
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }

          final result = (
            width: image.width,
            worstChannelDelta: worstChannelDelta,
            minX: minX,
            minY: minY,
            maxX: maxX,
            maxY: maxY,
          );
          image.dispose();
          codec.dispose();
          return result;
        });

        expect(stats, isNotNull, reason: '$path gagal didekode');
        final mark = stats!;

        expect(
          mark.worstChannelDelta,
          lessThanOrEqualTo(12),
          reason: '$path punya piksel berwarna (bukan putih)',
        );
        expect(mark.maxX, greaterThanOrEqualTo(0), reason: '$path kosong');

        final glyphWidth = mark.maxX - mark.minX + 1;
        final glyphHeight = mark.maxY - mark.minY + 1;

        // Mark harus mengisi target kanvas (tidak kekecilan) dan tetap punya
        // margin, dengan rasio glyph sumber 1.315:1.
        expect(
          glyphWidth / mark.width,
          closeTo(entry.widthRatio, 0.06),
          reason: '$path terlalu kecil/besar',
        );
        expect(
          glyphWidth / glyphHeight,
          closeTo(1.31, 0.12),
          reason: '$path bentuknya tidak sesuai master putih',
        );
      }
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
      expect(header.width, 392);
      expect(header.height, 300);
      expect(header.colorType, 6);

      final splash = File(
        'lib/features/auth/presentation/screens/splash_screen.dart',
      ).readAsStringSync();
      expect(splash, contains('assets/branding/app_mark.png'));
      expect(splash, isNot(contains('Icons.fact_check')));
    });
  });

  group('Branding desktop & web', () {
    test('Windows memakai judul dan metadata LiterasiAI', () {
      final mainCpp = File('windows/runner/main.cpp').readAsStringSync();
      expect(mainCpp, contains('window.Create(L"LiterasiAI"'));

      final rc = File('windows/runner/Runner.rc').readAsStringSync();
      expect(rc, contains('VALUE "ProductName", "LiterasiAI"'));
      expect(rc, contains('VALUE "FileDescription", "LiterasiAI"'));
      expect(rc, contains('VALUE "CompanyName", "LiterasiAI"'));
      expect(rc, isNot(contains('"com.example"')));
      // Nama exe tidak diubah: build output tetap literasi_ai.exe.
      expect(rc, contains('VALUE "OriginalFilename", "literasi_ai.exe"'));
    });

    test('Linux memakai judul jendela LiterasiAI', () {
      final linux = File('linux/runner/my_application.cc').readAsStringSync();
      expect(
        linux,
        contains('gtk_header_bar_set_title(header_bar, "LiterasiAI")'),
      );
      expect(linux, contains('gtk_window_set_title(window, "LiterasiAI")'));
      expect(linux, isNot(contains('"literasi_ai"')));
    });

    test('app_icon.ico memuat frame PNG untuk semua ukuran Windows', () {
      final bytes = File(
        'windows/runner/resources/app_icon.ico',
      ).readAsBytesSync();
      final data = ByteData.sublistView(bytes);

      expect(data.getUint16(0, Endian.little), 0, reason: 'reserved');
      expect(data.getUint16(2, Endian.little), 1, reason: 'tipe icon');
      final count = data.getUint16(4, Endian.little);
      expect(count, 7);

      final sizes = <int>[];
      for (var i = 0; i < count; i++) {
        final entry = 6 + i * 16;
        sizes.add(bytes[entry] == 0 ? 256 : bytes[entry]);
      }
      expect(sizes, [16, 24, 32, 48, 64, 128, 256]);

      for (var i = 0; i < count; i++) {
        final entry = 6 + i * 16;
        final length = data.getUint32(entry + 8, Endian.little);
        final offset = data.getUint32(entry + 12, Endian.little);
        expect(offset + length, lessThanOrEqualTo(bytes.length));
        expect(bytes[offset], 0x89, reason: 'frame $i bukan PNG');
        expect(
          String.fromCharCodes(bytes.sublist(offset + 1, offset + 4)),
          'PNG',
          reason: 'frame $i bukan PNG',
        );
        // Dimensi PNG harus sama dengan entri direktori.
        final frame = ByteData.sublistView(bytes.sublist(offset));
        expect(frame.getUint32(16), sizes[i], reason: 'lebar frame $i');
        expect(frame.getUint32(20), sizes[i], reason: 'tinggi frame $i');
      }
    });

    test('web memakai judul, manifest, dan ikon brand', () {
      final html = File('web/index.html').readAsStringSync();
      expect(html, contains('<title>LiterasiAI</title>'));
      expect(html, contains('content="LiterasiAI"'));
      expect(html, isNot(contains('literasi_ai')));
      expect(html, isNot(contains('A new Flutter project.')));
      expect(html, contains('content="#1A73E8"'));

      final manifest =
          jsonDecode(File('web/manifest.json').readAsStringSync())
              as Map<String, dynamic>;
      expect(manifest['name'], 'LiterasiAI');
      expect(manifest['short_name'], 'LiterasiAI');
      expect(manifest['background_color'], '#1A73E8');
      expect(manifest['theme_color'], '#1A73E8');
      expect(manifest['description'], isNot(contains('Flutter')));

      final icons = (manifest['icons'] as List).cast<Map<String, dynamic>>();
      expect(
        icons.map((icon) => icon['src']),
        containsAll([
          'icons/Icon-192.png',
          'icons/Icon-512.png',
          'icons/Icon-maskable-192.png',
          'icons/Icon-maskable-512.png',
        ]),
      );
      expect(
        icons.where((icon) => icon['purpose'] == 'maskable'),
        hasLength(2),
      );

      for (final icon in icons) {
        final src = icon['src'] as String;
        final expected = int.parse((icon['sizes'] as String).split('x').first);
        final header = _readPngHeader('web/$src');
        expect(header.width, expected, reason: src);
        expect(header.height, expected, reason: src);
        expect(
          header.colorType,
          isNot(anyOf(4, 6)),
          reason: '$src butuh opaque',
        );
      }

      final favicon = _readPngHeader('web/favicon.png');
      expect(favicon.width, 32);
      expect(favicon.height, 32);
    });

    test('ikon macOS mengikuti grid squircle Big Sur', () {
      final appInfo = File('macos/Runner/Info.plist').readAsStringSync();
      expect(appInfo, contains('<key>CFBundleDisplayName</key>'));
      expect(appInfo, contains('<string>LiterasiAI</string>'));

      final catalog =
          jsonDecode(
                File(
                  'macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final images = (catalog['images'] as List).cast<Map<String, dynamic>>();

      final expected = <String, int>{};
      for (final image in images) {
        final filename = image['filename'] as String;
        final size = double.parse((image['size'] as String).split('x').first);
        final scale = double.parse(
          (image['scale'] as String).replaceAll('x', ''),
        );
        expected[filename] = (size * scale).round();
      }
      // Setiap berkas yang direferensikan harus ada dan bersudut transparan.
      for (final entry in expected.entries) {
        final header = _readPngHeader(
          'macos/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
        );
        expect(header.width, entry.value, reason: entry.key);
        expect(header.height, entry.value, reason: entry.key);
        expect(header.colorType, 6, reason: '${entry.key} butuh alpha');
      }
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

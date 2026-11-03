import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/share_target_payload.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/share_target_launch.dart';

void main() {
  test('payload text URL memilih mode link dan menghapus tanda baca akhir', () {
    const url = 'https://contoh.id/berita-penting-akhir';
    final launch = ShareTargetLaunch.fromPayload(
      const ShareTargetPayload(id: 1, text: 'Cek ini $url.'),
    );

    expect(launch.mode, QuickCheckInitialMode.url);
    expect(launch.initialUrl, url);
    expect(launch.errorMessage, isNull);
  });

  test('payload teks tanpa URL tetap memilih mode teks', () {
    const text = 'Vaksin menyebabkan autisme menurut pesan berantai.';
    final launch = ShareTargetLaunch.fromPayload(
      const ShareTargetPayload(id: 2, text: text),
    );

    expect(launch.mode, QuickCheckInitialMode.text);
    expect(launch.initialClaim, text);
    expect(launch.errorMessage, isNull);
  });

  test('payload gambar valid memilih lampiran gambar', () {
    final launch = ShareTargetLaunch.fromPayload(
      ShareTargetPayload(
        id: 3,
        imageBytes: Uint8List.fromList([1, 2, 3, 4]),
        fileName: 'screenshot.png',
        mimeType: 'image/png',
      ),
    );

    expect(launch.mode, QuickCheckInitialMode.image);
    expect(launch.image, isNotNull);
    expect(launch.image!.fileName, 'screenshot.png');
    expect(launch.image!.mimeType, 'image/png');
    expect(launch.errorMessage, isNull);
  });

  test('payload gambar format tidak didukung gagal jujur', () {
    final launch = ShareTargetLaunch.fromPayload(
      ShareTargetPayload(
        id: 4,
        imageBytes: Uint8List.fromList([1]),
        fileName: 'animasi.gif',
        mimeType: 'image/gif',
      ),
    );

    expect(launch.image, isNull);
    expect(launch.errorMessage, AppStrings.shareTargetInvalidImage);
  });

  test('error too_large memetakan pesan yang benar', () {
    final launch = ShareTargetLaunch.fromPayload(
      const ShareTargetPayload(id: 6, errorCode: 'too_large'),
    );

    expect(launch.errorMessage, AppStrings.shareTargetTooLarge);
  });

  test('payload kosong ditolak dengan pesan yang jelas', () {
    final launch = ShareTargetLaunch.fromPayload(
      const ShareTargetPayload(id: 5),
    );

    expect(launch.errorMessage, AppStrings.shareTargetEmpty);
  });
}

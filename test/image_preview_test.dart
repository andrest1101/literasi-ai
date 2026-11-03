import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/core/utils/attachment_share_service.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/image_attachment.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/image_preview_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_image_section.dart';
import 'package:share_plus/share_plus.dart';

final Uint8List _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8'
  '/x8AAwMCAO+/p9sAAAAASUVORK5CYII=',
);

ImageAttachment _attachment() => ImageAttachment(
  bytes: _pngBytes,
  mimeType: 'image/png',
  fileName: 'screenshot.png',
);

void main() {
  group('AttachmentShareService', () {
    test('mengirim bytes gambar asli dengan MIME type yang benar', () async {
      ShareParams? captured;
      final service = AttachmentShareService(
        shareFn: (params) async {
          captured = params;
          return const ShareResult('', ShareResultStatus.success);
        },
      );

      await service.shareAttachment(
        bytes: _pngBytes,
        fileName: 'screenshot.png',
        mimeType: 'image/png',
      );

      expect(captured, isNotNull);
      expect(captured!.files, isNotNull);
      expect(captured!.files, hasLength(1));
      expect(captured!.files!.first.name, 'screenshot.png');
      expect(captured!.files!.first.mimeType, 'image/png');
    });

    test('menolak bytes kosong sebelum share dipanggil', () async {
      var calls = 0;
      final service = AttachmentShareService(
        shareFn: (_) async {
          calls++;
          return const ShareResult('', ShareResultStatus.success);
        },
      );

      expect(
        () => service.shareAttachment(
          bytes: Uint8List(0),
          fileName: 'kosong.png',
          mimeType: 'image/png',
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  });

  group('ImagePreviewScreen', () {
    testWidgets('kontrol zoom, rotasi, dan reset tidak crash', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ImagePreviewScreen(
            image: _attachment(),
            shareService: AttachmentShareService(
              shareFn: (_) async =>
                  const ShareResult('', ShareResultStatus.success),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final tooltip in [
        AppStrings.imagePreviewZoomIn,
        AppStrings.imagePreviewZoomIn,
        AppStrings.imagePreviewRotate,
        AppStrings.imagePreviewZoomOut,
        AppStrings.imagePreviewZoomReset,
      ]) {
        await tester.tap(find.byTooltip(tooltip).last);
        await tester.pumpAndSettle();
      }

      expect(find.byType(ImagePreviewScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('share memanggil share sheet dengan gambar asli', (
      tester,
    ) async {
      ShareParams? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: ImagePreviewScreen(
            image: _attachment(),
            shareService: AttachmentShareService(
              shareFn: (params) async {
                captured = params;
                return const ShareResult('', ShareResultStatus.success);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(AppStrings.imagePreviewShare));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.files!.first.name, 'screenshot.png');
      expect(captured!.files!.first.mimeType, 'image/png');
      expect(tester.takeException(), isNull);
    });

    testWidgets('share gagal menampilkan snackbar, bukan crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImagePreviewScreen(
            image: _attachment(),
            shareService: AttachmentShareService(
              shareFn: (_) async => throw Exception('share unsupported'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(AppStrings.imagePreviewShare));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.imageShareFailed), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('preview gambar membuka dan menutup layar detail', (
    tester,
  ) async {
    final captionController = TextEditingController();
    addTearDown(captionController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickCheckImageSection(
              image: _attachment(),
              captionController: captionController,
              captionError: null,
              loading: false,
              onPick: (_) {},
              onRemove: () {},
              onVerify: () {},
              onClearCaption: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImagePreviewScreen), findsNothing);

    await tester.tap(find.byTooltip(AppStrings.imagePreviewOpen).first);
    await tester.pumpAndSettle();

    expect(find.byType(ImagePreviewScreen), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.imagePreviewClose));
    await tester.pumpAndSettle();

    expect(find.byType(ImagePreviewScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

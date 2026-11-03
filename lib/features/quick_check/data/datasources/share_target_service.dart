import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import '../../domain/entities/share_target_payload.dart';

/// Jembatan Android Share Target <> Flutter.
///
/// Native hanya menangani baca Intent/MIME/URI; parsing dan routing tetap
/// berada di Dart agar mudah diuji. Di luar Android, service ini no-op.
class ShareTargetService {
  ShareTargetService({MethodChannel? channel, EventChannel? eventChannel})
    : _channel = channel ?? const MethodChannel(ShareTargetService.channelName),
      _events =
          eventChannel ??
          const EventChannel(ShareTargetService.eventChannelName);

  static const String channelName = 'literasi_ai/share_target';
  static const String eventChannelName = 'literasi_ai/share_target/events';

  final MethodChannel _channel;
  final EventChannel _events;

  /// Ambil share payload saat cold start, lalu hapus dari native.
  Future<ShareTargetPayload?> fetchInitialShare() async {
    if (!Platform.isAndroid) return null;

    try {
      final map = await _channel.invokeMethod<Map<Object?, Object?>>(
        'fetchInitialShare',
      );
      if (map == null) return null;
      return ShareTargetPayload.fromMap(map);
    } on PlatformException catch (error) {
      return ShareTargetPayload(
        id: DateTime.now().millisecondsSinceEpoch,
        errorCode: error.code,
      );
    } on MissingPluginException {
      return null;
    }
  }

  /// Arus share yang masuk ketika app sudah berjalan (`onNewIntent`).
  Stream<ShareTargetPayload> watchShareTargets() {
    if (!Platform.isAndroid) return const Stream<ShareTargetPayload>.empty();
    return _events.receiveBroadcastStream().map(
      (value) => ShareTargetPayload.fromMap(
        Map<Object?, Object?>.from(value as Map<dynamic, dynamic>),
      ),
    );
  }
}

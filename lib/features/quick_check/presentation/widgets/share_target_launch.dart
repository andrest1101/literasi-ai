import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/image_attachment.dart';
import '../../domain/entities/share_target_payload.dart';
import '../../domain/usecases/verify_url_claim.dart';
import '../screens/quick_check_session_screen.dart';

/// Hasil normalisasi payload Share Target menjadi parameter session.
class ShareTargetLaunch {
  const ShareTargetLaunch({
    required this.mode,
    this.initialClaim,
    this.initialUrl,
    this.image,
    this.errorMessage,
  });

  final QuickCheckInitialMode mode;
  final String? initialClaim;
  final String? initialUrl;
  final ImageAttachment? image;
  final String? errorMessage;

  factory ShareTargetLaunch.fromPayload(ShareTargetPayload payload) {
    if (payload.errorCode != null) {
      return ShareTargetLaunch(
        mode: QuickCheckInitialMode.text,
        errorMessage: _messageFor(payload.errorCode!),
      );
    }

    if (payload.isImage) {
      final attachment = ImageAttachment(
        bytes: payload.imageBytes!,
        mimeType: payload.mimeType ?? 'image/jpeg',
        // Native sudah sanitasi; jaga lagi agar tidak ada path absolut.
        fileName: _safeFileName(payload.fileName),
      );

      if (!attachment.isValid) {
        return const ShareTargetLaunch(
          mode: QuickCheckInitialMode.image,
          errorMessage: AppStrings.shareTargetInvalidImage,
        );
      }

      return ShareTargetLaunch(
        mode: QuickCheckInitialMode.image,
        image: attachment,
      );
    }

    final text = payload.text?.trim() ?? '';
    if (text.isEmpty) {
      return const ShareTargetLaunch(
        mode: QuickCheckInitialMode.text,
        errorMessage: AppStrings.shareTargetEmpty,
      );
    }

    final url = _extractHttpUrl(text);
    if (url != null) {
      return ShareTargetLaunch(
        mode: QuickCheckInitialMode.url,
        initialUrl: url,
      );
    }

    return ShareTargetLaunch(
      mode: QuickCheckInitialMode.text,
      initialClaim: text,
    );
  }

  static String? _extractHttpUrl(String text) {
    final whole = VerifyUrlClaim.normalize(text);
    if (VerifyUrlClaim.isParsable(whole)) {
      return whole;
    }

    final match = _urlPattern.firstMatch(text);
    if (match == null) return null;

    var candidate = match.group(0) ?? '';
    // URL sebelum tanda baca akhir (\"https://contoh.com.\") sering membawa
    // titik/kurung dari teks di luar link.
    candidate = candidate.replaceAll(RegExp(r'[)\],;.!?"]+$'), '');
    if (!VerifyUrlClaim.isParsable(candidate)) return null;
    return candidate;
  }

  static final RegExp _urlPattern = RegExp(
    r'https?:\/\/[^\s]+',
    caseSensitive: false,
  );

  static String _safeFileName(String? value) {
    final name = (value ?? 'gambar-dibagikan').trim();
    return name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'[\u0000-\u001f]'), '_')
        .replaceFirst(RegExp(r'^\.+'), '');
  }

  static String _messageFor(String code) {
    return switch (code) {
      'unsupported_type' => AppStrings.shareTargetUnsupported,
      'too_large' => AppStrings.shareTargetTooLarge,
      'unreadable' => AppStrings.shareTargetInvalidImage,
      'empty' => AppStrings.shareTargetEmpty,
      _ => AppStrings.shareTargetInvalid,
    };
  }
}

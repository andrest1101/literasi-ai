import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/gemini_text_datasource.dart';
import '../../data/datasources/gemini_vision_datasource.dart';
import '../../data/datasources/image_picker_datasource.dart';
import '../../data/repositories/verification_repository_impl.dart';
import '../../domain/entities/image_attachment.dart';
import '../../domain/entities/verification_result.dart';
import '../../domain/repositories/image_picker_service.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../domain/usecases/verify_claim.dart';
import '../../domain/usecases/verify_image_claim.dart';

/// Dependensi Quick Check — dapat di-override di test dengan fake.
final geminiTextDatasourceProvider = Provider<GeminiTextDatasource>((ref) {
  return GeminiTextDatasource();
});

final geminiVisionDatasourceProvider = Provider<GeminiVisionDatasource>((ref) {
  return GeminiVisionDatasource();
});

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerDatasource();
});

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepositoryImpl(
    ref.watch(geminiTextDatasourceProvider),
    visionDatasource: ref.watch(geminiVisionDatasourceProvider),
  );
});

final verifyClaimProvider = Provider<VerifyClaim>((ref) {
  return VerifyClaim(ref.watch(verificationRepositoryProvider));
});

final verifyImageClaimProvider = Provider<VerifyImageClaim>((ref) {
  return VerifyImageClaim(ref.watch(verificationRepositoryProvider));
});

/// State verifikasi klaim teks.
///
/// `null` berarti belum ada hasil (idle). Loading, data, dan error memakai
/// [AsyncValue] standar Riverpod agar UI tidak perlu state custom.
final quickCheckControllerProvider =
    AsyncNotifierProvider<QuickCheckController, VerificationResult?>(
      QuickCheckController.new,
    );

class QuickCheckController extends AsyncNotifier<VerificationResult?> {
  String? _lastClaim;
  ImageAttachment? _lastImage;
  String _lastCaption = '';

  String? get lastClaim => _lastClaim;

  bool get isVerifying => state.isLoading;

  @override
  FutureOr<VerificationResult?> build() => null;

  Future<void> verify(String rawClaim) async {
    if (state.isLoading) return;
    _lastClaim = rawClaim;
    _lastImage = null;
    _lastCaption = '';
    state = const AsyncLoading();
    try {
      final result = await ref.read(verifyClaimProvider).call(rawClaim);
      _lastClaim = result.claim;
      state = AsyncData(result);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> verifyImage({
    required ImageAttachment image,
    String caption = '',
  }) async {
    if (state.isLoading) return;
    _lastImage = image;
    _lastCaption = caption;
    _lastClaim = caption.isEmpty ? 'Gambar: ${image.fileName}' : caption;
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(verifyImageClaimProvider)
          .call(image: image, caption: caption);
      _lastClaim = result.claim;
      state = AsyncData(result);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> retry() async {
    if (state.isLoading) return;
    final image = _lastImage;
    if (image != null) {
      await verifyImage(image: image, caption: _lastCaption);
      return;
    }
    final claim = _lastClaim;
    if (claim == null) return;
    await verify(claim);
  }

  void reset() {
    _lastClaim = null;
    _lastImage = null;
    _lastCaption = '';
    state = const AsyncData(null);
  }
}

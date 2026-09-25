import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/api_key_resolver.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../../../score/presentation/providers/score_providers.dart';
import '../../data/datasources/demo_verification_datasource.dart';
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
import '../../domain/usecases/verify_url_claim.dart';

/// Dependensi Quick Check: dapat di-override di test dengan fake.
///
/// Kunci API mengikuti prioritas resolver: dart-define (compile) menang atas
/// kunci user dari secure storage.
final geminiTextDatasourceProvider = Provider<GeminiTextDatasource>((ref) {
  final status = ref.watch(apiKeyStatusProvider).valueOrNull;
  return GeminiTextDatasource(apiKey: status?.key ?? '');
});

final geminiVisionDatasourceProvider = Provider<GeminiVisionDatasource>((ref) {
  final status = ref.watch(apiKeyStatusProvider).valueOrNull;
  return GeminiVisionDatasource(apiKey: status?.key ?? '');
});

final demoVerificationDatasourceProvider =
    Provider<DemoVerificationDatasource>((ref) {
      return DemoVerificationDatasource();
    });

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerDatasource();
});

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  // Baca status live setiap request via closure (bukan snapshot sekali),
  // agar kunci user yang baru disimpan langsung aktif tanpa restart app.
  String resolveKey() =>
      ref.read(apiKeyStatusProvider).valueOrNull?.key ?? '';
  bool hasKey() =>
      ref.read(apiKeyStatusProvider).valueOrNull?.configured ?? false;
  return VerificationRepositoryImpl(
    ref.watch(geminiTextDatasourceProvider),
    visionDatasource: ref.watch(geminiVisionDatasourceProvider),
    resolveApiKey: resolveKey,
    hasApiKey: hasKey,
  );
});

final verifyClaimProvider = Provider<VerifyClaim>((ref) {
  return VerifyClaim(ref.watch(verificationRepositoryProvider));
});

final verifyImageClaimProvider = Provider<VerifyImageClaim>((ref) {
  return VerifyImageClaim(ref.watch(verificationRepositoryProvider));
});

final verifyUrlClaimProvider = Provider<VerifyUrlClaim>((ref) {
  return VerifyUrlClaim(ref.watch(verificationRepositoryProvider));
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
  String? _lastUrl;

  String? get lastClaim => _lastClaim;

  bool get isVerifying => state.isLoading;

  @override
  FutureOr<VerificationResult?> build() => null;

  /// Durasi verify terakhir: ditampilkan di kartu hasil sebagai bukti
  /// klaim <5 detik PRD §2.1. Null bila belum ada hasil.
  Duration? _lastDuration;

  Duration? get lastDuration => _lastDuration;

  Future<void> verify(String rawClaim) async {
    if (state.isLoading) return;
    _lastClaim = rawClaim;
    _lastImage = null;
    _lastCaption = '';
    _lastUrl = null;
    state = const AsyncLoading();
    final stopwatch = Stopwatch()..start();
    try {
      final result = await ref.read(verifyClaimProvider).call(rawClaim);
      _lastClaim = result.claim;
      _lastDuration = stopwatch.elapsed;
      debugPrint('QuickCheck teks selesai dalam $_lastDuration.');
      state = AsyncData(result);
      _saveHistory(result);
    } catch (error, stackTrace) {
      _lastDuration = stopwatch.elapsed;
      state = AsyncError(error, stackTrace);
    } finally {
      stopwatch.stop();
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
    _lastUrl = null;
    state = const AsyncLoading();
    final stopwatch = Stopwatch()..start();
    try {
      final result = await ref
          .read(verifyImageClaimProvider)
          .call(image: image, caption: caption);
      _lastClaim = result.claim;
      _lastDuration = stopwatch.elapsed;
      debugPrint('QuickCheck gambar selesai dalam $_lastDuration.');
      state = AsyncData(result);
      _saveHistory(result);
    } catch (error, stackTrace) {
      _lastDuration = stopwatch.elapsed;
      state = AsyncError(error, stackTrace);
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> verifyUrl(String rawUrl) async {
    if (state.isLoading) return;
    _lastUrl = rawUrl;
    _lastImage = null;
    _lastCaption = '';
    _lastClaim = rawUrl;
    state = const AsyncLoading();
    final stopwatch = Stopwatch()..start();
    try {
      final result = await ref.read(verifyUrlClaimProvider).call(rawUrl);
      _lastClaim = result.claim;
      _lastUrl = result.sourceUrl ?? rawUrl;
      _lastDuration = stopwatch.elapsed;
      debugPrint('QuickCheck link selesai dalam $_lastDuration.');
      state = AsyncData(result);
      _saveHistory(result);
    } catch (error, stackTrace) {
      _lastDuration = stopwatch.elapsed;
      state = AsyncError(error, stackTrace);
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> retry() async {
    if (state.isLoading) return;
    final image = _lastImage;
    if (image != null) {
      await verifyImage(image: image, caption: _lastCaption);
      return;
    }
    final url = _lastUrl;
    if (url != null) {
      await verifyUrl(url);
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
    _lastUrl = null;
    _lastDuration = null;
    state = const AsyncData(null);
  }

  /// Penyimpanan tidak boleh menahan hasil AI yang sudah selesai tampil.
  /// Jika Firestore sedang offline atau rules menolak, riwayat dapat dicoba
  /// lagi pada pemeriksaan berikutnya tanpa mengubah state hasil verifikasi.
  /// UID dibaca via provider agar widget test bisa override tanpa Firebase.
  /// Skor +10 diberikan best-effort bersamaan dengan auto-save riwayat.
  void _saveHistory(VerificationResult result) {
    String? userId;
    try {
      userId = ref.read(historyUserIdProvider);
    } catch (_) {
      // Firebase sengaja boleh tidak aktif pada mode offline dan widget test.
      return;
    }
    if (userId == null) return;
    unawaited(
      ref
          .read(saveHistoryProvider)(userId: userId, result: result)
          .catchError((Object error, StackTrace stackTrace) {
            debugPrint('Gagal menyimpan riwayat: $error');
          }),
    );
    unawaited(
      ref
          .read(awardVerificationProvider)(userId)
          .catchError((Object error, StackTrace stackTrace) {
            debugPrint('Gagal menambah skor: $error');
          }),
    );
  }
}

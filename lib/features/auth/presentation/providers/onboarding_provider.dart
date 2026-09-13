import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/onboarding_local_datasource.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// Dependensi onboarding — dapat di-override di test dengan fake.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final onboardingRepositoryProvider = FutureProvider<OnboardingRepository>((
  ref,
) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return OnboardingRepositoryImpl(OnboardingLocalDatasource(prefs));
});

/// Status onboarding sekali-per-install.
///
/// `false` berarti onboarding belum selesai. Error penyimpanan diperlakukan
/// sebagai belum selesai agar user baru tidak melewatkan onboarding.
final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    try {
      final repository = await ref.watch(onboardingRepositoryProvider.future);
      return repository.isCompleted();
    } catch (_) {
      return false;
    }
  }

  Future<void> complete() async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(onboardingRepositoryProvider.future);
      await repository.markCompleted();
      state = const AsyncData(true);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

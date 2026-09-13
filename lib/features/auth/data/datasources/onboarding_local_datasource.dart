import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan lokal flag onboarding sekali-per-install.
///
/// Kunci berversi agar perilaku dapat diubah di rilis berikutnya tanpa
/// bentrok dengan flag lama.
class OnboardingLocalDatasource {
  OnboardingLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  static const String completedKey = 'onboarding_completed_v1';

  bool isCompleted() => _prefs.getBool(completedKey) ?? false;

  Future<void> markCompleted() async {
    await _prefs.setBool(completedKey, true);
  }
}

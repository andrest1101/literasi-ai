/// Kontrak status onboarding sekali-per-install.
///
/// Diimplementasikan di data layer memakai penyimpanan lokal. Nilai default
/// yang aman adalah belum selesai agar user baru tetap melihat onboarding.
abstract class OnboardingRepository {
  Future<bool> isCompleted();

  Future<void> markCompleted();
}

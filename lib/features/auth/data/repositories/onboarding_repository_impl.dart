import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

/// Implementasi repository onboarding dari penyimpanan lokal.
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._datasource);

  final OnboardingLocalDatasource _datasource;

  @override
  Future<bool> isCompleted() async => _datasource.isCompleted();

  @override
  Future<void> markCompleted() => _datasource.markCompleted();
}

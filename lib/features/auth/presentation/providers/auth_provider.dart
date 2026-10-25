import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(FirebaseAuthDatasource());
});

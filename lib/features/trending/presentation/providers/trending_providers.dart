import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/trending_local_datasource.dart';
import '../../data/repositories/trending_repository_impl.dart';
import '../../domain/entities/trending_item.dart';
import '../../domain/repositories/trending_repository.dart';

final trendingDatasourceProvider = Provider<TrendingLocalDatasource>((ref) {
  return TrendingLocalDatasource();
});

final trendingRepositoryProvider = Provider<TrendingRepository>((ref) {
  return TrendingRepositoryImpl(ref.watch(trendingDatasourceProvider));
});

/// Feed trending — sync lokal, tanpa loading/error state.
/// Guest offline tetap melihat feed penuh tanpa login maupun API key.
final trendingItemsProvider = Provider<List<TrendingItem>>((ref) {
  return ref.watch(trendingRepositoryProvider).items();
});

final trendingHotProvider = Provider<List<TrendingItem>>((ref) {
  return ref.watch(trendingRepositoryProvider).hotItems();
});

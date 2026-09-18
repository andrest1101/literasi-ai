import '../../domain/entities/trending_item.dart';
import '../../domain/repositories/trending_repository.dart';
import '../datasources/trending_local_datasource.dart';

class TrendingRepositoryImpl implements TrendingRepository {
  TrendingRepositoryImpl(this._datasource);

  final TrendingLocalDatasource _datasource;

  @override
  List<TrendingItem> items() => _datasource.items();

  @override
  TrendingItem? itemById(String id) {
    for (final item in _datasource.items()) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  List<TrendingItem> hotItems() =>
      _datasource.items().where((item) => item.isHot).toList(growable: false);
}

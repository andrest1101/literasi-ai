import '../entities/trending_item.dart';

/// Kontrak feed trending — sync lokal fase ini, remote menyusul.
abstract class TrendingRepository {
  List<TrendingItem> items();

  TrendingItem? itemById(String id);

  List<TrendingItem> hotItems();
}

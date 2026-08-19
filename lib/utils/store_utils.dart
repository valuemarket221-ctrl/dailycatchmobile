import 'package:myapp/models/store_model.dart';

/// Utilitaires métier pour les stores
class StoreUtils {
  // ── Filtrage ─────────────────────────────────────
  static List<Store> filterByCategory(
    List<Store> stores,
    String category,
  ) {
    if (category == 'Tous') {
      return stores;
    }

    return stores.where((store) {
      final categoryMatch = store.category
          .toLowerCase()
          .contains(category.toLowerCase());
      final typeMatch = store.productTypes.any(
        (type) => type.toLowerCase().contains(category.toLowerCase()),
      );
      return categoryMatch || typeMatch;
    }).toList();
  }

  // ── Tri ──────────────────────────────────────────
  static List<Store> sortByDistance(List<Store> stores) {
    final List<Store> sorted = List.from(stores);
    sorted.sort((a, b) {
      final distA = _extractNumericValue(a.distance);
      final distB = _extractNumericValue(b.distance);
      return distA.compareTo(distB);
    });
    return sorted;
  }

  static List<Store> sortByDiscount(List<Store> stores) {
    final List<Store> sorted = List.from(stores);
    sorted.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
    return sorted;
  }

  static List<Store> sortByRating(List<Store> stores) {
    final List<Store> sorted = List.from(stores);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted;
  }

  // ── Helpers ──────────────────────────────────────
  static double _extractNumericValue(String distance) {
    try {
      final numeric = distance.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(numeric);
    } catch (e) {
      return 0;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:myapp/models/store_model.dart';
import 'package:myapp/utils/store_utils.dart';

/// Provider pour gérer les stores
class StoreProvider with ChangeNotifier {
  List<Store> _stores = [];
  List<Store> _filteredStores = [];
  String _selectedCategory = 'Tous';
  String _sortBy = 'distance'; // distance, discount, rating
  final bool _isLoading = false;
  String? _error;

  // ── Getters ──────────────────────────────────────
  List<Store> get stores => _stores;
  List<Store> get filteredStores => _filteredStores;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Init ──────────────────────────────────────────
  void initializeStores(List<Store> stores) {
    _stores = stores;
    _applyFilters();
    notifyListeners();
  }

  // ── Filter & Sort ────────────────────────────────
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _applyFilters();
      notifyListeners();
    }
  }

  void setSortBy(String sortType) {
    if (_sortBy != sortType) {
      _sortBy = sortType;
      _applySort();
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredStores = StoreUtils.filterByCategory(_stores, _selectedCategory);
    _applySort();
  }

  void _applySort() {
    switch (_sortBy) {
      case 'distance':
        _filteredStores = StoreUtils.sortByDistance(_filteredStores);
        break;
      case 'discount':
        _filteredStores = StoreUtils.sortByDiscount(_filteredStores);
        break;
      case 'rating':
        _filteredStores = StoreUtils.sortByRating(_filteredStores);
        break;
    }
  }

  // ── Favorites ────────────────────────────────────
  void toggleFavorite(String storeId) {
    final index = _stores.indexWhere((s) => s.id == storeId);
    if (index != -1) {
      _stores[index] = _stores[index].copyWith(
        isFavorite: !_stores[index].isFavorite,
      );
      _applyFilters();
      notifyListeners();
    }
  }

  List<Store> get favorites => _stores.where((s) => s.isFavorite).toList();

  // ── Search ───────────────────────────────────────
  void search(String query) {
    if (query.isEmpty) {
      _applyFilters();
    } else {
      final queryLower = query.toLowerCase();
      _filteredStores = _stores
          .where((store) =>
              store.name.toLowerCase().contains(queryLower) ||
              store.category.toLowerCase().contains(queryLower) ||
              store.productTypes
                  .any((p) => p.toLowerCase().contains(queryLower)))
          .toList();
    }
    notifyListeners();
  }

  // ── Error Handling ───────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

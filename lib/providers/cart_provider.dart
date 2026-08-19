import 'package:flutter/foundation.dart';

/// Modèle de produit pour le panier
class CartItem {
  final String id;
  final String name;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final String storeName;
  final String storeId;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.storeName,
    required this.storeId,
    required this.image,
    this.quantity = 1,
  });

  double get totalPrice => discountedPrice * quantity;
  double get savings => (originalPrice - discountedPrice) * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'storeName': storeName,
      'storeId': storeId,
      'image': image,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      originalPrice: (map['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (map['discountedPrice'] ?? 0).toDouble(),
      storeName: map['storeName'] ?? map['store'] ?? 'Boutique',
      storeId: map['storeId'] ?? '',
      image: map['image'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }
}

/// Provider pour gérer le panier de manière globale
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get totalSavings => _items.fold(0, (sum, item) => sum + item.savings);

  bool get isEmpty => _items.isEmpty;

  /// Ajouter un produit au panier
  void addItem(
    Map<String, dynamic> product,
    String storeId, {
    String storeName = 'Boutique',
    int quantity = 1,
  }) {
    final productId = product['id']?.toString() ?? '';
    if (productId.isEmpty) {
      debugPrint('CartProvider: product rejected because id is missing');
      return;
    }
    final resolvedStoreId = product['storeId']?.toString() ?? storeId;
    final resolvedStoreName =
        product['storeName']?.toString() ??
        product['store']?.toString() ??
        storeName;

    final existingIndex = _items.indexWhere(
      (item) =>
          item.id == productId &&
          item.storeId == resolvedStoreId &&
          item.discountedPrice == product['discountedPrice'],
    );

    if (existingIndex >= 0) {
      // Produit déjà dans le panier, augmenter la quantité
      _items[existingIndex].quantity += quantity;
    } else {
      // Nouveau produit
      _items.add(
        CartItem(
          id: productId,
          name: product['name'] ?? '',
          description: product['description'] ?? '',
          originalPrice: (product['originalPrice'] ?? 0).toDouble(),
          discountedPrice: (product['discountedPrice'] ?? 0).toDouble(),
          storeName: resolvedStoreName,
          storeId: resolvedStoreId,
          image: product['image'] ?? '',
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
  }

  /// Ajouter un CartItem directement
  void addCartItem(CartItem item) {
    final existingIndex = _items.indexWhere(
      (existing) =>
          existing.name == item.name &&
          existing.storeId == item.storeId &&
          existing.discountedPrice == item.discountedPrice,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  /// Modifier la quantité d'un produit
  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
    } else {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  /// Supprimer un produit du panier
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Supprimer un produit par ID
  void removeItemById(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  /// Vider le panier
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Vérifier si un produit est déjà dans le panier
  bool isInCart(String productName, String storeId) {
    return _items.any(
      (item) => item.name == productName && item.storeId == storeId,
    );
  }
}

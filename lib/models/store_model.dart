/// Modèle Store avec logique métier
class Store {
  final String id;
  final String name;
  final String category;
  final String distance;
  final double originalPrice;
  final double discountedPrice;
  final String timeRemaining;
  final int productsLeft;
  final String image;
  final String banner;
  final double rating;
  final int totalProducts;
  final List<String> productTypes;
  final DateTime? createdAt;
  final bool isFavorite;

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.originalPrice,
    required this.discountedPrice,
    required this.timeRemaining,
    required this.productsLeft,
    required this.image,
    required this.banner,
    required this.rating,
    required this.totalProducts,
    required this.productTypes,
    this.createdAt,
    this.isFavorite = false,
  });

  // ── Computed Properties ──────────────────────────
  int get discountPercentage {
    if (originalPrice <= 0 || originalPrice <= discountedPrice) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100).round();
  }

  bool get hasLowStock => productsLeft <= 2;

  bool get isSoldOut => productsLeft == 0;

  bool get isClosed => timeRemaining.toLowerCase().contains('fermé');

  bool get isSoon => timeRemaining.toLowerCase().contains('bientôt');

  bool get canReserve => !isSoldOut && !isClosed && !isSoon;

  double get ratingClipped => rating.clamp(0, 5);

  // ── Factory Methods ──────────────────────────────
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      distance: json['distance'] ?? '0 km',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      timeRemaining: json['timeRemaining'] ?? '',
      productsLeft: json['productsLeft'] ?? 0,
      image: json['image'] ?? '',
      banner: json['banner'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalProducts: json['totalProducts'] ?? 0,
      productTypes: List<String>.from(json['productTypes'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'distance': distance,
    'originalPrice': originalPrice,
    'discountedPrice': discountedPrice,
    'timeRemaining': timeRemaining,
    'productsLeft': productsLeft,
    'image': image,
    'banner': banner,
    'rating': rating,
    'totalProducts': totalProducts,
    'productTypes': productTypes,
    'isFavorite': isFavorite,
  };

  Store copyWith({
    String? id,
    String? name,
    String? category,
    String? distance,
    double? originalPrice,
    double? discountedPrice,
    String? timeRemaining,
    int? productsLeft,
    String? image,
    String? banner,
    double? rating,
    int? totalProducts,
    List<String>? productTypes,
    bool? isFavorite,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      distance: distance ?? this.distance,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      productsLeft: productsLeft ?? this.productsLeft,
      image: image ?? this.image,
      banner: banner ?? this.banner,
      rating: rating ?? this.rating,
      totalProducts: totalProducts ?? this.totalProducts,
      productTypes: productTypes ?? this.productTypes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() => 'Store(id: $id, name: $name, category: $category)';
}

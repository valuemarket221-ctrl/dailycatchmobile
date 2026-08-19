/// Modèle de produit pour les partenaires
class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String category;
  final double originalPrice;
  final double discountedPrice;
  final String image;
  final int availableQuantity;
  final int totalQuantity;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final bool isActive;
  final List<String> allergens;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.category,
    required this.originalPrice,
    required this.discountedPrice,
    required this.image,
    required this.availableQuantity,
    required this.totalQuantity,
    required this.createdAt,
    this.expiryDate,
    this.isActive = true,
    this.allergens = const [],
  });

  // ── Computed Properties ──────────────────────────
  int get discountPercentage {
    if (originalPrice == 0) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100).round();
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    return daysLeft <= 2 && daysLeft > 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isLowStock => availableQuantity <= 3;

  bool get isSoldOut => availableQuantity == 0;

  // ── Factory Methods ──────────────────────────────
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      availableQuantity: json['availableQuantity'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      isActive: json['isActive'] ?? true,
      allergens: List<String>.from(json['allergens'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeId': storeId,
        'name': name,
        'description': description,
        'category': category,
        'originalPrice': originalPrice,
        'discountedPrice': discountedPrice,
        'image': image,
        'availableQuantity': availableQuantity,
        'totalQuantity': totalQuantity,
        'createdAt': createdAt.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'isActive': isActive,
        'allergens': allergens,
      };

  Product copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    String? category,
    double? originalPrice,
    double? discountedPrice,
    String? image,
    int? availableQuantity,
    int? totalQuantity,
    DateTime? createdAt,
    DateTime? expiryDate,
    bool? isActive,
    List<String>? allergens,
  }) {
    return Product(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      image: image ?? this.image,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      allergens: allergens ?? this.allergens,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $discountedPrice€)';
}

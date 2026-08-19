/// Modèle de pack/offre pour les partenaires
class Pack {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final String image;
  final List<String> productIds; // Références aux produits
  final int availableQuantity;
  final int totalQuantity;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final bool isActive;
  final int estimatedPickupTime; // en minutes

  Pack({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.image,
    required this.productIds,
    required this.availableQuantity,
    required this.totalQuantity,
    required this.createdAt,
    this.expiryDate,
    this.isActive = true,
    this.estimatedPickupTime = 30,
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

  bool get isLowStock => availableQuantity <= 2;

  bool get isSoldOut => availableQuantity == 0;

  double get savings => originalPrice - discountedPrice;

  // ── Factory Methods ──────────────────────────────
  factory Pack.fromJson(Map<String, dynamic> json) {
    return Pack(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      productIds: List<String>.from(json['productIds'] ?? []),
      availableQuantity: json['availableQuantity'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      isActive: json['isActive'] ?? true,
      estimatedPickupTime: json['estimatedPickupTime'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeId': storeId,
        'name': name,
        'description': description,
        'originalPrice': originalPrice,
        'discountedPrice': discountedPrice,
        'image': image,
        'productIds': productIds,
        'availableQuantity': availableQuantity,
        'totalQuantity': totalQuantity,
        'createdAt': createdAt.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'isActive': isActive,
        'estimatedPickupTime': estimatedPickupTime,
      };

  Pack copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    double? originalPrice,
    double? discountedPrice,
    String? image,
    List<String>? productIds,
    int? availableQuantity,
    int? totalQuantity,
    DateTime? createdAt,
    DateTime? expiryDate,
    bool? isActive,
    int? estimatedPickupTime,
  }) {
    return Pack(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      image: image ?? this.image,
      productIds: productIds ?? this.productIds,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      estimatedPickupTime: estimatedPickupTime ?? this.estimatedPickupTime,
    );
  }

  @override
  String toString() => 'Pack(id: $id, name: $name, price: $discountedPrice€)';
}

import 'package:myapp/models/product_offer.dart';

/// Modèle de données pour un produit "sauvé" ( Too Good To Go )
/// Représente un produit alimentaire rescued du gaspillage à prix réduit
class RescuedProduct {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double originalPrice;
  final double discountedPrice;
  final int availableQuantity;
  final int reservedQuantity;
  final String partnerId;
  final String partnerName;
  final String partnerAddress;
  final DateTime pickupStartTime;
  final DateTime pickupEndTime;
  final DateTime createdAt;
  final String category;
  final double distance; // Distance en km du partenaire

  RescuedProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountedPrice,
    required this.availableQuantity,
    required this.reservedQuantity,
    required this.partnerId,
    required this.partnerName,
    required this.partnerAddress,
    required this.pickupStartTime,
    required this.pickupEndTime,
    required this.createdAt,
    required this.category,
    required this.distance,
  });

  /// Calcule le pourcentage d'éco-remboursement
  int get ecoSavingsPercentage {
    return ((1 - discountedPrice / originalPrice) * 100).round();
  }

  /// Calcule les kg de CO2 évités (estimation)
  double get co2Saved {
    // Estimation: 1kg de nourriture = 2.5kg de CO2 évité
    return originalPrice * 0.1;
  }

  /// Vérifie si le produit est encore disponible
  bool get isAvailable {
    final now = DateTime.now();
    return availableQuantity > reservedQuantity &&
        now.isBefore(pickupEndTime) &&
        now.isAfter(pickupStartTime);
  }

  /// Nombre de produits restants
  int get remainingQuantity => availableQuantity - reservedQuantity;

  /// Crée une copie avec une quantité réservée mise à jour
  RescuedProduct copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? originalPrice,
    double? discountedPrice,
    int? availableQuantity,
    int? reservedQuantity,
    String? partnerId,
    String? partnerName,
    String? partnerAddress,
    DateTime? pickupStartTime,
    DateTime? pickupEndTime,
    DateTime? createdAt,
    String? category,
    double? distance,
  }) {
    return RescuedProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      partnerAddress: partnerAddress ?? this.partnerAddress,
      pickupStartTime: pickupStartTime ?? this.pickupStartTime,
      pickupEndTime: pickupEndTime ?? this.pickupEndTime,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      distance: distance ?? this.distance,
    );
  }

  /// Convertit en Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'availableQuantity': availableQuantity,
      'reservedQuantity': reservedQuantity,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'partnerAddress': partnerAddress,
      'pickupStartTime': pickupStartTime.toIso8601String(),
      'pickupEndTime': pickupEndTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'distance': distance,
    };
  }

  /// Crée depuis une Map Firebase
  factory RescuedProduct.fromMap(Map<String, dynamic> map) {
    return RescuedProduct(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      originalPrice: (map['originalPrice'] ?? 0.0).toDouble(),
      discountedPrice: (map['discountedPrice'] ?? 0.0).toDouble(),
      availableQuantity: map['availableQuantity'] ?? 0,
      reservedQuantity: map['reservedQuantity'] ?? 0,
      partnerId: map['partnerId'] ?? '',
      partnerName: map['partnerName'] ?? '',
      partnerAddress: map['partnerAddress'] ?? '',
      pickupStartTime:
          map['pickupStartTime'] != null
              ? DateTime.parse(map['pickupStartTime'])
              : DateTime.now(),
      pickupEndTime:
          map['pickupEndTime'] != null
              ? DateTime.parse(map['pickupEndTime'])
              : DateTime.now(),
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      category: map['category'] ?? '',
      distance: (map['distance'] ?? 0.0).toDouble(),
    );
  }

  factory RescuedProduct.fromOffer(ProductOffer offer) {
    final now = DateTime.now();
    final pickupStartTime = offer.pickupStartsAt ?? now;
    final pickupEndTime =
        offer.pickupEndsAt ?? pickupStartTime.add(const Duration(hours: 2));
    final category = offer.category?.trim();
    final originalPrice =
        offer.originalPrice <= offer.price
            ? offer.price * 2
            : offer.originalPrice;

    return RescuedProduct(
      id: offer.id,
      name: offer.name,
      description:
          offer.description?.trim().isNotEmpty == true
              ? offer.description!.trim()
              : 'Panier surprise préparé par ${offer.storeName}.',
      imageUrl:
          offer.mediaUrls.isNotEmpty
              ? offer.mediaUrls.first
              : _fallbackImageForCategory(category ?? offer.name),
      originalPrice: originalPrice,
      discountedPrice: offer.price,
      availableQuantity: offer.availableQuantity,
      reservedQuantity: 0,
      partnerId: offer.storeId,
      partnerName: offer.storeName,
      partnerAddress: 'Commerce partenaire DailyCatch',
      pickupStartTime: pickupStartTime,
      pickupEndTime: pickupEndTime,
      createdAt: now,
      category: category?.isNotEmpty == true ? category! : 'Poissons',
      distance: offer.distanceKm ?? 0,
    );
  }

  static String _fallbackImageForCategory(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('crevette') ||
        lower.contains('crust') ||
        lower.contains('fruit')) {
      return 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png';
    }
    if (lower.contains('coquillage') ||
        lower.contains('huitre') ||
        lower.contains('huître')) {
      return 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png';
    }
    return 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RescuedProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

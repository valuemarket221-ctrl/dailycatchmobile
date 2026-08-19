class ProductOffer {
  const ProductOffer({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.name,
    required this.currency,
    required this.unitAmount,
    required this.availableQuantity,
    this.description,
    this.category,
    this.weightEstimate,
    this.originalUnitAmount,
    this.pickupStartsAt,
    this.pickupEndsAt,
    this.mediaUrls = const [],
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final String id;
  final String storeId;
  final String storeName;
  final String name;
  final String currency;
  final int unitAmount;
  final int availableQuantity;
  final String? description;
  final String? category;
  final String? weightEstimate;
  final int? originalUnitAmount;
  final DateTime? pickupStartsAt;
  final DateTime? pickupEndsAt;
  final List<String> mediaUrls;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  bool get isCfa => currency.toLowerCase() == 'xof';

  double get price => isCfa ? unitAmount.toDouble() : unitAmount / 100;
  double get originalPrice =>
      isCfa
          ? (originalUnitAmount ?? unitAmount).toDouble()
          : (originalUnitAmount ?? unitAmount) / 100;

  factory ProductOffer.fromJson(Map<String, dynamic> json) {
    return ProductOffer(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String? ?? 'Commerce DailyCatch',
      name: json['name'] as String,
      currency: json['currency'] as String,
      unitAmount: json['unitAmount'] as int,
      availableQuantity: json['availableQuantity'] as int,
      description: json['description'] as String?,
      category: json['category'] as String?,
      weightEstimate: json['weightEstimate'] as String?,
      originalUnitAmount: json['originalUnitAmount'] as int?,
      pickupStartsAt:
          json['pickupStartsAt'] == null
              ? null
              : DateTime.parse(json['pickupStartsAt'] as String),
      pickupEndsAt:
          json['pickupEndsAt'] == null
              ? null
              : DateTime.parse(json['pickupEndsAt'] as String),
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>? ?? const [])
              .map((url) => url as String)
              .toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toProductMap({
    String image = '',
    String description = '',
    double originalPrice = 0,
    String pickupTime = '',
  }) {
    return {
      'id': id,
      'name': name,
      'description': description.isNotEmpty ? description : this.description,
      'discountedPrice': price,
      'originalPrice': originalPrice > 0 ? originalPrice : this.originalPrice,
      'storeId': storeId,
      'storeName': storeName,
      'image': image,
      'images': mediaUrls,
      'category': category,
      'weightEstimate': weightEstimate,
      'time': pickupTime.isNotEmpty ? pickupTime : _formatPickupWindow(),
      'itemsLeft': availableQuantity,
      'distance': distanceKm,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String _formatPickupWindow() {
    if (pickupStartsAt == null || pickupEndsAt == null) return '';
    String hhmm(DateTime date) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    return '${hhmm(pickupStartsAt!)} - ${hhmm(pickupEndsAt!)}';
  }
}

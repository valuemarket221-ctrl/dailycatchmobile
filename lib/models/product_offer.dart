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
    this.storeAddress,
    this.storeRating,
    this.storeReviewCount = 0,
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
  final String? storeAddress;
  final double? storeRating;
  final int storeReviewCount;

  bool get hasValidCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180;

  bool get isCfa => currency.toLowerCase() == 'xof';

  double get price => isCfa ? unitAmount.toDouble() : unitAmount / 100;
  double get originalPrice =>
      isCfa
          ? (originalUnitAmount ?? unitAmount).toDouble()
          : (originalUnitAmount ?? unitAmount) / 100;

  factory ProductOffer.fromJson(Map<String, dynamic> json) {
    return ProductOffer(
      id: _string(json['id']),
      storeId: _string(json['storeId']),
      storeName: json['storeName'] as String? ?? 'Commerce DailyCatch',
      name: _string(json['name']),
      currency: json['currency'] as String? ?? 'xof',
      unitAmount: _int(json['unitAmount']),
      availableQuantity: _int(json['availableQuantity']),
      description: json['description'] as String?,
      category: json['category'] as String?,
      weightEstimate: json['weightEstimate'] as String?,
      originalUnitAmount: _optionalInt(json['originalUnitAmount']),
      pickupStartsAt: _optionalDate(json['pickupStartsAt']),
      pickupEndsAt: _optionalDate(json['pickupEndsAt']),
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>? ?? const [])
              .map((url) => url as String)
              .toList(),
      latitude: _optionalDouble(json['latitude']),
      longitude: _optionalDouble(json['longitude']),
      distanceKm: _optionalDouble(json['distanceKm']),
      storeAddress: json['storeAddress'] as String?,
      storeRating: _optionalDouble(json['storeRating']),
      storeReviewCount: _optionalInt(json['storeReviewCount']) ?? 0,
    );
  }

  static String _string(Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      throw const FormatException('missing required product offer field');
    }
    return text;
  }

  static int _int(Object? value) {
    final parsed = _optionalInt(value);
    if (parsed == null) {
      throw const FormatException('missing required product offer integer');
    }
    return parsed;
  }

  static int? _optionalInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }

  static double? _optionalDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _optionalDate(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
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

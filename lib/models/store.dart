/// Modèle de données pour une boutique partenaire
class Store {
  final String id;
  final String name;
  final String category;
  final String distance;
  final double originalPrice;
  final double discountedPrice;
  final String pickupTime;
  final int productsLeft;
  final String image;
  final String banner;
  final double? rating;
  final int productsCount;
  final List<String> productTypes;
  final double? lat;
  final double? lng;

  const Store({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.originalPrice,
    required this.discountedPrice,
    required this.pickupTime,
    required this.productsLeft,
    required this.image,
    required this.banner,
    required this.rating,
    required this.productsCount,
    required this.productTypes,
    required this.lat,
    required this.lng,
  });

  int get discountPercentage {
    if (originalPrice <= 0 || originalPrice <= discountedPrice) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100).round();
  }

  /// Convertit en map compatible avec les widgets existants
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'distance': distance,
    'originalPrice': originalPrice,
    'discountedPrice': discountedPrice,
    'time': pickupTime,
    'productsLeft': productsLeft,
    'image': image,
    'banner': banner,
    'rating': rating,
    'products': productsCount,
    'productTypes': productTypes,
    'lat': lat,
    'lng': lng,
    'price': discountedPrice,
  };

  factory Store.fromMap(Map<String, dynamic> data, {String id = ''}) {
    final rawTypes = data['productTypes'];
    final productTypes =
        rawTypes is List
            ? rawTypes.map((e) => e.toString()).toList()
            : <String>[];

    return Store(
      id: data['id'] ?? id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      distance: data['distance'] ?? '',
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      discountedPrice:
          (data['discountedPrice'] ?? data['price'] ?? 0).toDouble(),
      pickupTime: data['time'] ?? data['pickupTime'] ?? '',
      productsLeft: (data['productsLeft'] ?? 0) as int,
      image: data['image'] ?? '',
      banner: data['banner'] ?? data['image'] ?? '',
      rating: (data['rating'] as num?)?.toDouble(),
      productsCount: (data['products'] ?? data['productsCount'] ?? 0) as int,
      productTypes: productTypes,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
    );
  }
}

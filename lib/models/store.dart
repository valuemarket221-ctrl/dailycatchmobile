import 'package:cloud_firestore/cloud_firestore.dart';

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
  final double rating;
  final int productsCount;
  final List<String> productTypes;
  final double lat;
  final double lng;

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

  factory Store.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final GeoPoint? location = data['location'] as GeoPoint?;
    final rawTypes = data['productTypes'];
    final productTypes =
        rawTypes is List
            ? rawTypes.map((e) => e.toString()).toList()
            : <String>[];

    return Store(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      distance: data['distance'] ?? '',
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (data['discountedPrice'] ?? 0).toDouble(),
      pickupTime: data['pickupTime'] ?? '',
      productsLeft: (data['productsLeft'] ?? 0) as int,
      image: data['image'] ?? '',
      banner: data['banner'] ?? data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      productsCount: (data['productsCount'] ?? 0) as int,
      productTypes: productTypes,
      lat: location?.latitude ?? 0.0,
      lng: location?.longitude ?? 0.0,
    );
  }

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
      rating: (data['rating'] ?? 0).toDouble(),
      productsCount: (data['products'] ?? data['productsCount'] ?? 0) as int,
      productTypes: productTypes,
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
    );
  }

  /// Données mock pour le développement / si Firestore est vide
  static List<Store> getMockStores() {
    return const [
      Store(
        id: '1',
        name: 'DailyCatch Store',
        category: 'Poissonnerie',
        distance: '0.5 km',
        originalPrice: 15.00,
        discountedPrice: 4.99,
        pickupTime: '30 min left',
        productsLeft: 3,
        image: 'assets/images/saumon.jpg',
        banner: 'assets/images/saumon.jpg',
        rating: 4.5,
        productsCount: 12,
        productTypes: ['Poisson', 'Saumon', 'Morue'],
        lat: 14.7167,
        lng: -17.4677,
      ),
      Store(
        id: '2',
        name: 'Le Poisson Rouge',
        category: 'Poisson',
        distance: '1.2 km',
        originalPrice: 20.00,
        discountedPrice: 6.99,
        pickupTime: '1h 15min left',
        productsLeft: 2,
        image: 'assets/images/crevette.jpg',
        banner: 'assets/images/crevette.jpg',
        rating: 4.8,
        productsCount: 8,
        productTypes: ['Thon', 'Sardines', 'Anchois'],
        lat: 14.7240,
        lng: -17.4620,
      ),
      Store(
        id: '3',
        name: 'La Crustacerie',
        category: 'Crustacés',
        distance: '2.0 km',
        originalPrice: 18.00,
        discountedPrice: 5.49,
        pickupTime: '45 min left',
        productsLeft: 5,
        image: 'assets/images/homard.jpg',
        banner: 'assets/images/homard.jpg',
        rating: 4.2,
        productsCount: 15,
        productTypes: ['Homard', 'Crevettes', 'Langoustines'],
        lat: 14.7640,
        lng: -17.3950,
      ),
      Store(
        id: '4',
        name: 'Ocean Treasure',
        category: 'Fruits de mer',
        distance: '3.5 km',
        originalPrice: 25.00,
        discountedPrice: 7.99,
        pickupTime: '2h left',
        productsLeft: 4,
        image: 'assets/images/langoustines.jpg',
        banner: 'assets/images/langoustines.jpg',
        rating: 4.6,
        productsCount: 20,
        productTypes: ['Huîtres', 'Moules', 'Palourdes'],
        lat: 14.7730,
        lng: -17.3770,
      ),
      Store(
        id: '5',
        name: 'Coquillages & Délices',
        category: 'Coquillages',
        distance: '4.8 km',
        originalPrice: 12.00,
        discountedPrice: 3.99,
        pickupTime: '30 min left',
        productsLeft: 6,
        image: 'assets/images/saumon.jpg',
        banner: 'assets/images/saumon.jpg',
        rating: 4.9,
        productsCount: 10,
        productTypes: ['Huitres', 'Coquilles Saint-Jacques', 'Bulots'],
        lat: 14.7180,
        lng: -17.2700,
      ),
      Store(
        id: '6',
        name: 'Le Grand Bleu',
        category: 'Poissonnerie',
        distance: '5.2 km',
        originalPrice: 22.00,
        discountedPrice: 6.49,
        pickupTime: '1h 30min left',
        productsLeft: 3,
        image: 'assets/images/crevette.jpg',
        banner: 'assets/images/crevette.jpg',
        rating: 4.4,
        productsCount: 18,
        productTypes: ['Saumon', 'Truite', 'Cabillaud'],
        lat: 14.7900,
        lng: -16.9350,
      ),
      Store(
        id: '7',
        name: 'La Mer en Profondeur',
        category: 'Fruits de mer',
        distance: '260 km',
        originalPrice: 28.00,
        discountedPrice: 8.99,
        pickupTime: '3h left',
        productsLeft: 7,
        image: 'assets/images/homard.jpg',
        banner: 'assets/images/homard.jpg',
        rating: 4.7,
        productsCount: 25,
        productTypes: ['Langoustines', 'Bulots', 'Moules'],
        lat: 16.0333,
        lng: -16.5000,
      ),
      Store(
        id: '8',
        name: 'Le Rêve Marin',
        category: 'Crustacés',
        distance: '450 km',
        originalPrice: 30.00,
        discountedPrice: 9.99,
        pickupTime: '2h left',
        productsLeft: 2,
        image: 'assets/images/langoustines.jpg',
        banner: 'assets/images/langoustines.jpg',
        rating: 4.3,
        productsCount: 12,
        productTypes: ['Homard', 'Langoustines', 'Crevettes'],
        lat: 12.5833,
        lng: -16.2667,
      ),
      Store(
        id: '9',
        name: 'Atlantique Sud',
        category: 'Poisson',
        distance: '120 km',
        originalPrice: 18.00,
        discountedPrice: 5.99,
        pickupTime: '1h left',
        productsLeft: 5,
        image: 'assets/images/saumon.jpg',
        banner: 'assets/images/saumon.jpg',
        rating: 4.5,
        productsCount: 15,
        productTypes: ['Thon', 'Maquereau', 'Sardines'],
        lat: 14.1500,
        lng: -16.1000,
      ),
      Store(
        id: '10',
        name: 'Saveurs Océanes',
        category: 'Coquillages',
        distance: '150 km',
        originalPrice: 14.00,
        discountedPrice: 4.49,
        pickupTime: '45 min left',
        productsLeft: 8,
        image: 'assets/images/crevette.jpg',
        banner: 'assets/images/crevette.jpg',
        rating: 4.6,
        productsCount: 8,
        productTypes: ['Huitres', 'Palourdes', 'Moules'],
        lat: 14.3500,
        lng: -16.5667,
      ),
    ];
  }
}

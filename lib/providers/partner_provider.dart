import 'package:flutter/foundation.dart';

class Product {
  final String id;
  String name;
  String description;
  String category;
  double originalPrice;
  double discountedPrice;
  int quantity;
  DateTime? expiryDate;
  List<String> allergens;

  Product({
    required this.id,
    required this.name,
    this.description = '',
    this.category = 'Poisson',
    required this.originalPrice,
    required this.discountedPrice,
    required this.quantity,
    this.expiryDate,
    this.allergens = const [],
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? originalPrice,
    double? discountedPrice,
    int? quantity,
    DateTime? expiryDate,
    List<String>? allergens,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      allergens: allergens ?? this.allergens,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'quantity': quantity,
      'expiryDate': expiryDate?.toIso8601String(),
      'allergens': allergens,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Poisson',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null,
      allergens: List<String>.from(json['allergens'] ?? []),
    );
  }
}

class Pack {
  final String id;
  String name;
  String description;
  double originalPrice;
  double discountedPrice;
  int quantity;
  DateTime? expiryDate;
  List<String> products;
  String status;

  Pack({
    required this.id,
    required this.name,
    this.description = '',
    required this.originalPrice,
    required this.discountedPrice,
    required this.quantity,
    this.expiryDate,
    this.products = const [],
    this.status = 'Actif',
  });

  Pack copyWith({
    String? id,
    String? name,
    String? description,
    double? originalPrice,
    double? discountedPrice,
    int? quantity,
    DateTime? expiryDate,
    List<String>? products,
    String? status,
  }) {
    return Pack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      products: products ?? this.products,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'quantity': quantity,
      'expiryDate': expiryDate?.toIso8601String(),
      'products': products,
      'status': status,
    };
  }

  factory Pack.fromJson(Map<String, dynamic> json) {
    return Pack(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null,
      products: List<String>.from(json['products'] ?? []),
      status: json['status'] ?? 'Actif',
    );
  }
}

class Order {
  final String id;
  String clientName;
  String items;
  double total;
  String status;
  String time;
  DateTime createdAt;

  Order({
    required this.id,
    required this.clientName,
    required this.items,
    required this.total,
    required this.status,
    required this.time,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Order copyWith({
    String? id,
    String? clientName,
    String? items,
    double? total,
    String? status,
    String? time,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'items': items,
      'total': total,
      'status': status,
      'time': time,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      clientName: json['clientName'] ?? '',
      items: json['items'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'En attente',
      time: json['time'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

class StoreHours {
  final String day;
  String openTime;
  String closeTime;
  bool isOpen;

  StoreHours({
    required this.day,
    this.openTime = '08:00',
    this.closeTime = '19:00',
    this.isOpen = true,
  });

  StoreHours copyWith({
    String? day,
    String? openTime,
    String? closeTime,
    bool? isOpen,
  }) {
    return StoreHours(
      day: day ?? this.day,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen,
    };
  }

  factory StoreHours.fromJson(Map<String, dynamic> json) {
    return StoreHours(
      day: json['day'] ?? '',
      openTime: json['openTime'] ?? '08:00',
      closeTime: json['closeTime'] ?? '19:00',
      isOpen: json['isOpen'] ?? true,
    );
  }
}

class PartnerProvider extends ChangeNotifier {
  // Products
  List<Product> _products = [];
  List<Product> get products => _products;

  // Packs
  List<Pack> _packs = [];
  List<Pack> get packs => _packs;

  // Orders
  List<Order> _orders = [];
  List<Order> get orders => _orders;

  // Store Hours
  List<StoreHours> _storeHours = [];
  List<StoreHours> get storeHours => _storeHours;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Dashboard stats
  int get totalProducts => _products.length;
  int get activePacks => _packs.where((p) => p.status == 'Actif').length;
  int get totalOrders => _orders.length;
  double get totalRevenue => _orders.fold(0, (sum, order) => sum + order.total);
  int get pendingOrders =>
      _orders.where((o) => o.status == 'En attente').length;
  int get readyOrders => _orders.where((o) => o.status == 'Prête').length;
  int get completedOrders => _orders.where((o) => o.status == 'Retirée').length;

  PartnerProvider() {
    _initializeData();
  }

  void _initializeData() {
    // Initialize sample products
    _products = [
      Product(
        id: '1',
        name: 'Saumon frais',
        category: 'Poisson',
        originalPrice: 19.99,
        discountedPrice: 9.99,
        quantity: 15,
        allergens: ['Poisson'],
      ),
      Product(
        id: '2',
        name: 'Crevettes',
        category: 'Crustacés',
        originalPrice: 15.99,
        discountedPrice: 7.99,
        quantity: 3,
        allergens: ['Crustacés'],
      ),
      Product(
        id: '3',
        name: 'Homard entier',
        category: 'Crustacés',
        originalPrice: 45.99,
        discountedPrice: 22.99,
        quantity: 8,
        allergens: ['Crustacés'],
      ),
      Product(
        id: '4',
        name: 'Moules',
        category: 'Coquillages',
        originalPrice: 12.99,
        discountedPrice: 5.99,
        quantity: 20,
        allergens: [],
      ),
      Product(
        id: '5',
        name: 'Cabillaud',
        category: 'Poisson',
        originalPrice: 14.99,
        discountedPrice: 7.50,
        quantity: 12,
        allergens: ['Poisson'],
      ),
    ];

    // Initialize sample packs
    _packs = [
      Pack(
        id: '1',
        name: 'Panier Poisson',
        products: ['Saumon frais', 'Cabillaud'],
        originalPrice: 29.99,
        discountedPrice: 14.99,
        quantity: 3,
      ),
      Pack(
        id: '2',
        name: 'Box Crustacés',
        products: ['Crevettes', 'Homard'],
        originalPrice: 59.99,
        discountedPrice: 29.99,
        quantity: 2,
      ),
      Pack(
        id: '3',
        name: 'Panier Fruits de mer',
        products: ['Moules', 'Palourdes'],
        originalPrice: 24.99,
        discountedPrice: 12.99,
        quantity: 5,
      ),
      Pack(
        id: '4',
        name: 'MixSAVE',
        products: ['Saumon frais', 'Crevettes', 'Moules'],
        originalPrice: 19.99,
        discountedPrice: 9.99,
        quantity: 8,
        status: 'Inactif',
      ),
    ];

    // Initialize sample orders
    _orders = [
      Order(
        id: 'CMD-001',
        clientName: 'Marie D.',
        items: 'Saumon + Crevettes',
        total: 25.99,
        status: 'En attente',
        time: '10:30',
      ),
      Order(
        id: 'CMD-002',
        clientName: 'Jean P.',
        items: 'Panier Poisson',
        total: 14.99,
        status: 'Confirmée',
        time: '09:45',
      ),
      Order(
        id: 'CMD-003',
        clientName: 'Sophie L.',
        items: 'Homard entier',
        total: 22.99,
        status: 'Prête',
        time: '09:15',
      ),
      Order(
        id: 'CMD-004',
        clientName: 'Paul M.',
        items: 'Box Crustacés',
        total: 29.99,
        status: 'Retirée',
        time: 'Hier',
      ),
      Order(
        id: 'CMD-005',
        clientName: 'Claire B.',
        items: 'Moules + Huîtres',
        total: 18.50,
        status: 'Annulée',
        time: 'Hier',
      ),
      Order(
        id: 'CMD-006',
        clientName: 'Lucas M.',
        items: 'Panier Fruits de mer',
        total: 12.99,
        status: 'En attente',
        time: '11:20',
      ),
      Order(
        id: 'CMD-007',
        clientName: 'Emma B.',
        items: 'Saumon frais',
        total: 9.99,
        status: 'Confirmée',
        time: '10:45',
      ),
    ];

    // Initialize store hours
    _storeHours = [
      StoreHours(day: 'Lundi', openTime: '08:00', closeTime: '19:00'),
      StoreHours(day: 'Mardi', openTime: '08:00', closeTime: '19:00'),
      StoreHours(day: 'Mercredi', openTime: '08:00', closeTime: '19:00'),
      StoreHours(day: 'Jeudi', openTime: '08:00', closeTime: '19:00'),
      StoreHours(day: 'Vendredi', openTime: '08:00', closeTime: '20:00'),
      StoreHours(day: 'Samedi', openTime: '09:00', closeTime: '20:00'),
      StoreHours(day: 'Dimanche', isOpen: false),
    ];
  }

  // Products CRUD
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _products.add(
      product.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _products.removeWhere((p) => p.id == id);

    _isLoading = false;
    notifyListeners();
  }

  // Packs CRUD
  Future<void> addPack(Pack pack) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _packs.add(
      pack.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePack(Pack pack) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _packs.indexWhere((p) => p.id == pack.id);
    if (index != -1) {
      _packs[index] = pack;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deletePack(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _packs.removeWhere((p) => p.id == id);

    _isLoading = false;
    notifyListeners();
  }

  // Orders CRUD
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Order> getOrdersByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  // Store Hours CRUD
  Future<void> updateStoreHours(StoreHours hours) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final index = _storeHours.indexWhere((h) => h.day == hours.day);
    if (index != -1) {
      _storeHours[index] = hours;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Inventory management
  Future<void> updateStock(String productId, int newQuantity) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  int getLowStockCount() {
    return _products.where((p) => p.quantity <= 5).length;
  }

  int getOutOfStockCount() {
    return _products.where((p) => p.quantity == 0).length;
  }
}

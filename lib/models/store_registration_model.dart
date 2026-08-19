/// Modèle pour les informations de boutique/partenaire
class StoreRegistration {
  final String id;
  final String userId;
  final String storeName;
  final String storeCategory;
  final String description;
  final String address;
  final String city;
  final String phone;
  final String email;
  final String website;
  final double latitude;
  final double longitude;
  final String siretNumber;
  final String vatNumber;
  final String bankAccount;
  final String ownerName;
  final String ownerPhone;
  final List<String> operatingDays; // Lun-Dim
  final String openingTime; // HH:mm
  final String closingTime; // HH:mm
  final DateTime createdAt;
  final bool isApproved;
  final bool isActive;

  StoreRegistration({
    required this.id,
    required this.userId,
    required this.storeName,
    required this.storeCategory,
    required this.description,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.website,
    required this.latitude,
    required this.longitude,
    required this.siretNumber,
    required this.vatNumber,
    required this.bankAccount,
    required this.ownerName,
    required this.ownerPhone,
    required this.operatingDays,
    required this.openingTime,
    required this.closingTime,
    required this.createdAt,
    this.isApproved = false,
    this.isActive = true,
  });

  factory StoreRegistration.fromJson(Map<String, dynamic> json) {
    return StoreRegistration(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      storeName: json['storeName'] ?? '',
      storeCategory: json['storeCategory'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      siretNumber: json['siretNumber'] ?? '',
      vatNumber: json['vatNumber'] ?? '',
      bankAccount: json['bankAccount'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerPhone: json['ownerPhone'] ?? '',
      operatingDays: List<String>.from(json['operatingDays'] ?? []),
      openingTime: json['openingTime'] ?? '09:00',
      closingTime: json['closingTime'] ?? '20:00',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isApproved: json['isApproved'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'storeName': storeName,
        'storeCategory': storeCategory,
        'description': description,
        'address': address,
        'city': city,
        'phone': phone,
        'email': email,
        'website': website,
        'latitude': latitude,
        'longitude': longitude,
        'siretNumber': siretNumber,
        'vatNumber': vatNumber,
        'bankAccount': bankAccount,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'operatingDays': operatingDays,
        'openingTime': openingTime,
        'closingTime': closingTime,
        'createdAt': createdAt.toIso8601String(),
        'isApproved': isApproved,
        'isActive': isActive,
      };

  StoreRegistration copyWith({
    String? id,
    String? userId,
    String? storeName,
    String? storeCategory,
    String? description,
    String? address,
    String? city,
    String? phone,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    String? siretNumber,
    String? vatNumber,
    String? bankAccount,
    String? ownerName,
    String? ownerPhone,
    List<String>? operatingDays,
    String? openingTime,
    String? closingTime,
    DateTime? createdAt,
    bool? isApproved,
    bool? isActive,
  }) {
    return StoreRegistration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeName: storeName ?? this.storeName,
      storeCategory: storeCategory ?? this.storeCategory,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      siretNumber: siretNumber ?? this.siretNumber,
      vatNumber: vatNumber ?? this.vatNumber,
      bankAccount: bankAccount ?? this.bankAccount,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      operatingDays: operatingDays ?? this.operatingDays,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
      isActive: isActive ?? this.isActive,
    );
  }
}

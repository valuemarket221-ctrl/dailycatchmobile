import 'package:http/http.dart' as http;
import 'package:myapp/services/backend_api_client.dart';

class PartnerOfferRequest {
  const PartnerOfferRequest({
    required this.storeId,
    required this.storeName,
    required this.name,
    required this.unitAmount,
    required this.availableQuantity,
    this.description,
    this.category,
    this.weightEstimate,
    this.currency = 'xof',
    this.originalUnitAmount,
    this.pickupStartsAt,
    this.pickupEndsAt,
    this.latitude,
    this.longitude,
    this.mediaUrls = const [],
    this.pickupSlots = const [],
    this.active = true,
  });

  final String storeId;
  final String storeName;
  final String name;
  final String? description;
  final String? category;
  final String? weightEstimate;
  final String currency;
  final int unitAmount;
  final int? originalUnitAmount;
  final int availableQuantity;
  final DateTime? pickupStartsAt;
  final DateTime? pickupEndsAt;
  final double? latitude;
  final double? longitude;
  final List<String> mediaUrls;
  final List<Map<String, dynamic>> pickupSlots;
  final bool active;

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'storeName': storeName,
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (category != null && category!.isNotEmpty) 'category': category,
    if (weightEstimate != null && weightEstimate!.isNotEmpty)
      'weightEstimate': weightEstimate,
    'currency': currency,
    'unitAmount': unitAmount,
    if (originalUnitAmount != null) 'originalUnitAmount': originalUnitAmount,
    'availableQuantity': availableQuantity,
    if (pickupStartsAt != null)
      'pickupStartsAt': pickupStartsAt!.toUtc().toIso8601String(),
    if (pickupEndsAt != null)
      'pickupEndsAt': pickupEndsAt!.toUtc().toIso8601String(),
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'mediaUrls': mediaUrls,
    'pickupSlots': pickupSlots,
    'active': active,
  };
}

class PartnerProfileRequest {
  const PartnerProfileRequest({
    required this.storeId,
    required this.storeName,
    this.ownerName,
    this.commerceType = 'fishmonger',
    this.address,
    this.city,
    this.postalCode,
    this.phone,
    this.email,
    this.description,
    this.openingHours = const {},
    this.latitude,
    this.longitude,
  });

  final String storeId;
  final String storeName;
  final String? ownerName;
  final String commerceType;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? phone;
  final String? email;
  final String? description;
  final Map<String, String> openingHours;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'storeName': storeName,
    if (ownerName != null && ownerName!.isNotEmpty) 'ownerName': ownerName,
    'commerceType': commerceType,
    if (address != null && address!.isNotEmpty) 'address': address,
    if (city != null && city!.isNotEmpty) 'city': city,
    if (postalCode != null && postalCode!.isNotEmpty) 'postalCode': postalCode,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'openingHours': openingHours,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };
}

class UploadIntent {
  const UploadIntent({
    required this.objectKey,
    required this.storageUrl,
    required this.uploadIntentId,
    required this.uploadExpiresAt,
    required this.uploadMethod,
    required this.uploadUrl,
    this.documentId,
  });

  final String? documentId;
  final String objectKey;
  final String storageUrl;
  final String uploadIntentId;
  final DateTime uploadExpiresAt;
  final String uploadMethod;
  final String uploadUrl;

  factory UploadIntent.fromJson(Map<String, dynamic> json) {
    final upload = BackendApiClient.requireObject(json, 'upload');
    final expiresAt = DateTime.tryParse(
      _requiredString(json, 'uploadExpiresAt'),
    );
    if (expiresAt == null) {
      throw const BackendApiException(
        statusCode: 200,
        code: 'invalid_backend_response',
      );
    }

    final method = _requiredString(upload, 'method');
    if (method != 'direct_put') {
      throw const BackendApiException(
        statusCode: 200,
        code: 'unsupported_upload_method',
      );
    }

    final uploadUrl = _requiredString(upload, 'url');
    final uploadExpiresAt = _requiredString(upload, 'expiresAt');
    if (uploadExpiresAt != json['uploadExpiresAt']?.toString()) {
      throw const BackendApiException(
        statusCode: 200,
        code: 'invalid_backend_response',
      );
    }

    return UploadIntent(
      documentId: json['documentId']?.toString(),
      objectKey: _requiredString(json, 'objectKey'),
      storageUrl: _requiredString(json, 'storageUrl'),
      uploadIntentId: _requiredString(json, 'uploadIntentId'),
      uploadExpiresAt: expiresAt,
      uploadMethod: method,
      uploadUrl: uploadUrl,
    );
  }

  bool get isExpired => DateTime.now().toUtc().isAfter(uploadExpiresAt.toUtc());

  static String _requiredString(Map<String, dynamic> json, String fieldName) {
    final value = json[fieldName]?.toString().trim() ?? '';
    if (value.isEmpty) {
      throw const BackendApiException(
        statusCode: 200,
        code: 'invalid_backend_response',
      );
    }
    return value;
  }
}

class PartnerApiService {
  PartnerApiService({
    http.Client? client,
    String? baseUrl,
    BackendApiClient? api,
  }) : _api = api ?? BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<String> createOffer(PartnerOfferRequest request) async {
    final body = await _postJson('/api/v1/partner/offers', request.toJson());
    return body['offerId'].toString();
  }

  Future<Map<String, dynamic>> updateOffer(
    String offerId,
    Map<String, dynamic> updates,
  ) async {
    final body = await _patchJson('/api/v1/partner/offers/$offerId', updates);
    return BackendApiClient.requireObject(body, 'offer');
  }

  Future<Map<String, dynamic>> setOfferActive(String offerId, bool active) {
    return updateOffer(offerId, {'active': active});
  }

  Future<Map<String, dynamic>> deleteOffer(String offerId) async {
    final body = await _deleteJson('/api/v1/partner/offers/$offerId');
    return BackendApiClient.requireObject(body, 'offer');
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final body = await _getJson('/api/v1/partner/profile/me');
    return BackendApiClient.optionalObject(body, 'profile');
  }

  Future<PartnerStoreContext?> getMyStoreContext() async {
    final profile = await getMyProfile();
    if (profile == null) return null;
    final storeId =
        profile['storeId']?.toString().trim().isNotEmpty == true
            ? profile['storeId'].toString().trim()
            : profile['store_id']?.toString().trim() ?? '';
    if (storeId.isEmpty) return null;
    return PartnerStoreContext(
      storeId: storeId,
      storeName:
          profile['storeName']?.toString().trim().isNotEmpty == true
              ? profile['storeName'].toString().trim()
              : profile['store_name']?.toString().trim() ?? 'Mon commerce',
      latitude: _optionalDouble(profile['latitude']),
      longitude: _optionalDouble(profile['longitude']),
    );
  }

  Future<Map<String, dynamic>> saveMyProfile(
    PartnerProfileRequest request,
  ) async {
    final body = await _putJson('/api/v1/partner/profile/me', request.toJson());
    return BackendApiClient.requireObject(body, 'profile');
  }

  Future<UploadIntent> createDocumentUploadIntent({
    required String documentType,
    required String fileName,
    required String contentType,
    required int sizeBytes,
  }) async {
    final body = await _postJson('/api/v1/partner/documents/upload-intent', {
      'documentType': documentType,
      'fileName': fileName,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
    });
    return UploadIntent.fromJson(body);
  }

  Future<String> uploadDocumentBytes({
    required String documentType,
    required String fileName,
    required String contentType,
    required List<int> bytes,
  }) async {
    final intent = await createDocumentUploadIntent(
      documentType: documentType,
      fileName: fileName,
      contentType: contentType,
      sizeBytes: bytes.length,
    );
    return _uploadBytesFromIntent(
      intent: intent,
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<List<Map<String, dynamic>>> getMyDocuments() async {
    final body = await _getJson('/api/v1/partner/documents/me');
    return BackendApiClient.requireObjectList(body, 'documents');
  }

  Future<List<Map<String, dynamic>>> getPartnerPaymentMethods() async {
    final body = await _getJson('/api/v1/partner/payment-methods/me');
    return BackendApiClient.requireObjectList(body, 'paymentMethods');
  }

  Future<Map<String, dynamic>> createPartnerPaymentMethod(
    Map<String, dynamic> request,
  ) async {
    final body = await _postJson('/api/v1/partner/payment-methods', request);
    return BackendApiClient.requireObject(body, 'paymentMethod');
  }

  Future<void> deletePartnerPaymentMethod(String paymentMethodId) async {
    await _deleteJson('/api/v1/partner/payment-methods/$paymentMethodId');
  }

  Future<UploadIntent> createOfferMediaUploadIntent({
    required String fileName,
    required String contentType,
    required int sizeBytes,
    String? offerId,
  }) async {
    final body = await _postJson('/api/v1/partner/offer-media/upload-intent', {
      'fileName': fileName,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
      if (offerId != null) 'offerId': offerId,
    });
    return UploadIntent.fromJson(body);
  }

  Future<String> uploadOfferMediaBytes({
    required String fileName,
    required String contentType,
    required List<int> bytes,
    String? offerId,
  }) async {
    final intent = await createOfferMediaUploadIntent(
      fileName: fileName,
      contentType: contentType,
      sizeBytes: bytes.length,
      offerId: offerId,
    );
    return _uploadBytesFromIntent(
      intent: intent,
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<List<Map<String, dynamic>>> getStoreOffers(String storeId) async {
    final body = await _getJson('/api/v1/partner/stores/$storeId/offers');
    return BackendApiClient.requireObjectList(body, 'offers');
  }

  Future<List<Map<String, dynamic>>> getStoreReservations(
    String storeId,
  ) async {
    final body = await _getJson('/api/v1/partner/stores/$storeId/reservations');
    return BackendApiClient.requireObjectList(body, 'reservations');
  }

  Future<List<Map<String, dynamic>>> getStorePickups(String storeId) async {
    final body = await _getJson('/api/v1/partner/stores/$storeId/pickups');
    return BackendApiClient.requireObjectList(body, 'pickups');
  }

  Future<Map<String, dynamic>> getStoreFinanceSummary(String storeId) async {
    final body = await _getJson(
      '/api/v1/partner/stores/$storeId/finance/summary',
    );
    return BackendApiClient.requireObject(body, 'summary');
  }

  Future<List<Map<String, dynamic>>> getStoreFinanceTransactions(
    String storeId, {
    String? type,
    int limit = 50,
  }) async {
    final body = await _getJson(
      '/api/v1/partner/stores/$storeId/finance/transactions',
      queryParameters: {'type': type, 'limit': limit.toString()},
    );
    return BackendApiClient.requireObjectList(body, 'transactions');
  }

  Future<List<Map<String, dynamic>>> getStoreFinanceStatements(
    String storeId, {
    int months = 12,
  }) async {
    final body = await _getJson(
      '/api/v1/partner/stores/$storeId/finance/statements',
      queryParameters: {'months': months.toString()},
    );
    return BackendApiClient.requireObjectList(body, 'statements');
  }

  Future<Map<String, dynamic>> createStoreFinanceStatementDownloadIntent(
    String storeId,
    String period,
  ) async {
    final body = await _getJson(
      '/api/v1/partner/stores/$storeId/finance/statements/$period/download-intent',
    );
    return BackendApiClient.requireObject(body, 'download');
  }

  Future<List<Map<String, dynamic>>> getStorePayoutRequests(
    String storeId,
  ) async {
    final body = await _getJson('/api/v1/partner/stores/$storeId/payouts');
    return BackendApiClient.requireObjectList(body, 'payoutRequests');
  }

  Future<Map<String, dynamic>> createPartnerPayoutRequest({
    required String storeId,
    required String paymentMethodId,
    required int amount,
    String currency = 'xof',
  }) async {
    final body = await _postJson('/api/v1/partner/stores/$storeId/payouts', {
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'currency': currency,
    });
    return BackendApiClient.requireObject(body, 'payoutRequest');
  }

  Future<List<Map<String, dynamic>>> getStorePromotions(String storeId) async {
    final body = await _getJson('/api/v1/partner/stores/$storeId/promotions');
    return BackendApiClient.requireObjectList(body, 'promotions');
  }

  Future<String> createPromotion(Map<String, dynamic> request) async {
    final body = await _postJson('/api/v1/partner/promotions', request);
    return body['promotionId'].toString();
  }

  Future<Map<String, dynamic>> updatePromotion(
    String promotionId,
    Map<String, dynamic> updates,
  ) async {
    final body = await _patchJson(
      '/api/v1/partner/promotions/$promotionId',
      updates,
    );
    return BackendApiClient.requireObject(body, 'promotion');
  }

  Future<Map<String, dynamic>> setPromotionActive(
    String promotionId,
    bool active,
  ) {
    return updatePromotion(promotionId, {'active': active});
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String?> queryParameters = const {},
  }) async {
    try {
      return await _api.get(path, queryParameters: queryParameters);
    } on BackendApiException catch (error) {
      throw PartnerApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _api.post(path, body: payload);
    } on BackendApiException catch (error) {
      throw PartnerApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _putJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _api.put(path, body: payload);
    } on BackendApiException catch (error) {
      throw PartnerApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _patchJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _api.patch(path, body: payload);
    } on BackendApiException catch (error) {
      throw PartnerApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _deleteJson(String path) async {
    try {
      return await _api.delete(path);
    } on BackendApiException catch (error) {
      throw PartnerApiException.fromBackend(error);
    }
  }

  Future<String> _uploadBytesFromIntent({
    required UploadIntent intent,
    required List<int> bytes,
    required String contentType,
  }) async {
    if (intent.isExpired) {
      throw const PartnerApiException(
        statusCode: 410,
        message: 'upload_intent_expired',
      );
    }

    try {
      final body = await _api.putBytes(
        intent.uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );
      return body['storageUrl'] as String? ?? intent.storageUrl;
    } on BackendApiException catch (error) {
      throw PartnerApiException.fromBackend(error);
    }
  }

  static double? _optionalDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class PartnerStoreContext {
  const PartnerStoreContext({
    required this.storeId,
    required this.storeName,
    this.latitude,
    this.longitude,
  });

  final String storeId;
  final String storeName;
  final double? latitude;
  final double? longitude;
}

class PartnerApiException implements Exception {
  const PartnerApiException({required this.statusCode, required this.message});

  factory PartnerApiException.fromBackend(BackendApiException error) {
    return PartnerApiException(
      statusCode: error.statusCode,
      message: error.code,
    );
  }

  final int statusCode;
  final String message;

  @override
  String toString() => 'PartnerApiException($statusCode): $message';
}

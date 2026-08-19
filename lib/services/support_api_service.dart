import 'package:http/http.dart' as http;
import 'package:myapp/services/backend_api_client.dart';

class SupportApiService {
  SupportApiService({http.Client? client, String? baseUrl})
    : _api = BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<String> createTicket({
    String? orderId,
    required String category,
    required String subject,
    required String message,
  }) async {
    final body = await _postJson('/api/v1/support/tickets', {
      if (orderId != null && orderId.isNotEmpty) 'orderId': orderId,
      'category': category,
      'subject': subject,
      'message': message,
    });
    return body['ticketId'] as String;
  }

  Future<void> registerPushToken({
    required String platform,
    required String token,
  }) async {
    await _postJson('/api/v1/notifications/device-tokens', {
      'platform': platform,
      'token': token,
    });
  }

  Future<int> updatePushNotificationsEnabled(bool enabled) async {
    final body = await _patchJson('/api/v1/notifications/device-tokens/me', {
      'enabled': enabled,
    });
    return body['updatedCount'] as int;
  }

  Future<NotificationPreferences> getNotificationPreferences() async {
    final body = await _getJson('/api/v1/notifications/preferences/me');
    return NotificationPreferences.fromJson(
      body['preferences'] as Map<String, dynamic>,
    );
  }

  Future<NotificationPreferences> updateNotificationPreferences({
    required bool nearbyOffersEnabled,
    required bool ordersEnabled,
    required bool pickupRemindersEnabled,
    required bool newsEnabled,
  }) async {
    final body = await _patchJson('/api/v1/notifications/preferences/me', {
      'nearbyOffersEnabled': nearbyOffersEnabled,
      'ordersEnabled': ordersEnabled,
      'pickupRemindersEnabled': pickupRemindersEnabled,
      'newsEnabled': newsEnabled,
    });
    return NotificationPreferences.fromJson(
      body['preferences'] as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    try {
      return await _api.get(path);
    } on BackendApiException catch (error) {
      throw SupportApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _api.post(path, body: payload);
    } on BackendApiException catch (error) {
      throw SupportApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _patchJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _api.patch(path, body: payload);
    } on BackendApiException catch (error) {
      throw SupportApiException.fromBackend(error);
    }
  }
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.nearbyOffersEnabled,
    required this.ordersEnabled,
    required this.pickupRemindersEnabled,
    required this.newsEnabled,
  });

  final bool nearbyOffersEnabled;
  final bool ordersEnabled;
  final bool pickupRemindersEnabled;
  final bool newsEnabled;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      nearbyOffersEnabled: json['nearbyOffersEnabled'] as bool,
      ordersEnabled: json['ordersEnabled'] as bool,
      pickupRemindersEnabled: json['pickupRemindersEnabled'] as bool,
      newsEnabled: json['newsEnabled'] as bool,
    );
  }
}

class SupportApiException implements Exception {
  const SupportApiException({required this.statusCode, required this.message});

  factory SupportApiException.fromBackend(BackendApiException error) {
    return SupportApiException(
      statusCode: error.statusCode,
      message: error.code,
    );
  }

  final int statusCode;
  final String message;

  @override
  String toString() => 'SupportApiException($statusCode): $message';
}

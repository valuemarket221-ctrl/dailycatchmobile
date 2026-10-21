import 'package:http/http.dart' as http;
import 'package:myapp/services/backend_api_client.dart';

class NotificationSummary {
  const NotificationSummary({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.status,
    required this.createdAt,
    this.deliveryAttempts = 0,
    this.lastAttemptAt,
    this.deliveredAt,
    this.failureReason,
    this.readAt,
    this.orderId,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String status;
  final DateTime createdAt;
  final int deliveryAttempts;
  final DateTime? lastAttemptAt;
  final DateTime? deliveredAt;
  final String? failureReason;
  final DateTime? readAt;
  final String? orderId;

  bool get isRead => readAt != null;

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      id: BackendApiClient.requireString(json, 'id'),
      orderId: json['orderId']?.toString(),
      type: BackendApiClient.requireString(json, 'type'),
      title: BackendApiClient.requireString(json, 'title'),
      body: BackendApiClient.requireString(json, 'body'),
      status: BackendApiClient.requireString(json, 'status'),
      deliveryAttempts: BackendApiClient.requireInt(json, 'deliveryAttempts'),
      lastAttemptAt: _optionalDate(json['lastAttemptAt']),
      deliveredAt: _optionalDate(json['deliveredAt']),
      failureReason: json['failureReason']?.toString(),
      readAt: _optionalDate(json['readAt']),
      createdAt: BackendApiClient.requireDate(json, 'createdAt'),
    );
  }

  NotificationSummary copyWith({DateTime? readAt}) {
    return NotificationSummary(
      id: id,
      orderId: orderId,
      type: type,
      title: title,
      body: body,
      status: status,
      deliveryAttempts: deliveryAttempts,
      lastAttemptAt: lastAttemptAt,
      deliveredAt: deliveredAt,
      failureReason: failureReason,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

class NotificationApiService {
  NotificationApiService({
    http.Client? client,
    String? baseUrl,
    BackendApiClient? api,
  }) : _api = api ?? BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<List<NotificationSummary>> getMyNotifications() async {
    final body = await _getJson('/api/v1/notifications/me');

    return _parse(
      () =>
          BackendApiClient.requireObjectList(
            body,
            'notifications',
          ).map(NotificationSummary.fromJson).toList(),
    );
  }

  Future<DateTime> markAsRead(String notificationId) async {
    final body = await _postJson('/api/v1/notifications/$notificationId/read');
    return _parse(() {
      final notification = BackendApiClient.requireObject(body, 'notification');
      return BackendApiClient.requireDate(notification, 'readAt');
    });
  }

  Future<int> markAllAsRead() async {
    final body = await _postJson('/api/v1/notifications/read-all');
    return _parse(() => BackendApiClient.requireInt(body, 'updatedCount'));
  }

  Future<Map<String, dynamic>> _postJson(String path) async {
    try {
      return await _api.post(path);
    } on BackendApiException catch (error) {
      throw NotificationApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    try {
      return await _api.get(path);
    } on BackendApiException catch (error) {
      throw NotificationApiException.fromBackend(error);
    }
  }

  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } on BackendApiException catch (error) {
      throw NotificationApiException.fromBackend(error);
    } catch (_) {
      throw const NotificationApiException(
        statusCode: 200,
        message: 'invalid_backend_response',
      );
    }
  }
}

DateTime? _optionalDate(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

class NotificationApiException implements Exception {
  const NotificationApiException({
    required this.statusCode,
    required this.message,
  });

  factory NotificationApiException.fromBackend(BackendApiException error) {
    return NotificationApiException(
      statusCode: error.statusCode,
      message: error.code,
    );
  }

  final int statusCode;
  final String message;

  @override
  String toString() => 'NotificationApiException($statusCode): $message';
}

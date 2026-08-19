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
      id: json['id'].toString(),
      orderId: json['orderId'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      status: json['status'] as String,
      deliveryAttempts: json['deliveryAttempts'] as int? ?? 0,
      lastAttemptAt:
          json['lastAttemptAt'] == null
              ? null
              : DateTime.parse(json['lastAttemptAt'] as String),
      deliveredAt:
          json['deliveredAt'] == null
              ? null
              : DateTime.parse(json['deliveredAt'] as String),
      failureReason: json['failureReason'] as String?,
      readAt:
          json['readAt'] == null
              ? null
              : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
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

    return (body['notifications'] as List<dynamic>)
        .map(
          (item) => NotificationSummary.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<DateTime> markAsRead(String notificationId) async {
    final body = await _postJson('/api/v1/notifications/$notificationId/read');
    final notification = body['notification'] as Map<String, dynamic>;
    return DateTime.parse(notification['readAt'] as String);
  }

  Future<int> markAllAsRead() async {
    final body = await _postJson('/api/v1/notifications/read-all');
    return body['updatedCount'] as int;
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

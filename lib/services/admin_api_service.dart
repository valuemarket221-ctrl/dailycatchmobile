import 'package:http/http.dart' as http;
import 'package:myapp/services/backend_api_client.dart';

class AdminMetrics {
  const AdminMetrics({
    required this.activeOffers,
    required this.lowStockOffers,
    required this.paidOrders,
    required this.pickedUpOrders,
    required this.refundPendingOrders,
    required this.openSupportTickets,
    required this.highRiskEvents,
    required this.grossRevenue,
    required this.queuedNotifications,
    required this.failedNotifications,
    required this.sentNotificationsToday,
  });

  final int activeOffers;
  final int lowStockOffers;
  final int paidOrders;
  final int pickedUpOrders;
  final int refundPendingOrders;
  final int openSupportTickets;
  final int highRiskEvents;
  final int grossRevenue;
  final int queuedNotifications;
  final int failedNotifications;
  final int sentNotificationsToday;

  factory AdminMetrics.fromJson(Map<String, dynamic> json) {
    return AdminMetrics(
      activeOffers: json['activeOffers'] as int,
      lowStockOffers: json['lowStockOffers'] as int,
      paidOrders: json['paidOrders'] as int,
      pickedUpOrders: json['pickedUpOrders'] as int,
      refundPendingOrders: json['refundPendingOrders'] as int,
      openSupportTickets: json['openSupportTickets'] as int,
      highRiskEvents: json['highRiskEvents'] as int,
      grossRevenue: json['grossRevenue'] as int,
      queuedNotifications: json['queuedNotifications'] as int,
      failedNotifications: json['failedNotifications'] as int,
      sentNotificationsToday: json['sentNotificationsToday'] as int,
    );
  }
}

class AdminApiService {
  AdminApiService({http.Client? client, String? baseUrl})
    : _api = BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<AdminMetrics> getMetrics() async {
    final body = await _getJson('/api/v1/admin/metrics');
    return AdminMetrics.fromJson(body['metrics'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getSupportTickets() async {
    final body = await _getJson('/api/v1/admin/support/tickets');
    return (body['tickets'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getFraudEvents() async {
    final body = await _getJson('/api/v1/admin/fraud-events');
    return (body['events'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getNotificationFailures() async {
    final body = await _getJson('/api/v1/admin/notifications/failures');
    return (body['failures'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getAuditEvents() async {
    final body = await _getJson('/api/v1/admin/audit-events');
    return (body['events'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPartnerApplications() async {
    final body = await _getJson('/api/v1/admin/partner-applications');
    return (body['applications'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPartnerProfiles() async {
    final body = await _getJson('/api/v1/admin/partners/profiles');
    return (body['profiles'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPartnerDocuments() async {
    final body = await _getJson('/api/v1/admin/partners/documents');
    return (body['documents'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> updatePartnerProfileStatus({
    required String userId,
    required String status,
    String? rejectionReason,
  }) {
    return _patchJson('/api/v1/admin/partners/profiles/$userId/status', {
      'status': status,
      if (rejectionReason != null && rejectionReason.isNotEmpty)
        'rejectionReason': rejectionReason,
    });
  }

  Future<Map<String, dynamic>> updatePartnerDocumentStatus({
    required String documentId,
    required String status,
    String? rejectionReason,
  }) {
    return _patchJson('/api/v1/admin/partners/documents/$documentId/status', {
      'status': status,
      if (rejectionReason != null && rejectionReason.isNotEmpty)
        'rejectionReason': rejectionReason,
    });
  }

  Future<Map<String, dynamic>> updatePartnerApplication({
    required String userId,
    required String status,
    String? rejectionReason,
  }) {
    return _patchJson('/api/v1/admin/partner-applications/$userId', {
      'status': status,
      if (rejectionReason != null && rejectionReason.isNotEmpty)
        'rejectionReason': rejectionReason,
    });
  }

  Future<Map<String, dynamic>> refundOrder(String orderId) {
    return _postJson('/api/v1/payments/refunds', {
      'orderId': orderId,
      'reason': 'requested_by_customer',
    });
  }

  Future<Map<String, dynamic>> updateSupportTicketStatus({
    required String ticketId,
    required String status,
  }) {
    return _patchJson('/api/v1/admin/support/tickets/$ticketId', {
      'status': status,
    });
  }

  Future<Map<String, dynamic>> processNotificationQueue({
    int limit = 25,
    bool includeFailed = false,
    int maxAttempts = 3,
  }) {
    return _postJson('/api/v1/notifications/queue/process', {
      'limit': limit,
      'includeFailed': includeFailed,
      'maxAttempts': maxAttempts,
    });
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    try {
      return await _api.get(path);
    } on BackendApiException catch (error) {
      throw AdminApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _api.post(path, body: payload);
    } on BackendApiException catch (error) {
      throw AdminApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _patchJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _api.patch(path, body: payload);
    } on BackendApiException catch (error) {
      throw AdminApiException.fromBackend(error);
    }
  }
}

class AdminApiException implements Exception {
  const AdminApiException({required this.statusCode, required this.message});

  factory AdminApiException.fromBackend(BackendApiException error) {
    return AdminApiException(statusCode: error.statusCode, message: error.code);
  }

  final int statusCode;
  final String message;

  @override
  String toString() => 'AdminApiException($statusCode): $message';
}

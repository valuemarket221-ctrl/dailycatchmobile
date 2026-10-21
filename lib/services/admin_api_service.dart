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
      activeOffers: _int(json['activeOffers']),
      lowStockOffers: _int(json['lowStockOffers']),
      paidOrders: _int(json['paidOrders']),
      pickedUpOrders: _int(json['pickedUpOrders']),
      refundPendingOrders: _int(json['refundPendingOrders']),
      openSupportTickets: _int(json['openSupportTickets']),
      highRiskEvents: _int(json['highRiskEvents']),
      grossRevenue: _int(json['grossRevenue']),
      queuedNotifications: _int(json['queuedNotifications']),
      failedNotifications: _int(json['failedNotifications']),
      sentNotificationsToday: _int(json['sentNotificationsToday']),
    );
  }

  static int _int(Object? value) => value is num ? value.toInt() : 0;
}

class AdminApiService {
  AdminApiService({http.Client? client, String? baseUrl, BackendApiClient? api})
    : _api = api ?? BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<AdminMetrics> getMetrics() async {
    final body = await _getJson('/api/v1/admin/metrics');
    return AdminMetrics.fromJson(
      BackendApiClient.requireObject(body, 'metrics'),
    );
  }

  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    bool? active,
    String? search,
    int limit = 100,
  }) async {
    try {
      final body = await _api.get(
        '/api/v1/admin/users',
        queryParameters: {
          'role': role,
          'active': active?.toString(),
          'search': search,
          'limit': limit.toString(),
        },
      );
      return BackendApiClient.requireObjectList(body, 'users');
    } on BackendApiException catch (error) {
      throw AdminApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    String? role,
    bool? active,
  }) {
    return _patchJson('/api/v1/admin/users/$userId', {
      if (role != null && role.isNotEmpty) 'role': role,
      if (active != null) 'active': active,
    });
  }

  Future<List<Map<String, dynamic>>> getSupportTickets() async {
    final body = await _getJson('/api/v1/admin/support/tickets');
    return BackendApiClient.requireObjectList(body, 'tickets');
  }

  Future<List<Map<String, dynamic>>> getFraudEvents() async {
    final body = await _getJson('/api/v1/admin/fraud-events');
    return BackendApiClient.requireObjectList(body, 'events');
  }

  Future<List<Map<String, dynamic>>> getNotificationFailures() async {
    final body = await _getJson('/api/v1/admin/notifications/failures');
    return BackendApiClient.requireObjectList(body, 'failures');
  }

  Future<List<Map<String, dynamic>>> getAuditEvents() async {
    final body = await _getJson('/api/v1/admin/audit-events');
    return BackendApiClient.requireObjectList(body, 'events');
  }

  Future<List<Map<String, dynamic>>> getPartnerApplications() async {
    final body = await _getJson('/api/v1/admin/partner-applications');
    return BackendApiClient.requireObjectList(body, 'applications');
  }

  Future<List<Map<String, dynamic>>> getPartnerProfiles() async {
    final body = await _getJson('/api/v1/admin/partners/profiles');
    return BackendApiClient.requireObjectList(body, 'profiles');
  }

  Future<List<Map<String, dynamic>>> getPartnerDocuments() async {
    final body = await _getJson('/api/v1/admin/partners/documents');
    return BackendApiClient.requireObjectList(body, 'documents');
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

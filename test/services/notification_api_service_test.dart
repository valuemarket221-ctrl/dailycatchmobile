import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/notification_api_service.dart';

void main() {
  test('loads user notifications with authentication', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'notifications': [
            {
              'id': 'notif_1',
              'orderId': 'ord_1',
              'type': 'order_ready',
              'title': 'Commande prete',
              'body': 'Votre panier est pret.',
              'status': 'queued',
              'deliveryAttempts': 0,
              'createdAt': '2026-08-16T16:30:00.000Z',
            },
          ],
        }),
        200,
      );
    });

    final service = NotificationApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'client-token',
      ),
    );

    final notifications = await service.getMyNotifications();

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/v1/notifications/me');
    expect(capturedRequest.headers['authorization'], 'Bearer client-token');
    expect(notifications.single.id, 'notif_1');
    expect(notifications.single.orderId, 'ord_1');
    expect(notifications.single.isRead, false);
  });

  test('marks a notification as read', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        '{"notification":{"readAt":"2026-08-16T16:35:00.000Z"}}',
        200,
      );
    });

    final service = NotificationApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'client-token',
      ),
    );

    final readAt = await service.markAsRead('notif_1');

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/v1/notifications/notif_1/read');
    expect(readAt.toUtc().toIso8601String(), '2026-08-16T16:35:00.000Z');
  });

  test('marks all notifications as read', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"updatedCount":4}', 200);
    });

    final service = NotificationApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'client-token',
      ),
    );

    final updatedCount = await service.markAllAsRead();

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/v1/notifications/read-all');
    expect(updatedCount, 4);
  });

  test('rejects malformed notifications', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'notifications': [
            {
              'id': 'notif_1',
              'type': 'order_ready',
              'title': 'Commande prete',
              'body': 'Votre panier est pret.',
              'status': 'queued',
              'createdAt': 'not-a-date',
            },
          ],
        }),
        200,
      );
    });

    final service = NotificationApiService(
      api: BackendApiClient(
        client: client,
        tokenProvider: () async => 'client-token',
      ),
    );

    expect(
      service.getMyNotifications,
      throwsA(
        isA<NotificationApiException>()
            .having((error) => error.statusCode, 'statusCode', 200)
            .having(
              (error) => error.message,
              'message',
              'invalid_backend_response',
            ),
      ),
    );
  });

  test('normalizes backend errors', () async {
    final client = MockClient((request) async {
      return http.Response('{"error":"notification_not_found"}', 404);
    });

    final service = NotificationApiService(
      api: BackendApiClient(
        client: client,
        tokenProvider: () async => 'client-token',
      ),
    );

    expect(
      () => service.markAsRead('missing'),
      throwsA(
        isA<NotificationApiException>()
            .having((error) => error.statusCode, 'statusCode', 404)
            .having(
              (error) => error.message,
              'message',
              'notification_not_found',
            ),
      ),
    );
  });
}

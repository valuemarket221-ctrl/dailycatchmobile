import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/support_api_service.dart';

void main() {
  test('creates a support ticket from backend contract', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"ticketId":"sup_123","status":"open"}', 201);
    });

    final service = SupportApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'client-token',
      ),
    );

    final ticketId = await service.createTicket(
      orderId: 'ord_1',
      category: 'order_issue',
      subject: 'Probleme commande',
      message: 'Le panier ne correspond pas.',
    );

    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/v1/support/tickets');
    expect(capturedRequest.headers['authorization'], 'Bearer client-token');
    expect(body['orderId'], 'ord_1');
    expect(body['category'], 'order_issue');
    expect(ticketId, 'sup_123');
  });

  test(
    'registers a push token through a no-content backend response',
    () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204);
      });

      final service = SupportApiService(
        api: BackendApiClient(
          client: client,
          baseUrl: 'http://127.0.0.1:8080',
          tokenProvider: () async => 'client-token',
        ),
      );

      await service.registerPushToken(platform: 'android', token: 'fcm-token');

      final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/api/v1/notifications/device-tokens');
      expect(body['platform'], 'android');
      expect(body['token'], 'fcm-token');
    },
  );

  test('updates push settings and notification preferences', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);

      if (request.url.path == '/api/v1/notifications/device-tokens/me') {
        return http.Response('{"enabled":false,"updatedCount":2}', 200);
      }

      expect(request.url.path, '/api/v1/notifications/preferences/me');
      return http.Response(
        jsonEncode({
          'preferences': {
            'nearbyOffersEnabled': true,
            'ordersEnabled': true,
            'pickupRemindersEnabled': false,
            'newsEnabled': false,
          },
        }),
        200,
      );
    });

    final service = SupportApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'client-token',
      ),
    );

    final updatedCount = await service.updatePushNotificationsEnabled(false);
    final preferences = await service.updateNotificationPreferences(
      nearbyOffersEnabled: true,
      ordersEnabled: true,
      pickupRemindersEnabled: false,
      newsEnabled: false,
    );

    expect(requests, hasLength(2));
    expect(updatedCount, 2);
    expect(preferences.pickupRemindersEnabled, false);
  });

  test('rejects malformed support responses', () async {
    final client = MockClient((request) async {
      return http.Response('{"ticketId":""}', 201);
    });

    final service = SupportApiService(
      api: BackendApiClient(
        client: client,
        tokenProvider: () async => 'client-token',
      ),
    );

    expect(
      () => service.createTicket(
        category: 'order_issue',
        subject: 'Probleme commande',
        message: 'Le panier ne correspond pas.',
      ),
      throwsA(
        isA<SupportApiException>()
            .having((error) => error.statusCode, 'statusCode', 200)
            .having(
              (error) => error.message,
              'message',
              'invalid_backend_response',
            ),
      ),
    );
  });
}

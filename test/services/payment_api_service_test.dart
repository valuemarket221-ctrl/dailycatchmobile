import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/payment_api_service.dart';

void main() {
  test('validates a pickup code against the backend', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        '{"orderId":"ord_1","status":"picked_up"}',
        200,
      );
    });

    final service = PaymentApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'partner-token',
      ),
    );

    final response = await service.completePickup(
      orderId: 'ord_1',
      pickupCode: 'dc_pickup_ord_1_signature',
    );

    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/v1/orders/ord_1/pickup');
    expect(capturedRequest.headers['authorization'], 'Bearer partner-token');
    expect(body['pickupCode'], 'dc_pickup_ord_1_signature');
    expect(response.status, 'picked_up');
  });
}

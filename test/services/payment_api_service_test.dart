import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/payment_api_service.dart';

void main() {
  test('creates a payment intent from backend contract', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        '{"paymentIntentId":"pi_123","clientSecret":"pi_123_secret"}',
        201,
      );
    });

    final service = PaymentApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'client-token',
      ),
    );

    final intent = await service.createPaymentIntent(
      const PaymentIntentRequest(orderId: 'ord_1', customerId: 'cus_1'),
    );

    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/v1/payments/payment-intents');
    expect(capturedRequest.headers['authorization'], 'Bearer client-token');
    expect(body['orderId'], 'ord_1');
    expect(body['customerId'], 'cus_1');
    expect(intent.paymentIntentId, 'pi_123');
    expect(intent.clientSecret, 'pi_123_secret');
  });

  test('loads authenticated orders from backend contract', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'orders': [
            {
              'id': 'ord_1',
              'status': 'pending_payment',
              'amount': 13000,
              'currency': 'xof',
              'deliveryMode': 'pickup',
              'deliveryFee': 0,
              'pickupSlot': "Aujourd'hui 17:00 - 19:00",
              'pickupCode': 'DCYF24',
              'createdAt': '2026-08-16T16:30:00.000Z',
              'items': [
                {
                  'productOfferId': 'offer_1',
                  'storeId': 'store_yoff',
                  'name': 'Panier surprise',
                  'quantity': 1,
                  'unitAmount': 13000,
                },
              ],
            },
          ],
        }),
        200,
      );
    });

    final service = PaymentApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'client-token',
      ),
    );

    final orders = await service.getMyOrders();

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/v1/orders/me');
    expect(capturedRequest.headers['authorization'], 'Bearer client-token');
    expect(orders.single.id, 'ord_1');
    expect(orders.single.items.single['productOfferId'], 'offer_1');
  });

  test('validates a pickup code against the backend', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"orderId":"ord_1","status":"picked_up"}', 200);
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

  test('rejects malformed order responses', () async {
    final client = MockClient((request) async {
      return http.Response('{"orderId":"ord_1"}', 201);
    });

    final service = PaymentApiService(
      api: BackendApiClient(
        client: client,
        tokenProvider: () async => 'client-token',
      ),
    );

    expect(
      () => service.createOrder(
        const CreateOrderRequest(
          items: [CreateOrderItemRequest(productId: 'offer_1', quantity: 1)],
        ),
      ),
      throwsA(
        isA<PaymentApiException>()
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

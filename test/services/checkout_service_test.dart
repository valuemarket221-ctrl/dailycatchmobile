import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/checkout_service.dart';
import 'package:myapp/services/payment_api_service.dart';

void main() {
  test('creates an order from cart items with idempotency', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'orderId': 'ord_123',
          'status': 'pending_payment',
          'amount': 6000,
          'currency': 'XOF',
          'pickupCode': '5287',
        }),
        201,
      );
    });

    final api = BackendApiClient(
      client: client,
      baseUrl: 'http://127.0.0.1:8080',
      tokenProvider: () async => 'client-token',
    );
    final checkout = CheckoutService(
      paymentApiService: PaymentApiService(api: api),
    );

    final order = await checkout.createOrderFromCart(
      idempotencyKey: 'checkout-session-0001',
      pickupSlot: 'Aujourd’hui 18:00 - 19:00',
      deliveryMode: 'pickup',
      items: [CheckoutCartItem(id: 'offer_1', quantity: 2)],
    );

    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(capturedRequest.url.path, '/api/v1/orders');
    expect(capturedRequest.headers['authorization'], 'Bearer client-token');
    expect(body['pickupSlot'], 'Aujourd’hui 18:00 - 19:00');
    expect(body['deliveryMode'], 'pickup');
    expect(body['idempotencyKey'], 'checkout-session-0001');
    expect(body['items'], [
      {'productId': 'offer_1', 'quantity': 2},
    ]);
    expect(order.orderId, 'ord_123');
    expect(order.amount, 6000);
  });

  test('rejects an empty cart before calling the backend', () async {
    var called = false;
    final client = MockClient((request) async {
      called = true;
      return http.Response('{"ok":true}', 200);
    });
    final api = BackendApiClient(
      client: client,
      tokenProvider: () async => 'client-token',
    );
    final checkout = CheckoutService(
      paymentApiService: PaymentApiService(api: api),
    );

    expect(
      () => checkout.createOrderFromCart(
        items: const [],
        pickupSlot: 'Aujourd’hui 18:00 - 19:00',
        deliveryMode: 'pickup',
        idempotencyKey: 'checkout-session-0002',
      ),
      throwsA(
        isA<CheckoutException>().having(
          (error) => error.code,
          'code',
          'empty_cart',
        ),
      ),
    );
    expect(called, false);
  });
}

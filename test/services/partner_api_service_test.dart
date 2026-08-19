import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/partner_api_service.dart';

void main() {
  test('loads validated pickups for a store', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'pickups': [
            {
              'id': 'pickup_1',
              'orderId': 'ord_1',
              'clientUserId': 'dev-client',
              'amount': 10000,
              'currency': 'xof',
              'createdAt': '2026-08-16T16:30:00.000Z',
            },
          ],
        }),
        200,
      );
    });

    final service = PartnerApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'partner-token',
      ),
    );

    final pickups = await service.getStorePickups('store_yoff');

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.path,
      '/api/v1/partner/stores/store_yoff/pickups',
    );
    expect(capturedRequest.headers['authorization'], 'Bearer partner-token');
    expect(pickups.single['orderId'], 'ord_1');
  });

  test('loads store promotions', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'promotions': [
            {
              'id': 'promo_1',
              'storeId': 'store_yoff',
              'title': '-10%',
              'code': 'POISSON10',
              'active': true,
              'usageCount': 4,
            },
          ],
        }),
        200,
      );
    });

    final service = PartnerApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'partner-token',
      ),
    );

    final promotions = await service.getStorePromotions('store_yoff');

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.path,
      '/api/v1/partner/stores/store_yoff/promotions',
    );
    expect(promotions.single['code'], 'POISSON10');
  });

  test('updates promotion active state', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(payload, {'active': false});
      return http.Response(
        jsonEncode({
          'promotion': {
            'id': 'promo_1',
            'storeId': 'store_yoff',
            'title': '-10%',
            'code': 'POISSON10',
            'active': false,
          },
        }),
        200,
      );
    });

    final service = PartnerApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'partner-token',
      ),
    );

    final promotion = await service.setPromotionActive('promo_1', false);

    expect(capturedRequest.method, 'PATCH');
    expect(capturedRequest.url.path, '/api/v1/partner/promotions/promo_1');
    expect(capturedRequest.headers['authorization'], 'Bearer partner-token');
    expect(promotion['active'], false);
  });
}

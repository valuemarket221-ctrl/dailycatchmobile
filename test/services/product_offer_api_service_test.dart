import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/product_offer_api_service.dart';

void main() {
  test('loads product offers from backend contract', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/product-offers');
      expect(request.url.queryParameters['latitude'], '14.69');
      expect(request.url.queryParameters['longitude'], '-17.44');
      expect(request.url.queryParameters['radiusKm'], '25.0');
      expect(request.url.queryParameters['limit'], '20');
      expect(request.url.queryParameters['offset'], '10');
      expect(request.headers.containsKey('authorization'), false);
      return http.Response('''
        {
          "offers": [
            {
              "id": "offer_1",
              "storeId": "store_1",
              "storeName": "Poissonnerie Yoff",
              "name": "Panier surprise",
              "currency": "xof",
              "unitAmount": 3000,
              "originalUnitAmount": 6000,
              "availableQuantity": 3,
              "pickupStartsAt": "2026-08-20T17:00:00.000Z",
              "pickupEndsAt": "2026-08-20T19:00:00.000Z",
              "mediaUrls": ["/api/v1/uploads/offer-media/store_1/photo.jpg"],
              "latitude": "14.7458",
              "longitude": "-17.4572",
              "distanceKm": "0.4"
            }
          ]
        }
        ''', 200);
    });

    final service = ProductOfferApiService(
      client: client,
      baseUrl: 'http://127.0.0.1:8080',
    );

    final offers = await service.getProductOffers(
      latitude: 14.69,
      longitude: -17.44,
      limit: 20,
      offset: 10,
    );

    expect(offers, hasLength(1));
    expect(offers.first.id, 'offer_1');
    expect(offers.first.price, 3000);
    expect(offers.first.originalPrice, 6000);
    expect(offers.first.mediaUrls.single, startsWith('/api/v1/uploads/'));
    expect(offers.first.distanceKm, 0.4);
  });

  test('rejects invalid offer response shape', () async {
    final client = MockClient((request) async {
      return http.Response('{"offers":{}}', 200);
    });

    final service = ProductOfferApiService(
      client: client,
      baseUrl: 'http://127.0.0.1:8080',
    );

    await expectLater(
      service.getProductOffers(),
      throwsA(
        isA<BackendApiException>().having(
          (error) => error.code,
          'code',
          'invalid_backend_response',
        ),
      ),
    );
  });
}

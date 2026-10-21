import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/partner_api_service.dart';

void main() {
  test('uploads offer media through a single-use backend upload intent', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);

      if (request.method == 'POST') {
        expect(request.url.path, '/api/v1/partner/offer-media/upload-intent');
        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        expect(payload['fileName'], 'panier.jpg');
        expect(payload['contentType'], 'image/jpeg');
        expect(payload['sizeBytes'], 4);

        return http.Response(
          jsonEncode({
            'objectKey':
                'offer-media/dev-partner/123e4567-e89b-12d3-a456-426614174000.jpg',
            'storageUrl':
                '/api/v1/uploads/offer-media/dev-partner/123e4567-e89b-12d3-a456-426614174000.jpg',
            'uploadIntentId': 'upl_123',
            'uploadExpiresAt': '2099-08-20T12:30:00.000Z',
            'upload': {
              'method': 'direct_put',
              'url':
                  '/api/v1/uploads/offer-media/dev-partner/123e4567-e89b-12d3-a456-426614174000.jpg',
              'expiresAt': '2099-08-20T12:30:00.000Z',
            },
          }),
          201,
        );
      }

      expect(request.method, 'PUT');
      expect(
        request.url.path,
        '/api/v1/uploads/offer-media/dev-partner/123e4567-e89b-12d3-a456-426614174000.jpg',
      );
      expect(request.headers['authorization'], 'Bearer partner-token');
      expect(request.headers['content-type'], 'image/jpeg');
      expect(request.bodyBytes, [0xff, 0xd8, 0xff, 0xd9]);
      return http.Response(
        jsonEncode({
          'storageUrl':
              '/api/v1/uploads/offer-media/dev-partner/123e4567-e89b-12d3-a456-426614174000.jpg',
        }),
        201,
      );
    });

    final service = PartnerApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'partner-token',
      ),
    );

    final storageUrl = await service.uploadOfferMediaBytes(
      fileName: 'panier.jpg',
      contentType: 'image/jpeg',
      bytes: [0xff, 0xd8, 0xff, 0xd9],
    );

    expect(requests, hasLength(2));
    expect(
      storageUrl,
      '/api/v1/uploads/offer-media/dev-partner/123e4567-e89b-12d3-a456-426614174000.jpg',
    );
  });

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

  test('loads store finance summary', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'summary': {
            'storeId': 'store_yoff',
            'currency': 'xof',
            'availableBalance': 87500,
            'grossRevenue': 120000,
            'commissionAmount': 12000,
            'refundsAmount': 5000,
            'pendingPayoutAmount': 32000,
            'netRevenue': 103000,
            'completedOrders': 12,
            'basketsSold': 46,
            'averageRating': 4.9,
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

    final summary = await service.getStoreFinanceSummary('store_yoff');

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.path,
      '/api/v1/partner/stores/store_yoff/finance/summary',
    );
    expect(summary['availableBalance'], 87500);
    expect(summary['averageRating'], 4.9);
  });

  test('loads store finance transactions with filters', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'transactions': [
            {
              'id': 'revenue:order_1:store_yoff',
              'type': 'revenue',
              'orderId': 'order_1',
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

    final transactions = await service.getStoreFinanceTransactions(
      'store_yoff',
      type: 'revenue',
      limit: 25,
    );

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.path,
      '/api/v1/partner/stores/store_yoff/finance/transactions',
    );
    expect(capturedRequest.url.queryParameters['type'], 'revenue');
    expect(capturedRequest.url.queryParameters['limit'], '25');
    expect(transactions.single['amount'], 10000);
  });

  test('loads partner payout requests', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'payoutRequests': [
            {
              'id': 'payout_1',
              'storeId': 'store_yoff',
              'amount': 50000,
              'currency': 'xof',
              'status': 'pending_review',
              'requestedAt': '2026-08-16T16:30:00.000Z',
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

    final payouts = await service.getStorePayoutRequests('store_yoff');

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.path,
      '/api/v1/partner/stores/store_yoff/payouts',
    );
    expect(payouts.single['status'], 'pending_review');
  });

  test('loads store finance statements', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'statements': [
            {
              'id': 'statement_store_yoff_2026-08',
              'storeId': 'store_yoff',
              'period': '2026-08',
              'periodStart': '2026-08-01T00:00:00.000Z',
              'periodEnd': '2026-08-31T23:59:59.999Z',
              'currency': 'xof',
              'grossRevenue': 120000,
              'commissionAmount': 12000,
              'refundsAmount': 5000,
              'paidPayoutAmount': 0,
              'pendingPayoutAmount': 32000,
              'netRevenue': 103000,
              'generatedAt': '2026-08-24T12:00:00.000Z',
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

    final statements = await service.getStoreFinanceStatements(
      'store_yoff',
      months: 6,
    );

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.path,
      '/api/v1/partner/stores/store_yoff/finance/statements',
    );
    expect(capturedRequest.url.queryParameters['months'], '6');
    expect(statements.single['period'], '2026-08');
    expect(statements.single['netRevenue'], 103000);
  });

  test('creates store finance statement download intent', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'download': {
            'downloadUrl': '/api/v1/partner/statement-downloads/signed-token',
            'expiresAt': '2026-08-24T12:05:00.000Z',
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

    final download = await service.createStoreFinanceStatementDownloadIntent(
      'store_yoff',
      '2026-08',
    );

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.path,
      '/api/v1/partner/stores/store_yoff/finance/statements/2026-08/download-intent',
    );
    expect(
      download['downloadUrl'],
      '/api/v1/partner/statement-downloads/signed-token',
    );
  });

  test('creates partner payment method with masked reference', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(payload, {
        'type': 'mobile_money',
        'label': 'Wave +221 77 *** 45 67',
        'provider': 'wave',
        'accountHolder': 'Moussa Fall',
        'maskedReference': '+22177***4567',
      });
      return http.Response(
        jsonEncode({
          'paymentMethod': {
            'id': 'ppm_1',
            'type': 'mobile_money',
            'label': 'Wave +221 77 *** 45 67',
            'provider': 'wave',
            'accountHolder': 'Moussa Fall',
            'maskedReference': '+22177***4567',
            'active': true,
          },
        }),
        201,
      );
    });

    final service = PartnerApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'partner-token',
      ),
    );

    final paymentMethod = await service.createPartnerPaymentMethod({
      'type': 'mobile_money',
      'label': 'Wave +221 77 *** 45 67',
      'provider': 'wave',
      'accountHolder': 'Moussa Fall',
      'maskedReference': '+22177***4567',
    });

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/v1/partner/payment-methods');
    expect(capturedRequest.headers['authorization'], 'Bearer partner-token');
    expect(paymentMethod['id'], 'ppm_1');
  });

  test('creates partner payout request', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(payload, {
        'paymentMethodId': 'pm_1',
        'amount': 87500,
        'currency': 'xof',
      });
      return http.Response(
        jsonEncode({
          'payoutRequest': {
            'id': 'payout_1',
            'storeId': 'store_yoff',
            'paymentMethodId': 'pm_1',
            'amount': 87500,
            'currency': 'xof',
            'status': 'pending_review',
          },
        }),
        201,
      );
    });

    final service = PartnerApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'partner-token',
      ),
    );

    final payout = await service.createPartnerPayoutRequest(
      storeId: 'store_yoff',
      paymentMethodId: 'pm_1',
      amount: 87500,
    );

    expect(capturedRequest.method, 'POST');
    expect(
      capturedRequest.url.path,
      '/api/v1/partner/stores/store_yoff/payouts',
    );
    expect(capturedRequest.headers['authorization'], 'Bearer partner-token');
    expect(payout['id'], 'payout_1');
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

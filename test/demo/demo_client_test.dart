import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/demo/demo_client.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/payment_api_service.dart';
import 'package:myapp/services/client_api_service.dart';
import 'package:myapp/services/partner_api_service.dart';
import 'package:myapp/services/notification_api_service.dart';
import 'package:myapp/services/message_api_service.dart';
import 'package:myapp/services/support_api_service.dart';
import 'package:myapp/services/admin_api_service.dart';
import 'package:myapp/services/product_offer_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late BackendApiClient api;
  setUp(() {
    SharedPreferences.setMockInitialValues({'userRole': 'client'});
    api = BackendApiClient(
      client: DemoClient(),
      tokenProvider: () async => null,
    );
  });

  Future<Map<String, dynamic>> reserve({
    String key = 'test',
    int quantity = 1,
  }) => api.post(
    '/api/v1/orders',
    body: {
      'idempotencyKey': key,
      'items': [
        {'productId': 'demo_offer_0', 'quantity': quantity},
      ],
    },
  );

  test('all core service DTOs parse seeded offline data', () async {
    expect(
      await ProductOfferApiService(client: DemoClient()).getProductOffers(),
      hasLength(6),
    );
    expect(await PaymentApiService(api: api).getMyOrders(), hasLength(2));
    expect((await ClientApiService(api: api).getMyProfile()).email, isNotEmpty);
    expect(await ClientApiService(api: api).getMyAddresses(), isNotEmpty);
    expect(await ClientApiService(api: api).getMyPaymentMethods(), isNotEmpty);
    expect(
      (await PartnerApiService(api: api).getMyStoreContext())?.storeId,
      'store_yoff',
    );
    expect(
      await PartnerApiService(api: api).getStoreReservations('store_yoff'),
      hasLength(2),
    );
    expect((await AdminApiService(api: api).getMetrics()).activeOffers, 6);
    expect(await MessageApiService(api: api).getConversations(), isNotEmpty);
    expect(
      await NotificationApiService(api: api).getMyNotifications(),
      isNotEmpty,
    );
  });

  test(
    'existing demo geography migrates to Berlin without losing stock',
    () async {
      await reserve(quantity: 2);
      final prefs = await SharedPreferences.getInstance();
      final state =
          jsonDecode(prefs.getString(DemoClient.storageKey)!)
              as Map<String, dynamic>;
      state.remove('mapRegion');
      state['offers'][0]['latitude'] = 14.6928;
      state['offers'][0]['longitude'] = -17.4467;
      await prefs.setString(DemoClient.storageKey, jsonEncode(state));
      final offers =
          (await api.get('/api/v1/product-offers'))['offers'] as List;
      expect(offers.first['latitude'], 52.5200);
      expect(offers.first['longitude'], 13.4050);
      expect(offers.first['availableQuantity'], 6);
      expect((await api.get('/api/v1/orders/me'))['orders'], hasLength(3));
    },
  );

  test(
    'reservation persists and decrements stock only once per idempotency key',
    () async {
      final first = await reserve(quantity: 2);
      final second = await reserve(quantity: 2);
      expect(first['orderId'], second['orderId']);
      expect(first['amount'], 5000);
      final freshApi = BackendApiClient(
        client: DemoClient(),
        tokenProvider: () async => null,
      );
      final offers = await freshApi.get('/api/v1/product-offers');
      expect((offers['offers'] as List).first['availableQuantity'], 6);
      expect((await freshApi.get('/api/v1/orders/me'))['orders'], hasLength(3));
    },
  );

  test('concurrent reservations cannot oversell', () async {
    final outcomes = await Future.wait(
      List.generate(10, (i) async {
        try {
          await reserve(key: 'order_$i');
          return true;
        } on BackendApiException catch (e) {
          expect(e.statusCode, 409);
          return false;
        }
      }),
    );
    expect(outcomes.where((e) => e), hasLength(8));
  });

  test('cancellation restores stock once and remains persisted', () async {
    final order = await reserve();
    await api.post('/api/v1/orders/${order['orderId']}/cancel');
    await api.post('/api/v1/orders/${order['orderId']}/cancel');
    expect(
      ((await api.get('/api/v1/product-offers'))['offers'] as List)
          .first['availableQuantity'],
      8,
    );
    final orders = (await api.get('/api/v1/orders/me'))['orders'] as List;
    expect(orders.first['status'], 'cancelled');
  });

  test(
    'pickup validates code, role and replay; review requires pickup',
    () async {
      final order = await reserve();
      final path = '/api/v1/orders/${order['orderId']}';
      await expectLater(
        api.post('$path/pickup', body: {'pickupCode': order['pickupCode']}),
        throwsA(isA<BackendApiException>()),
      );
      await (await SharedPreferences.getInstance()).setString(
        'userRole',
        'partner',
      );
      await expectLater(
        api.post('$path/pickup', body: {'pickupCode': 'wrong'}),
        throwsA(isA<BackendApiException>()),
      );
      expect(
        (await api.post(
          '$path/pickup',
          body: {'pickupCode': order['pickupCode']},
        ))['status'],
        'picked_up',
      );
      await expectLater(
        api.post('$path/pickup', body: {'pickupCode': order['pickupCode']}),
        throwsA(isA<BackendApiException>()),
      );
      await api.post('$path/review', body: {'rating': 5});
    },
  );

  test(
    'unsupported routes fail explicitly instead of faking success',
    () async {
      await expectLater(
        api.post('/api/v1/unknown'),
        throwsA(isA<BackendApiException>()),
      );
      expect((await api.get('/api/v1/product-offers'))['offers'], hasLength(6));
    },
  );

  test(
    'profile, notification preferences, conversations and offers can change',
    () async {
      await api.patch(
        '/api/v1/client/profile/me',
        body: {'phone': '770000123'},
      );
      expect(
        (await ClientApiService(api: api).getMyProfile()).phone,
        '770000123',
      );
      await api.patch(
        '/api/v1/notifications/preferences/me',
        body: {'newsEnabled': true},
      );
      expect(
        (await SupportApiService(api: api).getNotificationPreferences())
            .newsEnabled,
        true,
      );
      await MessageApiService(
        api: api,
      ).sendMessage(conversationId: 'demo_chat', body: 'Bonjour');
      expect(
        await MessageApiService(api: api).getMessages('demo_chat'),
        hasLength(3),
      );
      await PartnerApiService(
        api: api,
      ).updateOffer('demo_offer_0', {'availableQuantity': 12});
      expect(
        ((await api.get('/api/v1/product-offers'))['offers'] as List)
            .first['availableQuantity'],
        12,
      );
      await DemoClient.reset();
      expect(
        ((await api.get('/api/v1/product-offers'))['offers'] as List)
            .first['availableQuantity'],
        8,
      );
    },
  );
}

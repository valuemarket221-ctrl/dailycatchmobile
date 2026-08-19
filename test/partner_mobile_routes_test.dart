import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/config/router/app_router.dart';
import 'package:myapp/main.dart';
import 'package:myapp/widgets/dailycatch_tile_layer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    DailyCatchTileLayer.debugUseTransparentTiles = true;
    SharedPreferences.setMockInitialValues({'isLoggedIn': false});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpDailyCatch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
          Locale('de', 'DE'),
          Locale('es', 'ES'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('fr', 'FR'),
        startLocale: const Locale('fr', 'FR'),
        useOnlyLangCode: true,
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  const routes = <String>[
    '/partner-dashboard',
    '/partner/add-product',
    '/partner/add-pack',
    '/partner/products',
    '/partner/packs',
    '/partner/inventory',
    '/partner/mobile-dashboard',
    '/partner/baskets',
    '/partner/orders',
    '/partner/scan',
    '/partner/schedules',
    '/partner/analytics',
    '/partner/new-basket',
    '/partner/new-basket/photos',
    '/partner/recurring-slots',
    '/partner/calendar',
    '/partner/opening-hours',
    '/partner/documents-mobile',
    '/partner/validation-status',
    '/partner/validated-pickups',
    '/partner/promotions',
    '/partner/create-promotion',
    '/partner/activity',
    '/partner/stats',
    '/partner/commerce-settings',
    '/partner/revenue-detail',
    '/partner/transactions',
    '/partner/payouts',
    '/partner/payment-coordinates',
    '/partner/invoices',
  ];

  testWidgets('partner mobile routes render on phone viewport', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpDailyCatch(tester);

    const routeFilter = String.fromEnvironment('PARTNER_ROUTE');
    final routesToTest =
        routeFilter.isEmpty
            ? routes
            : routes.where((route) => route == routeFilter);

    for (final route in routesToTest) {
      router.go(route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final exception = tester.takeException();
      if (exception != null) {
        debugPrint(exception.toString());
      }
      expect(exception, isNull, reason: 'Route failed: $route');
      final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
      final hasMaterial = find.byType(Material).evaluate().isNotEmpty;
      expect(
        hasScaffold || hasMaterial,
        isTrue,
        reason: 'No screen for: $route',
      );
    }
  });
}

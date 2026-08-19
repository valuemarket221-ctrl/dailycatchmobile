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
    await tester.pump();
  }

  const mobilePartnerAliases = <String>{
    '/partner-dashboard',
    '/partner/add-product',
    '/partner/add-pack',
    '/partner/products',
    '/partner/packs',
    '/partner/inventory',
    '/partner/orders',
    '/partner/scan',
    '/partner/schedules',
    '/partner/analytics',
  };

  Future<void> openRoute(
    WidgetTester tester,
    String route, {
    Size? viewport,
  }) async {
    final isDashboardRoute =
        route.startsWith('/admin') ||
        (route.startsWith('/partner') && !mobilePartnerAliases.contains(route));
    tester.view.physicalSize =
        viewport ??
        (isDashboardRoute ? const Size(1366, 900) : const Size(390, 844));
    tester.view.devicePixelRatio = 1;
    router.go(route);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final exception = tester.takeException();
    if (exception != null) {
      debugPrint(exception.toString());
    }
    expect(exception, isNull, reason: 'Route failed: $route');
    final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
    final hasMaterial = find.byType(Material).evaluate().isNotEmpty;
    expect(hasScaffold || hasMaterial, isTrue, reason: 'No screen for: $route');
  }

  testWidgets('main client, admin and partner routes render without crashing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDailyCatch(tester);

    const routes = <String>[
      '/login',
      '/role-selection',
      '/register-client',
      '/register-partner',
      '/forgot-password',
      '/home',
      '/map',
      '/search',
      '/favorites',
      '/profile',
      '/settings',
      '/parametre',
      '/help',
      '/legal',
      '/edit-profile',
      '/change-password',
      '/addresses',
      '/payment-methods',
      '/notifications',
      '/notifications-settings',
      '/orders',
      '/pickup',
      '/my-reservations',
      '/pickup-confirmation',
      '/rate-review',
      '/rescued-products',
      '/cart',
      '/payment',
      '/order-confirmation',
      '/store/1',
      '/product',
      '/detail',
      '/offer',
      '/precommande',
      '/admin/dashboard',
      '/admin/partners',
      '/admin/partners/new',
      '/admin/partners/pending',
      '/admin/partners/1',
      '/admin/clients',
      '/admin/clients/1',
      '/admin/orders',
      '/admin/products',
      '/admin/products/new',
      '/admin/deliveries',
      '/admin/revenue',
      '/admin/partner-payments',
      '/admin/settings',
      '/partner-dashboard',
      '/partner/add-product',
      '/partner/add-pack',
      '/partner/products',
      '/partner/packs',
      '/partner/inventory',
      '/partner/orders',
      '/partner/scan',
      '/partner/schedules',
      '/partner/analytics',
    ];

    for (final route in routes) {
      await openRoute(tester, route);
    }

    await openRoute(tester, '/admin/dashboard');
    final newPartnerButton = find.text('Nouveau partenaire');
    if (newPartnerButton.evaluate().isNotEmpty) {
      await tester.tap(newPartnerButton.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/admin/partners/new',
      );
    }

    await openRoute(tester, '/partner-dashboard');
    final scanButton = find.text('Scanner un retrait');
    if (scanButton.evaluate().isNotEmpty) {
      await tester.tap(scanButton.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(router.routeInformationProvider.value.uri.path, '/partner/scan');
    }

    const mobilePartnerRoutes = <String>[
      '/partner/mobile-dashboard',
      '/partner/baskets',
      '/partner/orders',
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

    for (final route in mobilePartnerRoutes) {
      await openRoute(tester, route, viewport: const Size(390, 844));
    }

    router.go('/login');
    await tester.pump();
  });
}

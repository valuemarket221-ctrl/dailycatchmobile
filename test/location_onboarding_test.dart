import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/pages/location_onboarding_page.dart';
import 'package:myapp/pages/onboarding_page.dart';
import 'package:myapp/pages/categories_page.dart';
import 'package:myapp/services/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets(
    'skipping introduction leads to location, then login without a GPS request',
    (tester) async {
      var calls = 0;
      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (_, _) => const OnboardingPage(),
          ),
          GoRoute(
            path: '/permission-location',
            builder:
                (_, _) => LocationOnboardingPage(
                  locate: () async {
                    calls++;
                    return const LocationResult(
                      latitude: 52,
                      longitude: 13,
                      label: 'Test',
                      isFallback: false,
                    );
                  },
                ),
          ),
          GoRoute(
            path: '/login',
            builder: (_, _) => const Scaffold(body: Text('Login destination')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Passer').first);
      await tester.pumpAndSettle();
      expect(find.text('Activer votre position'), findsOneWidget);
      expect(calls, 0);
      await tester.tap(find.text('Plus tard'));
      await tester.pumpAndSettle();
      expect(find.text('Login destination'), findsOneWidget);
      expect(calls, 0);
    },
  );

  testWidgets(
    'location refusal stays recoverable and does not overflow a small phone',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: LocationOnboardingPage(
            locate: () async {
              calls++;
              return const LocationResult(
                latitude: 52,
                longitude: 13,
                label: 'Fallback',
                isFallback: true,
                warning: 'Localisation refusee',
              );
            },
          ),
        ),
      );
      expect(calls, 0);
      await tester.ensureVisible(find.text('Activer la localisation'));
      await tester.tap(find.text('Activer la localisation'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Continuer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('category grid opens the selected category', (tester) async {
    final router = GoRouter(
      initialLocation: '/categories',
      routes: [
        GoRoute(path: '/categories', builder: (_, _) => const CategoriesPage()),
        GoRoute(
          path: '/category-products',
          builder:
              (_, state) => Scaffold(
                body: Text(
                  'Selected: ${state.uri.queryParameters['category']}',
                ),
              ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Poissons'), findsOneWidget);
    await tester.tap(find.text('Poissons'));
    await tester.pumpAndSettle();
    expect(find.text('Selected: Poisson'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

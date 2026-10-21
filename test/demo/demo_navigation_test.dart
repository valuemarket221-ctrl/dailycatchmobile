import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/demo/demo_mode.dart';
import 'package:myapp/main.dart';
import 'package:myapp/config/router/app_router.dart';
import 'package:myapp/utils/local_auth_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
    await EasyLocalization.ensureInitialized();
  });

  test('demo signup persists and signs in without Firebase', () async {
    final route = await LocalAuthSession.registerDemo(
      email: 'visiteur@demo.local',
      password: 'Demo123!',
      name: 'Visiteur',
      role: 'client',
    );
    expect(route, '/home');
    await LocalAuthSession.signOut();
    expect(
      await LocalAuthSession.signIn(
        email: 'visiteur@demo.local',
        password: 'Demo123!',
      ),
      '/home',
    );
    expect(await LocalAuthSession.initialRoute(), '/home');
    await expectLater(
      LocalAuthSession.signIn(email: 'visiteur@demo.local', password: 'bad'),
      throwsA(isA<LocalAuthException>()),
    );
  }, skip: !DemoMode.enabled);

  testWidgets(
    'demo account selector switches client, seller and admin',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('fr', 'FR')],
          path: 'assets/translations',
          fallbackLocale: const Locale('fr', 'FR'),
          startLocale: const Locale('fr', 'FR'),
          useOnlyLangCode: true,
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      router.go('/login');
      await tester.pumpAndSettle();
      for (final entry
          in const {
            'Voir comme client': 'client',
            'Voir comme vendeur': 'partner',
            'Voir comme administrateur': 'admin',
          }.entries) {
        await tester.tap(find.text('Comptes'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();
        expect(
          (await SharedPreferences.getInstance()).getString('userRole'),
          entry.value,
        );
        expect(tester.takeException(), isNull);
      }
    },
    skip: !DemoMode.enabled,
  );
}

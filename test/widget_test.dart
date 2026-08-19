import 'dart:ui' show Locale;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart' show SizedBox;
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': false});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('DailyCatch app renders the splash screen', (
    WidgetTester tester,
  ) async {
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

    expect(find.text('Moins de gaspillage,\nplus de fraîcheur.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();

    expect(
      find.text('Sauvez du bon\npoisson, pas du\npoisson pour rien.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

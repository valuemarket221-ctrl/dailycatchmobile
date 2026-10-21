import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/pages/login_page.dart';

void main() {
  for (final size in [
    const Size(390, 844),
    const Size(320, 568),
    const Size(1280, 800),
  ]) {
    testWidgets('Login is centered and usable at $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      final top = tester.getTopLeft(find.text('DailyCatch')).dy;
      final bottom =
          tester
              .getBottomRight(
                find.widgetWithText(TextButton, 'Créer un compte'),
              )
              .dy;
      expect((top + bottom) / 2, closeTo(size.height / 2, 2));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();
      expect(find.text('Email requis'), findsOneWidget);
      expect(find.text('Mot de passe requis'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Login scrolls with keyboard and supports password visibility', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.viewInsets = const FakeViewPadding(bottom: 340);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Afficher le mot de passe'));
    await tester.tap(find.byTooltip('Afficher le mot de passe'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).last),
      isNotNull,
    );
    expect(find.byTooltip('Masquer le mot de passe'), findsOneWidget);
    await tester.ensureVisible(find.text('Créer un compte'));
    expect(find.text('Créer un compte').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

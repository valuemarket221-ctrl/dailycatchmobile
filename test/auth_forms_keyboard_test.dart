import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/pages/role_selection_page.dart';
import 'package:myapp/pages/register_client_page.dart';
import 'package:myapp/pages/register_partner_page.dart';
import 'package:myapp/pages/forget_page.dart';
import 'package:myapp/pages/change_password_page.dart';
import 'package:myapp/pages/partner/add_product_page.dart';
import 'package:myapp/pages/partner/add_pack_page.dart';
import 'package:myapp/pages/Admin/admin_partner_registration_page.dart';

void main() {
  testWidgets('All seller steps remain scrollable with keyboard', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MaterialApp(home: RegisterPartnerPage()));
    await tester.pumpAndSettle();
    final values = [
      ['Test User', '0123456789', 'test@example.com', 'test-password'],
      ['Test Store', 'Fresh food', '1 Main Street', 'Berlin', '0123456789'],
      ['12345678901234', 'TESTVAT', 'TESTIBAN', 'https://example.com'],
    ];
    for (var step = 0; step < values.length; step++) {
      final fields = find.byType(TextFormField);
      expect(fields.evaluate().length, values[step].length);
      for (var index = 0; index < values[step].length; index++) {
        await tester.ensureVisible(fields.at(index));
        await tester.enterText(fields.at(index), values[step][index]);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      final action = find.text(step == 2 ? 'Envoyer' : 'Continuer');
      await tester.ensureVisible(action);
      expect(action.hitTestable(), findsOneWidget);
      if (step < 2) {
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  final pages = <String, Widget>{
    'client': const RegisterClientPage(),
    'partner': const RegisterPartnerPage(),
    'reset': const ForgotPasswordPage(),
    'password': const ChangePasswordPage(),
    'product': const Scaffold(body: AddProductPage()),
    'pack': const Scaffold(body: AddPackPage()),
    'admin partner registration': const PartnerRegistrationPage(),
  };
  for (final entry in pages.entries) {
    for (final size in [const Size(568, 320), const Size(320, 568)]) {
      testWidgets('${entry.key}: large text and keyboard at $size', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.view.viewInsets = const FakeViewPadding(bottom: 150);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpWidget(
          MaterialApp(
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.5)),
                  child: child!,
                ),
            home: entry.value,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final fields = find.byType(TextFormField);
        for (var index = 0; index < fields.evaluate().length; index++) {
          await tester.ensureVisible(fields.at(index));
          await tester.enterText(fields.at(index), 'test');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
    testWidgets('${entry.key}: fields stay accessible with keyboard', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(MaterialApp(home: entry.value));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final fields = find.byType(TextFormField);
      expect(fields, findsWidgets);
      final width = tester.getSize(fields.last).width;
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      for (var index = 0; index < fields.evaluate().length; index++) {
        final field = fields.at(index);
        await tester.ensureVisible(field);
        await tester.enterText(field, 'test');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(tester.getSize(fields.last).width, width);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('Role selection is centered', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: RoleSelectionPage()));
    await tester.pumpAndSettle();
    final top = tester.getTopLeft(find.text('DailyCatch')).dy;
    final bottom = tester.getBottomRight(find.text('J’ai déjà un compte')).dy;
    expect((top + bottom) / 2, closeTo(422, 5));
    expect(tester.takeException(), isNull);
  });
}

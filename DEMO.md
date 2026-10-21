# DailyCatch Demo

> ARCHIVE (20 October 2026): these instructions apply only to older APKs.
> The current application no longer enables demo mode, local test accounts or
> mock API fallbacks. The demo build script now refuses to generate an APK.
> See PRODUCTION_READINESS.md for the current status. Existing APK files are
> not updated by source changes.

Build a separate, offline demonstration APK:

```bash
FLUTTER_BIN=/home/cherif/flutter/bin/flutter bash scripts/build_demo_apk.sh
```

Artifact: `build/app/outputs/flutter-apk/DailyCatch-Demo.apk`.
Application ID: `com.dailycatch.app.demo`; label: `DailyCatch Demo`.
This is a debug-signed demonstration, not a Play Store production build.
The demo is explicitly enabled by `DEMO_MODE=true` and disabled in release mode.
No Firebase credentials, API server or Stripe keys are needed.

## Trying the app

Install the APK, open it, then use **Comptes** in the top demo bar to select
client, seller or administrator. The same menu resets the seeded business data.
Manual login also works:

| Role | Email | Password |
| --- | --- | --- |
| Client | client@dailycatch.local | client |
| Seller | vendeur@dailycatch.local | vendeur |
| Admin | admin@dailycatch.local | admin |
| Support | support@dailycatch.local | support |

Only use fictional information. New demo registrations are stored on the device
(including their demo passwords), not in Firebase. Business data persists after
closing the app. All demo roles share one simulated marketplace on this device;
devices do not synchronize.

1. Client: browse baskets, add to cart, simulate payment, view the pickup code.
2. Seller: view reservations, scan the simulated QR or enter a pickup code.
3. Client: view the collected order and submit a review, or cancel another order.
4. Seller: modify stock/offers, schedules, payment methods and request a simulated payout.
5. Admin: view metrics, partners and users; change statuses and resolve support tickets.
6. Edit a profile/address, send a simulated conversation message and read notifications.

The preloaded paid reservation has pickup code `123456`.
Photos and fonts are bundled. The geographic map requires Internet and starts
in Berlin, Germany, with nearby fictional offers. No GPS permission
is required by the demo location service. Payments, refunds, documents, statements,
support replies and payouts are simulated. Notifications appear in the app;
no real push or email is sent. No bank card is charged.

## Checks

```bash
flutter analyze
flutter test
flutter test --dart-define=DEMO_MODE=true test/demo test/ui_route_smoke_test.dart test/partner_mobile_routes_test.dart
```

Widget and service tests do not replace an installed-device check. Before sending
the APK, verify launch in airplane mode, client checkout, seller pickup, account
switching and persistence after closing and reopening the app on an Android phone.

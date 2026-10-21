import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/demo/demo_mode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/config/router/app_router.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/providers/locale_provider.dart';
import 'package:myapp/providers/partner_provider.dart';
import 'package:myapp/services/push_token_registration_service.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/utils/api_environment.dart';
import 'package:myapp/utils/environment.dart';
import 'package:provider/provider.dart';

// Options de configuration Firebase pour votre projet.
final firebaseOptions = FirebaseOptions(
  apiKey: Environment.firebaseApiKey,
  authDomain: Environment.firebaseAuthDomain,
  projectId: Environment.firebaseProjectId,
  storageBucket: Environment.firebaseStorageBucket,
  messagingSenderId: Environment.firebaseMessagingSenderId,
  appId: Environment.firebaseAppId,
);

void main() async {
  // Assure que les liaisons Flutter sont prêtes avant d'exécuter du code natif.
  WidgetsFlutterBinding.ensureInitialized();
  if (DemoMode.enabled) GoogleFonts.config.allowRuntimeFetching = false;
  ApiEnvironment.validateRuntimeConfiguration();
  Environment.validateRuntimeConfiguration();
  PaintingBinding.instance.imageCache.maximumSize = 120;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 120 << 20;
  usePathUrlStrategy();
  // Initialise EasyLocalization
  await EasyLocalization.ensureInitialized();
  // Initialise les données de date pour intl
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('de_DE', null);
  final firebaseInitialized = await _initializeFirebase();
  if (firebaseInitialized) {
    PushTokenRegistrationService().registerDeviceToken().ignore();
  }

  if (!DemoMode.enabled &&
      !kIsWeb &&
      ApiEnvironment.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = ApiEnvironment.stripePublishableKey;
    await Stripe.instance.applySettings();
  }
  runApp(
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
}

Future<bool> _initializeFirebase() async {
  if (DemoMode.enabled) return false;
  if (Environment.isFirebaseConfigured) {
    await Firebase.initializeApp(options: firebaseOptions);
    return true;
  }

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      return true;
    } catch (error) {
      if (kReleaseMode) rethrow;
      debugPrint(
        'Native Firebase configuration unavailable: authentication unavailable.',
      );
      return false;
    }
  }

  if (kReleaseMode) {
    throw StateError(
      'Firebase configuration is missing. Provide FIREBASE_* values with --dart-define.',
    );
  }

  debugPrint('Firebase configuration missing: authentication unavailable.');
  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => PartnerProvider()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        title: 'DailyCatch',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

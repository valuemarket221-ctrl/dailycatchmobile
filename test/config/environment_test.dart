import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/utils/api_environment.dart';
import 'package:myapp/utils/environment.dart';

void main() {
  test('does not hardcode Firebase configuration', () {
    expect(Environment.firebaseApiKey, isEmpty);
    expect(Environment.firebaseAuthDomain, isEmpty);
    expect(Environment.firebaseProjectId, isEmpty);
    expect(Environment.firebaseStorageBucket, isEmpty);
    expect(Environment.firebaseMessagingSenderId, isEmpty);
    expect(Environment.firebaseAppId, isEmpty);
    expect(Environment.isFirebaseConfigured, false);
  });

  test('does not hardcode sensitive API or payment keys', () {
    expect(ApiEnvironment.apiKey, isEmpty);
    expect(ApiEnvironment.stripePublishableKey, isEmpty);
  });

  test('keeps safe local defaults for non-sensitive development settings', () {
    expect(ApiEnvironment.baseUrl, 'http://127.0.0.1:8080');
    expect(
      ApiEnvironment.mapTileUrlTemplate,
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
  });

  test('reports unsafe mobile release configuration', () {
    expect(
      ApiEnvironment.releaseConfigurationIssues(
        apiBaseUrl: 'http://127.0.0.1:8080',
        devApiKey: 'dev-key',
        publishableKey: 'pk_test_replace_me',
        tileUrlTemplate: 'http://tiles.example.test/{z}/{x}/{y}.png',
        tileUserAgentPackageName: 'replace_me',
        demoFallbacksEnabled: true,
      ),
      containsAll([
        'API_BASE_URL must be an HTTPS absolute URL',
        'API_KEY must not be embedded in a release build',
        'DEMO_FALLBACKS_ENABLED must be false in release builds',
        'STRIPE_PUBLISHABLE_KEY must not use a test key in release',
        'STRIPE_PUBLISHABLE_KEY must not use a placeholder value',
        'MAP_TILE_URL_TEMPLATE must not use a placeholder value',
        'MAP_TILE_URL_TEMPLATE must use HTTPS in release',
        'MAP_TILE_USER_AGENT_PACKAGE_NAME must be explicitly set for release builds',
      ]),
    );
  });

  test('rejects local API origins even over HTTPS', () {
    expect(
      ApiEnvironment.releaseConfigurationIssues(
        apiBaseUrl: 'https://localhost:8080',
      ),
      contains('API_BASE_URL must not point to a local host'),
    );
  });

  test('accepts safe mobile release configuration shape', () {
    expect(
      ApiEnvironment.releaseConfigurationIssues(
        apiBaseUrl: 'https://api.dailycatch.sn',
        publishableKey: 'pk_live_dailycatch_public_key',
        tileUrlTemplate: 'https://tiles.dailycatch.sn/{z}/{x}/{y}.png',
        tileUserAgentPackageName: 'com.dailycatch.app',
        demoFallbacksEnabled: false,
      ),
      isEmpty,
    );
  });

  test('requires a live Stripe publishable key for release', () {
    expect(
      ApiEnvironment.releaseConfigurationIssues(
        apiBaseUrl: 'https://api.dailycatch.sn',
        publishableKey: 'dailycatch_live_publishable_key',
        tileUrlTemplate: 'https://tiles.dailycatch.sn/{z}/{x}/{y}.png',
        tileUserAgentPackageName: 'com.dailycatch.app',
        demoFallbacksEnabled: false,
      ),
      contains(
        'STRIPE_PUBLISHABLE_KEY must use a live publishable key in release',
      ),
    );
  });

  test('requires explicit production map configuration for release', () {
    expect(
      ApiEnvironment.releaseConfigurationIssues(
        apiBaseUrl: 'https://api.dailycatch.sn',
        publishableKey: 'pk_live_dailycatch_public_key',
        tileUrlTemplate: ApiEnvironment.mapTileUrlTemplate,
        tileUserAgentPackageName: 'com.dailycatch.app',
        demoFallbacksEnabled: false,
      ),
      contains(
        'MAP_TILE_URL_TEMPLATE must be explicitly set for release builds',
      ),
    );

    expect(
      ApiEnvironment.releaseConfigurationIssues(
        apiBaseUrl: 'https://api.dailycatch.sn',
        publishableKey: 'pk_live_dailycatch_public_key',
        tileUrlTemplate: 'https://tiles.dailycatch.sn/{z}/{x}.png',
        tileUserAgentPackageName: 'com.dailycatch.app',
        demoFallbacksEnabled: false,
      ),
      contains('MAP_TILE_URL_TEMPLATE must include {y}'),
    );
  });

  test('reports unsafe Firebase release configuration', () {
    expect(
      Environment.releaseConfigurationIssues(
        apiKey: 'replace_me',
        authDomain: '',
        projectId: 'local-dev',
        storageBucket: 'dailycatch.example.test',
        messagingSenderId: '',
        appId: 'replace_me',
      ),
      containsAll([
        'FIREBASE_API_KEY must not use a placeholder value',
        'FIREBASE_AUTH_DOMAIN is required in release builds',
        'FIREBASE_PROJECT_ID must not use a placeholder value',
        'FIREBASE_STORAGE_BUCKET must not use a placeholder value',
        'FIREBASE_MESSAGING_SENDER_ID is required in release builds',
        'FIREBASE_APP_ID must not use a placeholder value',
      ]),
    );
  });

  test('accepts safe Firebase release configuration shape', () {
    expect(
      Environment.releaseConfigurationIssues(
        apiKey: 'ci-mobile-api-key',
        authDomain: 'dailycatch-ci.firebaseapp.com',
        projectId: 'dailycatch-ci',
        storageBucket: 'dailycatch-ci.appspot.com',
        messagingSenderId: '1234567890',
        appId: '1:1234567890:android:abcdef123456',
      ),
      isEmpty,
    );
  });
}

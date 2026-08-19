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
      ),
      containsAll([
        'API_BASE_URL must be an HTTPS absolute URL',
        'API_KEY must not be embedded in a release build',
        'STRIPE_PUBLISHABLE_KEY must not use a test key in release',
        'STRIPE_PUBLISHABLE_KEY must not use a placeholder value',
        'MAP_TILE_URL_TEMPLATE must not use a placeholder value',
        'MAP_TILE_URL_TEMPLATE must use HTTPS in release',
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
        publishableKey: 'dailycatch_live_publishable_key',
      ),
      isEmpty,
    );
  });
}

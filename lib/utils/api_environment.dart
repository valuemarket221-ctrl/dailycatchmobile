import 'package:flutter/foundation.dart';

class ApiEnvironment {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  static const apiKey = String.fromEnvironment('API_KEY');

  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  static const mapTileUrlTemplate = String.fromEnvironment(
    'MAP_TILE_URL_TEMPLATE',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const mapTileUserAgentPackageName = String.fromEnvironment(
    'MAP_TILE_USER_AGENT_PACKAGE_NAME',
    defaultValue: 'com.dailycatch.app',
  );

  static void validateRuntimeConfiguration() {
    if (!kReleaseMode) return;

    final issues = releaseConfigurationIssues();
    if (issues.isNotEmpty) {
      throw StateError('Invalid release configuration: ${issues.join('; ')}');
    }
  }

  static List<String> releaseConfigurationIssues({
    String apiBaseUrl = baseUrl,
    String devApiKey = apiKey,
    String publishableKey = stripePublishableKey,
    String tileUrlTemplate = mapTileUrlTemplate,
  }) {
    final issues = <String>[];
    final apiUri = Uri.tryParse(apiBaseUrl);

    if (_isPlaceholder(apiBaseUrl)) {
      issues.add('API_BASE_URL must not use a placeholder value');
    }

    if (apiUri == null || apiUri.scheme != 'https' || apiUri.host.isEmpty) {
      issues.add('API_BASE_URL must be an HTTPS absolute URL');
    } else if (_isLocalHost(apiUri.host)) {
      issues.add('API_BASE_URL must not point to a local host');
    }

    if (devApiKey.isNotEmpty) {
      issues.add('API_KEY must not be embedded in a release build');
    }

    if (publishableKey.startsWith('pk_test_')) {
      issues.add('STRIPE_PUBLISHABLE_KEY must not use a test key in release');
    }
    if (_isPlaceholder(publishableKey)) {
      issues.add('STRIPE_PUBLISHABLE_KEY must not use a placeholder value');
    }

    final tileUri = Uri.tryParse(tileUrlTemplate);
    if (_isPlaceholder(tileUrlTemplate)) {
      issues.add('MAP_TILE_URL_TEMPLATE must not use a placeholder value');
    }
    if (tileUri == null || tileUri.scheme != 'https') {
      issues.add('MAP_TILE_URL_TEMPLATE must use HTTPS in release');
    }

    return issues;
  }

  static bool _isLocalHost(String host) {
    final normalized = host.toLowerCase();
    return normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '0.0.0.0' ||
        normalized.endsWith('.local');
  }

  static bool _isPlaceholder(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('replace_me') ||
        normalized.contains('changeme') ||
        normalized.contains('example.test');
  }
}

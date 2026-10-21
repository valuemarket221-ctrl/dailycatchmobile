import 'package:flutter/foundation.dart';

/// Configuration d'environnement sécurisée
class Environment {
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');

  static const firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
  );

  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );

  static const firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );

  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');

  static const firebaseWebVapidKey = String.fromEnvironment(
    'FIREBASE_WEB_VAPID_KEY',
  );

  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAuthDomain.isNotEmpty &&
      firebaseProjectId.isNotEmpty &&
      firebaseStorageBucket.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      !_isPlaceholder(firebaseApiKey) &&
      !_isPlaceholder(firebaseProjectId) &&
      !_isPlaceholder(firebaseAppId);

  static void validateRuntimeConfiguration() {
    if (!kReleaseMode) return;

    final issues = releaseConfigurationIssues();
    if (issues.isNotEmpty) {
      throw StateError(
        'Invalid Firebase release configuration: ${issues.join('; ')}',
      );
    }
  }

  static List<String> releaseConfigurationIssues({
    String apiKey = firebaseApiKey,
    String authDomain = firebaseAuthDomain,
    String projectId = firebaseProjectId,
    String storageBucket = firebaseStorageBucket,
    String messagingSenderId = firebaseMessagingSenderId,
    String appId = firebaseAppId,
  }) {
    final issues = <String>[];
    final values = <String, String>{
      'FIREBASE_API_KEY': apiKey,
      'FIREBASE_AUTH_DOMAIN': authDomain,
      'FIREBASE_PROJECT_ID': projectId,
      'FIREBASE_STORAGE_BUCKET': storageBucket,
      'FIREBASE_MESSAGING_SENDER_ID': messagingSenderId,
      'FIREBASE_APP_ID': appId,
    };

    for (final entry in values.entries) {
      if (entry.value.isEmpty) {
        issues.add('${entry.key} is required in release builds');
      } else if (_isPlaceholder(entry.value)) {
        issues.add('${entry.key} must not use a placeholder value');
      }
    }

    if (appId.isNotEmpty && !appId.startsWith('1:')) {
      issues.add('FIREBASE_APP_ID must use a Firebase app id');
    }

    return issues;
  }

  static bool _isPlaceholder(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('replace_me') ||
        normalized.contains('local_dev') ||
        normalized.contains('local-dev') ||
        normalized.contains('changeme') ||
        normalized.contains('example.test') ||
        normalized == 'todo' ||
        normalized == 'null';
  }
}

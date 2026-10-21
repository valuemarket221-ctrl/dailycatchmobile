import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/utils/environment.dart';
import 'package:myapp/utils/api_environment.dart';

void main() {
  test('release configuration is valid before delivering an artifact', () {
    expect(Environment.releaseConfigurationIssues(), isEmpty);
    expect(ApiEnvironment.releaseConfigurationIssues(), isEmpty);
    expect(Environment.firebaseWebVapidKey, isNotEmpty,
        reason: 'Web push requires FIREBASE_WEB_VAPID_KEY');
  }, skip: !const bool.fromEnvironment('VALIDATE_RELEASE_CONFIG'));
}

import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/demo/demo_mode.dart';
import 'package:myapp/utils/api_environment.dart';
import 'package:myapp/utils/local_auth_session.dart';

void main() {
  test('application cannot enable demo or local authentication', () async {
    expect(DemoMode.enabled, isFalse);
    expect(ApiEnvironment.isDemoFallbackAllowed, isFalse);
    expect(LocalAuthSession.isDevelopmentAuthAllowed, isFalse);
    expect(LocalAuthSession.isLocalEmail('admin@dailycatch.local'), isFalse);
    expect(
      await LocalAuthSession.signIn(
        email: 'admin@dailycatch.local',
        password: 'admin',
      ),
      isNull,
    );
  });
}

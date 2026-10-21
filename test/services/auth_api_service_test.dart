import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/auth_api_service.dart';
import 'package:myapp/services/backend_api_client.dart';

void main() {
  test('loads current backend auth session', () async {
    final service = AuthApiService(
      api: BackendApiClient(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/me');
        expect(request.headers['authorization'], 'Bearer firebase-token');
        return http.Response(
          '''
          {
            "session": {
              "user": {
                "uid": "user_1",
                "email": "client@dailycatch.sn",
                "displayName": "Client DailyCatch",
                "role": "client"
              },
              "homeRoute": "/home"
            }
          }
          ''',
          200,
        );
      }),
      baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'firebase-token',
      ),
    );

    final session = await service.getCurrentSession();

    expect(session.role, 'client');
    expect(session.homeRoute, '/home');
    expect(session.email, 'client@dailycatch.sn');
  });

  test('registers partner and reads validation route', () async {
    final service = AuthApiService(
      api: BackendApiClient(
        client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/register-partner');
        expect(request.method, 'POST');
        return http.Response(
          '''
          {
            "session": {
              "user": {
                "uid": "partner_1",
                "email": "vendeur@dailycatch.sn",
                "displayName": "Moussa Fall",
                "role": "partner"
              },
              "partnerProfile": {
                "status": "pending_review",
                "storeName": "Poissonnerie Yoff"
              },
              "homeRoute": "/partner/validation-status"
            }
          }
          ''',
          201,
        );
        }),
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'firebase-token',
      ),
    );

    final session = await service.registerPartner(
      displayName: 'Moussa Fall',
      email: 'vendeur@dailycatch.sn',
      storeName: 'Poissonnerie Yoff',
      commerceType: 'fish_shop',
    );

    expect(session.role, 'partner');
    expect(session.partnerProfile?['status'], 'pending_review');
    expect(session.homeRoute, '/partner/validation-status');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';

void main() {
  test('sends bearer token for authenticated requests', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"ok":true}', 200);
    });

    final api = BackendApiClient(
      client: client,
      baseUrl: 'http://127.0.0.1:8080/',
      tokenProvider: () async => 'firebase-token',
    );

    final body = await api.get('/api/v1/orders/me');

    expect(body['ok'], true);
    expect(
      capturedRequest.url.toString(),
      'http://127.0.0.1:8080/api/v1/orders/me',
    );
    expect(capturedRequest.headers['authorization'], 'Bearer firebase-token');
  });

  test('does not send bearer token for public requests', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"offers":[]}', 200);
    });

    final api = BackendApiClient(
      client: client,
      baseUrl: 'http://127.0.0.1:8080',
      tokenProvider: () async => 'firebase-token',
    );

    await api.get('/api/v1/product-offers', authenticated: false);

    expect(capturedRequest.headers.containsKey('authorization'), false);
  });

  test('throws structured backend errors', () async {
    final client = MockClient((request) async {
      return http.Response('{"error":"forbidden","requestId":"req_123"}', 403);
    });

    final api = BackendApiClient(
      client: client,
      tokenProvider: () async => null,
    );

    expect(
      () => api.get('/api/v1/admin/metrics'),
      throwsA(
        isA<BackendApiException>()
            .having((error) => error.statusCode, 'statusCode', 403)
            .having((error) => error.code, 'code', 'forbidden')
            .having((error) => error.requestId, 'requestId', 'req_123'),
      ),
    );
  });

  test('normalizes non JSON backend errors', () async {
    final client = MockClient((request) async {
      return http.Response('<html>unavailable</html>', 502);
    });

    final api = BackendApiClient(
      client: client,
      tokenProvider: () async => null,
    );

    expect(
      () => api.get('/api/v1/admin/metrics'),
      throwsA(
        isA<BackendApiException>()
            .having((error) => error.statusCode, 'statusCode', 502)
            .having((error) => error.code, 'code', 'backend_http_502'),
      ),
    );
  });

  test('rejects successful responses that are not JSON objects', () async {
    final client = MockClient((request) async {
      return http.Response('[1,2,3]', 200);
    });

    final api = BackendApiClient(
      client: client,
      tokenProvider: () async => null,
    );

    expect(
      () => api.get('/api/v1/admin/metrics'),
      throwsA(
        isA<BackendApiException>()
            .having((error) => error.statusCode, 'statusCode', 200)
            .having((error) => error.code, 'code', 'invalid_backend_response'),
      ),
    );
  });

  test('normalizes network errors', () async {
    final client = MockClient((request) async {
      throw http.ClientException('Connection refused', request.url);
    });

    final api = BackendApiClient(
      client: client,
      tokenProvider: () async => null,
    );

    expect(
      () => api.get('/api/v1/admin/metrics'),
      throwsA(
        isA<BackendApiException>()
            .having((error) => error.statusCode, 'statusCode', 0)
            .having((error) => error.code, 'code', 'network_unavailable'),
      ),
    );
  });

  test('normalizes request timeouts', () async {
    final client = MockClient((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return http.Response('{"ok":true}', 200);
    });

    final api = BackendApiClient(
      client: client,
      tokenProvider: () async => null,
      timeout: const Duration(milliseconds: 1),
    );

    expect(
      () => api.get('/api/v1/admin/metrics'),
      throwsA(
        isA<BackendApiException>()
            .having((error) => error.statusCode, 'statusCode', 0)
            .having((error) => error.code, 'code', 'request_timeout'),
      ),
    );
  });

  test('uploads raw bytes with authentication headers', () async {
    late http.Request capturedRequest;
    late List<int> capturedBytes;
    final client = MockClient((request) async {
      capturedRequest = request;
      capturedBytes = request.bodyBytes;
      return http.Response(
        '{"storageUrl":"/api/v1/uploads/offer-media/dev/photo.jpg"}',
        201,
      );
    });

    final api = BackendApiClient(
      client: client,
      baseUrl: 'http://127.0.0.1:8080',
      tokenProvider: () async => 'partner-token',
    );

    final body = await api.putBytes(
      '/api/v1/uploads/offer-media/dev/photo.jpg',
      bytes: [1, 2, 3],
      contentType: 'image/jpeg',
    );

    expect(body['storageUrl'], '/api/v1/uploads/offer-media/dev/photo.jpg');
    expect(capturedRequest.method, 'PUT');
    expect(capturedRequest.headers['authorization'], 'Bearer partner-token');
    expect(capturedRequest.headers['content-type'], 'image/jpeg');
    expect(capturedBytes, [1, 2, 3]);
  });

  test('sends authenticated delete requests', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"offer":{"id":"offer_1","active":false}}', 200);
    });

    final api = BackendApiClient(
      client: client,
      baseUrl: 'http://127.0.0.1:8080',
      tokenProvider: () async => 'partner-token',
    );

    final body = await api.delete('/api/v1/partner/offers/offer_1');

    expect(capturedRequest.method, 'DELETE');
    expect(capturedRequest.headers['authorization'], 'Bearer partner-token');
    expect((body['offer'] as Map<String, dynamic>)['active'], false);
  });
}

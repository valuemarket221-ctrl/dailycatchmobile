import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myapp/utils/api_environment.dart';
import 'package:myapp/utils/local_auth_session.dart';

class BackendApiClient {
  BackendApiClient({
    http.Client? client,
    String? baseUrl,
    Future<String?> Function()? tokenProvider,
    Duration? timeout,
  }) : _client = client ?? http.Client(),
       _baseUrl = (baseUrl ?? ApiEnvironment.baseUrl).replaceAll(
         RegExp(r'/$'),
         '',
       ),
       _tokenProvider = tokenProvider ?? LocalAuthSession.getBearerToken,
       _timeout = timeout ?? const Duration(seconds: 20);

  final http.Client _client;
  final String _baseUrl;
  final Future<String?> Function() _tokenProvider;
  final Duration _timeout;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String?> queryParameters = const {},
    bool authenticated = true,
  }) async {
    final response = await _send(
      _client.get(
        _uri(path, queryParameters),
        headers: await _headers(authenticated: authenticated),
      ),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic> body = const {},
    bool authenticated = true,
  }) async {
    final response = await _send(
      _client.post(
        _uri(path),
        headers: await _headers(
          authenticated: authenticated,
          hasJsonBody: true,
        ),
        body: jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = true,
  }) async {
    final response = await _send(
      _client.put(
        _uri(path),
        headers: await _headers(
          authenticated: authenticated,
          hasJsonBody: true,
        ),
        body: jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> putBytes(
    String path, {
    required List<int> bytes,
    required String contentType,
    bool authenticated = true,
  }) async {
    final headers = await _headers(authenticated: authenticated);
    final response = await _send(
      _client.put(
        _uri(path),
        headers: {...headers, 'content-type': contentType},
        body: bytes,
      ),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = true,
  }) async {
    final response = await _send(
      _client.patch(
        _uri(path),
        headers: await _headers(
          authenticated: authenticated,
          hasJsonBody: true,
        ),
        body: jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool authenticated = true,
  }) async {
    final response = await _send(
      _client.delete(
        _uri(path),
        headers: await _headers(authenticated: authenticated),
      ),
    );
    return _decode(response);
  }

  Uri _uri(String path, [Map<String, String?> queryParameters = const {}]) {
    final absoluteUri = Uri.tryParse(path);
    if (absoluteUri?.hasScheme == true) return absoluteUri!;

    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final filteredQueryParameters = {
      for (final entry in queryParameters.entries)
        if (entry.value != null && entry.value!.isNotEmpty)
          entry.key: entry.value!,
    };
    final uri = Uri.parse('$_baseUrl$normalizedPath');
    if (filteredQueryParameters.isEmpty) return uri;
    return uri.replace(queryParameters: filteredQueryParameters);
  }

  Future<Map<String, String>> _headers({
    required bool authenticated,
    bool hasJsonBody = false,
  }) async {
    final bearerToken = authenticated ? await _tokenProvider() : null;
    return {
      'accept': 'application/json',
      if (hasJsonBody) 'content-type': 'application/json',
      if (bearerToken != null && bearerToken.isNotEmpty)
        'authorization': 'Bearer $bearerToken',
    };
  }

  Future<http.Response> _send(Future<http.Response> request) async {
    try {
      return await request.timeout(_timeout);
    } on TimeoutException {
      throw const BackendApiException(statusCode: 0, code: 'request_timeout');
    } on http.ClientException {
      throw const BackendApiException(
        statusCode: 0,
        code: 'network_unavailable',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = _decodeJsonObject(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendApiException(
        statusCode: response.statusCode,
        code: body['error'] as String? ?? 'backend_api_error',
        requestId: body['requestId'] as String?,
      );
    }

    return body;
  }

  Map<String, dynamic> _decodeJsonObject(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Backend response is not a JSON object');
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw BackendApiException(
          statusCode: response.statusCode,
          code: 'invalid_backend_response',
        );
      }
      return <String, dynamic>{'error': 'backend_http_${response.statusCode}'};
    }
  }
}

class BackendApiException implements Exception {
  const BackendApiException({
    required this.statusCode,
    required this.code,
    this.requestId,
  });

  final int statusCode;
  final String code;
  final String? requestId;

  @override
  String toString() => 'BackendApiException($statusCode): $code';
}

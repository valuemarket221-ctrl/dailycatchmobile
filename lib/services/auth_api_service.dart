import 'package:http/http.dart' as http;
import 'package:myapp/services/backend_api_client.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.homeRoute,
    this.partnerProfile,
  });

  final Map<String, dynamic> user;
  final String homeRoute;
  final Map<String, dynamic>? partnerProfile;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: BackendApiClient.requireObject(json, 'user'),
      homeRoute: json['homeRoute']?.toString() ?? '/home',
      partnerProfile: BackendApiClient.optionalObject(json, 'partnerProfile'),
    );
  }

  String get role => user['role']?.toString() ?? 'client';
  String get displayName => user['displayName']?.toString() ?? 'DailyCatch';
  String get email => user['email']?.toString() ?? '';
}

class AuthApiService {
  AuthApiService({
    http.Client? client,
    String? baseUrl,
    BackendApiClient? api,
  }) : _api = api ?? BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<AuthSession> getCurrentSession() async {
    final body = await _api.get('/api/v1/auth/me');
    return _sessionFromBody(body);
  }

  Future<AuthSession> registerClient({
    required String displayName,
    required String email,
    String? phone,
  }) async {
    final body = await _api.post('/api/v1/auth/register-client', body: {
      'displayName': displayName,
      'email': email,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
    });
    return _sessionFromBody(body);
  }

  Future<AuthSession> registerPartner({
    required String displayName,
    required String email,
    required String storeName,
    String? phone,
    String? ownerName,
    String commerceType = 'fishmonger',
    String? address,
    String? city,
    String? postalCode,
    String? storePhone,
    String? description,
  }) async {
    final body = await _api.post('/api/v1/auth/register-partner', body: {
      'displayName': displayName,
      'email': email,
      'storeName': storeName,
      'commerceType': commerceType,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (ownerName != null && ownerName.trim().isNotEmpty)
        'ownerName': ownerName.trim(),
      if (address != null && address.trim().isNotEmpty)
        'address': address.trim(),
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      if (postalCode != null && postalCode.trim().isNotEmpty)
        'postalCode': postalCode.trim(),
      if (storePhone != null && storePhone.trim().isNotEmpty)
        'storePhone': storePhone.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    });
    return _sessionFromBody(body);
  }

  AuthSession _sessionFromBody(Map<String, dynamic> body) {
    return AuthSession.fromJson(BackendApiClient.requireObject(body, 'session'));
  }
}

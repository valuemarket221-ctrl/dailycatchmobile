import 'package:http/http.dart' as http;
import 'package:myapp/services/backend_api_client.dart';

class ClientProfile {
  const ClientProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
  });

  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String? phone;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      uid: BackendApiClient.requireString(json, 'uid'),
      email: BackendApiClient.requireString(json, 'email'),
      displayName: BackendApiClient.requireString(json, 'displayName'),
      role: BackendApiClient.requireString(json, 'role'),
      phone: _optionalString(json['phone']),
      active: BackendApiClient.requireBool(json, 'active'),
      createdAt: BackendApiClient.requireDate(json, 'createdAt'),
      updatedAt: BackendApiClient.requireDate(json, 'updatedAt'),
    );
  }
}

class ClientAddressDto {
  const ClientAddressDto({
    required this.id,
    required this.label,
    required this.address,
    required this.country,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.phone,
    this.complement,
  });

  final String id;
  final String label;
  final String? fullName;
  final String? phone;
  final String address;
  final String? complement;
  final String country;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ClientAddressDto.fromJson(Map<String, dynamic> json) {
    return ClientAddressDto(
      id: BackendApiClient.requireString(json, 'id'),
      label: BackendApiClient.requireString(json, 'label'),
      fullName: _optionalString(json['fullName']),
      phone: _optionalString(json['phone']),
      address: BackendApiClient.requireString(json, 'address'),
      complement: _optionalString(json['complement']),
      country: BackendApiClient.requireString(json, 'country'),
      isDefault: BackendApiClient.requireBool(json, 'isDefault'),
      createdAt: BackendApiClient.requireDate(json, 'createdAt'),
      updatedAt: BackendApiClient.requireDate(json, 'updatedAt'),
    );
  }
}

class ClientPaymentMethodDto {
  const ClientPaymentMethodDto({
    required this.id,
    required this.type,
    required this.label,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.provider,
  });

  final String id;
  final String type;
  final String label;
  final String? provider;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ClientPaymentMethodDto.fromJson(Map<String, dynamic> json) {
    return ClientPaymentMethodDto(
      id: BackendApiClient.requireString(json, 'id'),
      type: BackendApiClient.requireString(json, 'type'),
      label: BackendApiClient.requireString(json, 'label'),
      provider: _optionalString(json['provider']),
      active: BackendApiClient.requireBool(json, 'active'),
      createdAt: BackendApiClient.requireDate(json, 'createdAt'),
      updatedAt: BackendApiClient.requireDate(json, 'updatedAt'),
    );
  }
}

class ClientApiService {
  ClientApiService({
    http.Client? client,
    String? baseUrl,
    BackendApiClient? api,
  }) : _api = api ?? BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<ClientProfile> getMyProfile() async {
    final body = await _api.get('/api/v1/client/profile/me');
    return ClientProfile.fromJson(
      BackendApiClient.requireObject(body, 'profile'),
    );
  }

  Future<ClientProfile> updateMyProfile({
    String? displayName,
    String? email,
    String? phone,
  }) async {
    final body = await _api.patch(
      '/api/v1/client/profile/me',
      body: {
        if (_hasText(displayName)) 'displayName': displayName!.trim(),
        if (_hasText(email)) 'email': email!.trim(),
        if (_hasText(phone)) 'phone': phone!.trim(),
      },
    );
    return ClientProfile.fromJson(
      BackendApiClient.requireObject(body, 'profile'),
    );
  }

  Future<List<ClientAddressDto>> getMyAddresses() async {
    final body = await _api.get('/api/v1/client/addresses/me');
    return BackendApiClient.requireObjectList(
      body,
      'addresses',
    ).map(ClientAddressDto.fromJson).toList();
  }

  Future<ClientAddressDto> createAddress({
    required String label,
    required String address,
    String? fullName,
    String? phone,
    String? complement,
    String country = 'Sénégal',
    bool isDefault = false,
  }) async {
    final body = await _api.post(
      '/api/v1/client/addresses',
      body: {
        'label': label.trim(),
        'address': address.trim(),
        'country': country.trim().isEmpty ? 'Sénégal' : country.trim(),
        'isDefault': isDefault,
        if (_hasText(fullName)) 'fullName': fullName!.trim(),
        if (_hasText(phone)) 'phone': phone!.trim(),
        if (_hasText(complement)) 'complement': complement!.trim(),
      },
    );
    return ClientAddressDto.fromJson(
      BackendApiClient.requireObject(body, 'address'),
    );
  }

  Future<void> deleteAddress(String addressId) async {
    await _api.delete('/api/v1/client/addresses/$addressId');
  }

  Future<List<ClientPaymentMethodDto>> getMyPaymentMethods() async {
    final body = await _api.get('/api/v1/client/payment-methods/me');
    return BackendApiClient.requireObjectList(
      body,
      'paymentMethods',
    ).map(ClientPaymentMethodDto.fromJson).toList();
  }

  Future<ClientPaymentMethodDto> createPaymentMethod({
    required String type,
    required String label,
    String? provider,
    String? tokenReference,
  }) async {
    final body = await _api.post(
      '/api/v1/client/payment-methods',
      body: {
        'type': type,
        'label': label.trim(),
        if (_hasText(provider)) 'provider': provider!.trim(),
        if (_hasText(tokenReference)) 'tokenReference': tokenReference!.trim(),
      },
    );
    return ClientPaymentMethodDto.fromJson(
      BackendApiClient.requireObject(body, 'paymentMethod'),
    );
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    await _api.delete('/api/v1/client/payment-methods/$paymentMethodId');
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String? _optionalString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

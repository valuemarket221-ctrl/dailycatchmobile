import 'package:http/http.dart' as http;
import 'package:myapp/services/backend_api_client.dart';

class MessageApiService {
  MessageApiService({
    http.Client? client,
    String? baseUrl,
    BackendApiClient? api,
  }) : _api = api ?? BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<List<Map<String, dynamic>>> getConversations() async {
    final body = await _getJson('/api/v1/messages/conversations');
    return (body['conversations'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<String> createConversation({
    String? orderId,
    String? clientUserId,
    required String partnerUserId,
    String? storeId,
  }) async {
    final body = await _postJson('/api/v1/messages/conversations', {
      if (orderId != null && orderId.isNotEmpty) 'orderId': orderId,
      if (clientUserId != null && clientUserId.isNotEmpty)
        'clientUserId': clientUserId,
      'partnerUserId': partnerUserId,
      if (storeId != null && storeId.isNotEmpty) 'storeId': storeId,
    });
    return body['conversationId'] as String;
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final body = await _getJson(
      '/api/v1/messages/conversations/$conversationId/messages',
    );
    return (body['messages'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<String> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final response = await _postJson(
      '/api/v1/messages/conversations/$conversationId/messages',
      {'body': body},
    );
    return response['messageId'] as String;
  }

  Future<int> markConversationAsRead(String conversationId) async {
    final body = await _postJson(
      '/api/v1/messages/conversations/$conversationId/read',
      const {},
    );
    return body['updatedCount'] as int;
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    try {
      return await _api.get(path);
    } on BackendApiException catch (error) {
      throw MessageApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _api.post(path, body: payload);
    } on BackendApiException catch (error) {
      throw MessageApiException.fromBackend(error);
    }
  }
}

class MessageApiException implements Exception {
  const MessageApiException({required this.statusCode, required this.message});

  factory MessageApiException.fromBackend(BackendApiException error) {
    return MessageApiException(
      statusCode: error.statusCode,
      message: error.code,
    );
  }

  final int statusCode;
  final String message;

  @override
  String toString() => 'MessageApiException($statusCode): $message';
}

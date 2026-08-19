import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/message_api_service.dart';

void main() {
  test('loads conversations with authentication', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'conversations': [
            {
              'id': 'conv_1',
              'clientUserId': 'dev-client',
              'partnerUserId': 'dev-partner',
              'storeId': 'poissonnerie_yoff',
              'lastMessage': 'Votre commande est prete !',
              'lastMessageAt': '2026-08-16T16:30:00.000Z',
              'createdAt': '2026-08-16T16:00:00.000Z',
            },
          ],
        }),
        200,
      );
    });

    final service = MessageApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'client-token',
      ),
    );

    final conversations = await service.getConversations();

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.path,
      '/api/v1/messages/conversations',
    );
    expect(capturedRequest.headers['authorization'], 'Bearer client-token');
    expect(conversations.single['id'], 'conv_1');
    expect(conversations.single['lastMessage'], 'Votre commande est prete !');
  });

  test('sends a conversation message', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"messageId":"msg_1"}', 201);
    });

    final service = MessageApiService(
      api: BackendApiClient(
        client: client,
        baseUrl: 'http://127.0.0.1:8080',
        tokenProvider: () async => 'client-token',
      ),
    );

    final messageId = await service.sendMessage(
      conversationId: 'conv_1',
      body: "Merci, j'arrive.",
    );

    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(capturedRequest.method, 'POST');
    expect(
      capturedRequest.url.path,
      '/api/v1/messages/conversations/conv_1/messages',
    );
    expect(body['body'], "Merci, j'arrive.");
    expect(messageId, 'msg_1');
  });

  test('normalizes backend errors', () async {
    final client = MockClient((request) async {
      return http.Response('{"error":"conversation_not_found"}', 404);
    });

    final service = MessageApiService(
      api: BackendApiClient(
        client: client,
        tokenProvider: () async => 'client-token',
      ),
    );

    expect(
      () => service.getMessages('missing'),
      throwsA(
        isA<MessageApiException>()
            .having((error) => error.statusCode, 'statusCode', 404)
            .having(
              (error) => error.message,
              'message',
              'conversation_not_found',
            ),
      ),
    );
  });
}

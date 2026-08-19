import 'package:http/http.dart' as http;
import 'package:myapp/services/backend_api_client.dart';

class PaymentIntentRequest {
  const PaymentIntentRequest({required this.orderId, this.customerId});

  final String orderId;
  final String? customerId;

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    if (customerId != null) 'customerId': customerId,
  };
}

class CreateOrderItemRequest {
  const CreateOrderItemRequest({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };
}

class CreateOrderRequest {
  const CreateOrderRequest({
    required this.items,
    this.pickupSlot,
    this.deliveryMode,
    this.idempotencyKey,
  });

  final List<CreateOrderItemRequest> items;
  final String? pickupSlot;
  final String? deliveryMode;
  final String? idempotencyKey;

  Map<String, dynamic> toJson() => {
    if (pickupSlot != null && pickupSlot!.isNotEmpty) 'pickupSlot': pickupSlot,
    if (deliveryMode != null && deliveryMode!.isNotEmpty)
      'deliveryMode': deliveryMode,
    if (idempotencyKey != null && idempotencyKey!.isNotEmpty)
      'idempotencyKey': idempotencyKey,
    'items': items.map((item) => item.toJson()).toList(),
  };
}

class CreateOrderResponse {
  const CreateOrderResponse({
    required this.orderId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.deliveryMode,
    required this.deliveryFee,
    this.pickupCode,
  });

  final String orderId;
  final String status;
  final int amount;
  final String currency;
  final String deliveryMode;
  final int deliveryFee;
  final String? pickupCode;

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      deliveryMode: json['deliveryMode'] as String? ?? 'pickup',
      deliveryFee: json['deliveryFee'] as int? ?? 0,
      pickupCode: json['pickupCode'] as String?,
    );
  }
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.deliveryMode,
    required this.deliveryFee,
    required this.pickupCode,
    required this.createdAt,
    required this.items,
    this.pickupSlot,
  });

  final String id;
  final String status;
  final int amount;
  final String currency;
  final String deliveryMode;
  final int deliveryFee;
  final String pickupCode;
  final DateTime createdAt;
  final String? pickupSlot;
  final List<Map<String, dynamic>> items;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      deliveryMode: json['deliveryMode'] as String? ?? 'pickup',
      deliveryFee: json['deliveryFee'] as int? ?? 0,
      pickupCode: json['pickupCode'] as String,
      pickupSlot: json['pickupSlot'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items:
          (json['items'] as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
    );
  }
}

class PaymentIntentResponse {
  const PaymentIntentResponse({
    required this.paymentIntentId,
    required this.clientSecret,
  });

  final String paymentIntentId;
  final String clientSecret;

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      paymentIntentId: json['paymentIntentId'] as String,
      clientSecret: json['clientSecret'] as String,
    );
  }
}

class OrderActionResponse {
  const OrderActionResponse({required this.orderId, required this.status});

  final String orderId;
  final String status;

  factory OrderActionResponse.fromJson(Map<String, dynamic> json) {
    return OrderActionResponse(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
    );
  }
}

class PaymentApiService {
  PaymentApiService({
    http.Client? client,
    String? baseUrl,
    BackendApiClient? api,
  }) : _api = api ?? BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<PaymentIntentResponse> createPaymentIntent(
    PaymentIntentRequest request,
  ) async {
    final body = await _post(
      '/api/v1/payments/payment-intents',
      request.toJson(),
    );

    return PaymentIntentResponse.fromJson(body);
  }

  Future<CreateOrderResponse> createOrder(CreateOrderRequest request) async {
    final body = await _post('/api/v1/orders', request.toJson());

    return CreateOrderResponse.fromJson(body);
  }

  Future<List<OrderSummary>> getMyOrders() async {
    final body = await _get('/api/v1/orders/me');

    return (body['orders'] as List<dynamic>)
        .map((order) => OrderSummary.fromJson(order as Map<String, dynamic>))
        .toList();
  }

  Future<OrderActionResponse> cancelOrder(
    String orderId, {
    String? reason,
  }) async {
    final body = await _post('/api/v1/orders/$orderId/cancel', {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    return OrderActionResponse.fromJson(body);
  }

  Future<OrderActionResponse> completePickup({
    required String orderId,
    required String pickupCode,
  }) async {
    final body = await _post('/api/v1/orders/$orderId/pickup', {
      'pickupCode': pickupCode,
    });
    return OrderActionResponse.fromJson(body);
  }

  Future<void> reviewOrder({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    await _post('/api/v1/orders/$orderId/review', {
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      return await _api.get(path);
    } on BackendApiException catch (error) {
      throw PaymentApiException.fromBackend(error);
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      return await _api.post(path, body: body);
    } on BackendApiException catch (error) {
      throw PaymentApiException.fromBackend(error);
    }
  }
}

class PaymentApiException implements Exception {
  const PaymentApiException({required this.statusCode, required this.message});

  factory PaymentApiException.fromBackend(BackendApiException error) {
    return PaymentApiException(
      statusCode: error.statusCode,
      message: error.code,
    );
  }

  final int statusCode;
  final String message;

  @override
  String toString() => 'PaymentApiException($statusCode): $message';
}

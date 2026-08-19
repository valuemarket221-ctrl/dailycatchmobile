import 'package:myapp/services/payment_api_service.dart';

class CheckoutCartItem {
  const CheckoutCartItem({required this.id, required this.quantity});

  final String id;
  final int quantity;
}

class CheckoutService {
  CheckoutService({PaymentApiService? paymentApiService})
    : _paymentApiService = paymentApiService ?? PaymentApiService();

  final PaymentApiService _paymentApiService;

  Future<CreateOrderResponse> createOrderFromCart({
    required List<CheckoutCartItem> items,
    required String pickupSlot,
    required String deliveryMode,
    required String idempotencyKey,
  }) async {
    if (items.isEmpty) {
      throw const CheckoutException('empty_cart');
    }

    final validItems =
        items.where((item) => item.id.isNotEmpty && item.quantity > 0).toList();
    if (validItems.isEmpty) {
      throw const CheckoutException('invalid_cart');
    }

    return _paymentApiService.createOrder(
      CreateOrderRequest(
        pickupSlot: pickupSlot,
        deliveryMode: deliveryMode,
        idempotencyKey: idempotencyKey,
        items:
            validItems
                .map(
                  (item) => CreateOrderItemRequest(
                    productId: item.id,
                    quantity: item.quantity,
                  ),
                )
                .toList(),
      ),
    );
  }
}

class CheckoutException implements Exception {
  const CheckoutException(this.code);

  final String code;

  @override
  String toString() => 'CheckoutException($code)';
}

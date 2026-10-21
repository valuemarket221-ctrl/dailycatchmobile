import 'package:myapp/services/payment_api_service.dart';
import 'package:myapp/src/features/discovery/domain/basket.dart';

class OrderRepository {
  OrderRepository({PaymentApiService? paymentApiService})
    : _paymentApiService = paymentApiService ?? PaymentApiService();

  final PaymentApiService _paymentApiService;

  Future<void> createOrder(Basket basket) async {
    await _paymentApiService.createOrder(
      CreateOrderRequest(
        pickupSlot: basket.pickupTime,
        deliveryMode: 'pickup',
        idempotencyKey:
            'legacy_${basket.id}_${DateTime.now().microsecondsSinceEpoch}',
        items: [
          CreateOrderItemRequest(productId: basket.id, quantity: 1),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:myapp/demo/demo_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/services/checkout_service.dart';
import 'package:myapp/services/payment_api_service.dart';
import 'package:myapp/utils/api_environment.dart';
import 'package:myapp/utils/formatters.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, this.paymentData});

  final Map<String, dynamic>? paymentData;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final CheckoutService _checkoutService = CheckoutService();
  final PaymentApiService _paymentApiService = PaymentApiService();
  late final String _idempotencyKey;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _selectedMethod = 'card';

  @override
  void initState() {
    super.initState();
    _idempotencyKey =
        'checkout_${DateTime.now().microsecondsSinceEpoch.toString()}';
  }

  String get _pickupSlot =>
      widget.paymentData?['pickupSlot']?.toString() ??
      'Aujourd’hui 18:00 - 19:00';

  double get _serviceFee =>
      (widget.paymentData?['serviceFee'] as num?)?.toDouble() ?? 0;

  double get _deliveryFee =>
      (widget.paymentData?['deliveryFee'] as num?)?.toDouble() ?? 0;

  String get _deliveryMode =>
      widget.paymentData?['deliveryMode']?.toString() ?? 'pickup';

  bool get _canPresentPaymentSheet =>
      !DemoMode.enabled &&
      !kIsWeb &&
      _selectedMethod == 'card' &&
      ApiEnvironment.stripePublishableKey.isNotEmpty;

  Future<void> _submitPayment(CartProvider cart) async {
    if (cart.isEmpty || _isSubmitting) return;

    final firstItem = cart.items.first;
    final itemCount = cart.itemCount;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final order = await _checkoutService.createOrderFromCart(
        items:
            cart.items
                .map(
                  (item) =>
                      CheckoutCartItem(id: item.id, quantity: item.quantity),
                )
                .toList(),
        pickupSlot: _pickupSlot,
        deliveryMode: _deliveryMode,
        idempotencyKey: _idempotencyKey,
      );
      final paymentCompleted = await _presentPaymentSheetIfAvailable(
        order.orderId,
      );

      if (!mounted) return;

      cart.clear();
      context.go(
        '/order-confirmation',
        extra: {
          'orderId': order.orderId,
          'status': paymentCompleted ? 'paid' : order.status,
          'amount': order.amount,
          'currency': order.currency,
          'deliveryMode': order.deliveryMode,
          'deliveryFee': order.deliveryFee,
          'pickupCode': order.pickupCode,
          'pickupSlot': _pickupSlot,
          'storeName': firstItem.storeName,
          'productName': firstItem.name,
          'image': firstItem.image,
          'quantity': itemCount,
          'paymentCompleted': paymentCompleted,
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _messageForError(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _messageForError(Object error) {
    if (error is StripeException) {
      return error.error.localizedMessage ?? 'Paiement annulé ou refusé.';
    }

    if (error is CheckoutException) {
      return error.code == 'empty_cart'
          ? 'Votre panier est vide.'
          : 'Le panier contient une offre invalide.';
    }

    if (error is PaymentApiException) {
      return switch (error.statusCode) {
        0 => 'Connexion impossible au serveur. Vérifiez votre réseau.',
        401 => 'Connectez-vous pour finaliser la réservation.',
        404 => 'Cette offre n’est plus disponible.',
        409 => 'Quantité insuffisante pour cette offre.',
        429 => 'Trop de réservations récentes. Réessayez plus tard.',
        _ => 'Le paiement n’a pas pu être initialisé. Réessayez.',
      };
    }

    return 'Une erreur est survenue. Réessayez.';
  }

  Future<bool> _presentPaymentSheetIfAvailable(String orderId) async {
    if (DemoMode.enabled) return true;
    if (!_canPresentPaymentSheet) return false;

    final intent = await _paymentApiService.createPaymentIntent(
      PaymentIntentRequest(orderId: orderId),
    );
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: intent.clientSecret,
        merchantDisplayName: 'DailyCatch',
      ),
    );
    await Stripe.instance.presentPaymentSheet();
    return true;
  }

  String _actionLabel(double total) {
    if (DemoMode.enabled) return 'Simuler le paiement';
    final amount = AppFormatters.formatCfa(total);
    if (_canPresentPaymentSheet) return 'Payer $amount';
    return 'Réserver $amount';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Consumer<CartProvider>(
        builder: (context, cart, _) {
          final subtotal = cart.totalPrice;
          final total = subtotal + _serviceFee + _deliveryFee;

          return Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => safePop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.blueBic,
                      ),
                    ),
                    const Spacer(),
                    Text('PAIEMENT', style: _header),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Récapitulatif de la commande', style: _section),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _card,
                  child: Column(
                    children: [
                      _Line('Sous-total', AppFormatters.formatCfa(subtotal)),
                      const SizedBox(height: 14),
                      _Line(
                        'Frais de service',
                        AppFormatters.formatCfa(_serviceFee),
                      ),
                      const SizedBox(height: 14),
                      _Line(
                        'Livraison',
                        _deliveryFee > 0
                            ? AppFormatters.formatCfa(_deliveryFee)
                            : 'Gratuit',
                      ),
                      const Divider(height: 28),
                      _Line(
                        'Total',
                        AppFormatters.formatCfa(total),
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text('Méthode de paiement', style: _section),
                const SizedBox(height: 12),
                _PayOption(
                  'Carte bancaire',
                  selected: _selectedMethod == 'card',
                  suffix: 'VISA   ••••',
                  onTap: () => setState(() => _selectedMethod = 'card'),
                ),
                _PayOption(
                  'Mobile Money',
                  selected: _selectedMethod == 'mobile_money',
                  onTap: () => setState(() => _selectedMethod = 'mobile_money'),
                ),
                _PayOption(
                  'Orange Money',
                  selected: _selectedMethod == 'orange_money',
                  onTap: () => setState(() => _selectedMethod = 'orange_money'),
                ),
                _PayOption(
                  'Espèces à la livraison',
                  selected: _selectedMethod == 'cash',
                  onTap: () => setState(() => _selectedMethod = 'cash'),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 4),
                  _PaymentErrorBanner(message: _errorMessage!),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed:
                        cart.isEmpty || _isSubmitting
                            ? null
                            : () => _submitPayment(cart),
                    style: _buttonStyle,
                    child: Text(
                      _isSubmitting ? 'Traitement...' : _actionLabel(total),
                      style: _buttonText,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(child: Text('Paiement 100% sécurisé', style: _secure)),
                const SizedBox(height: 36),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _Line extends StatelessWidget {
  const _Line(this.l, this.v, {this.bold = false});

  final String l;
  final String v;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(l, style: bold ? _bold : _text),
      const Spacer(),
      Text(v, style: bold ? _bold : _text),
    ],
  );
}

class _PayOption extends StatelessWidget {
  const _PayOption(
    this.label, {
    required this.onTap,
    this.selected = false,
    this.suffix,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? suffix;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              selected
                  ? AppColors.greenTGTG.withValues(alpha: .45)
                  : const Color(0xFFE1E8E6),
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.greenTGTG : const Color(0xFFD1DBDD),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: _option)),
          if (suffix != null) Text(suffix!, style: _suffix),
        ],
      ),
    ),
  );
}

class _PaymentErrorBanner extends StatelessWidget {
  const _PaymentErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3F1),
      border: Border.all(color: const Color(0xFFFFD2CC)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(message, style: _error),
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _section = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF263B3E),
);
final _text = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _bold = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _option = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF263B3E),
);
final _suffix = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _secure = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: AppColors.blueBic,
);
final _error = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFFB42318),
);
final _buttonText = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _buttonStyle = FilledButton.styleFrom(
  backgroundColor: AppColors.blueBic,
  disabledBackgroundColor: const Color(0xFFC7D2D4),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);
final _card = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xFFE1E8E6)),
  borderRadius: BorderRadius.circular(12),
);

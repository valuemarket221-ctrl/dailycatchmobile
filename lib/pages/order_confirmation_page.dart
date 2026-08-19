import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/utils/formatters.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key, this.orderData});
  final Map<String, dynamic>? orderData;

  String get _storeName =>
      orderData?['storeName']?.toString() ?? 'Poissonnerie Yoff';

  String get _productName =>
      orderData?['productName']?.toString() ?? 'Panier surprise';

  String get _pickupSlot =>
      orderData?['pickupSlot']?.toString() ?? 'Aujourd’hui 17:00 - 19:00';

  String get _orderId => orderData?['orderId']?.toString() ?? 'DCYF24A6B7';

  String get _image => orderData?['image']?.toString() ?? '';

  String get _currency => orderData?['currency']?.toString() ?? 'XOF';

  num get _amount {
    final amount = orderData?['amount'];
    if (amount is num) return amount;
    return num.tryParse(amount?.toString() ?? '') ?? 13000;
  }

  bool get _paymentCompleted => orderData?['paymentCompleted'] == true;

  String get _deliveryMode =>
      orderData?['deliveryMode']?.toString() ?? 'pickup';

  bool get _isDelivery => _deliveryMode == 'delivery';

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 38, 26, 0),
        child: Column(
          children: [
            Text('CONFIRMATION', style: _header),
            const SizedBox(height: 42),
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: AppColors.blueBic,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 28),
            Text('Merci !', style: _thanks),
            const SizedBox(height: 10),
            Text(
              _paymentCompleted
                  ? 'Votre réservation est confirmée.'
                  : 'Votre réservation est enregistrée.',
              textAlign: TextAlign.center,
              style: _sub,
            ),
            const SizedBox(height: 30),
            Container(
              decoration: _card,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _OrderImage(path: _image),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_storeName, style: _name),
                              Text(_productName, style: _sub),
                              const SizedBox(height: 8),
                              Text(
                                AppFormatters.formatMoney(
                                  _amount,
                                  currency: _currency,
                                ),
                                style: _name,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _Row(
                          _isDelivery ? 'Livraison prévue' : 'Retrait le',
                          _pickupSlot,
                        ),
                        const SizedBox(height: 18),
                        _Row(
                          _isDelivery ? 'Adresse de livraison' : 'Adresse',
                          _isDelivery
                              ? 'Adresse client'
                              : 'Commerce partenaire',
                        ),
                        const SizedBox(height: 18),
                        _Row('N° de commande', _orderId),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => context.go('/my-reservations'),
                style: _buttonStyle,
                child: Text('Voir ma réservation', style: _buttonText),
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Text('Retour à l’accueil', style: _green),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    ),
  );
}

class _OrderImage extends StatelessWidget {
  const _OrderImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _OrderImageFallback(),
      );
    }

    if (path.isNotEmpty) {
      return Image.asset(
        path,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _OrderImageFallback(),
      );
    }

    return const _OrderImageFallback();
  }
}

class _OrderImageFallback extends StatelessWidget {
  const _OrderImageFallback();

  @override
  Widget build(BuildContext context) => Container(
    width: 70,
    height: 70,
    color: const Color(0xFFEAF3F1),
    child: const Icon(Icons.shopping_bag_outlined, color: AppColors.blueBic),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.l, this.v);
  final String l;
  final String v;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(l, style: _label)),
      Expanded(child: Text(v, textAlign: TextAlign.right, style: _value)),
    ],
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _thanks = GoogleFonts.poppins(
  fontSize: 24,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _sub = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _name = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _label = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _value = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _green = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.greenTGTG,
);
final _buttonText = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _buttonStyle = FilledButton.styleFrom(
  backgroundColor: AppColors.blueBic,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);
final _card = BoxDecoration(
  border: Border.all(color: const Color(0xFFE1E8E6)),
  borderRadius: BorderRadius.circular(12),
);

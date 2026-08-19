import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/utils/formatters.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key, this.extra});
  final Map<String, dynamic>? extra;

  static const double _serviceFee = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            final serviceFee = cart.isEmpty ? 0 : _serviceFee;
            final total = cart.totalPrice + serviceFee;

            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.blueBic,
                        ),
                      ),
                      const Spacer(),
                      Text('PANIER', style: _header),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (cart.isEmpty)
                    const Expanded(child: _EmptyCart())
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: cart.items.length,
                        itemBuilder:
                            (context, index) => _CartLine(
                              item: cart.items[index],
                              onDecrease:
                                  () => cart.updateQuantity(
                                    index,
                                    cart.items[index].quantity - 1,
                                  ),
                              onIncrease:
                                  () => cart.updateQuantity(
                                    index,
                                    cart.items[index].quantity + 1,
                                  ),
                            ),
                      ),
                    ),
                  _TotalLine(
                    'Sous-total',
                    AppFormatters.formatCfa(cart.totalPrice),
                  ),
                  const SizedBox(height: 18),
                  _TotalLine(
                    'Frais de service',
                    AppFormatters.formatCfa(serviceFee),
                  ),
                  const SizedBox(height: 22),
                  _TotalLine(
                    'Total',
                    AppFormatters.formatCfa(total),
                    bold: true,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed:
                          cart.isEmpty
                              ? null
                              : () => context.go(
                                '/delivery',
                                extra: {
                                  'serviceFee': serviceFee,
                                  'subtotal': cart.totalPrice,
                                  'total': total,
                                },
                              ),
                      style: _buttonStyle,
                      child: Text('Continuer', style: _buttonText),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
  });

  final CartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: _CartImage(path: item.image),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.storeName, style: _name, maxLines: 1),
              const SizedBox(height: 3),
              Text(item.name, style: _sub, maxLines: 1),
              const SizedBox(height: 8),
              Text(AppFormatters.formatCfa(item.totalPrice), style: _price),
            ],
          ),
        ),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E8E6)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onDecrease,
                child: const Icon(Icons.remove, size: 16),
              ),
              const SizedBox(width: 12),
              Text('${item.quantity}', style: _name),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onIncrease,
                child: const Icon(Icons.add, size: 16),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CartImage extends StatelessWidget {
  const _CartImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      );
    }

    if (path.isNotEmpty) {
      return Image.asset(
        path,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      );
    }

    return const _ImageFallback();
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) => Container(
    width: 72,
    height: 72,
    color: const Color(0xFFEAF3F1),
    child: const Icon(Icons.shopping_bag_outlined, color: AppColors.blueBic),
  );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(
        Icons.shopping_basket_outlined,
        color: AppColors.blueBic,
        size: 84,
      ),
      const SizedBox(height: 22),
      Text('Votre panier est vide', style: _emptyTitle),
      const SizedBox(height: 8),
      Text(
        'Découvrez les paniers disponibles près de chez vous.',
        textAlign: TextAlign.center,
        style: _sub,
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: 190,
        height: 44,
        child: FilledButton(
          onPressed: () => context.go('/home'),
          style: _buttonStyle,
          child: Text('Découvrir', style: _buttonText),
        ),
      ),
    ],
  );
}

class _TotalLine extends StatelessWidget {
  const _TotalLine(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: bold ? _totalBold : _total),
      const Spacer(),
      Text(value, style: bold ? _totalBold : _total),
    ],
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _name = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _sub = GoogleFonts.poppins(
  fontSize: 10.5,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF526669),
);
final _price = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _emptyTitle = GoogleFonts.poppins(
  fontSize: 17,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _total = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _totalBold = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key, this.checkoutData});

  final Map<String, dynamic>? checkoutData;

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  bool _deliverySelected = false;
  String _selectedDate = 'Aujourd’hui';
  String _selectedSlot = '18:00 - 19:00';

  double get _deliveryFee => _deliverySelected ? 1000 : 0;

  void _continue(BuildContext context) {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) {
      context.go('/cart');
      return;
    }

    context.go(
      '/payment',
      extra: {
        ...?widget.checkoutData,
        'deliveryMode': _deliverySelected ? 'delivery' : 'pickup',
        'deliveryFee': _deliveryFee,
        'pickupSlot': '$_selectedDate $_selectedSlot',
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => safePop(context),
                  icon: const Icon(Icons.arrow_back, color: AppColors.blueBic),
                ),
                const Spacer(),
                Text('LIVRAISON / RETRAIT', style: _header),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 32),
            Text('Choisissez une option', style: _section),
            const SizedBox(height: 14),
            _Option(
              icon: Icons.storefront_outlined,
              title: 'Retrait en magasin',
              subtitle: 'Gratuit',
              selected: !_deliverySelected,
              onTap: () => setState(() => _deliverySelected = false),
            ),
            const SizedBox(height: 12),
            _Option(
              icon: Icons.delivery_dining_outlined,
              title: 'Livraison à domicile',
              subtitle: '1000 FCFA',
              selected: _deliverySelected,
              onTap: () => setState(() => _deliverySelected = true),
            ),
            const SizedBox(height: 34),
            Text(
              _deliverySelected ? 'Créneau de livraison' : 'Date de retrait',
              style: _section,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _DateBox(
                        'Aujourd’hui',
                        selected: _selectedDate == 'Aujourd’hui',
                        onTap:
                            () => setState(() => _selectedDate = 'Aujourd’hui'),
                      ),
                      _DateBox(
                        'Demain',
                        selected: _selectedDate == 'Demain',
                        onTap: () => setState(() => _selectedDate = 'Demain'),
                      ),
                      _DateBox(
                        'Après-demain',
                        selected: _selectedDate == 'Après-demain',
                        onTap:
                            () =>
                                setState(() => _selectedDate = 'Après-demain'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    children: [
                      _DateBox(
                        '17:00 - 18:00',
                        selected: _selectedSlot == '17:00 - 18:00',
                        onTap:
                            () =>
                                setState(() => _selectedSlot = '17:00 - 18:00'),
                      ),
                      _DateBox(
                        '18:00 - 19:00',
                        selected: _selectedSlot == '18:00 - 19:00',
                        onTap:
                            () =>
                                setState(() => _selectedSlot = '18:00 - 19:00'),
                      ),
                      _DateBox(
                        '19:00 - 20:00',
                        selected: _selectedSlot == '19:00 - 20:00',
                        onTap:
                            () =>
                                setState(() => _selectedSlot = '19:00 - 20:00'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => _continue(context),
                style: _buttonStyle,
                child: Text('Continuer', style: _buttonText),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    ),
    bottomNavigationBar: const BottomNavBar(currentIndex: 0),
  );
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              selected
                  ? AppColors.greenTGTG.withValues(alpha: .35)
                  : const Color(0xFFE1E8E6),
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blueBic, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _name),
                Text(subtitle, style: _sub),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.greenTGTG : const Color(0xFFD1DBDD),
            size: 18,
          ),
        ],
      ),
    ),
  );
}

class _DateBox extends StatelessWidget {
  const _DateBox(this.label, {required this.onTap, this.selected = false});

  final String label;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 43,
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color:
              selected
                  ? AppColors.greenTGTG.withValues(alpha: .45)
                  : const Color(0xFFE8EEEE),
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: selected ? _selectedDate : _date),
    ),
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
final _name = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF263B3E),
);
final _sub = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF526669),
);
final _date = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF526669),
);
final _selectedDate = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
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

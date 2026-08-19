import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});
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
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.blueBic),
                ),
                const Spacer(),
                Text('DÉTAIL COMMANDEE', style: _header),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
                    height: 118,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 12,
                    top: 14,
                    child: Text('Poissonnerie Yoff', style: _hero),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: .85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Confirmée', style: _badge),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Restaurant', style: _label),
            const SizedBox(height: 14),
            Text('Articles', style: _label),
            const SizedBox(height: 16),
            const _Line('Panier surprise\n17:00', 'x1', '3 000 FCFA'),
            const SizedBox(height: 20),
            const _Line('Panier surprise\n19:00', 'x1', '5 000 FCFA'),
            const Divider(height: 34),
            const _Line('Total payé', '', '13 000 FCFA', bold: true),
            const Divider(height: 40),
            Text('Adresse de retrait', style: _label),
            const SizedBox(height: 12),
            Text('Marché de Yoff\nYoff, Dakar, Sénégal', style: _value),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => context.push('/withdrawal-code'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Voir le code de retrait', style: _button),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => context.push('/refund-request'),
                child: Text('Problème avec la commande', style: _link),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    ),
    bottomNavigationBar: const BottomNavBar(currentIndex: 0),
  );
}

class _Line extends StatelessWidget {
  const _Line(this.a, this.b, this.c, {this.bold = false});
  final String a, b, c;
  final bool bold;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(a, style: bold ? _bold : _value)),
      if (b.isNotEmpty) Text(b, style: _value),
      const SizedBox(width: 24),
      Text(c, style: bold ? _bold : _value),
    ],
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _hero = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _badge = GoogleFonts.poppins(
  fontSize: 9,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _label = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _value = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF263B3E),
);
final _bold = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _link = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);

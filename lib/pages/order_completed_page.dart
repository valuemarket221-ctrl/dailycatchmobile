import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class OrderCompletedPage extends StatelessWidget {
  const OrderCompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 30),
          child: Column(
            children: [
              Text('COMMANDE TERMINÉE', style: _title),
              const Spacer(flex: 2),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F6),
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  const Positioned(
                    bottom: 16,
                    child: Icon(
                      Icons.shopping_bag,
                      size: 110,
                      color: AppColors.blueBic,
                    ),
                  ),
                  Positioned(
                    bottom: 38,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
                        width: 68,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 58),
              Text('Merci pour votre achat !', style: _headline),
              const SizedBox(height: 18),
              Text(
                'Vous avez contribué à sauver\nde la nourriture.',
                textAlign: TextAlign.center,
                style: _body,
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => context.go('/orders'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blueBic,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Voir mes commandes', style: _button),
                ),
              ),
              const SizedBox(height: 22),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text('Retour à l’accueil', style: _link),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _title = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _headline = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _body = GoogleFonts.poppins(
  fontSize: 13,
  height: 1.8,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _button = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _link = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);

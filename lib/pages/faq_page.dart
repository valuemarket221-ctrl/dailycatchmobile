import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});
  static const questions = [
    'Qu’est-ce que DailyCatch ?',
    'Comment réserver un panier ?',
    'Comment annuler une réservation ?',
    'Comment ça fonctionne ?',
    'Comment sont fixés les prix ?',
    'Le paiement est-il sécurisé ?',
    'Puis-je devenir partenaire ?',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
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
                Text('Questions fréquentes', style: _title),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE1E8E6)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search, size: 17, color: Color(0xFF9AA8AA)),
                  const SizedBox(width: 8),
                  Text('Rechercher une question...', style: _hint),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final q in questions)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFCFC),
                  border: Border.all(color: const Color(0xFFE8EEEE)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(q, style: _row)),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

final _title = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _hint = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF9AA8AA),
);
final _row = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF263B3E),
);

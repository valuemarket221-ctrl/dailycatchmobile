import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class JoinPartnerPage extends StatelessWidget {
  const JoinPartnerPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
        child: Column(
          children: [
            Text('DEVENIR PARTENAIRE', style: _header),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
                height: 132,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 26),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Rejoignez DailyCatch\net donnez une seconde vie\nà vos invendus.',
                style: _title,
              ),
            ),
            const SizedBox(height: 38),
            const _Benefit('Augmentez vos revenus'),
            const SizedBox(height: 22),
            const _Benefit('Facile à utiliser'),
            const SizedBox(height: 22),
            const _Benefit('Impact positif garanti'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => context.go('/partner/type'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Inscrire mon commerce', style: _button),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/about'),
              child: Text('En savoir plus', style: _link),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.auto_awesome, size: 15, color: AppColors.blueBic),
      const SizedBox(width: 15),
      Text(text, style: _benefit),
    ],
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _title = GoogleFonts.poppins(
  fontSize: 18,
  height: 1.55,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _benefit = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF526669),
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _link = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);

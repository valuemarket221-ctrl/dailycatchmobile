import 'package:flutter/material.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 34, 22, 0),
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
                Text('Contactez-nous', style: _title),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 16),
            Text('Notre équipe est là pour vous aider.', style: _sub),
            const SizedBox(height: 28),
            const _Field('Nom complet'),
            const _Field('Email'),
            Text('Sujet', style: _label),
            const _Field('Choisissez un sujet', suffix: true),
            Text('Votre message', style: _label),
            const _Field('', height: 118),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed:
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Message envoyé',
                          style: GoogleFonts.poppins(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.blueBic,
                      ),
                    ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Envoyer le message', style: _button),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field(this.hint, {this.height = 43, this.suffix = false});
  final String hint;
  final double height;
  final bool suffix;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        Expanded(child: Text(hint, style: _hint)),
        if (suffix) const Icon(Icons.keyboard_arrow_down, size: 16),
      ],
    ),
  );
}

final _title = GoogleFonts.poppins(
  fontSize: 21,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _sub = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF263B3E),
);
final _label = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _hint = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF9AA8AA),
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);

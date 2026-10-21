import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.help_outline, 'Questions fréquentes', '/faq'),
      (Icons.mail_outline, 'Nous contacter', '/contact'),
      (Icons.article_outlined, 'Conditions d’utilisation', '/legal'),
      (Icons.lock_outline, 'Politique de confidentialité', '/legal'),
      (Icons.info_outline, 'Mentions légales', '/legal'),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (context.canPop())
                    IconButton(
                      onPressed: () => safePop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.blueBic,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      'Aide & support',
                      style: _title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              for (final row in rows)
                _HelpRow(
                  icon: row.$1,
                  label: row.$2,
                  onTap: () => context.push(row.$3),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 48,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF526669)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: _row)),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9AA8AA)),
        ],
      ),
    ),
  );
}

final _title = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _row = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF263B3E),
);

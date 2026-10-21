import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _emails = false;
  bool _location = true;

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.blueBic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => safePop(context),
                  icon: const Icon(Icons.arrow_back, color: AppColors.blueBic),
                ),
                const Spacer(),
                Text('PARAMÈTRES', style: _header),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 28),
            _SwitchRow(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Alertes commandes et offres',
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
            _SwitchRow(
              icon: Icons.email_outlined,
              title: 'Emails',
              subtitle: 'Conseils et nouveautés',
              value: _emails,
              onChanged: (value) => setState(() => _emails = value),
            ),
            _SwitchRow(
              icon: Icons.location_on_outlined,
              title: 'Position',
              subtitle: 'Offres proches de vous',
              value: _location,
              onChanged: (value) => setState(() => _location = value),
            ),
            _NavRow(
              icon: Icons.lock_outline,
              title: 'Mot de passe',
              subtitle: 'Sécurité du compte',
              onTap: () => context.push('/change-password'),
            ),
            _NavRow(
              icon: Icons.article_outlined,
              title: 'Conditions d’utilisation',
              subtitle: 'CGU DailyCatch',
              onTap: () => context.push('/terms'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => _message('Préférences enregistrées'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Enregistrer', style: _button),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => _RowShell(
    icon: icon,
    title: title,
    subtitle: subtitle,
    trailing: Switch(
      value: value,
      activeThumbColor: AppColors.blueBic,
      onChanged: onChanged,
    ),
  );
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: _RowShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9AA8AA)),
    ),
  );
}

class _RowShell extends StatelessWidget {
  const _RowShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFE8EEEE))),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF526669), size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _title),
              const SizedBox(height: 4),
              Text(subtitle, style: _subtitle),
            ],
          ),
        ),
        trailing,
      ],
    ),
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _title = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _subtitle = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF526669),
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/utils/local_auth_session.dart';
import 'package:myapp/utils/profile_photo_store.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    ProfilePhotoStore.load();
  }

  Future<void> _logout(BuildContext context) async {
    await LocalAuthSession.signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.calendar_month_outlined, 'Mes réservations', '/pickup'),
      (Icons.favorite_border, 'Mes favoris', '/favorites'),
      (Icons.location_on_outlined, 'Mes adresses', '/addresses'),
      (Icons.info_outline, 'Mes informations', '/edit-profile'),
      (Icons.credit_card_outlined, 'Paiement', '/payment-methods'),
      (Icons.settings_outlined, 'Paramètres', '/settings'),
      (Icons.help_outline, 'Aide & support', '/help'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mon profil', style: _title),
                    const SizedBox(height: 24),
                    _ProfileHeader(
                      onTapProfile: () => context.push('/edit-profile'),
                      onTapNotifications: () => context.push('/notifications'),
                    ),
                    const SizedBox(height: 30),
                    for (final item in items)
                      _ProfileRow(
                        icon: item.$1,
                        label: item.$2,
                        onTap: () => context.push(item.$3),
                      ),
                    const SizedBox(height: 8),
                    _ProfileRow(
                      icon: Icons.logout,
                      label: 'Se déconnecter',
                      onTap: () => _logout(context),
                      showChevron: false,
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text('DailyCatch Sénégal', style: _footer),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.onTapProfile,
    required this.onTapNotifications,
  });

  final VoidCallback onTapProfile;
  final VoidCallback onTapNotifications;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: onTapProfile,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              const _ProfileAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amadou Fall', style: _name),
                    Text('Voir mon profil', style: _sub),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      InkWell(
        onTap: onTapNotifications,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8F7),
            borderRadius: BorderRadius.circular(21),
          ),
          child: Text('2', style: _name),
        ),
      ),
    ],
  );
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Uint8List?>(
    valueListenable: ProfilePhotoStore.bytes,
    builder:
        (context, bytes, _) => ValueListenableBuilder<String>(
          valueListenable: ProfilePhotoStore.asset,
          builder:
              (context, asset, _) => CircleAvatar(
                radius: 34,
                backgroundImage:
                    bytes == null
                        ? AssetImage(asset) as ImageProvider
                        : MemoryImage(bytes),
                backgroundColor: const Color(0xFFE8F4F2),
              ),
        ),
  );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 47,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE8EEEE))),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF526669), size: 19),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: _row)),
            if (showChevron)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9AA8AA),
                size: 19,
              ),
          ],
        ),
      ),
    );
  }
}

final _title = GoogleFonts.poppins(
  fontSize: 21,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _name = GoogleFonts.poppins(
  fontSize: 13.5,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _sub = GoogleFonts.poppins(
  fontSize: 10.5,
  fontWeight: FontWeight.w700,
  color: AppColors.greenTGTG,
);
final _row = GoogleFonts.poppins(
  fontSize: 12.5,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF263B3E),
);
final _footer = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF8BA0A3),
);

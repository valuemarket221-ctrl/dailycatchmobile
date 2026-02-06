import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Assure-toi que le package est installé
import 'package:myapp/constants.dart';

class PartenairePage extends StatelessWidget {
  PartenairePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.blueBic,
        title: Text(
          "Espace Partenaire",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2, // Change ratio for a better layout
          ),
          itemCount: _dashboardItems.length,
          itemBuilder: (context, index) {
            return dashboardCard(
              context,
              icon: _dashboardItems[index].icon,
              title: _dashboardItems[index].title,
              subtitle: _dashboardItems[index].subtitle,
              onTap: _dashboardItems[index].onTap,
            );
          },
        ),
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.yellowColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(4, 4), // Adjust shadow direction for better effect
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white), // Increase icon size
            SizedBox(height: 16), // Increased space between icon and text
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ), // Slightly lighter color for subtitle
            ),
          ],
        ),
      ),
    );
  }

  // Liste des éléments du dashboard
  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      LucideIcons.store,
      "Inscription",
      "Nom, secteur, service...",
      () {},
    ),
    DashboardItem(
      LucideIcons.packagePlus,
      "Produits",
      "Ajouter / Éditer",
      () {},
    ),
    DashboardItem(LucideIcons.layers, "Stock", "Suivi & gestion", () {}),
    DashboardItem(
      LucideIcons.shoppingBag,
      "Commandes",
      "Commandes reçues",
      () {},
    ),
    DashboardItem(LucideIcons.clock, "Horaires", "Disponibilité", () {}),
    DashboardItem(
      LucideIcons.barChart,
      "Statistiques",
      "Ventes & suivi",
      () {},
    ),
    DashboardItem(
      LucideIcons.messageCircle,
      "Messages",
      "Clients & système",
      () {},
    ),
    DashboardItem(
      LucideIcons.bell,
      "Notifications",
      "Commandes, stock bas...",
      () {},
    ),
  ];
}

class DashboardItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  DashboardItem(this.icon, this.title, this.subtitle, this.onTap);
}

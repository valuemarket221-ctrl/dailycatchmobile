import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Dashboard Admin - Clone TGTG Style
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final stats = {
      'totalOrders': 1247,
      'activePartners': 45,
      'totalUsers': 3250,
      'revenue': 45890.50,
    };

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.blueBic,
        elevation: 0,
        title: Text(
          'Tableau de Bord',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Bienvenue, Administrateur',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Voici un aperçu de votre activité',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Commandes',
                    value: stats['totalOrders'].toString(),
                    icon: Icons.shopping_bag,
                    color: AppColors.blueBic,
                    onTap: () => context.go('/admin/orders'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Partenaires',
                    value: stats['activePartners'].toString(),
                    icon: Icons.store,
                    color: Colors.green,
                    onTap: () => context.go('/admin/partners'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Utilisateurs',
                    value: stats['totalUsers'].toString(),
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () => context.go('/admin/clients'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Revenus',
                    value: '${(stats['revenue'] as double).toStringAsFixed(0)}€',
                    icon: Icons.euro,
                    color: Colors.purple,
                    onTap: () => context.go('/admin/revenue'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Text(
              'Actions rapides',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context: context,
                    icon: Icons.person_add,
                    label: 'Nouveau partenaire',
                    onTap: () => context.go('/admin/partners/new'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context: context,
                    icon: Icons.inventory_2,
                    label: 'Ajouter produit',
                    onTap: () => context.go('/admin/products/new'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Activity
            Text(
              'Activité récente',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentActivityTile(
              icon: Icons.storefront,
              title: 'Nouveau partenaire',
              subtitle: 'Poissonnerie du Port - En attente de validation',
              time: 'Il y a 5 min',
              color: Colors.orange,
            ),
            _buildRecentActivityTile(
              icon: Icons.shopping_bag,
              title: 'Nouvelle commande',
              subtitle: 'CMD-1247 - 12.50€',
              time: 'Il y a 12 min',
              color: AppColors.blueBic,
            ),
            _buildRecentActivityTile(
              icon: Icons.person,
              title: 'Nouvel utilisateur',
              subtitle: 'Ibrahima S. - S\'est inscrit',
              time: 'Il y a 25 min',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blueBic,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.blueBic),
            accountName: Text(
              'Administrateur',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('admin@dailycatch.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: AppColors.blueBic),
            ),
          ),
          _buildDrawerSection('Gestion Utilisateurs'),
          _buildDrawerItem(
            Icons.people,
            'Clients',
            () => context.go('/admin/clients'),
          ),
          _buildDrawerItem(
            Icons.store,
            'Partenaires',
            () => context.go('/admin/partners'),
          ),
          _buildDrawerItem(
            Icons.verified_user,
            'Validation partenaires',
            () => context.go('/admin/partners/pending'),
          ),
          const Divider(),
          _buildDrawerSection('Gestion Produits'),
          _buildDrawerItem(
            Icons.inventory_2,
            'Produits',
            () => context.go('/admin/products'),
          ),
          _buildDrawerItem(
            Icons.add_box,
            'Ajouter produit',
            () => context.go('/admin/products/new'),
          ),
          const Divider(),
          _buildDrawerSection('Commandes'),
          _buildDrawerItem(
            Icons.shopping_bag,
            'Toutes les commandes',
            () => context.go('/admin/orders'),
          ),
          _buildDrawerItem(
            Icons.local_shipping,
            'Suivi livraisons',
            () => context.go('/admin/deliveries'),
          ),
          const Divider(),
          _buildDrawerSection('Paiements'),
          _buildDrawerItem(
            Icons.euro,
            'Revenus',
            () => context.go('/admin/revenue'),
          ),
          _buildDrawerItem(
            Icons.payments,
            'Paiements partenaires',
            () => context.go('/admin/partner-payments'),
          ),
          const Divider(),
          _buildDrawerSection('Paramètres'),
          _buildDrawerItem(
            Icons.settings,
            'Paramètres',
            () => context.go('/admin/settings'),
          ),
          _buildDrawerItem(
            Icons.logout,
            'Déconnexion',
            () => context.go('/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.blueBic),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: onTap,
    );
  }
}

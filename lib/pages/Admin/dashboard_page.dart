import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importation de Google Fonts
import 'package:myapp/constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tableau de Bord Admin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.blueBic,
        centerTitle: true,
        elevation: 4,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.blueBic),
              accountName: Text(
                'Administrateur',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text('admin@domain.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.blueBic,
                ),
              ),
            ),
            _buildSectionTitle('Gestion des Utilisateurs'),
            _buildDrawerItem(
              Icons.person,
              'Liste clients',
              () => Navigator.pushNamed(context, '/client'),
            ),
            _buildDrawerItem(
              Icons.group,
              'Liste partenaires',
              () => Navigator.pushNamed(context, '/listPartenaire'),
            ),
            _buildDrawerItem(
              Icons.verified_user,
              'Validation de partenaires',
              () {},
            ),

            _buildSectionTitle('Gestion Produits'),
            _buildDrawerItem(
              Icons.add_box,
              'Ajouter / Modifier / Supprimer',
              () {},
            ),
            _buildDrawerItem(
              Icons.inventory_2,
              'Produits proposés par admin',
              () {},
            ),

            _buildSectionTitle('Commandes'),
            _buildDrawerItem(
              Icons.local_shipping,
              'Suivi global des commandes',
              () {},
            ),
            _buildDrawerItem(Icons.history, 'Statut & Historique', () {}),

            _buildSectionTitle('Paiements'),
            _buildDrawerItem(Icons.receipt_long, 'Reçus', () {}),
            _buildDrawerItem(Icons.payments, 'Historique', () {}),
            _buildDrawerItem(
              Icons.account_balance_wallet,
              'Paiements partenaires',
              () {},
            ),

            _buildSectionTitle('Statistiques'),
            _buildDrawerItem(
              Icons.bar_chart,
              'Ventes journalières / mensuelles',
              () {},
            ),
            _buildDrawerItem(
              Icons.trending_up,
              'Produits les plus vendus',
              () {},
            ),
            _buildDrawerItem(
              Icons.pie_chart,
              'Activité des partenaires',
              () {},
            ),

            _buildSectionTitle('Notifications & Alertes'),
            _buildDrawerItem(
              Icons.notifications_active,
              'Envoyer push notif',
              () {},
            ),
            _buildDrawerItem(Icons.local_offer, 'Offres & Promos', () {}),
            _buildDrawerItem(Icons.warning_amber, 'Alertes de stock', () {}),

            _buildSectionTitle('Paramètres globaux'),
            _buildDrawerItem(
              Icons.api,
              'Configuration API (CinetPay, SMS, Géoloc)',
              () {},
            ),
            _buildDrawerItem(Icons.text_snippet, 'Gestion de contenu', () {}),
            _buildDrawerItem(Icons.language, 'Langues', () {}),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                // Log out
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre principal du dashboard avec Poppins
              Text(
                'Vue d\'ensemble',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),

              // Cards pour afficher les statistiques avec Poppins
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('Ventes', '123', Colors.green),
                  _buildStatCard('Commandes', '45', Colors.blue),
                  _buildStatCard('Paiements', '678', Colors.orange),
                ],
              ),
              const SizedBox(height: 30),

              // Graphiques ou d'autres sections dynamiques ici
              Card(
                elevation: 3,
                color: Colors.blueAccent.withOpacity(0.1),
                child: ListTile(
                  title: Text(
                    'Graphique des ventes',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Graphique des ventes journalières et mensuelles',
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.show_chart),
                    onPressed: () {
                      // Action pour afficher le graphique des ventes
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Autres sections de données
              Card(
                elevation: 3,
                color: Colors.yellow.withOpacity(0.1),
                child: ListTile(
                  title: Text(
                    'Notifications récentes',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Dernières notifications envoyées aux utilisateurs',
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // Action pour afficher les notifications
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour créer les cartes de statistiques avec Poppins
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 5,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour créer les titres de section dans le menu
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          fontSize: 13,
        ),
      ),
    );
  }

  // Méthode pour créer les éléments du menu
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.blueBic),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: onTap,
      hoverColor: Colors.indigo.withOpacity(0.1),
    );
  }
}

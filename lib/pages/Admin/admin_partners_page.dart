import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Partners Management Page - Clone TGTG Style
/// Gestion des partenaires/commerces qui vendent leurs produits
class AdminPartnersPage extends StatefulWidget {
  const AdminPartnersPage({super.key});

  @override
  State<AdminPartnersPage> createState() => _AdminPartnersPageState();
}

class _AdminPartnersPageState extends State<AdminPartnersPage> {
  int _selectedTab = 0; // 0 = Tous, 1 = Actifs, 2 = En attente, 3 = Inactifs
  final TextEditingController _searchController = TextEditingController();

  // Mock data for partners
  final List<Map<String, dynamic>> _partners = [
    {
      'id': 'P001',
      'name': 'DailyCatch Store',
      'owner': 'Ibrahima Aidara',
      'category': 'Poissonnerie',
      'email': 'contact@dailycatch.com',
      'phone': '+221 77 123 45 67',
      'address': '15 Rue du Port, Dakar',
      'status': 'active',
      'rating': 4.5,
      'ordersCount': 245,
      'revenue': 12500.50,
      'joinedDate': DateTime.now().subtract(const Duration(days: 60)),
    },
    {
      'id': 'P002',
      'name': 'Poissonnerie du Port',
      'owner': 'Mamadou Diop',
      'category': 'Fruits de mer',
      'email': 'contact@portpoisson.com',
      'phone': '+221 77 234 56 78',
      'address': '28 Avenue de la Plage, Dakar',
      'status': 'active',
      'rating': 4.8,
      'ordersCount': 189,
      'revenue': 9800.25,
      'joinedDate': DateTime.now().subtract(const Duration(days: 45)),
    },
    {
      'id': 'P003',
      'name': 'Ocean Fresh',
      'owner': 'Fatou Sall',
      'category': 'Poisson',
      'email': 'hello@oceanfresh.sn',
      'phone': '+221 77 345 67 89',
      'address': '42 Quai des Pêcheurs',
      'status': 'pending',
      'rating': 0,
      'ordersCount': 0,
      'revenue': 0,
      'joinedDate': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 'P004',
      'name': 'Le Marché de la Mer',
      'owner': 'Cheikh Ndiaye',
      'category': 'Crustacés',
      'email': 'info@marchemer.sn',
      'phone': '+221 77 456 78 90',
      'address': '10 Boulevard de la Corniche',
      'status': 'active',
      'rating': 4.2,
      'ordersCount': 156,
      'revenue': 7650.00,
      'joinedDate': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 'P005',
      'name': 'Coquillages & Crustacés',
      'owner': 'Aissatou Diallo',
      'category': 'Coquillages',
      'email': 'contact@coquillages.sn',
      'phone': '+221 77 567 89 01',
      'address': '55 Rue des Coquillages',
      'status': 'inactive',
      'rating': 3.9,
      'ordersCount': 78,
      'revenue': 4200.75,
      'joinedDate': DateTime.now().subtract(const Duration(days: 90)),
    },
  ];

  List<Map<String, dynamic>> get _filteredPartners {
    var filtered = _partners;

    // Filter by tab
    if (_selectedTab == 1) {
      filtered = filtered.where((p) => p['status'] == 'active').toList();
    } else if (_selectedTab == 2) {
      filtered = filtered.where((p) => p['status'] == 'pending').toList();
    } else if (_selectedTab == 3) {
      filtered = filtered.where((p) => p['status'] == 'inactive').toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered =
          filtered
              .where(
                (p) =>
                    p['name'].toString().toLowerCase().contains(query) ||
                    p['owner'].toString().toLowerCase().contains(query) ||
                    p['category'].toString().toLowerCase().contains(query),
              )
              .toList();
    }

    return filtered;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Actif';
      case 'pending':
        return 'En attente';
      case 'inactive':
        return 'Inactif';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Partenaires',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.blueBic),
            onPressed: () => context.go('/admin/partners/new'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un partenaire...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          // Status tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('Tous', 0),
                  _buildTab('Actifs', 1),
                  _buildTab('En attente', 2),
                  _buildTab('Inactifs', 3),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Partners list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPartners.length,
              itemBuilder: (context, index) {
                final partner = _filteredPartners[index];
                return _buildPartnerCard(context, partner);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueBic : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerCard(BuildContext context, Map<String, dynamic> partner) {
    return GestureDetector(
      onTap: () => context.go('/admin/partners/${partner['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          border: Border.all(
            color:
                partner['status'] == 'pending'
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.blueBic.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      partner['name'][0],
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueBic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              partner['name'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                partner['status'] as String,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(partner['status'] as String),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(
                                  partner['status'] as String,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        partner['category'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            partner['owner'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (partner['status'] == 'active') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetric(
                    Icons.star,
                    '${partner['rating']}',
                    Colors.amber,
                  ),
                  const SizedBox(width: 24),
                  _buildMetric(
                    Icons.shopping_bag,
                    '${partner['ordersCount']}',
                    AppColors.blueBic,
                  ),
                  const SizedBox(width: 24),
                  _buildMetric(
                    Icons.euro,
                    '${(partner['revenue'] as double).toStringAsFixed(0)}€',
                    Colors.green,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
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
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppColors.blueBic),
            title: Text('Dashboard', style: GoogleFonts.poppins()),
            onTap: () => context.go('/admin/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.store, color: AppColors.blueBic),
            title: Text('Partenaires', style: GoogleFonts.poppins()),
            onTap: () => context.pop(),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.blueBic),
            title: Text('Clients', style: GoogleFonts.poppins()),
            onTap: () => context.go('/admin/clients'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('Déconnexion', style: GoogleFonts.poppins()),
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

/// Page Order History - Clone TGTG
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  int _selectedFilter = 0; // 0 = Tout, 1 = Actif, 2 = Terminé

  // Données mock pour les commandes
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'CMD-001',
      'store': 'DailyCatch Store',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'items': 2,
      'total': 8.98,
      'status': 'completed',
      'products': ['Sacs magic Saumon', 'Sacs magic Crevettes'],
    },
    {
      'id': 'CMD-002',
      'store': 'Poissonnerie du Port',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'items': 1,
      'total': 4.99,
      'status': 'completed',
      'products': ['Plateau Huîtres'],
    },
    {
      'id': 'CMD-003',
      'store': 'Ocean Fresh',
      'date': DateTime.now(),
      'items': 3,
      'total': 15.47,
      'status': 'active',
      'products': ['Sacs magic Saumon', 'Sacs magic Crevettes', 'Sacs magic Homard'],
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 0) return _orders;
    if (_selectedFilter == 1) {
      return _orders.where((o) => o['status'] == 'active').toList();
    }
    return _orders.where((o) => o['status'] == 'completed').toList();
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
          'Historique des commandes',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('Tout', 0),
                const SizedBox(width: 8),
                _buildFilterChip('En cours', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Terminé', 2),
              ],
            ),
          ),
          // Orders list
          Expanded(
            child: _filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _buildOrderCard(context, order);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.blueBic),
            accountName: Text(
              'Ibrahima Aidara',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              'ibrahima@email.com',
              style: GoogleFonts.poppins(),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.blueBic),
            ),
          ),
          _buildDrawerItem(Icons.qr_code_2, 'Mes sauvés', '/pickup'),
          _buildDrawerItem(Icons.shopping_bag, 'Commander', '/home'),
          _buildDrawerItem(Icons.person, 'Mon profil', '/profile'),
          _buildDrawerItem(Icons.settings, 'Paramètres', '/settings'),
          const Divider(),
          _buildDrawerItem(Icons.help, 'Aide & FAQ', '/help'),
          _buildDrawerItem(Icons.logout, 'Déconnexion', '/login'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.blueBic),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: () {
        context.pop();
        context.push(route);
      },
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.poppins()),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? index : 0;
        });
      },
      selectedColor: AppColors.blueBic,
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune commande',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final isCompleted = order['status'] == 'completed';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['store'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '#${order['id']} • ${_formatDate(order['date'] as DateTime)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isCompleted ? 'Terminé' : 'En cours',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${order['items']} produit(s) • ${order['total'].toStringAsFixed(2)}€',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.blueBic,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...(order['products'] as List<String>).map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(product, style: GoogleFonts.poppins()),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text(
                      '${order['total'].toStringAsFixed(2)}€',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueBic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blueBic,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Voir les détails', style: GoogleFonts.poppins()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

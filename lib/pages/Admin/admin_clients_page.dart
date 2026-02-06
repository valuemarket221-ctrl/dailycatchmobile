import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Admin Clients Page - Clone TGTG Style
/// Gestion des utilisateurs/clients de la plateforme
class AdminClientsPage extends StatefulWidget {
  const AdminClientsPage({super.key});

  @override
  State<AdminClientsPage> createState() => _AdminClientsPageState();
}

class _AdminClientsPageState extends State<AdminClientsPage> {
  int _selectedTab = 0; // 0 = Tous, 1 = Actifs, 2 = Inactifs
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  // Mock data for clients
  final List<Map<String, dynamic>> _clients = List.generate(
    25,
    (index) => {
      'id': 'USR${index + 1}',
      'name': 'Client ${index + 1}',
      'email': 'client${index + 1}@example.com',
      'phone': '+221 77${index}00123${index}',
      'status': index % 5 == 0 ? 'inactive' : 'active',
      'ordersCount': index * 3,
      'totalSpent': (index * 3 * 15.50),
      'joinedDate': DateTime.now().subtract(Duration(days: index * 10)),
      'lastOrder': DateTime.now().subtract(Duration(days: index)),
    },
  );

  List<Map<String, dynamic>> get _filteredClients {
    var filtered = _clients;

    // Filter by tab
    if (_selectedTab == 1) {
      filtered = filtered.where((c) => c['status'] == 'active').toList();
    } else if (_selectedTab == 2) {
      filtered = filtered.where((c) => c['status'] == 'inactive').toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((c) =>
        c['name'].toString().toLowerCase().contains(query) ||
        c['email'].toString().toLowerCase().contains(query) ||
        c['phone'].toString().contains(query)
      ).toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _paginatedClients {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage) > _filteredClients.length
        ? _filteredClients.length
        : start + _itemsPerPage;
    return _filteredClients.sublist(start, end);
  }

  int get _totalPages => (_filteredClients.length / _itemsPerPage).ceil();

  Color _getStatusColor(String status) {
    return status == 'active' ? Colors.green : Colors.red;
  }

  String _getStatusText(String status) {
    return status == 'active' ? 'Actif' : 'Inactif';
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
          'Clients',
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
            icon: const Icon(Icons.person_add, color: AppColors.blueBic),
            onPressed: () {},
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
                hintText: 'Rechercher un client...',
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
                  _buildTab('Inactifs', 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Clients count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredClients.length} clients',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Clients list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _paginatedClients.length,
              itemBuilder: (context, index) {
                final client = _paginatedClients[index];
                return _buildClientCard(context, client);
              },
            ),
          ),
          // Pagination
          if (_totalPages > 1)
            _buildPagination(),
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

  Widget _buildClientCard(BuildContext context, Map<String, dynamic> client) {
    return GestureDetector(
      onTap: () => context.go('/admin/clients/${client['id']}'),
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
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.blueBic.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      client['name'][0],
                      style: GoogleFonts.poppins(
                        fontSize: 20,
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
                          Text(
                            client['name'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(client['status'] as String).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(client['status'] as String),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(client['status'] as String),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client['email'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                _buildStat(Icons.shopping_bag, '${client['ordersCount']}', 'Commandes'),
                const SizedBox(width: 24),
                _buildStat(Icons.euro, '${(client['totalSpent'] as double).toStringAsFixed(0)}€', 'Dépensé'),
                const SizedBox(width: 24),
                _buildStat(Icons.access_time, _getDaysAgo(client['lastOrder'] as DateTime), 'Dernière cmd'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.blueBic),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _getDaysAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays}j';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inMinutes}m';
    }
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Page ${_currentPage + 1} sur $_totalPages',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
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
            accountName: Text('Administrateur', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
            onTap: () => context.go('/admin/partners'),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.blueBic),
            title: Text('Clients', style: GoogleFonts.poppins()),
            onTap: () => context.pop(),
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

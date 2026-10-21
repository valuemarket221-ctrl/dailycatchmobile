import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/admin_api_service.dart';
import 'package:myapp/styles/app_theme.dart';

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
  final AdminApiService _adminApiService = AdminApiService();
  var _clients = <Map<String, dynamic>>[];
  var _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final clients = await _adminApiService.getUsers(
        role: 'client',
        limit: 200,
      );
      if (!mounted) return;
      setState(() {
        _clients = clients;
        _currentPage = 0;
        _isLoading = false;
      });
    } on AdminApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'clients_unavailable';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredClients {
    var filtered = _clients;

    // Filter by tab
    if (_selectedTab == 1) {
      filtered = filtered.where((c) => c['active'] == true).toList();
    } else if (_selectedTab == 2) {
      filtered = filtered.where((c) => c['active'] != true).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered =
          filtered
              .where(
                (c) =>
                    _displayName(c).toLowerCase().contains(query) ||
                    c['email'].toString().toLowerCase().contains(query) ||
                    (c['phone']?.toString() ?? '').contains(query),
              )
              .toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _paginatedClients {
    final filtered = _filteredClients;
    if (filtered.isEmpty) return const [];

    final start = _currentPage * _itemsPerPage;
    if (start >= filtered.length) {
      return filtered.take(_itemsPerPage).toList();
    }
    final end =
        (start + _itemsPerPage) > filtered.length
            ? filtered.length
            : start + _itemsPerPage;
    return filtered.sublist(start, end);
  }

  int get _totalPages => (_filteredClients.length / _itemsPerPage).ceil();

  Color _getStatusColor(bool active) {
    return active ? AppColors.greenTGTG : AppTheme.errorColor;
  }

  String _getStatusText(bool active) {
    return active ? 'Actif' : 'Inactif';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mutedSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Sauveurs',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blueBic,
          ),
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.blueBic),
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
          _buildSummaryHeader(),
          // Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un sauveur...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.softBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.softBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged:
                  (value) => setState(() {
                    _currentPage = 0;
                  }),
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
                  '${_filteredClients.length} sauveurs',
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                    ? _buildStateMessage(
                      icon: Icons.cloud_off_outlined,
                      title: 'Clients indisponibles',
                      message: _loadError!,
                      actionLabel: 'Réessayer',
                      onAction: _loadClients,
                    )
                    : _filteredClients.isEmpty
                    ? _buildStateMessage(
                      icon: Icons.people_alt_outlined,
                      title: 'Aucun client',
                      message:
                          'Aucun compte client ne correspond aux filtres actuels.',
                    )
                    : RefreshIndicator(
                      onRefresh: _loadClients,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _paginatedClients.length,
                        itemBuilder: (context, index) {
                          final client = _paginatedClients[index];
                          return _buildClientCard(context, client);
                        },
                      ),
                    ),
          ),
          // Pagination
          if (_totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.blueBic.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.people_alt, color: AppColors.blueBic),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Communauté DailyCatch',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueBic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Suivi des comptes, réservations et activité récente.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap:
          () => setState(() {
            _selectedTab = index;
            _currentPage = 0;
          }),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueBic : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.blueBic : AppTheme.softBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.blueBic,
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, Map<String, dynamic> client) {
    final active = client['active'] == true;
    final name = _displayName(client);
    final createdAt = _date(client['createdAt']);
    return GestureDetector(
      onTap: () => context.go('/admin/clients/${client['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.softBorder),
          boxShadow: AppTheme.shadowSm,
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
                      name[0].toUpperCase(),
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
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blueBic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                active,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(active),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(active),
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
                Expanded(
                  child: _buildStat(
                    Icons.badge_outlined,
                    client['id']?.toString() ?? '-',
                    'Identifiant',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStat(
                    Icons.phone_outlined,
                    client['phone']?.toString().isNotEmpty == true
                        ? client['phone'].toString()
                        : '-',
                    'Téléphone',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStat(
                    Icons.calendar_today_outlined,
                    createdAt == null ? '-' : _getDaysAgo(createdAt),
                    'Inscrit',
                  ),
                ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.blueBic),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  String _displayName(Map<String, dynamic> client) {
    final displayName = client['displayName']?.toString().trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = client['email']?.toString().trim();
    if (email != null && email.isNotEmpty) return email;
    return 'Client DailyCatch';
  }

  DateTime? _date(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  Widget _buildStateMessage({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.blueBic),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.blueBic,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              TextButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Page ${_currentPage + 1} sur $_totalPages',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                _currentPage < _totalPages - 1
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
            onTap: () => context.go('/admin/partners'),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.blueBic),
            title: Text('Clients', style: GoogleFonts.poppins()),
            onTap: () => safePop(context),
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

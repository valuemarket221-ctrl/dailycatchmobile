import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/admin_api_service.dart';
import 'package:myapp/styles/app_theme.dart';

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
  final AdminApiService _adminApiService = AdminApiService();
  var _partners = <Map<String, dynamic>>[];
  var _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPartners() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final partners = await _adminApiService.getPartnerProfiles();
      if (!mounted) return;
      setState(() {
        _partners = partners;
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
        _loadError = 'partners_unavailable';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredPartners {
    var filtered = _partners;

    // Filter by tab
    if (_selectedTab == 1) {
      filtered = filtered.where((p) => p['status'] == 'approved').toList();
    } else if (_selectedTab == 2) {
      filtered =
          filtered.where((p) => p['status'] == 'pending_review').toList();
    } else if (_selectedTab == 3) {
      filtered =
          filtered
              .where(
                (p) => p['status'] == 'rejected' || p['status'] == 'suspended',
              )
              .toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered =
          filtered
              .where(
                (p) =>
                    _storeName(p).toLowerCase().contains(query) ||
                    _ownerName(p).toLowerCase().contains(query) ||
                    (p['commerceType']?.toString().toLowerCase() ?? '')
                        .contains(query),
              )
              .toList();
    }

    return filtered;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.greenTGTG;
      case 'pending_review':
        return AppTheme.warningColor;
      case 'rejected':
      case 'suspended':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Actif';
      case 'pending_review':
        return 'En attente';
      case 'rejected':
        return 'Refusé';
      case 'suspended':
        return 'Suspendu';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mutedSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Commerces',
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
            icon: const Icon(Icons.add, color: AppColors.blueBic),
            onPressed: () => context.go('/admin/partners/new'),
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
                hintText: 'Rechercher un commerce...',
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                    ? _buildStateMessage(
                      icon: Icons.cloud_off_outlined,
                      title: 'Commerces indisponibles',
                      message: _loadError!,
                      actionLabel: 'Réessayer',
                      onAction: _loadPartners,
                    )
                    : _filteredPartners.isEmpty
                    ? _buildStateMessage(
                      icon: Icons.storefront_outlined,
                      title: 'Aucun commerce',
                      message:
                          'Aucun compte partenaire ne correspond aux filtres actuels.',
                    )
                    : RefreshIndicator(
                      onRefresh: _loadPartners,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPartners.length,
                        itemBuilder: (context, index) {
                          final partner = _filteredPartners[index];
                          return _buildPartnerCard(context, partner);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final activeCount =
        _partners.where((p) => p['status'] == 'approved').length.toString();
    final pendingCount =
        _partners
            .where((p) => p['status'] == 'pending_review')
            .length
            .toString();

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
              color: AppColors.greenTGTG.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront, color: AppColors.greenTGTG),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$activeCount commerces actifs',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueBic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$pendingCount demande en attente de validation.',
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
      onTap: () => setState(() => _selectedTab = index),
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

  Widget _buildPartnerCard(BuildContext context, Map<String, dynamic> partner) {
    final name = _storeName(partner);
    final status = partner['status']?.toString() ?? 'pending_review';
    return GestureDetector(
      onTap: () => context.go('/admin/partners/${partner['userId']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowSm,
          border: Border.all(
            color:
                status == 'pending_review'
                    ? AppTheme.warningColor.withValues(alpha: 0.35)
                    : AppTheme.softBorder,
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
                      name[0].toUpperCase(),
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
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueBic,
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
                                status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(status),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _commerceType(partner),
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
                            _ownerName(partner),
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
            if (status == 'approved') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetric(
                    Icons.star,
                    partner['city']?.toString().isNotEmpty == true
                        ? partner['city'].toString()
                        : '-',
                    AppColors.blueBic,
                  ),
                  const SizedBox(width: 24),
                  _buildMetric(
                    Icons.shopping_bag,
                    partner['phone']?.toString().isNotEmpty == true
                        ? partner['phone'].toString()
                        : '-',
                    AppColors.blueBic,
                  ),
                  const SizedBox(width: 24),
                  _buildMetric(
                    Icons.savings,
                    _dateLabel(partner['createdAt']),
                    AppColors.greenTGTG,
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

  String _storeName(Map<String, dynamic> partner) {
    final value = partner['storeName']?.toString().trim();
    return value == null || value.isEmpty ? 'Commerce DailyCatch' : value;
  }

  String _ownerName(Map<String, dynamic> partner) {
    final value = partner['ownerName']?.toString().trim();
    return value == null || value.isEmpty ? 'Responsable non renseigné' : value;
  }

  String _commerceType(Map<String, dynamic> partner) {
    final value = partner['commerceType']?.toString().trim();
    return value == null || value.isEmpty ? 'Commerce' : value;
  }

  String _dateLabel(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return '-';
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
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
            onTap: () => safePop(context),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/admin_api_service.dart';
import 'package:myapp/styles/app_theme.dart';

/// Partner Validation Page - Clone TGTG Style
/// Page pour valider/refuser les demandes de partenariat en attente
class PartnerValidationPage extends StatefulWidget {
  const PartnerValidationPage({super.key});

  @override
  State<PartnerValidationPage> createState() => _PartnerValidationPageState();
}

class _PartnerValidationPageState extends State<PartnerValidationPage> {
  final AdminApiService _adminApiService = AdminApiService();
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _pendingPartners = const [];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    try {
      final applications = await _adminApiService.getPartnerApplications();
      if (!mounted) return;
      setState(() {
        _pendingPartners = applications;
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pendingPartners = const [];
        _loadError = 'Demandes partenaires indisponibles.';
        _isLoading = false;
      });
    }
  }

  Future<void> _approvePartner(String userId) async {
    try {
      await _adminApiService.updatePartnerApplication(
        userId: userId,
        status: 'approved',
      );
      if (!mounted) return;
      _showMessage('Partenaire approuvé. Le rôle vendeur est actif.');
      await _loadApplications();
    } catch (_) {
      if (!mounted) return;
      _showMessage('Approbation impossible.', isError: true);
    }
  }

  void _rejectPartner(String partnerId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Rejeter le commerce',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motif du rejet',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _adminApiService.updatePartnerApplication(
                      userId: partnerId,
                      status: 'rejected',
                      rejectionReason: reasonController.text.trim(),
                    );
                    if (!mounted) return;
                    _showMessage('Demande partenaire rejetée.');
                    await _loadApplications();
                  } catch (_) {
                    if (!mounted) return;
                    _showMessage('Rejet impossible.', isError: true);
                  } finally {
                    reasonController.dispose();
                  }
                },
                child: Text('Confirmer le rejet', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    ).then((_) {
      if (reasonController.text.isEmpty) {
        reasonController.dispose();
      }
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppColors.greenTGTG,
      ),
    );
  }

  Map<String, dynamic> _normalizeApplication(Map<String, dynamic> partner) {
    final createdAt = DateTime.tryParse(partner['createdAt'] as String? ?? '');
    return {
      'id': partner['userId'] as String? ?? partner['id'] as String? ?? '',
      'name': partner['storeName'] as String? ?? 'Commerce',
      'owner': partner['ownerName'] as String? ?? 'Responsable',
      'category': partner['category'] as String? ?? 'Non renseigné',
      'email': partner['email'] as String? ?? '',
      'phone':
          partner['storePhone'] as String? ??
          partner['ownerPhone'] as String? ??
          '',
      'address': [
        partner['address'] as String? ?? '',
        partner['city'] as String? ?? '',
      ].where((item) => item.isNotEmpty).join(', '),
      'appliedDate': createdAt ?? DateTime.now(),
      'description': partner['description'] as String? ?? '',
      'openingHours': 'A configurer',
      'siret': partner['siret'] as String? ?? '',
      'vat': partner['vat'] as String? ?? '',
      'website': partner['website'] as String? ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mutedSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Validation partenaires',
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
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_pendingPartners.length} en attente',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warningColor,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
              ? _buildLoadError()
              : _pendingPartners.isEmpty
              ? _buildEmptyState()
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryHeader(),
                  const SizedBox(height: 14),
                  ..._pendingPartners
                      .map(_normalizeApplication)
                      .map((partner) => _buildPartnerCard(context, partner)),
                ],
              ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
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
              color: AppTheme.warningColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_user,
              color: AppTheme.warningColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commerces à vérifier',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueBic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Contrôlez identité, adresse, horaires et catégorie avant activation.',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.greenTGTG.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 48,
              color: AppColors.greenTGTG,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune demande en attente',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toutes les demandes ont été traitées',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.softBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AppTheme.errorColor, size: 42),
            const SizedBox(height: 12),
            Text(
              _loadError!,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadApplications,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCard(BuildContext context, Map<String, dynamic> partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
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
                    Text(
                      partner['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueBic,
                      ),
                    ),
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
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Il y a ${_getTimeAgo(partner['appliedDate'] as DateTime)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          // Info
          _buildInfoRow(
            Icons.person,
            'Responsable:',
            partner['owner'] as String,
          ),
          _buildInfoRow(Icons.email, 'Email:', partner['email'] as String),
          _buildInfoRow(Icons.phone, 'Téléphone:', partner['phone'] as String),
          _buildInfoRow(
            Icons.location_on,
            'Adresse:',
            partner['address'] as String,
          ),
          _buildInfoRow(
            Icons.access_time,
            'Horaires:',
            partner['openingHours'] as String,
          ),
          _buildInfoRow(Icons.badge, 'SIRET:', partner['siret'] as String),
          if ((partner['website'] as String).isNotEmpty)
            _buildInfoRow(
              Icons.language,
              'Site:',
              partner['website'] as String,
            ),
          const SizedBox(height: 12),
          // Description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.mutedSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              partner['description'] as String,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectPartner(partner['id'] as String),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppTheme.errorColor),
                    foregroundColor: AppTheme.errorColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.close),
                  label: Text(
                    'Rejeter',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approvePartner(partner['id'] as String),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.greenTGTG,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(
                    'Approuver',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.blueBic),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}';
    } else {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
    }
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
            leading: const Icon(Icons.verified_user, color: Colors.orange),
            title: Text('Validation', style: GoogleFonts.poppins()),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Partner Validation Page - Clone TGTG Style
/// Page pour valider/refuser les demandes de partenariat en attente
class PartnerValidationPage extends StatefulWidget {
  const PartnerValidationPage({super.key});

  @override
  State<PartnerValidationPage> createState() => _PartnerValidationPageState();
}

class _PartnerValidationPageState extends State<PartnerValidationPage> {
  // Mock data for pending partners
  final List<Map<String, dynamic>> _pendingPartners = [
    {
      'id': 'P003',
      'name': 'Ocean Fresh',
      'owner': 'Fatou Sall',
      'category': 'Poisson',
      'email': 'hello@oceanfresh.sn',
      'phone': '+221 77 345 67 89',
      'address': '42 Quai des Pêcheurs',
      'appliedDate': DateTime.now().subtract(const Duration(days: 3)),
      'description': 'Spécialiste du poisson frais avec 10 ans d\'expérience.',
      'openingHours': '08:00 - 20:00',
    },
    {
      'id': 'P006',
      'name': 'Les Fruits de Mer',
      'owner': 'Ousmane Touré',
      'category': 'Fruits de mer',
      'email': 'contact@fruitsdemer.sn',
      'phone': '+221 77 678 90 12',
      'address': '25 Boulevard de la Corniche',
      'appliedDate': DateTime.now().subtract(const Duration(days: 1)),
      'description': 'Commerce familial spécialisé dans les crustacés.',
      'openingHours': '07:00 - 19:00',
    },
    {
      'id': 'P007',
      'name': 'Le Petit Pêcheur',
      'owner': 'Marie Diop',
      'category': 'Poissonnerie',
      'email': 'info@petitpecheur.sn',
      'phone': '+221 77 789 01 23',
      'address': '8 Rue de la Plage',
      'appliedDate': DateTime.now().subtract(const Duration(hours: 6)),
      'description': 'Poisson frais directement de la peche du jour.',
      'openingHours': '06:00 - 14:00',
    },
  ];

  void _approvePartner(String partnerId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partenaire $partnerId approuvé avec succès!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {});
  }

  void _rejectPartner(String partnerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rejeter le partenaire', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Partenaire $partnerId rejeté'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {});
            },
            child: Text('Confirmer le rejet', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
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
          'Validation partenaires',
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
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_pendingPartners.length} en attente',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _pendingPartners.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingPartners.length,
              itemBuilder: (context, index) {
                final partner = _pendingPartners[index];
                return _buildPartnerCard(context, partner);
              },
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
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 48, color: Colors.green),
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
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
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
                        const Icon(Icons.access_time, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'Il y a ${_getTimeAgo(partner['appliedDate'] as DateTime)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.orange,
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
          _buildInfoRow(Icons.person, 'Responsable:', partner['owner'] as String),
          _buildInfoRow(Icons.email, 'Email:', partner['email'] as String),
          _buildInfoRow(Icons.phone, 'Téléphone:', partner['phone'] as String),
          _buildInfoRow(Icons.location_on, 'Adresse:', partner['address'] as String),
          _buildInfoRow(Icons.access_time, 'Horaires:', partner['openingHours'] as String),
          const SizedBox(height: 12),
          // Description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              partner['description'] as String,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
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
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.close),
                  label: Text('Rejeter', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approvePartner(partner['id'] as String),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text('Approuver', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
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
            leading: const Icon(Icons.verified_user, color: Colors.orange),
            title: Text('Validation', style: GoogleFonts.poppins()),
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

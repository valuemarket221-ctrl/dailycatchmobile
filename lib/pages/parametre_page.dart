import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/support_api_service.dart';
import 'package:myapp/styles/app_theme.dart';

class ParametrePage extends StatefulWidget {
  const ParametrePage({super.key});

  @override
  State<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
  final SupportApiService _supportApiService = SupportApiService();
  String _selectedLangue = "Français";
  bool _notificationsEnabled = true;
  bool _isUpdatingNotifications = false;

  void _changerMotDePasse() {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Modifier le mot de passe",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Nouveau mot de passe",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Annuler",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Ajouter la logique de modification ici
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Mot de passe modifié avec succès !"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text("Modifier", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mutedSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.blueBic),
        title: Text(
          "Paramètres",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blueBic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildSectionTitle("Langue"),
            const SizedBox(height: 8),
            _buildSettingsCard(children: [_buildLanguageDropdown()]),
            const SizedBox(height: 18),
            _buildSectionTitle("Préférences"),
            const SizedBox(height: 8),
            _buildSettingsCard(children: [_buildNotificationToggle()]),
            const SizedBox(height: 18),
            _buildSectionTitle("Compte"),
            const SizedBox(height: 8),
            _buildSettingsCard(children: [_buildSecurityOption()]),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.greenTGTG.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune, color: AppColors.greenTGTG),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expérience DailyCatch',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueBic,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Gérez vos préférences de compte et de notifications.',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.blueBic,
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLangue,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.blueBic),
          items:
              ["Français", "Anglais", "Espagnol", "Allemand"].map((
                String langue,
              ) {
                return DropdownMenuItem<String>(
                  value: langue,
                  child: Text(
                    langue,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueBic,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue == null) return;
            setState(() {
              _selectedLangue = newValue;
            });
          },
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: _buildIconBox(Icons.notifications_active),
      title: Text(
        "Alertes paniers",
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        "Recevoir les nouveautés et paniers disponibles.",
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
      ),
      value: _notificationsEnabled,
      onChanged:
          _isUpdatingNotifications
              ? null
              : (bool value) => _updateNotificationPreference(value),
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.blueBic,
    );
  }

  Widget _buildSecurityOption() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: _buildIconBox(Icons.lock),
      title: Text(
        "Sécurité",
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        "Modifier le mot de passe",
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: _changerMotDePasse,
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.blueBic.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.blueBic, size: 22),
    );
  }

  Future<void> _updateNotificationPreference(bool enabled) async {
    final previousValue = _notificationsEnabled;
    setState(() {
      _notificationsEnabled = enabled;
      _isUpdatingNotifications = true;
    });

    try {
      await _supportApiService.updatePushNotificationsEnabled(enabled);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled ? 'Notifications activées' : 'Notifications désactivées',
          ),
          backgroundColor: AppColors.greenTGTG,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _notificationsEnabled = previousValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d’enregistrer cette préférence.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingNotifications = false);
      }
    }
  }
}

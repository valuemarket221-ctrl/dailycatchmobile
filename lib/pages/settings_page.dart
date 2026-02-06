import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Page Settings - Clone TGTG
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Paramètres',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Account section
            _buildSectionTitle('Compte'),
            _buildSettingItem(
              Icons.person,
              'Modifier le profil',
              'Nom, email, téléphone',
              () => context.push('/edit-profile'),
            ),
            _buildSettingItem(
              Icons.lock,
              'Mot de passe',
              'Changer votre mot de passe',
              () => context.push('/change-password'),
            ),
            _buildSettingItem(
              Icons.location_on,
              'Adresses',
              'Gérer vos adresses',
              () => context.push('/addresses'),
            ),
            _buildSettingItem(
              Icons.payment,
              'Moyens de paiement',
              'Cartes, mobile money',
              () => context.push('/payment-methods'),
            ),

            // Notifications section
            _buildSectionTitle('Notifications'),
            _buildSwitchItem(
              Icons.notifications,
              'Notifications push',
              'Recevoir des alertes',
              true,
            ),
            _buildSwitchItem(
              Icons.email,
              'Emails',
              'Recevoir des emails promotionnels',
              false,
            ),

            // Preferences section
            _buildSectionTitle('Préférences'),
            _buildSettingItem(Icons.language, 'Langue', 'Français', () {
              _showLanguagePicker(context);
            }),
            _buildSettingItem(Icons.currency_exchange, 'Devise', 'FCFA', () {
              _showCurrencyPicker(context);
            }),

            // About section
            _buildSectionTitle('À propos'),
            _buildSettingItem(Icons.info, 'Version', '1.0.0', () {
              _showVersionDialog(context);
            }),
            _buildSettingItem(
              Icons.rate_review,
              'Noter l\'application',
              'Donnez votre avis',
              () => _showRateAppDialog(context),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blueBic.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.blueBic, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blueBic.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.blueBic, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: AppColors.blueBic,
          ),
        ],
      ),
    );
  }

  // ========== HELPER METHODS ==========

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Choisir la langue', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildLanguageOption(context, 'Français'),
            _buildLanguageOption(context, 'English'),
            _buildLanguageOption(context, 'Español'),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language) {
    return ListTile(
      title: Text(language, style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.check, color: AppColors.blueBic),
      onTap: () => Navigator.of(context).pop(),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Choisir la devise', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildCurrencyOption(context, 'FCFA', 'Franc CFA'),
            _buildCurrencyOption(context, 'EUR', 'Euro'),
            _buildCurrencyOption(context, 'USD', 'Dollar US'),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildCurrencyOption(BuildContext context, String code, String name) {
    return ListTile(
      title: Text('$code - $name', style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.check, color: AppColors.blueBic),
      onTap: () => Navigator.of(context).pop(),
    );
  }

  void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('À propos', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('DailyCatch', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Version 1.0.0', style: GoogleFonts.poppins(color: Colors.grey)),
              const SizedBox(height: 16),
              Text(
                'DailyCatch est une application qui vous permet de sauver les produits alimentaires pour réduire le gaspillage.',
                style: GoogleFonts.poppins(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.poppins(color: AppColors.blueBic)),
            ),
          ],
        );
      },
    );
  }

  void _showRateAppDialog(BuildContext context) {
    int _selectedRating = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Noter l\'application', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 48, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'Avez-vous aimé DailyCatch ?\nDonnez-nous votre avis !',
                    style: GoogleFonts.poppins(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Plus tard', style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueBic),
                  onPressed: () {
                    if (_selectedRating > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.blueBic,
                          content: Text(
                            'Merci pour votre note de $_selectedRating étoile${_selectedRating > 1 ? 's' : ''} !',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Noter', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

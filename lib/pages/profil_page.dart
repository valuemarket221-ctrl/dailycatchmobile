import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/constants.dart';

/// Page Profil utilisateur complète
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // Données utilisateur fictives
  String _userName = 'Ibrahima Aidara Sadio';
  String _userEmail = 'ibrahima.aidara@gmail.com';
  String _userAvatar = '';
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec photo de profil
            _buildProfileHeader(),

            // Statistiques
            _buildStatsCard(),

            // Menu du profil
            _buildProfileMenu(),

            // Section Aide & Support
            _buildHelpSection(),

            // Bouton Déconnexion
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Photo de profil avec edit
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.blueBic,
                child:
                    _userAvatar.isEmpty
                        ? Icon(
                          Icons.account_circle,
                          size: 100,
                          color: Colors.white,
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            _userAvatar,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.yellowColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: _changeAvatar,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nom
          Text(
            _userName,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.blueBic,
            ),
          ),
          // Email
          Text(
            _userEmail,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          // Badge membre
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Membre Gold',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blueBic, AppColors.blueBic.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueBic.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.shopping_bag,
            value: '12',
            label: 'Sauvés',
          ),
          _buildStatItem(
            icon: Icons.savings,
            value: '89€',
            label: 'Économisés',
          ),
          _buildStatItem(icon: Icons.eco, value: '15kg', label: 'CO₂ évité'),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu() {
    final menuItems = [
      {
        'icon': Icons.qr_code_2,
        'title': 'Mes réservations',
        'subtitle': 'Voir mes produits sauvés',
        'color': AppColors.blueBic,
        'route': '/my-reservations',
      },
      {
        'icon': Icons.edit,
        'title': 'Modifier le profil',
        'subtitle': 'Nom, email, téléphone',
        'color': Colors.purple,
        'route': '/edit-profile',
      },
      {
        'icon': Icons.location_on,
        'title': 'Mes adresses',
        'subtitle': 'Gérer mes adresses',
        'color': Colors.orange,
        'route': '/addresses',
      },
      {
        'icon': Icons.notifications,
        'title': 'Notifications',
        'subtitle': 'Préférences de notification',
        'color': Colors.red,
        'route': '/notifications-settings',
      },
      {
        'icon': Icons.payment,
        'title': 'Moyens de paiement',
        'subtitle': 'Cartes, mobile money',
        'color': Colors.green,
        'route': '/payment-methods',
      },
      {
        'icon': Icons.history,
        'title': 'Historique',
        'subtitle': 'Mes anciennes commandes',
        'color': Colors.blueGrey,
        'route': '/orders-history',
      },
      {
        'icon': Icons.lock,
        'title': 'Changer le mot de passe',
        'subtitle': 'Sécuriser mon compte',
        'color': Colors.teal,
        'route': '/change-password',
      },
      {
        'icon': Icons.favorite,
        'title': 'Mes favoris',
        'subtitle': 'Produits favoris',
        'color': Colors.pink,
        'route': '/favorites',
      },
      {
        'icon': Icons.chat,
        'title': 'Messages',
        'subtitle': 'Voir mes conversations',
        'color': Colors.amber,
        'route': '/messages',
      },
      {
        'icon': Icons.store,
        'title': 'Devenir partenaire',
        'subtitle': 'Rejoindre le réseau DailyCatch',
        'color': Colors.indigo,
        'route': '/partenaire',
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children:
            menuItems.map((item) {
              return _buildMenuItem(
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
                color: item['color'] as Color,
                route: item['route'] as String?,
              );
            }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String? route,
  }) {
    return InkWell(
      onTap: () {
        if (route != null) {
          context.push(route);
        } else {
          _showComingSoonDialog(title);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildHelpSection() {
    final helpItems = [
      {
        'icon': Icons.help_outline,
        'title': 'Aide & FAQ',
        'color': Colors.blue,
        'route': '/help',
      },
      {
        'icon': Icons.security,
        'title': 'Confidentialité',
        'color': Colors.teal,
        'route': '/legal',
      },
      {
        'icon': Icons.description,
        'title': 'Conditions générales',
        'color': Colors.grey,
        'route': '/legal',
      },
      {
        'icon': Icons.contact_mail,
        'title': 'Nous contacter',
        'color': Colors.pink,
        'route': '/help',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children:
            helpItems.map((item) {
              return _buildHelpItem(
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                color: item['color'] as Color,
                route: item['route'] as String?,
              );
            }).toList(),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required Color color,
    required String? route,
  }) {
    return InkWell(
      onTap: () {
        if (route != null) {
          context.push(route);
        } else {
          _showComingSoonDialog(title);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Bouton Déconnexion
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.red),
          label: Text(
            'Déconnexion',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.home, color: AppColors.blueBic),
        onPressed: () => context.go('/home'),
      ),
      title: Text(
        "Mon Profil",
        style: GoogleFonts.poppins(
          color: AppColors.blueBic,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.blueBic),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.blueBic.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.settings, color: AppColors.blueBic),
            onPressed: () {
              context.push('/parametre');
            },
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    );
  }

  void _changeAvatar() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Changer la photo',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAvatarOption(
                      Icons.camera_alt,
                      'Prendre une photo',
                      () => _pickImage(ImageSource.camera),
                    ),
                    _buildAvatarOption(
                      Icons.photo_library,
                      'Choisir depuis galerie',
                      () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _userAvatar = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Photo de profil mise à jour!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAvatarOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.blueBic.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppColors.blueBic),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(feature),
            content: Text('Cette fonctionnalité sera bientôt disponible!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    // Déconnexion Firebase
                    await FirebaseAuth.instance.signOut();
                    // Navigation vers la page de login
                    if (mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erreur: ${e.toString()}',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

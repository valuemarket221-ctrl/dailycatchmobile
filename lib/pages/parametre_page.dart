import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class ParametrePage extends StatefulWidget {
  @override
  _ParametrePageState createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
  String _selectedLangue = "Français";
  bool _notificationsEnabled = true;

  void _changerMotDePasse() {
    TextEditingController _passwordController = TextEditingController();
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
              controller: _passwordController,
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
      appBar: AppBar(
        title: Text(
          "Paramètres ",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.blueBic,
        elevation: 2,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Langue"),
            _buildLanguageDropdown(),
            Divider(height: 30, thickness: 1, color: Colors.grey[300]),
            _buildNotificationToggle(),
            Divider(height: 30, thickness: 1, color: Colors.grey[300]),
            _buildSecurityOption(),
          ],
        ),
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

  Widget _buildLanguageDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blueBic),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLangue,
          items:
              ["Français", "Anglais", "Espagnol", "Allemand"].map((
                String langue,
              ) {
                return DropdownMenuItem<String>(
                  value: langue,
                  child: Text(langue, style: GoogleFonts.poppins(fontSize: 16)),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLangue = newValue!;
            });
          },
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return ListTile(
      leading: Icon(Icons.notifications_active, color: AppColors.blueBic),
      title: Text(
        "Notifications",
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: (bool value) {
          setState(() {
            _notificationsEnabled = value;
          });
        },
        activeColor: AppColors.blueBic,
      ),
    );
  }

  Widget _buildSecurityOption() {
    return ListTile(
      leading: Icon(Icons.lock, color: AppColors.blueBic),
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
}

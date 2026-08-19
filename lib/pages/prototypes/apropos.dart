import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart'; // Importer le widget partagé

class AProposPage extends StatelessWidget {
  // Lien du site web
  final Uri _url = Uri.parse('https://dailycatch.app');

  AProposPage({super.key});

  // Fonction pour ouvrir l'URL
  void _openWebsite() async {
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d\'ouvrir le lien $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'À propos / Notre vision',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Section : Concept
            Text(
              ' Concept',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.blueBic,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'DailyCatch connecte les consommateurs avec des commerces locaux qui proposent des paniers surprise de poissons et fruits de mer à prix réduit, pour réduire le gaspillage alimentaire.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Section : Mission
            Text(
              ' Mission',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.blueBic,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Notre mission est de simplifier la réservation de paniers de la mer à récupérer sur créneau court, avec une expérience fluide de la découverte au retrait.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Section : Équipe
            Text(
              ' Équipe fondatrice',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.blueBic,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Peter et son équipe ont créé DailyCatch pour aider les commerces à valoriser leurs invendus tout en rendant les paniers de la mer plus accessibles.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // ✅ Lien vers le site
            InkWell(
              onTap: _openWebsite,
              child: Row(
                children: [
                  const Icon(Icons.link, color: AppColors.blueBic),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Visitez notre site web : dailycatch.app',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.blueBic,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Ajout du widget de navigation partagé
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/widgets/dailycatch_tile_layer.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Panier confirmé",
      "subtitle": "Votre réservation DC-12345 est confirmée.",
      "time": "Il y a 10 min",
      "status": "Confirmé",
    },
    {
      "title": "Retrait bientôt disponible",
      "subtitle": "Votre panier sera prêt à la Poissonnerie du Port.",
      "time": "Il y a 30 min",
      "status": "À retirer",
      "commerce": {
        "nom": "Poissonnerie du Port",
        "telephone": "+221784567890",
        "position": LatLng(14.6928, -17.4467), // Dakar
      },
    },
    {
      "title": "Panier récupéré",
      "subtitle": "Votre panier DC-12345 a été récupéré avec succès.",
      "time": "Aujourd'hui",
      "status": "Récupéré",
    },
  ];

  void _contacterCommerce(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Impossible de passer l'appel.");
    }
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final commerce = notification["commerce"];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications, color: AppColors.blueBic),
            title: Text(
              notification["title"]!,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              notification["subtitle"]!,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            trailing: Text(
              notification["time"]!,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ),
          if (commerce != null) ...[
            _buildMap(commerce),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _contacterCommerce(commerce["telephone"]),
              icon: const Icon(Icons.phone),
              label: Text("Contacter ${commerce["nom"]}"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueBic,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildMap(Map<String, dynamic> commerce) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.softBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: commerce["position"],
            initialZoom: 13.0,
          ),
          children: [
            const DailyCatchTileLayer(),
            MarkerLayer(
              markers: [
                Marker(
                  point: commerce["position"],
                  width: 50.0,
                  height: 50.0,
                  child: Icon(
                    Icons.storefront,
                    color: AppColors.greenTGTG,
                    size: 40.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mutedSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.blueBic,
        elevation: 0,
        title: Text(
          "Suivi du retrait",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blueBic,
          ),
        ),
      ),
      body:
          notifications.isEmpty
              ? Center(
                child: Text(
                  "Aucune alerte de retrait pour le moment",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationTile(notification);
                },
              ),
    );
  }
}

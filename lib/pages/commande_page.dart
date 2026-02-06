import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/constants.dart';

class CommandePage extends StatefulWidget {
  @override
  _CommandePageState createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Commande en préparation 🍽️",
      "subtitle": "Votre commande #12345 est en cours de préparation.",
      "time": "Il y a 10 min",
      "status": "En préparation",
    },
    {
      "title": "Commande en livraison 🚚",
      "subtitle": "Votre commande #12345 est en route.",
      "time": "Il y a 30 min",
      "status": "En livraison",
      "livreur": {
        "nom": "Moussa Diop",
        "telephone": "+221784567890",
        "position": LatLng(14.6928, -17.4467), // Dakar
      },
    },
    {
      "title": "Commande livrée ✅",
      "subtitle": "Votre commande #12345 a été livrée avec succès.",
      "time": "Aujourd'hui",
      "status": "Livré",
    },
  ];

  void _contacterLivreur(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Impossible de passer l'appel.");
    }
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final livreur = notification["livreur"];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notifications, color: AppColors.blueBic),
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
          if (livreur != null) ...[
            _buildMap(livreur),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _contacterLivreur(livreur["telephone"]),
              icon: Icon(Icons.phone),
              label: Text("Contacter ${livreur["nom"]}"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueBic,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildMap(Map<String, dynamic> livreur) {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FlutterMap(
          options: MapOptions(center: livreur["position"], zoom: 13.0),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: livreur["position"],
                  width: 50.0,
                  height: 50.0,
                  child: Icon(
                    Icons.delivery_dining,
                    color: Colors.red,
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
      appBar: AppBar(
        title: Text(
          "Suivi de Commande 🔔",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
      ),
      body:
          notifications.isEmpty
              ? Center(
                child: Text(
                  "Aucune notification pour le moment 📭",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationTile(notification);
                },
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class PickupLocationPage extends StatefulWidget {
  const PickupLocationPage({super.key});

  @override
  State<PickupLocationPage> createState() => _PickupLocationPageState();
}

class _PickupLocationPageState extends State<PickupLocationPage> {
  final MapController _mapController = MapController();

  final Map<String, LatLng> villes = {
    'Dakar': LatLng(14.6928, -17.4467),
    'Malte': LatLng(35.8997, 14.5146),
    'Dublin': LatLng(53.3498, -6.2603),
  };

  String villeSelectionnee = 'Dakar';
  late LatLng selectedLatLng;

  @override
  void initState() {
    super.initState();
    selectedLatLng = villes[villeSelectionnee]!;
  }

  void _onVilleChange(String ville) {
    setState(() {
      villeSelectionnee = ville;
      selectedLatLng = villes[ville]!;
    });
    _mapController.move(selectedLatLng, _mapController.camera.zoom);
  }

  void _confirmerLieu() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Lieu de retrait selectionne : $villeSelectionnee",
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.blueBic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choix du lieu de retrait',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            "Selectionnez votre ville",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children:
                  villes.keys.map((ville) {
                    final isSelected = villeSelectionnee == ville;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          ville,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.blueBic,
                        onSelected: (_) => _onVilleChange(ville),
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: selectedLatLng,
                  initialZoom: 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLatLng,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_on,
                          size: 50,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmerLieu,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  "Confirmer ce lieu",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

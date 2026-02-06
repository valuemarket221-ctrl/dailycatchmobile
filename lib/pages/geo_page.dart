import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'home_page.dart';

class GeolocationPage extends StatefulWidget {
  @override
  _GeolocationPageState createState() => _GeolocationPageState();
}

class _GeolocationPageState extends State<GeolocationPage> {
  String _locationMessage = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateGeolocation();
  }

  void _simulateGeolocation() {
    final random = Random();
    double latitude = -90 + random.nextDouble() * 180;
    double longitude = -180 + random.nextDouble() * 360;

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _locationMessage =
            "📍 Latitude : ${latitude.toStringAsFixed(6)}\n📍 Longitude : ${longitude.toStringAsFixed(6)}";
        _isLoading = false;
      });

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Géolocalisation',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child:
              _isLoading
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 70,
                        color: AppColors.blueBic,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Localisation en cours...',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      CircularProgressIndicator(color: AppColors.blueBic),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 70,
                        color: Colors.green,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Votre position a été détectée avec succès !',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          _locationMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

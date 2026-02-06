
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart'; // Tes couleurs personnalisées

class CountrySelectionPage extends StatefulWidget {
  @override
  _CountrySelectionPageState createState() => _CountrySelectionPageState();
}

class _CountrySelectionPageState extends State<CountrySelectionPage> {
  final List<String> countries = [
    'Sénégal', 'Allemagne', 'France', 'Côte d\'Ivoire', 'Mali', 'Gambie',
    'Burkina Faso', 'Algérie', 'Tunisie', 'Maroc', 'Cameroun', 'Niger',
    'Togo', 'Nigeria', 'Ghana', 'Soudan', 'Kenya', 'Uganda', 'Zimbabwe',
    'Éthiopie', 'Afrique du Sud', 'République Démocratique du Congo',
  ];

  String? _selectedCountry;
  bool _isLoading = false;
  bool _showError = false;

  void _handleNext() {
    setState(() {
      _showError = _selectedCountry == null;
    });

    if (_selectedCountry != null) {
      setState(() => _isLoading = true);

      Future.delayed(Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        Navigator.pushNamed(context, '/geolocation');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sélectionner un pays',
          style: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.blueBic,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Veuillez sélectionner votre pays',
              style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  String country = countries[index];
                  return RadioListTile<String>(
                    title: Text(
                      country,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    value: country,
                    groupValue: _selectedCountry,
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                        _showError = false;
                      });
                    },
                    activeColor: AppColors.blueBic,
                  );
                },
              ),
            ),

            if (_showError)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Veuillez sélectionner un pays.",
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),

            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      child: Text(
                        'Suivant',
                        style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueBic,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

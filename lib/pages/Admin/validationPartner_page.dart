import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart'; // Pour AppColors.blueBic par exemple

class Partner {
  final String name;
  final String sector;
  String status;

  Partner({required this.name, required this.sector, required this.status});
}

class PartnerValidationPage extends StatefulWidget {
  final Partner partner;

  PartnerValidationPage({required this.partner});

  @override
  _PartnerValidationPageState createState() => _PartnerValidationPageState();
}

class _PartnerValidationPageState extends State<PartnerValidationPage> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.partner.status;
  }

  void updateStatus(String newStatus) {
    setState(() {
      status = newStatus;
      widget.partner.status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partenaire ${newStatus.toLowerCase()}'),
        backgroundColor: newStatus == 'Validé' ? Colors.green : Colors.red,
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'validé':
        return Colors.green;
      case 'refusé':
        return Colors.red;
      case 'en attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final partner = widget.partner;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Validation Partenaire',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.blueBic,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.name,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueBic,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Secteur : ${partner.sector}',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Statut actuel : ',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: getStatusColor(status)),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => updateStatus('Validé'),
                      icon: Icon(Icons.check_circle),
                      label: Text('Valider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => updateStatus('Refusé'),
                      icon: Icon(Icons.cancel),
                      label: Text('Refuser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

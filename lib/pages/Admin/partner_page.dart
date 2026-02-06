import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart'; // Assure-toi d'avoir une couleur comme AppColors.blueBic

class Partner {
  final String name;
  final String sector;
  final String status;

  Partner({required this.name, required this.sector, required this.status});
}

class PartnersPage extends StatefulWidget {
  @override
  _PartnersPageState createState() => _PartnersPageState();
}

class _PartnersPageState extends State<PartnersPage> {
  List<Partner> partners = [
    Partner(name: 'Poissonnerie ABC', sector: 'Poissonnerie', status: 'Validé'),
    Partner(
      name: 'Restaurant XYZ',
      sector: 'Restauration',
      status: 'En attente',
    ),
    Partner(name: 'Marché Dakar', sector: 'Poissonnerie', status: 'Refusé'),
    // Ajoute d'autres partenaires ici
  ];

  List<Partner> filteredPartners = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPartners = partners;
  }

  void filterPartners(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPartners = partners;
      } else {
        filteredPartners =
            partners
                .where(
                  (partner) =>
                      partner.name.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      partner.sector.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      partner.status.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'validé':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'refusé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Partenaires',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.blueBic,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Champ de recherche
            TextField(
              controller: searchController,
              onChanged: filterPartners,
              decoration: InputDecoration(
                hintText: 'Rechercher un partenaire...',
                prefixIcon: Icon(Icons.search),
                hintStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Liste des partenaires
            Expanded(
              child: ListView.builder(
                itemCount: filteredPartners.length,
                itemBuilder: (context, index) {
                  final partner = filteredPartners[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.blueBic.withOpacity(0.1),
                        child: Icon(Icons.business, color: AppColors.blueBic),
                      ),
                      title: Text(
                        partner.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        partner.sector,
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(
                            partner.status,
                          ).withOpacity(0.1),
                          border: Border.all(
                            color: getStatusColor(partner.status),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          partner.status,
                          style: GoogleFonts.poppins(
                            color: getStatusColor(partner.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Détails ou actions
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:myapp/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart'; // Importer le widget partagé

class OfferPage extends StatefulWidget {
  const OfferPage({super.key});

  @override
  State<OfferPage> createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  String _selectedFilter = 'Tous';

  final List<Map<String, String>> produits = [
    {
      'nom': 'Thiof frais',
      'image':
          'https://images.unsplash.com/photo-1639895329098-22c3029db8ab?w=500',
      'origine': 'Dakar',
      'prix': '7.00 €/kg',
      'disponibilite': 'Aujourd’hui',
    },
    {
      'nom': 'Sardine',
      'image':
          'https://images.unsplash.com/photo-1535424921017-85119f91e5a1?w=500',
      'origine': 'Malte',
      'prix': '3.50 €/kg',
      'disponibilite': 'Précommandable',
    },
    {
      'nom': 'Crevette',
      'image':
          'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=500',
      'origine': 'Dublin',
      'prix': '9.00 €/kg',
      'disponibilite': 'Aujourd’hui',
    },
    {
      'nom': 'Saumon',
      'image':
          'https://plus.unsplash.com/premium_photo-1723478431094-4854c4555fc2?w=500',
      'origine': 'Dublin',
      'prix': '12.00 €/kg',
      'disponibilite': 'Précommandable',
    },
  ];

  List<Map<String, String>> get filteredProduits {
    if (_selectedFilter == 'Tous') return produits;
    return produits
        .where((p) => p['disponibilite'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Offre du jour", style: GoogleFonts.poppins()),
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.amber[100],
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Text(
                "Données de démonstration – Prototype",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),

            // Catégories horizontales
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildCategoryChip("Tous", Icons.all_inclusive),
                  const SizedBox(width: 10),
                  _buildCategoryChip("Aujourd’hui", Icons.today),
                  const SizedBox(width: 10),
                  _buildCategoryChip("Précommandable", Icons.schedule),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Liste des produits
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children:
                    filteredProduits.map((produit) {
                      final estDisponible =
                          produit['disponibilite'] == "Aujourd’hui";
                      final boutonTexte =
                          estDisponible ? "Commander" : "Précommander";
                      final boutonCouleur =
                          estDisponible ? Colors.green : AppColors.blueBic;
                      final boutonIcone =
                          estDisponible
                              ? Icons.shopping_bag
                              : Icons.shopping_cart_outlined;
                      final boutonRoute =
                          estDisponible ? '/commande' : '/precommande';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: OpenContainer(
                          closedElevation: 4,
                          transitionDuration: const Duration(milliseconds: 500),
                          closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          closedColor: Colors.white,
                          openBuilder:
                              (context, _) => Scaffold(
                                appBar: AppBar(
                                  title: Text(produit['nom'] ?? ''),
                                ),
                                body: Center(
                                  child: Text("Détails en cours..."),
                                ),
                              ),
                          closedBuilder:
                              (context, openContainer) => GestureDetector(
                                onTap: openContainer,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Image.network(
                                            produit['image'] ?? '',
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.45,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            right: 12,
                                            top: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    estDisponible
                                                        ? Colors.green
                                                        : Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                produit['disponibilite'] ?? '',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              produit['nom'] ?? '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Origine : ${produit['origine']}",
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              produit['prix'] ?? '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.blueBic,
                                              ),
                                            ),
                                            if (estDisponible)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  top: 6,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  "Livraison rapide",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 12),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (ctx) => AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        title: Text(
                                                          "$boutonTexte - ${produit['nom']}",
                                                        ),
                                                        content: Text(
                                                          "Souhaitez-vous vraiment $boutonTexte ce produit ?",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      ctx,
                                                                    ),
                                                            child: Text(
                                                              "Annuler",
                                                              style:
                                                                  GoogleFonts.poppins(),
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(ctx); // Ferme la dialog
                                                              context.go(boutonRoute); // Navigue avec go_router
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  boutonCouleur,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                            child: Text(
                                                              "Confirmer",
                                                              style:
                                                                  GoogleFonts.poppins(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                              },
                                              icon: Icon(boutonIcone),
                                              label: Text(
                                                boutonTexte,
                                                style: GoogleFonts.poppins(),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: boutonCouleur,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
      // Utilisation du widget de navigation partagé
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : Colors.grey,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.blueBic,
      onSelected: (_) => setState(() => _selectedFilter = label),
      backgroundColor: Colors.grey[200],
    );
  }
}

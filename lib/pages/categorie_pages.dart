import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class ListeProduitsPage extends StatefulWidget {
  @override
  _ListeProduitsPageState createState() => _ListeProduitsPageState();
}

class _ListeProduitsPageState extends State<ListeProduitsPage> {
  String _selectedCategory = "Tous";
  String _searchQuery = "";
  bool _isLoading = true;

  final List<Map<String, dynamic>> produits = [
    {
      "nom": "Dorade",
      "prix": 7.50,
      "poids": "2kg",
      "popularite": 4,
      "categorie": "Poisson",
      "image":
          "https://media.istockphoto.com/id/855749956/fr/photo/poisson-dorade-r%C3%B4tie-avec-des-tranches-de-citron.webp?a=1&b=1&s=612x612&w=0&k=20&c=cPlNCRlies7B-A8AIbFFgrLg7bWYFubzxJWpPwKZviQ=",
    },
    {
      "nom": "Sole",
      "prix": 4.50,
      "poids": "1.5kg",
      "popularite": 5,
      "categorie": "Poisson",
      "image":
          "https://media.istockphoto.com/id/171266598/fr/photo/sole-meuni%C3%A8re-de-prime-fra%C3%AEcheur-servis-sur-une-assiette.webp?a=1&b=1&s=612x612&w=0&k=20&c=n2kJscvA345-u5ZgVgwXTMLX_4tFw-YId2ldscVUteI=",
    },
    {
      "nom": "Saumon",
      "prix": 10.00,
      "poids": "2.5kg",
      "popularite": 3,
      "categorie": "Poisson",
      "image":
          "https://images.unsplash.com/photo-1499125562588-29fb8a56b5d5?w=500",
    },
    {
      "nom": "Crevette",
      "prix": 9.00,
      "poids": "2kg",
      "popularite": 4,
      "categorie": "Crustacés",
      "image":
          "https://images.unsplash.com/photo-1590759668628-05b0fc34bb70?w=500",
    },
  ];

  List<String> categories = ["Tous", "Poisson", "Crustacés", "Fruits de mer"];

  List<Map<String, dynamic>> get filteredProduits {
    return produits
        .where(
          (produit) =>
              (_selectedCategory == "Tous" ||
                  produit["categorie"] == _selectedCategory) &&
              produit["nom"].toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Rechercher un produit...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.blueBic),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        categories.map((category) {
                          bool isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ChoiceChip(
                              label: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.blueBic,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.greenTGTG,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppColors.greenTGTG),
                              onSelected: (selected) {
                                print('Catégorie sélectionnée: $category');
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
              : Expanded(
                child: ListView.builder(
                  itemCount: filteredProduits.length,
                  itemBuilder: (context, index) {
                    final produit = filteredProduits[index];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          print('Produit cliqué: ${produit["nom"]}');
                          context.push('/detail', extra: produit);
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                produit["image"],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produit["nom"],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < produit["popularite"]
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.yellow[700],
                                        size: 18,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Poids: ${produit["poids"]}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        "Prix: ",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "${produit["prix"]} €",
                                        style: GoogleFonts.poppins(
                                          color: AppColors.greenTGTG,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

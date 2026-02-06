import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

/// Page Store Detail - Clone TGTG
/// Affiche les détails d'un commerce avec ses produits
class StoreDetailPage extends StatefulWidget {
  final String storeId;

  const StoreDetailPage({super.key, required this.storeId});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  bool _isFavorite = false;

  // Données mock pour le store avec images
  final Map<String, dynamic> _storeData = {
    '1': {
      'name': 'DailyCatch Store',
      'address': '15 Rue du Port, Dakar',
      'distance': '0.5 km',
      'rating': 4.5,
      'reviews': 124,
      'image': 'assets/images/saumon.jpg',
      'banner': 'assets/images/saumon.jpg',
      'products': [
        {
          'name': 'Sacs magic Saumon',
          'description': 'Sacs surprise avec produits frais du jour',
          'originalPrice': 15.00,
          'discountedPrice': 4.99,
          'time': '30 min left',
          'itemsLeft': 3,
          'image': 'assets/images/saumon.jpg',
        },
        {
          'name': 'Sacs magic Crevettes',
          'description': 'Crevettes grises fraîches',
          'originalPrice': 12.00,
          'discountedPrice': 3.99,
          'time': '1h 15min left',
          'itemsLeft': 5,
          'image': 'assets/images/crevette.jpg',
        },
        {
          'name': 'Plateau Huîtres',
          'description': '6 huîtres spécial',
          'originalPrice': 18.00,
          'discountedPrice': 5.49,
          'time': '45 min left',
          'itemsLeft': 2,
          'image': 'assets/images/langoustines.jpg',
        },
      ],
    },
    '2': {
      'name': 'Le Poisson Rouge',
      'address': '28 Avenue de la Plage, Dakar',
      'distance': '1.2 km',
      'rating': 4.8,
      'reviews': 89,
      'image': 'assets/images/crevette.jpg',
      'banner': 'assets/images/crevette.jpg',
      'products': [
        {
          'name': 'Sacs magic Thon',
          'description': 'Thon frais du jour',
          'originalPrice': 18.00,
          'discountedPrice': 5.99,
          'time': '2h left',
          'itemsLeft': 4,
          'image': 'assets/images/saumon.jpg',
        },
        {
          'name': 'Sacs magic Sardines',
          'description': 'Sardines grillées',
          'originalPrice': 10.00,
          'discountedPrice': 2.99,
          'time': '3h left',
          'itemsLeft': 8,
          'image': 'assets/images/homard.jpg',
        },
      ],
    },
    '3': {
      'name': 'La Crustacerie',
      'address': '42 Quai des Pêcheurs, Dakar',
      'distance': '2.0 km',
      'rating': 4.2,
      'reviews': 56,
      'image': 'assets/images/homard.jpg',
      'banner': 'assets/images/homard.jpg',
      'products': [
        {
          'name': 'Homard entier',
          'description': 'Homard breton frais',
          'originalPrice': 35.00,
          'discountedPrice': 12.99,
          'time': '1h left',
          'itemsLeft': 2,
          'image': 'assets/images/homard.jpg',
        },
        {
          'name': 'Crevettes roses',
          'description': 'Crevettes roses décortiquées',
          'originalPrice': 22.00,
          'discountedPrice': 7.99,
          'time': '2h 30min left',
          'itemsLeft': 6,
          'image': 'assets/images/crevette.jpg',
        },
        {
          'name': 'Langoustines',
          'description': 'Langoustines vivantes',
          'originalPrice': 28.00,
          'discountedPrice': 9.99,
          'time': '45 min left',
          'itemsLeft': 3,
          'image': 'assets/images/langoustines.jpg',
        },
      ],
    },
  };

  Map<String, dynamic> get store {
    return _storeData[widget.storeId] ?? _storeData['1']!;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (_isFavorite) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${store['name']} ajouté aux favoris',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.greenTGTG,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _shareStore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Partager',
          style: GoogleFonts.poppins(),
        ),
        content: Text(
          'Lien de partage copié!\n\nDécouvrez ${store['name']} sur DailyCatch',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Fermer',
              style: GoogleFonts.poppins(color: AppColors.blueBic),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = store['products'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.blueBic,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    store['banner'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareStore,
              ),
            ],
          ),
          // Store Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          store['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            store['rating'].toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${store['reviews']})',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Address and distance
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store['address'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        store['distance'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.blueBic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Eco info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blueBic.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.blueBic,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.eco, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Impact environnemental',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Vous pouvez sauver jusqu\'à 2.5 kg de CO₂',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Products section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Produits disponibles',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Products list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = products[index];
                return _buildProductCard(context, product);
              },
              childCount: products.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    final discountPercentage =
        ((product['originalPrice'] - product['discountedPrice']) /
                product['originalPrice'] *
                100)
            .round();

    return GestureDetector(
      onTap: () {
        context.push('/product', extra: product);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    product['image'] as String,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                // Time remaining
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product['time'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Items left
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product['itemsLeft']} restants',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        product['discountedPrice'].toStringAsFixed(2) + '€',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greenTGTG,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product['originalPrice'].toStringAsFixed(2) + '€',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greenTGTG,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-$discountPercentage%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product['name']} ajouté au panier!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: AppColors.greenTGTG,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenTGTG,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Ajouter au panier',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

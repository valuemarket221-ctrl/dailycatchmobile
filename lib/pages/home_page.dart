import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

/// Page Home - Clone TGTG Style
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Poisson',
    'Fruits de mer',
    'Crustacés',
    'Coquillages',
  ];

  // Stores data - with unique store images and more details
  final List<Map<String, dynamic>> _stores = [
    {
      'id': '1',
      'name': 'DailyCatch Store',
      'category': 'Poissonnerie',
      'distance': '0.5 km',
      'originalPrice': 15.00,
      'discountedPrice': 4.99,
      'time': '30 min left',
      'productsLeft': 3,
      'image': 'assets/images/saumon.jpg',
      'banner': 'assets/images/saumon.jpg',
      'rating': 4.5,
      'products': 12,
      'productTypes': ['Poisson', 'Saumon', 'Morue'],
    },
    {
      'id': '2',
      'name': 'Le Poisson Rouge',
      'category': 'Poisson',
      'distance': '1.2 km',
      'originalPrice': 20.00,
      'discountedPrice': 6.99,
      'time': '1h 15min left',
      'productsLeft': 2,
      'image': 'assets/images/crevette.jpg',
      'banner': 'assets/images/crevette.jpg',
      'rating': 4.8,
      'products': 8,
      'productTypes': ['Thon', 'Sardines', 'Anchois'],
    },
    {
      'id': '3',
      'name': 'La Crustacerie',
      'category': 'Crustacés',
      'distance': '2.0 km',
      'originalPrice': 18.00,
      'discountedPrice': 5.49,
      'time': '45 min left',
      'productsLeft': 5,
      'image': 'assets/images/homard.jpg',
      'banner': 'assets/images/homard.jpg',
      'rating': 4.2,
      'products': 15,
      'productTypes': ['Homard', 'Crevettes', 'Langoustines'],
    },
    {
      'id': '4',
      'name': 'Ocean Treasure',
      'category': 'Fruits de mer',
      'distance': '3.5 km',
      'originalPrice': 25.00,
      'discountedPrice': 7.99,
      'time': '2h left',
      'productsLeft': 4,
      'image': 'assets/images/langoustines.jpg',
      'banner': 'assets/images/langoustines.jpg',
      'rating': 4.6,
      'products': 20,
      'productTypes': ['Huîtres', 'Moules', 'Palourdes'],
    },
    {
      'id': '5',
      'name': 'Coquillages & Delices',
      'category': 'Coquillages',
      'distance': '4.8 km',
      'originalPrice': 12.00,
      'discountedPrice': 3.99,
      'time': '30 min left',
      'productsLeft': 6,
      'image': 'assets/images/saumon.jpg',
      'banner': 'assets/images/saumon.jpg',
      'rating': 4.9,
      'products': 10,
      'productTypes': ['Huitres', 'Coquilles Saint-Jacques', 'Bulots'],
    },
    {
      'id': '6',
      'name': 'Le Grand Bleu',
      'category': 'Poissonnerie',
      'distance': '5.2 km',
      'originalPrice': 22.00,
      'discountedPrice': 6.49,
      'time': '1h 30min left',
      'productsLeft': 3,
      'image': 'assets/images/crevette.jpg',
      'banner': 'assets/images/crevette.jpg',
      'rating': 4.4,
      'products': 18,
      'productTypes': ['Saumon', 'Truite', 'Cabillaud'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          // AppBar with drawer
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.blueBic,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Dakar, Sénégal',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                ),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
          // Categories
          SliverToBoxAdapter(
            child: SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        // Passer le filtre à la page map
                        context.go('/map?category=$category');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.blueBic : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Eco banner
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => context.go('/map'),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blueBic.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.blueBic,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sauvez les produits, sauvez la planète !',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Vous avez sauvé 12.5 kg de CO₂ ce mois',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: AppColors.blueBic),
                  ],
                ),
              ),
            ),
          ),
          // Map button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/map'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.blueBic,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              'Voir la carte',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/favorites'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.blueBic),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: AppColors.blueBic),
                            const SizedBox(width: 12),
                            Text(
                              'Favoris',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueBic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Près de chez vous',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '${_stores.length} boutiques',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Stores list
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final store = _stores[index];
              return _buildStoreCard(context, store);
            }, childCount: _stores.length),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.blueBic),
            accountName: Text(
              'Ibrahima Aidara',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              'ibrahima@email.com',
              style: GoogleFonts.poppins(),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.blueBic),
            ),
          ),
          _buildDrawerItem(Icons.map, 'Carte des boutiques', '/map'),
          _buildDrawerItem(Icons.qr_code_2, 'Mes sauvés', '/pickup'),
          _buildDrawerItem(Icons.history, 'Historique', '/orders'),
          _buildDrawerItem(Icons.person, 'Mon profil', '/profile'),
          _buildDrawerItem(Icons.settings, 'Paramètres', '/settings'),
          const Divider(),
          _buildDrawerItem(Icons.help, 'Aide & FAQ', '/help'),
          _buildDrawerItem(Icons.logout, 'Déconnexion', '/login'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.blueBic),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: () {
        context.pop();
        context.push(route);
      },
    );
  }

  Widget _buildStoreCard(BuildContext context, Map<String, dynamic> store) {
    final discountPercentage =
        ((store['originalPrice'] - store['discountedPrice']) /
                store['originalPrice'] *
                100)
            .round();

    return GestureDetector(
      onTap: () {
        context.push('/store/${store['id']}', extra: store);
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
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    store['image'] as String,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                  ),
                ),
                // Distance badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      store['distance'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Products count badge
                Positioned(
                  top: 12,
                  right: 50,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${store['products']} prod',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // CO2 badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.blueBic,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 18),
                  ),
                ),
                // Time remaining
                Positioned(
                  bottom: 12,
                  right: 12,
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
                      store['time'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            store['rating'].toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Category and product types
                  Text(
                    store['category'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Product types
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          (store['productTypes'] as List<String>)
                              .map(
                                (type) => Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    type,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price
                  Row(
                    children: [
                      Text(
                        store['discountedPrice'].toStringAsFixed(2) + '€',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greenTGTG,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        store['originalPrice'].toStringAsFixed(2) + '€',
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
                  const SizedBox(height: 8),
                  // Products left
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Plus que ${store['productsLeft']} produits',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
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
  }
}

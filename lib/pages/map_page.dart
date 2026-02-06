import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

/// Page Map - Carte des boutiques à proximité - Clone TGTG
class MapPage extends StatefulWidget {
  final String initialCategory;
  
  const MapPage({super.key, this.initialCategory = 'Tous'});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Poisson',
    'Fruits de mer',
    'Crustacés',
    'Coquillages',
  ];

  // Boutiques avec coordonnées dispersées à Dakar
  final List<Map<String, dynamic>> _stores = [
    {
      'id': '1',
      'name': 'DailyCatch Store',
      'category': 'Poissonnerie',
      'lat': 14.6928,
      'lng': -17.4467,
      'distance': '0.5 km',
      'price': 4.99,
      'originalPrice': 15.00,
      'rating': 4.5,
      'products': 12,
      'productTypes': ['Poisson', 'Saumon', 'Morue'],
      'image': 'assets/images/saumon.jpg',
      'banner': 'assets/images/saumon.jpg',
    },
    {
      'id': '2',
      'name': 'Le Poisson Rouge',
      'category': 'Poisson',
      'lat': 14.7100,
      'lng': -17.4600,
      'distance': '2.3 km',
      'price': 6.99,
      'originalPrice': 20.00,
      'rating': 4.8,
      'products': 8,
      'productTypes': ['Thon', 'Sardines', 'Anchois'],
      'image': 'assets/images/crevette.jpg',
      'banner': 'assets/images/crevette.jpg',
    },
    {
      'id': '3',
      'name': 'La Crustacerie',
      'category': 'Crustacés',
      'lat': 14.6800,
      'lng': -17.4300,
      'distance': '3.1 km',
      'price': 5.49,
      'originalPrice': 18.00,
      'rating': 4.2,
      'products': 15,
      'productTypes': ['Homard', 'Crevettes', 'Langoustines'],
      'image': 'assets/images/homard.jpg',
      'banner': 'assets/images/homard.jpg',
    },
    {
      'id': '4',
      'name': 'Ocean Treasure',
      'category': 'Fruits de mer',
      'lat': 14.7200,
      'lng': -17.4200,
      'distance': '4.5 km',
      'price': 7.99,
      'originalPrice': 25.00,
      'rating': 4.6,
      'products': 20,
      'productTypes': ['Huîtres', 'Moules', 'Palourdes'],
      'image': 'assets/images/langoustines.jpg',
      'banner': 'assets/images/langoustines.jpg',
    },
    {
      'id': '5',
      'name': 'Coquillages & Delices',
      'category': 'Coquillages',
      'lat': 14.6650,
      'lng': -17.4700,
      'distance': '5.2 km',
      'price': 3.99,
      'originalPrice': 12.00,
      'rating': 4.9,
      'products': 10,
      'productTypes': ['Huitres', 'Coquilles Saint-Jacques', 'Bulots'],
      'image': 'assets/images/saumon.jpg',
      'banner': 'assets/images/saumon.jpg',
    },
    {
      'id': '6',
      'name': 'Le Grand Bleu',
      'category': 'Poissonnerie',
      'lat': 14.7350,
      'lng': -17.4500,
      'distance': '5.8 km',
      'price': 6.49,
      'originalPrice': 22.00,
      'rating': 4.4,
      'products': 18,
      'productTypes': ['Saumon', 'Truite', 'Cabillaud'],
      'image': 'assets/images/crevette.jpg',
      'banner': 'assets/images/crevette.jpg',
    },
    {
      'id': '7',
      'name': 'La Mer en Profondeur',
      'category': 'Fruits de mer',
      'lat': 14.6500,
      'lng': -17.4800,
      'distance': '6.5 km',
      'price': 8.99,
      'originalPrice': 28.00,
      'rating': 4.7,
      'products': 25,
      'productTypes': ['Langoustines', 'Bulots', 'Moules'],
      'image': 'assets/images/homard.jpg',
      'banner': 'assets/images/homard.jpg',
    },
    {
      'id': '8',
      'name': 'Le Rêve Marin',
      'category': 'Crustacés',
      'lat': 14.7450,
      'lng': -17.4100,
      'distance': '7.2 km',
      'price': 9.99,
      'originalPrice': 30.00,
      'rating': 4.3,
      'products': 12,
      'productTypes': ['Homard', 'Langoustines', 'Crevettes'],
      'image': 'assets/images/langoustines.jpg',
      'banner': 'assets/images/langoustines.jpg',
    },
  ];

  List<Map<String, dynamic>> get _filteredStores {
    if (_selectedCategory == 'Tous') return _stores;
    return _stores.where((s) => s['category'] == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      setState(() {
        _selectedCategory = widget.initialCategory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Boutiques à proximité',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_filteredStores.length} boutiques trouvées',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.blueBic),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Categories filter
          SizedBox(
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
          // Flutter Map
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(14.6928, -17.4467),
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _filteredStores.map((store) {
                    return Marker(
                      point: LatLng(store['lat'] as double, store['lng'] as double),
                      width: 60,
                      height: 60,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          context.push('/store/${store['id']}', extra: store);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.blueBic,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.store, color: Colors.white, size: 18),
                                  Text(
                                    '${store['price']}€',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 0,
                              height: 0,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                  left: BorderSide(width: 8, color: Colors.transparent),
                                  right: BorderSide(width: 8, color: Colors.transparent),
                                  top: BorderSide(width: 12, color: AppColors.blueBic),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // List toggle button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showStoresSheet(context),
                icon: const Icon(Icons.list, color: Colors.black),
                label: Text(
                  'Voir les boutiques (${_filteredStores.length})',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  void _showStoresSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Boutiques à proximité (${_filteredStores.length})',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredStores.length,
                itemBuilder: (context, index) {
                  final store = _filteredStores[index];
                  return _buildStoreListItem(context, store);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreListItem(BuildContext context, Map<String, dynamic> store) {
    final discount =
        ((store['originalPrice'] - store['price']) /
                store['originalPrice'] *
                100)
            .round();

    return GestureDetector(
      onTap: () {
        context.pop();
        context.push('/store/${store['id']}', extra: store);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Bannière de la boutique
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                store['banner'] as String? ?? store['image'] as String,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et note
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            store['rating'].toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Distance et catégorie
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        store['distance'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueBic.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          store['category'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.blueBic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Produits et types
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        size: 14,
                        color: AppColors.blueBic,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${store['products']} produits',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Types de produits
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: (store['productTypes'] as List<String>)
                          .map((type) => Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  type,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Prix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                store['price'].toStringAsFixed(2) + '€',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blueBic,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                store['originalPrice'].toStringAsFixed(2) + '€',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greenTGTG,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
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
          _buildDrawerItem(Icons.map, 'Carte', '/map'),
          _buildDrawerItem(Icons.qr_code_2, 'Mes sauvés', '/pickup'),
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
}

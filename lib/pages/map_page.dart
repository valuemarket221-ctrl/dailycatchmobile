import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/dailycatch_tile_layer.dart';

/// Page Map - Carte des boutiques à proximité - Clone TGTG
class MapPage extends StatefulWidget {
  final String initialCategory;

  const MapPage({super.key, this.initialCategory = 'Tous'});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String _selectedCategory = 'Tous';

  // ignore: unused_field
  final List<String> _categories = [
    'Tous',
    'Poisson',
    'Fruits de mer',
    'Crustacés',
    'Coquillages',
  ];

  // Boutiques avec coordonnées dans différentes villes du Sénégal - Sur terre ferme
  final List<Map<String, dynamic>> _stores = [
    // Dakar Centre
    {
      'id': '1',
      'name': 'DailyCatch Store',
      'category': 'Poissonnerie',
      'lat': 14.7167,
      'lng': -17.4677,
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
      'lat': 14.7240,
      'lng': -17.4620,
      'distance': '1.2 km',
      'price': 6.99,
      'originalPrice': 20.00,
      'rating': 4.8,
      'products': 8,
      'productTypes': ['Thon', 'Sardines', 'Anchois'],
      'image': 'assets/images/crevette.jpg',
      'banner': 'assets/images/crevette.jpg',
    },
    // Pikine
    {
      'id': '3',
      'name': 'La Crustacerie',
      'category': 'Crustacés',
      'lat': 14.7640,
      'lng': -17.3950,
      'distance': '3.5 km',
      'price': 5.49,
      'originalPrice': 18.00,
      'rating': 4.2,
      'products': 15,
      'productTypes': ['Homard', 'Crevettes', 'Langoustines'],
      'image': 'assets/images/homard.jpg',
      'banner': 'assets/images/homard.jpg',
    },
    // Guédiawaye
    {
      'id': '4',
      'name': 'Ocean Treasure',
      'category': 'Fruits de mer',
      'lat': 14.7730,
      'lng': -17.3770,
      'distance': '4.8 km',
      'price': 7.99,
      'originalPrice': 25.00,
      'rating': 4.6,
      'products': 20,
      'productTypes': ['Huîtres', 'Moules', 'Palourdes'],
      'image': 'assets/images/langoustines.jpg',
      'banner': 'assets/images/langoustines.jpg',
    },
    // Rufisque
    {
      'id': '5',
      'name': 'Coquillages & Delices',
      'category': 'Coquillages',
      'lat': 14.7180,
      'lng': -17.2700,
      'distance': '15 km',
      'price': 3.99,
      'originalPrice': 12.00,
      'rating': 4.9,
      'products': 10,
      'productTypes': ['Huitres', 'Coquilles Saint-Jacques', 'Bulots'],
      'image': 'assets/images/saumon.jpg',
      'banner': 'assets/images/saumon.jpg',
    },
    // Thiès
    {
      'id': '6',
      'name': 'Le Grand Bleu',
      'category': 'Poissonnerie',
      'lat': 14.7900,
      'lng': -16.9350,
      'distance': '50 km',
      'price': 6.49,
      'originalPrice': 22.00,
      'rating': 4.4,
      'products': 18,
      'productTypes': ['Saumon', 'Truite', 'Cabillaud'],
      'image': 'assets/images/crevette.jpg',
      'banner': 'assets/images/crevette.jpg',
    },
    // Saint-Louis
    {
      'id': '7',
      'name': 'La Mer en Profondeur',
      'category': 'Fruits de mer',
      'lat': 16.0333,
      'lng': -16.5000,
      'distance': '260 km',
      'price': 8.99,
      'originalPrice': 28.00,
      'rating': 4.7,
      'products': 25,
      'productTypes': ['Langoustines', 'Bulots', 'Moules'],
      'image': 'assets/images/homard.jpg',
      'banner': 'assets/images/homard.jpg',
    },
    // Ziguinchor
    {
      'id': '8',
      'name': 'Le Rêve Marin',
      'category': 'Crustacés',
      'lat': 12.5833,
      'lng': -16.2667,
      'distance': '450 km',
      'price': 9.99,
      'originalPrice': 30.00,
      'rating': 4.3,
      'products': 12,
      'productTypes': ['Homard', 'Langoustines', 'Crevettes'],
      'image': 'assets/images/langoustines.jpg',
      'banner': 'assets/images/langoustines.jpg',
    },
    // Kaolack
    {
      'id': '9',
      'name': 'Atlantique Sud',
      'category': 'Poisson',
      'lat': 14.1500,
      'lng': -16.1000,
      'distance': '120 km',
      'price': 5.99,
      'originalPrice': 18.00,
      'rating': 4.5,
      'products': 15,
      'productTypes': ['Thon', 'Maquereau', 'Sardines'],
      'image': 'assets/images/saumon.jpg',
      'banner': 'assets/images/saumon.jpg',
    },
    // Fatick
    {
      'id': '10',
      'name': 'Saveurs Océanes',
      'category': 'Coquillages',
      'lat': 14.3500,
      'lng': -16.5667,
      'distance': '150 km',
      'price': 4.49,
      'originalPrice': 14.00,
      'rating': 4.6,
      'products': 8,
      'productTypes': ['Huitres', 'Palourdes', 'Moules'],
      'image': 'assets/images/crevette.jpg',
      'banner': 'assets/images/crevette.jpg',
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
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(14.7100, -17.4550),
                initialZoom: 12.5,
              ),
              children: [
                const DailyCatchTileLayer(),
                MarkerLayer(
                  markers:
                      _filteredStores.take(6).map((store) {
                        return Marker(
                          point: LatLng(
                            store['lat'] as double,
                            store['lng'] as double,
                          ),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap:
                                () => context.push(
                                  '/store/${store['id']}',
                                  extra: store,
                                ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.blueBic,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${store['products']}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 18,
            right: 18,
            child: Column(
              children: [
                Row(
                  children: [
                    _RoundMapButton(
                      icon: Icons.arrow_back,
                      onTap: () => context.go('/home'),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'DAKAR',
                          style: TextStyle(
                            color: AppColors.blueBic,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.search,
                        color: Color(0xFF748487),
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rechercher dans cette zone',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF263B3E),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 36,
            right: 36,
            bottom: MediaQuery.paddingOf(context).bottom + 32,
            child: SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: () => context.go('/search'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Voir la liste',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPersistentResultsPanel(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 176 : 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_filteredStores.length} paniers près de vous',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueBic,
                    ),
                  ),
                ),
                Text(
                  'Dakar',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredStores.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 280,
                  child: _buildStoreListItem(context, _filteredStores[index]),
                );
              },
            ),
          ),
        ],
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
        context.push('/store/${store['id']}', extra: store);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3EAE3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 86,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    store['image'],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenTGTG,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${store['price']}€',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      store['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueBic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Panier surprise ${store['category']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${store['distance']}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenTGTG.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-$discount%',
                            style: GoogleFonts.poppins(
                              color: AppColors.greenTGTG,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.blueBic),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.store, size: 50, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'DailyCatch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sauvez des paniers',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              context.pop();
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Carte'),
            onTap: () {
              context.pop();
              context.go('/map');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favoris'),
            onTap: () {
              context.pop();
              context.go('/favorites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_2),
            title: const Text('Mes sauvés'),
            onTap: () {
              context.pop();
              context.go('/pickup');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              context.pop();
              context.go('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Aide'),
            onTap: () {
              context.pop();
              context.go('/help');
            },
          ),
        ],
      ),
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: AppColors.blueBic, size: 18),
        ),
      ),
    );
  }
}

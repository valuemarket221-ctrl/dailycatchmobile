import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/services/product_offer_api_service.dart';
import 'package:myapp/utils/api_environment.dart';
import 'package:myapp/utils/api_error_messages.dart';
import 'package:provider/provider.dart';
import 'package:myapp/widgets/app_remote_image.dart';

class StoreDetailPage extends StatefulWidget {
  final String storeId;
  const StoreDetailPage({super.key, required this.storeId});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  bool _isFavorite = false;
  int _quantity = 1;
  late Future<List<Map<String, dynamic>>> _productsFuture;
  Map<String, dynamic>? _remoteStore;
  final ProductOfferApiService _productOfferApiService =
      ProductOfferApiService();

  final Map<String, dynamic> _storeData = {
    '1': {
      'name': 'DailyCatch Store',
      'address': '15 Rue du Port, Dakar',
      'distance': '0.5 km',
      'rating': 4.5,
      'reviews': 124,
      'image': 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      'banner': 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      'products': [
        {
          'id': 'offer_saumon_magic',
          'storeId': '1',
          'name': 'Sacs magic Saumon',
          'description': 'Sacs surprise avec produits frais du jour',
          'originalPrice': 15.00,
          'discountedPrice': 4.99,
          'time': '30 min left',
          'itemsLeft': 3,
          'image': 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
        },
        {
          'id': 'offer_crevettes_magic',
          'storeId': '1',
          'name': 'Sacs magic Crevettes',
          'description': 'Crevettes grises fraiches',
          'originalPrice': 12.00,
          'discountedPrice': 3.99,
          'time': '1h 15min left',
          'itemsLeft': 5,
          'image': 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
        },
        {
          'id': 'offer_huitres_plateau',
          'storeId': '1',
          'name': 'Plateau Huitres',
          'description': '6 huitres special',
          'originalPrice': 18.00,
          'discountedPrice': 5.49,
          'time': '45 min left',
          'itemsLeft': 2,
          'image': 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
        },
      ],
    },
    '2': {
      'name': 'Le Poisson Rouge',
      'address': '28 Avenue de la Plage, Dakar',
      'distance': '1.2 km',
      'rating': 4.8,
      'reviews': 89,
      'image': 'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
      'banner': 'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
      'products': [
        {
          'id': 'offer_thon_magic',
          'storeId': '2',
          'name': 'Sacs magic Thon',
          'description': 'Thon frais du jour',
          'originalPrice': 18.00,
          'discountedPrice': 5.99,
          'time': '2h left',
          'itemsLeft': 4,
          'image': 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
        },
        {
          'id': 'offer_sardines_magic',
          'storeId': '2',
          'name': 'Sacs magic Sardines',
          'description': 'Sardines grillees',
          'originalPrice': 10.00,
          'discountedPrice': 2.99,
          'time': '3h left',
          'itemsLeft': 8,
          'image': 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
        },
      ],
    },
    '3': {
      'name': 'La Crustacerie',
      'address': '42 Quai des Pecheurs, Dakar',
      'distance': '2.0 km',
      'rating': 4.2,
      'reviews': 56,
      'image': 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      'banner': 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      'products': [
        {
          'id': 'offer_homard_entier',
          'storeId': '3',
          'name': 'Homard entier',
          'description': 'Homard breton frais',
          'originalPrice': 35.00,
          'discountedPrice': 12.99,
          'time': '1h left',
          'itemsLeft': 2,
          'image': 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
        },
        {
          'id': 'offer_crevettes_roses',
          'storeId': '3',
          'name': 'Crevettes roses',
          'description': 'Crevettes roses decortiquees',
          'originalPrice': 22.00,
          'discountedPrice': 7.99,
          'time': '2h 30min left',
          'itemsLeft': 6,
          'image': 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
        },
        {
          'id': 'offer_langoustines',
          'storeId': '3',
          'name': 'Langoustines',
          'description': 'Langoustines vivantes',
          'originalPrice': 28.00,
          'discountedPrice': 9.99,
          'time': '45 min left',
          'itemsLeft': 3,
          'image': 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
        },
      ],
    },
  };

  Map<String, dynamic> get store =>
      _remoteStore ?? _storeData[widget.storeId] ?? _storeData['1']!;

  List<Map<String, dynamic>> get _fallbackProducts =>
      store['products'] as List<Map<String, dynamic>>;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  @override
  void didUpdateWidget(covariant StoreDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) {
      _productsFuture = _loadProducts();
    }
  }

  Future<List<Map<String, dynamic>>> _loadProducts() async {
    try {
      final offers = await _productOfferApiService.getProductOffers();
      final matchingOffers =
          offers.where((offer) => offer.storeId == widget.storeId).toList();
      if (matchingOffers.isNotEmpty) {
        final first = matchingOffers.first;
        _remoteStore = {
          'name': first.storeName,
          'address': 'Commerce partenaire DailyCatch',
          'distance':
              first.distanceKm == null
                  ? 'Proche'
                  : '${first.distanceKm!.toStringAsFixed(1)} km',
          'rating': 4.6,
          'reviews': 0,
          'image':
              first.mediaUrls.isNotEmpty
                  ? first.mediaUrls.first
                  : _imageForOffer(first.name),
          'banner':
              first.mediaUrls.isNotEmpty
                  ? first.mediaUrls.first
                  : _imageForOffer(first.name),
          'products': _fallbackProducts,
        };
      }
      final fallbackById = {
        for (final product in _fallbackProducts)
          (product['id'] as String): product,
      };

      final products =
          matchingOffers.map((offer) {
            final fallback = fallbackById[offer.id];
            final image =
                offer.mediaUrls.isNotEmpty
                    ? offer.mediaUrls.first
                    : fallback?['image'] as String? ??
                        store['image'] as String? ??
                        '';
            return offer.toProductMap(
              image: image,
              description: fallback?['description'] as String? ?? '',
              originalPrice:
                  (fallback?['originalPrice'] as num?)?.toDouble() ??
                  offer.price,
              pickupTime: fallback?['time'] as String? ?? 'Disponible',
            );
          }).toList();

      if (products.isNotEmpty || !ApiEnvironment.isDemoFallbackAllowed) {
        return products;
      }
      return _fallbackProducts;
    } catch (error) {
      if (!ApiEnvironment.isDemoFallbackAllowed) rethrow;
      debugPrint(ApiErrorMessages.fromObject(error));
      return _fallbackProducts;
    }
  }

  String _imageForOffer(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('crevette')) {
      return 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png';
    }
    if (lower.contains('homard') ||
        lower.contains('huître') ||
        lower.contains('huitre')) {
      return 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png';
    }
    if (lower.contains('langoustine')) {
      return 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png';
    }
    return 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png';
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (_isFavorite) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${store['name']} ajoute aux favoris',
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

  void _reserveNow(BuildContext context, Map<String, dynamic> product) {
    final cartProvider = context.read<CartProvider>();
    cartProvider.addItem(product, widget.storeId);
    context.push('/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blueBic),
            );
          }
          final products =
              snapshot.data ??
              (ApiEnvironment.isDemoFallbackAllowed
                  ? _fallbackProducts
                  : <Map<String, dynamic>>[]);
          if (products.isEmpty) {
            return _StoreUnavailableState(
              message:
                  snapshot.hasError
                      ? ApiErrorMessages.fromObject(snapshot.error!)
                      : 'Aucun panier disponible pour cette boutique.',
              onRetry: () => setState(() => _productsFuture = _loadProducts()),
            );
          }
          final product = _normalizedDetailProduct(products.first);

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 282,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppRemoteImage(
                            path:
                                product['image'] as String? ??
                                store['banner'] as String? ??
                                '',
                            width: MediaQuery.sizeOf(context).width,
                            height: 282,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.38),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.paddingOf(context).top + 10,
                            left: 16,
                            child: _CircleAction(
                              icon: Icons.arrow_back,
                              onTap: () => safePop(context),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.paddingOf(context).top + 10,
                            right: 16,
                            child: _CircleAction(
                              icon:
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                              onTap: _toggleFavorite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _DetailPanel(product: product, store: store),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 108)),
                ],
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: MediaQuery.paddingOf(context).bottom + 18,
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE1E8E6)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed:
                                _quantity <= 1
                                    ? null
                                    : () => setState(() => _quantity--),
                            icon: const Icon(Icons.remove, size: 18),
                          ),
                          Text(
                            '$_quantity',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _quantity++),
                            icon: const Icon(Icons.add, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: () => _reserveNow(context, product),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.blueBic,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Réserver - ${_formatCfa((product['discountedPrice'] as num) * _quantity)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, dynamic> _normalizedDetailProduct(Map<String, dynamic> product) {
    final price = product['discountedPrice'] as num? ?? 3000;
    final originalPrice = product['originalPrice'] as num? ?? 6000;
    final normalizedPrice = price < 1000 ? 3000 : price;
    final normalizedOriginal =
        originalPrice < normalizedPrice || originalPrice < 1000
            ? normalizedPrice * 2
            : originalPrice;

    return {
      ...product,
      'name': 'Panier surprise',
      'discountedPrice': normalizedPrice,
      'originalPrice': normalizedOriginal,
      'description':
          'Un assortiment de poissons frais du jour (invendus du marché), idéal pour vos préparations maison.',
    };
  }

  // ignore: unused_element
  Widget _buildStoreSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  store['name'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueBic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${store['rating']}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Colors.grey,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  store['address'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                store['distance'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.blueBic,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInfoPill(
                  icon: Icons.schedule_outlined,
                  title: 'Retrait',
                  value: 'Aujourd’hui',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoPill(
                  icon: Icons.eco_outlined,
                  title: 'Impact',
                  value: '2.5 kg CO2',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greenTGTG.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Le contenu exact du panier dépend des invendus du jour. Tous les paniers sont réservés sur un créneau court.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3EAE3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.greenTGTG, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueBic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildProductsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Paniers à sauver',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '$count disponibles',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final discountPercentage =
        ((product['originalPrice'] - product['discountedPrice']) /
                product['originalPrice'] *
                100)
            .round();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3EAE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 154,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppRemoteImage(
                  path: product['image'] as String? ?? '',
                  width: 112,
                  height: 154,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenTGTG,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${product['itemsLeft']} dispo',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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
                children: [
                  Text(
                    product['name'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blueBic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 15,
                        color: AppColors.blueBic,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Retrait ${product['time']}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.blueBic,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(
                              '${product['discountedPrice'].toStringAsFixed(2)} €',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.greenTGTG,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '${product['originalPrice'].toStringAsFixed(2)} €',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        flex: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenTGTG.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-$discountPercentage%',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenTGTG,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueBic,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _reserveNow(context, product),
                      child: Text(
                        'Réserver ce panier',
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
          ),
        ],
      ),
    );
  }
}

class _StoreUnavailableState extends StatelessWidget {
  const _StoreUnavailableState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _CircleAction(icon: Icons.arrow_back, onTap: () => safePop(context)),
          ),
          const Spacer(),
          const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.blueBic,
            size: 74,
          ),
          const SizedBox(height: 18),
          Text(
            'Aucun panier disponible',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.blueBic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF52666A),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blueBic,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Réessayer',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    ),
  );
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.product, required this.store});

  final Map<String, dynamic> product;
  final Map<String, dynamic> store;

  @override
  Widget build(BuildContext context) {
    final price = product['discountedPrice'] as num;
    final originalPrice = product['originalPrice'] as num;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Panier surprise',
                  style: GoogleFonts.poppins(
                    color: AppColors.blueBic,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenTGTG.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'EN COURS',
                  style: GoogleFonts.poppins(
                    color: AppColors.greenTGTG,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                _formatCfa(price),
                style: GoogleFonts.poppins(
                  color: AppColors.blueBic,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _formatCfa(originalPrice),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Economisez ${_formatCfa(originalPrice - price)}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF263B3E),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _Meta(icon: Icons.star, text: '4,6 (126 avis)'),
              _Meta(icon: Icons.location_on_outlined, text: '0,3 km'),
              _Meta(icon: Icons.schedule, text: 'Aujourd’hui 17:00 - 19:00'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Un assortiment de poissons frais du jour\n(invendus du marché), idéal pour vos\npréparations maison.',
            style: GoogleFonts.poppins(
              color: const Color(0xFF263B3E),
              fontSize: 13,
              height: 1.65,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voir plus',
            style: GoogleFonts.poppins(
              color: AppColors.greenTGTG,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          const Divider(color: Color(0xFFE1E8E6)),
          const SizedBox(height: 14),
          Text(
            'Contenu possible',
            style: GoogleFonts.poppins(
              color: AppColors.blueBic,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [_Tag('Poissons'), _Tag('Fruits de mer'), _Tag('Filets')],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.blueBic, size: 15),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: const Color(0xFF263B3E),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E8E6)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: const Color(0xFF263B3E),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

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
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.blueBic, size: 20),
        ),
      ),
    );
  }
}

String _formatCfa(num value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    final remaining = rounded.length - i;
    buffer.write(rounded[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
  }
  return '$buffer FCFA';
}

// Page de confirmation d'ajout au panier
class SaveConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final String storeId;

  const SaveConfirmationPage({
    super.key,
    required this.product,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Panier ajouté',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image du produit
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(product['image'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Nom du produit
              Text(
                product['name'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Prix
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${product['discountedPrice'].toStringAsFixed(2)} €',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenTGTG,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${product['originalPrice'].toStringAsFixed(2)} €',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Message de confirmation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.greenTGTG.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.greenTGTG,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Panier ajouté avec succès !',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Info nombre d'articles dans le panier
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  if (cart.itemCount > 1) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.blueBic.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag,
                            color: AppColors.blueBic,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${cart.itemCount} articles dans votre panier',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
              // Bouton voir plus de produits
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/store/$storeId');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.blueBic, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Voir plus de paniers',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueBic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Bouton aller au panier
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    cartProvider.addItem(product, storeId);
                    context.go('/cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueBic,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Aller au panier',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

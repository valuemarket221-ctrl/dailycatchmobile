import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/models/product_offer.dart';
import 'package:myapp/models/store_model.dart';
import 'package:myapp/services/location_service.dart';
import 'package:myapp/services/product_offer_api_service.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/utils/store_utils.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:myapp/widgets/store_card.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/cart_provider.dart';

/// Page d'accueil DailyCatch
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Tous';
  late List<Store> _filteredStores;
  List<Store> _stores = [];
  // ignore: unused_field
  bool _isLoadingNearby = true;
  String _locationLabel = 'Dakar, Sénégal';
  String? _nearbyError;
  final ProductOfferApiService _productOfferApiService =
      ProductOfferApiService();
  final LocationService _locationService = LocationService();
  bool _didPrecacheImages = false;

  // ignore: unused_field
  final List<String> _categories = [
    'Tous',
    'Poisson',
    'Fruits de mer',
    'Crustacés',
    'Coquillages',
  ];

  final List<Store> _fallbackStores = [
    Store(
      id: '1',
      name: 'Poissonnerie Yoff',
      category: 'Poisson',
      distance: '0,3 km',
      originalPrice: 6000,
      discountedPrice: 3000,
      timeRemaining: '17:00 - 19:00',
      productsLeft: 3,
      image: 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      banner: 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      rating: 4.5,
      totalProducts: 12,
      productTypes: ['Thiof', 'Dorade', 'Arrivage local'],
    ),
    Store(
      id: '2',
      name: 'Mareyeur Soumbédioune',
      category: 'Poisson',
      distance: '0,6 km',
      originalPrice: 7500,
      discountedPrice: 4000,
      timeRemaining: '18:30 - 19:30',
      productsLeft: 2,
      image: 'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
      banner: 'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
      rating: 4.8,
      totalProducts: 8,
      productTypes: ['Thon', 'Sardines', 'Yoff'],
    ),
    Store(
      id: '3',
      name: 'Chez Ousmane',
      category: 'Crustacés',
      distance: '0,8 km',
      originalPrice: 6500,
      discountedPrice: 3500,
      timeRemaining: '17:00 - 18:00',
      productsLeft: 5,
      image: 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      banner: 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      rating: 4.2,
      totalProducts: 15,
      productTypes: ['Crevettes', 'Langoustes', 'Marché Kermel'],
    ),
    Store(
      id: '4',
      name: 'Blue Sea Seafood',
      category: 'Fruits de mer',
      distance: '1,1 km',
      originalPrice: 9000,
      discountedPrice: 5000,
      timeRemaining: '18:00 - 20:00',
      productsLeft: 4,
      image: 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
      banner: 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
      rating: 4.6,
      totalProducts: 20,
      productTypes: ['Huîtres', 'Moules', 'Plateau'],
    ),
    Store(
      id: '5',
      name: 'Fruit de Mer Dakar',
      category: 'Coquillages',
      distance: '1,5 km',
      originalPrice: 7000,
      discountedPrice: 4500,
      timeRemaining: '17:00 - 18:00',
      productsLeft: 6,
      image: 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      banner: 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      rating: 4.9,
      totalProducts: 10,
      productTypes: ['Huitres', 'Coquilles Saint-Jacques', 'Bulots'],
    ),
    Store(
      id: '6',
      name: 'Marché Kermel Frais',
      category: 'Poisson',
      distance: '1,9 km',
      originalPrice: 8000,
      discountedPrice: 4200,
      timeRemaining: '16:30 - 18:30',
      productsLeft: 3,
      image: 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      banner: 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      rating: 4.4,
      totalProducts: 18,
      productTypes: ['Mérou', 'Sole', 'Filets du jour'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _stores = _fallbackStores;
    _updateFilteredStores();
    _loadNearbyOffers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheImages) return;
    _didPrecacheImages = true;
    for (final imagePath in {
      'assets/images/crevette.jpg',
      'assets/images/saumon.jpg',
      'assets/images/homard.jpg',
      'assets/images/langoustines.jpg',
      'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
      'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
    }) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  Future<void> _loadNearbyOffers() async {
    final location = await _locationService.resolveCurrentLocation();

    try {
      final offers = await _productOfferApiService.getProductOffers(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm: 30,
      );
      final stores = offers.map(_storeFromOffer).toList();
      if (!mounted) return;
      setState(() {
        _stores = stores.isEmpty ? _fallbackStores : stores;
        _locationLabel = location.label;
        _nearbyError =
            stores.isEmpty
                ? 'Aucun panier proche: suggestions par défaut'
                : location.warning;
        _isLoadingNearby = false;
        _updateFilteredStores();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stores = _fallbackStores;
        _nearbyError = 'Backend indisponible: paniers de démonstration';
        _isLoadingNearby = false;
        _updateFilteredStores();
      });
    }
  }

  void _updateFilteredStores() {
    _filteredStores = StoreUtils.filterByCategory(_stores, _selectedCategory);
  }

  // ignore: unused_element
  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _updateFilteredStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildCompactHeader(context)),
            if (_nearbyError != null)
              SliverToBoxAdapter(child: _buildInfoBanner(_nearbyError!)),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'À proximité',
                        style: AppTextStyles.subtitleS.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/search'),
                      child: Text(
                        'Voir tout',
                        style: AppTextStyles.captionS.copyWith(
                          color: AppTheme.reef,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= _filteredStores.take(4).length) return null;
                return StoreCard(store: _filteredStores[index]);
              }, childCount: _filteredStores.take(4).length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'DAILYCATCH',
                style: AppTextStyles.subtitleS.copyWith(
                  color: AppColors.blueBic,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => context.push('/cart'),
                    icon: const Icon(
                      Icons.account_circle_outlined,
                      color: AppTheme.textPrimary,
                      size: 21,
                    ),
                  );
                },
              ),
            ],
          ),
          InkWell(
            onTap: () => context.go('/search'),
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.textPrimary,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  _locationLabel,
                  style: AppTextStyles.captionS.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.keyboard_arrow_down, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _SearchBox(
            hint: 'Rechercher un panier...',
            onTap: () => context.go('/search'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = ['Trier', 'Catégories', 'Filtres'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => context.go('/search'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE1E8E6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: AppTheme.textPrimary, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    chips[index],
                    style: AppTextStyles.captionS.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: chips.length,
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDiscoveryHeader(BuildContext context) {
    final heroCacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.lg,
        AppTheme.sm,
        AppTheme.lg,
        AppTheme.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppTheme.coastalInk,
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              boxShadow: AppTheme.shadowLg,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
                    fit: BoxFit.cover,
                    cacheWidth: heroCacheWidth,
                    filterQuality: FilterQuality.medium,
                    color: AppTheme.coastalInk.withValues(alpha: 0.44),
                    colorBlendMode: BlendMode.srcATop,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPremiumPill('Arrivages frais de Dakar'),
                      const SizedBox(height: AppTheme.lg),
                      Text(
                        'Réservez les meilleurs paniers de la côte',
                        style: AppTextStyles.headingL.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Text(
                        'Poissonneries, marchés et restaurants partenaires: du frais valorisé avant la fermeture.',
                        style: AppTextStyles.bodyM.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                      const SizedBox(height: AppTheme.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _buildImpactMetric('jusqu’à', '-65%'),
                          ),
                          const SizedBox(width: AppTheme.sm),
                          Expanded(
                            child: _buildImpactMetric('retrait', 'ce soir'),
                          ),
                          const SizedBox(width: AppTheme.sm),
                          Expanded(child: _buildImpactMetric('zone', 'Dakar')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.md,
              vertical: AppTheme.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.softBorder),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.sm),
                Expanded(
                  child: Text(
                    'Rechercher une poissonnerie, un panier...',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.md),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Carte',
                  icon: Icons.map_outlined,
                  onTap: () => context.go('/map'),
                  primary: true,
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Expanded(
                child: _buildActionButton(
                  label: 'Favoris',
                  icon: Icons.favorite_border,
                  onTap: () => context.go('/favorites'),
                  primary: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.md),
            decoration: BoxDecoration(
              color: AppTheme.reef.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.reef.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_outlined, color: AppTheme.reef),
                const SizedBox(width: AppTheme.sm),
                Expanded(
                  child: Text(
                    '12.5 kg de produits sauvés ce mois-ci avec les partenaires locaux',
                    style: AppTextStyles.captionL.copyWith(
                      color: AppTheme.coastalInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.md,
        vertical: AppTheme.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionL.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildImpactMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.captionS.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.captionL.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.md),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.warningColor.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppTheme.warningColor),
            const SizedBox(width: AppTheme.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.captionL.copyWith(
                  color: AppTheme.textPrimary,
                ),
                softWrap: true,
              ),
            ),
            const SizedBox(width: AppTheme.xs),
            Flexible(
              flex: 0,
              child: TextButton(
                onPressed: _loadNearbyOffers,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.sm,
                    vertical: AppTheme.xs,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Réessayer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildLocationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: AppTheme.reef, size: 20),
          const SizedBox(width: AppTheme.xs),
          Flexible(
            child: Text(
              _locationLabel,
              style: AppTextStyles.subtitleS.copyWith(
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.md,
          vertical: AppTheme.md,
        ),
        decoration: BoxDecoration(
          color: primary ? AppTheme.primaryColor : Colors.white,
          border: primary ? null : Border.all(color: AppTheme.softBorder),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          boxShadow: primary ? AppTheme.shadowSm : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary ? Colors.white : AppTheme.primaryColor),
            const SizedBox(width: AppTheme.sm),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.subtitleS.copyWith(
                  color: primary ? Colors.white : AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            decoration: const BoxDecoration(color: AppTheme.coastalInk),
            accountName: Text(
              'Ibrahima Aidara',
              style: AppTextStyles.subtitleM.copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              'ibrahima@email.com',
              style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppTheme.primaryColor),
            ),
          ),
          _buildDrawerItem(context, Icons.map, 'Carte des boutiques', '/map'),
          _buildDrawerItem(context, Icons.qr_code_2, 'Mes sauvés', '/pickup'),
          _buildDrawerItem(context, Icons.history, 'Historique', '/orders'),
          _buildDrawerItem(context, Icons.person, 'Mon profil', '/profile'),
          _buildDrawerItem(context, Icons.settings, 'Paramètres', '/settings'),
          const Divider(),
          _buildDrawerItem(context, Icons.help, 'Aide & FAQ', '/help'),
          _buildDrawerItem(context, Icons.logout, 'Déconnexion', '/login'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.reef),
      title: Text(title, style: AppTextStyles.bodyM),
      onTap: () {
        context.pop();
        context.push(route);
      },
    );
  }

  Store _storeFromOffer(ProductOffer offer) {
    final distance =
        offer.distanceKm == null
            ? 'Proche'
            : '${offer.distanceKm!.toStringAsFixed(1)} km';
    return Store(
      id: offer.storeId,
      name: offer.storeName,
      category: _categoryFromName(offer.name),
      distance: distance,
      originalPrice: offer.originalPrice,
      discountedPrice: offer.price,
      timeRemaining: _pickupTime(offer.pickupStartsAt, offer.pickupEndsAt),
      productsLeft: offer.availableQuantity,
      image: _imageForOffer(offer.name),
      banner: _imageForOffer(offer.name),
      rating: 4.6,
      totalProducts: offer.availableQuantity,
      productTypes: [_categoryFromName(offer.name), 'Surprise'],
    );
  }

  String _pickupTime(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'créneau disponible';
    String hhmm(DateTime date) =>
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${hhmm(start.toLocal())} - ${hhmm(end.toLocal())}';
  }

  String _categoryFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('crevette') ||
        lower.contains('homard') ||
        lower.contains('crust')) {
      return 'Crustacés';
    }
    if (lower.contains('huître') ||
        lower.contains('huitre') ||
        lower.contains('coquillage')) {
      return 'Coquillages';
    }
    if (lower.contains('sashimi') || lower.contains('thon')) {
      return 'Poisson';
    }
    return 'Poisson';
  }

  String _imageForOffer(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('crevette')) return 'assets/images/crevette.jpg';
    if (lower.contains('homard') || lower.contains('huître')) {
      return 'assets/images/homard.jpg';
    }
    if (lower.contains('langoustine')) return 'assets/images/langoustines.jpg';
    return 'assets/images/saumon.jpg';
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 39,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFE1E8E6)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: AppTheme.textSecondary, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint,
                style: AppTextStyles.captionS.copyWith(
                  color: AppTheme.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

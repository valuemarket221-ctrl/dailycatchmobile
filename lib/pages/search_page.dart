import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/models/store_model.dart';
import 'package:myapp/services/location_service.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/utils/favorite_store_ids.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:myapp/widgets/dailycatch_tile_layer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _mapController = MapController();
  final _locationService = LocationService();

  String _query = '';
  String _selectedCategory = 'Tous';
  String _sort = 'distance';
  double _distanceLimitKm = 3;
  String _selectedStoreId = '1';
  _LocationChoice _location = _locationChoices.first;
  bool _isLocating = false;

  static const _categories = [
    'Tous',
    'Poisson',
    'Fruits de mer',
    'Coquillages',
    'Filtres',
  ];

  final List<_MapStore> _stores = [
    _MapStore(
      latLng: const LatLng(14.7458, -17.4572),
      address: 'Yoff, Dakar',
      reviews: 126,
      store: Store(
        id: '1',
        name: 'Poissonnerie Yoff',
        category: 'Poisson',
        distance: '0,4 km',
        originalPrice: 5000,
        discountedPrice: 3000,
        timeRemaining: '17:00 - 19:00',
        productsLeft: 3,
        image: 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
        banner: 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
        rating: 4.8,
        totalProducts: 8,
        productTypes: const ['Poisson', 'Panier surprise'],
      ),
    ),
    _MapStore(
      latLng: const LatLng(14.6878, -17.4476),
      address: 'Fann, Dakar',
      reviews: 98,
      store: Store(
        id: '4',
        name: 'Ocean Fresh',
        category: 'Fruits de mer',
        distance: '0,7 km',
        originalPrice: 5000,
        discountedPrice: 3500,
        timeRemaining: '16:30 - 18:30',
        productsLeft: 4,
        image: 'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
        banner: 'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
        rating: 4.6,
        totalProducts: 10,
        productTypes: const ['Fruits de mer', 'Crevettes'],
      ),
    ),
    _MapStore(
      latLng: const LatLng(14.7238, -17.4727),
      address: 'Ouakam, Dakar',
      reviews: 67,
      store: Store(
        id: '3',
        name: 'Chez Mame Coumba',
        category: 'Coquillages',
        distance: '1,2 km',
        originalPrice: 4500,
        discountedPrice: 2800,
        timeRemaining: '17:00 - 20:00',
        productsLeft: 2,
        image: 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
        banner: 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
        rating: 4.7,
        totalProducts: 6,
        productTypes: const ['Coquillages', 'Fruits de mer'],
      ),
    ),
    _MapStore(
      latLng: const LatLng(14.7111, -17.4922),
      address: 'Almadies, Dakar',
      reviews: 54,
      store: Store(
        id: '5',
        name: 'La Mer à Table',
        category: 'Poisson',
        distance: '1,4 km',
        originalPrice: 5000,
        discountedPrice: 3200,
        timeRemaining: '18:00 - 20:00',
        productsLeft: 2,
        image: 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
        banner: 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
        rating: 4.5,
        totalProducts: 7,
        productTypes: const ['Poisson', 'Arrivage local'],
      ),
    ),
    _MapStore(
      latLng: const LatLng(14.7002, -17.4588),
      address: 'Mermoz, Dakar',
      reviews: 81,
      store: Store(
        id: '2',
        name: 'Sokhna Fish',
        category: 'Poisson',
        distance: '2,1 km',
        originalPrice: 6000,
        discountedPrice: 4000,
        timeRemaining: '17:30 - 19:30',
        productsLeft: 3,
        image: 'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
        banner: 'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
        rating: 4.6,
        totalProducts: 9,
        productTypes: const ['Poisson', 'Fruits de mer'],
      ),
    ),
  ];

  List<_MapStore> get _filteredStores {
    final normalizedQuery = _query.trim().toLowerCase();
    final stores =
        _stores.where((item) {
          final store = item.store;
          final matchesQuery =
              normalizedQuery.isEmpty ||
              store.name.toLowerCase().contains(normalizedQuery) ||
              item.address.toLowerCase().contains(normalizedQuery) ||
              store.category.toLowerCase().contains(normalizedQuery) ||
              store.productTypes.any(
                (type) => type.toLowerCase().contains(normalizedQuery),
              );
          final matchesCategory =
              _selectedCategory == 'Tous' ||
              store.category == _selectedCategory ||
              store.productTypes.contains(_selectedCategory);
          return matchesQuery &&
              matchesCategory &&
              item.distanceKm <= _distanceLimitKm;
        }).toList();

    stores.sort((a, b) {
      return switch (_sort) {
        'price' => a.store.discountedPrice.compareTo(b.store.discountedPrice),
        'rating' => b.store.rating.compareTo(a.store.rating),
        'stock' => b.store.productsLeft.compareTo(a.store.productsLeft),
        _ => a.distanceKm.compareTo(b.distanceKm),
      };
    });
    return stores;
  }

  _MapStore? get _selectedStore {
    final stores = _filteredStores;
    if (stores.isEmpty) return null;
    for (final store in stores) {
      if (store.store.id == _selectedStoreId) return store;
    }
    return stores.first;
  }

  @override
  void initState() {
    super.initState();
    FavoriteStoreIds.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectStore(_MapStore store) {
    setState(() => _selectedStoreId = store.store.id);
    _mapController.move(store.latLng, 13.5);
  }

  void _selectCategory(String category) {
    if (category == 'Filtres') {
      _openFilters();
      return;
    }
    setState(() {
      _selectedCategory = category;
      final stores = _filteredStores;
      _selectedStoreId = stores.isEmpty ? '' : stores.first.store.id;
    });
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      final location = await _locationService.resolveCurrentLocation();
      final choice = _LocationChoice(
        location.label,
        LatLng(location.latitude, location.longitude),
      );
      if (!mounted) return;
      setState(() => _location = choice);
      _mapController.move(choice.center, 13);
      if (location.warning != null) _showSnack(location.warning!);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _changeLocation(_LocationChoice choice) {
    setState(() => _location = choice);
    _mapController.move(choice.center, 13);
    Navigator.of(context).pop();
  }

  void _showLocationSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Changer ma localisation',
                    style: AppTextStyles.headingS,
                  ),
                  const SizedBox(height: 14),
                  _LocationRow(
                    icon: Icons.my_location,
                    title: _isLocating ? 'Recherche...' : 'Autour de moi',
                    onTap: _useCurrentLocation,
                  ),
                  for (final choice in _locationChoices)
                    _LocationRow(
                      icon: Icons.location_on_outlined,
                      title: choice.label,
                      selected: choice.label == _location.label,
                      onTap: () => _changeLocation(choice),
                    ),
                ],
              ),
            ),
          ),
    );
  }

  void _openFilters() {
    var nextSort = _sort;
    var nextDistance = _distanceLimitKm;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setSheetState) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filtres', style: AppTextStyles.headingS),
                        const SizedBox(height: 16),
                        Text('Trier par', style: AppTextStyles.subtitleS),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FilterPill(
                              label: 'Distance',
                              active: nextSort == 'distance',
                              onTap:
                                  () => setSheetState(
                                    () => nextSort = 'distance',
                                  ),
                            ),
                            _FilterPill(
                              label: 'Prix',
                              active: nextSort == 'price',
                              onTap:
                                  () => setSheetState(() => nextSort = 'price'),
                            ),
                            _FilterPill(
                              label: 'Note',
                              active: nextSort == 'rating',
                              onTap:
                                  () =>
                                      setSheetState(() => nextSort = 'rating'),
                            ),
                            _FilterPill(
                              label: 'Disponibilité',
                              active: nextSort == 'stock',
                              onTap:
                                  () => setSheetState(() => nextSort = 'stock'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Text(
                              'Distance max',
                              style: AppTextStyles.subtitleS,
                            ),
                            const Spacer(),
                            Text(
                              '${nextDistance.toStringAsFixed(0)} km',
                              style: AppTextStyles.subtitleS.copyWith(
                                color: AppTheme.reef,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: nextDistance,
                          min: 1,
                          max: 8,
                          divisions: 7,
                          activeColor: AppTheme.reef,
                          onChanged:
                              (value) =>
                                  setSheetState(() => nextDistance = value),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _sort = nextSort;
                                _distanceLimitKm = nextDistance;
                                final stores = _filteredStores;
                                _selectedStoreId =
                                    stores.isEmpty ? '' : stores.first.store.id;
                              });
                              Navigator.of(context).pop();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: Text(
                              'Appliquer',
                              style: AppTextStyles.subtitleS.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _showListSheet() {
    final stores = _filteredStores;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: .72,
            minChildSize: .42,
            maxChildSize: .92,
            builder:
                (
                  context,
                  scrollController,
                ) => ValueListenableBuilder<Set<String>>(
                  valueListenable: FavoriteStoreIds.ids,
                  builder:
                      (context, favorites, _) => ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        children: [
                          Center(
                            child: Container(
                              width: 42,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD8E1DF),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${stores.length} boutiques autour de vous',
                                  style: AppTextStyles.headingS,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (stores.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 70),
                              child: Text(
                                'Aucun résultat dans cette zone.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyM.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            )
                          else
                            for (final store in stores)
                              _StoreListRow(
                                item: store,
                                favorite: favorites.contains(store.store.id),
                                onFavorite:
                                    () =>
                                        FavoriteStoreIds.toggle(store.store.id),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _selectStore(store);
                                },
                              ),
                        ],
                      ),
                ),
          ),
    );
  }

  void _openStore(_MapStore item) {
    context.push('/store/${item.store.id}', extra: item.store);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: AppTextStyles.bodyS.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stores = _filteredStores;
    final selected = _selectedStore;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _location.center,
                initialZoom: 13,
                minZoom: 11,
                maxZoom: 17,
              ),
              children: [
                const DailyCatchTileLayer(),
                MarkerLayer(
                  markers:
                      stores
                          .map(
                            (item) => Marker(
                              point: item.latLng,
                              width: 112,
                              height: 116,
                              child: _PhotoMarker(
                                item: item,
                                selected: item.store.id == selected?.store.id,
                                onTap: () => _selectStore(item),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            left: 16,
            right: 16,
            child: _TopSearchPanel(
              locationLabel: _location.label,
              controller: _searchController,
              selectedCategory: _selectedCategory,
              categories: _categories,
              onLocationTap: _showLocationSheet,
              onSearchChanged:
                  (value) => setState(() {
                    _query = value;
                    final stores = _filteredStores;
                    _selectedStoreId =
                        stores.isEmpty ? '' : stores.first.store.id;
                  }),
              onCategoryTap: _selectCategory,
              onFilterTap: _openFilters,
            ),
          ),
          Positioned(
            right: 16,
            bottom: selected == null ? 26 : 264,
            child: Column(
              children: [
                _FloatingMapButton(
                  icon: Icons.format_list_bulleted_rounded,
                  label: 'Liste',
                  onTap: _showListSheet,
                ),
                const SizedBox(height: 12),
                _RoundButton(
                  icon: _isLocating ? Icons.more_horiz : Icons.my_location,
                  onTap: _useCurrentLocation,
                ),
              ],
            ),
          ),
          if (selected != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: FavoriteStoreIds.ids,
                builder:
                    (context, favorites, _) => _StorePreviewSheet(
                      item: selected,
                      favorite: favorites.contains(selected.store.id),
                      onFavorite:
                          () => FavoriteStoreIds.toggle(selected.store.id),
                      onOpen: () => _openStore(selected),
                    ),
              ),
            )
          else
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: _EmptyMapState(onFilters: _openFilters),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

class _MapStore {
  const _MapStore({
    required this.store,
    required this.latLng,
    required this.address,
    required this.reviews,
  });

  final Store store;
  final LatLng latLng;
  final String address;
  final int reviews;

  double get distanceKm {
    final value = store.distance
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(value) ?? 99;
  }
}

class _LocationChoice {
  const _LocationChoice(this.label, this.center);

  final String label;
  final LatLng center;
}

const _locationChoices = [
  _LocationChoice('Dakar, Sénégal', LatLng(14.6928, -17.4467)),
  _LocationChoice('Yoff', LatLng(14.7458, -17.4572)),
  _LocationChoice('Almadies', LatLng(14.7392, -17.5212)),
  _LocationChoice('Ouakam', LatLng(14.7238, -17.4727)),
  _LocationChoice('Soumbédioune', LatLng(14.6816, -17.4529)),
];

class _TopSearchPanel extends StatelessWidget {
  const _TopSearchPanel({
    required this.locationLabel,
    required this.controller,
    required this.selectedCategory,
    required this.categories,
    required this.onLocationTap,
    required this.onSearchChanged,
    required this.onCategoryTap,
    required this.onFilterTap,
  });

  final String locationLabel;
  final TextEditingController controller;
  final String selectedCategory;
  final List<String> categories;
  final VoidCallback onLocationTap;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: .12),
              child: InkWell(
                onTap: onLocationTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.reef,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          locationLabel,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.captionL.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _RoundButton(
            icon: Icons.notifications_none,
            onTap: () => context.push('/notifications'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: .12),
        child: SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            onChanged: onSearchChanged,
            style: AppTextStyles.captionL.copyWith(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Rechercher une boutique, un quartier...',
              hintStyle: AppTextStyles.captionS.copyWith(
                color: AppTheme.textHint,
                fontSize: 11.5,
              ),
              prefixIcon: const Icon(Icons.search, size: 19),
              suffixIcon: IconButton(
                onPressed: onFilterTap,
                icon: const Icon(Icons.tune, size: 19),
              ),
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.softBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.softBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.reef, width: 1.4),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: category,
                        active: category == selectedCategory,
                        onTap: () => onCategoryTap(category),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    ],
  );
}

class _PhotoMarker extends StatelessWidget {
  const _PhotoMarker({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _MapStore item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedScale(
      scale: selected ? 1.08 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: SizedBox(
        width: 108,
        height: 116,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 72,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppTheme.reef : Colors.white,
                  width: selected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .22),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.store.banner,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.coastalInk.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${item.store.productsLeft} paniers',
                        style: AppTextStyles.captionS.copyWith(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxWidth: 96),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    item.store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionS.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 5, color: AppTheme.reef),
                      const SizedBox(width: 4),
                      Text(
                        item.store.distance,
                        style: AppTextStyles.captionS.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 9,
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
    ),
  );
}

class _StorePreviewSheet extends StatelessWidget {
  const _StorePreviewSheet({
    required this.item,
    required this.favorite,
    required this.onFavorite,
    required this.onOpen,
  });

  final _MapStore item;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final store = item.store;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD8E1DF),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  store.image,
                  width: 118,
                  height: 112,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _OpenBadge(),
                        const Spacer(),
                        IconButton(
                          onPressed: onFavorite,
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            color: AppTheme.lagoon,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitleM.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _MetaLine(
                      icon: Icons.star,
                      label:
                          '${store.rating.toStringAsFixed(1)} (${item.reviews} avis)',
                      iconColor: AppTheme.saffron,
                    ),
                    _MetaLine(
                      icon: Icons.location_on_outlined,
                      label: '${item.address} • ${store.distance}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.softBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppTheme.lagoon,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Panier surprise',
                        style: AppTextStyles.captionL.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      _formatPrice(store.discountedPrice),
                      style: AppTextStyles.subtitleS.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${store.productsLeft} paniers disponibles',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.captionS.copyWith(
                          color: AppTheme.reef,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(store.originalPrice),
                      style: AppTextStyles.captionS.copyWith(
                        color: AppTheme.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '-${store.discountPercentage}%',
                      style: AppTextStyles.captionS.copyWith(
                        color: AppTheme.coral,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Retrait aujourd’hui',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.captionS,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      store.timeRemaining,
                      style: AppTextStyles.captionS.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: onOpen,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Voir les paniers',
                style: AppTextStyles.subtitleS.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreListRow extends StatelessWidget {
  const _StoreListRow({
    required this.item,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });

  final _MapStore item;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final store = item.store;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.softBorder),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                store.image,
                width: 96,
                height: 92,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _OpenBadge(),
                      const Spacer(),
                      Text(store.distance, style: AppTextStyles.captionS),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitleS.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _MetaLine(
                    icon: Icons.location_on_outlined,
                    label: item.address,
                  ),
                  _MetaLine(
                    icon: Icons.schedule_outlined,
                    label: 'Retrait ${store.timeRemaining}',
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _formatPrice(store.discountedPrice),
                        style: AppTextStyles.subtitleS.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatPrice(store.originalPrice),
                        style: AppTextStyles.captionS.copyWith(
                          color: AppTheme.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onFavorite,
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          color: AppTheme.lagoon,
                          size: 20,
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

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    onTap: onTap,
    leading: Icon(
      icon,
      color: selected ? AppTheme.reef : AppTheme.textSecondary,
    ),
    title: Text(
      title,
      style: AppTextStyles.subtitleS.copyWith(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    ),
    trailing:
        selected
            ? const Icon(Icons.check_circle, color: AppTheme.reef)
            : const Icon(Icons.chevron_right),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: active ? AppTheme.primaryColor : Colors.white,
    borderRadius: BorderRadius.circular(999),
    elevation: active ? 3 : 1,
    shadowColor: Colors.black.withValues(alpha: .12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppTheme.primaryColor : AppTheme.softBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label == 'Filtres') ...[
              const Icon(Icons.tune, size: 15, color: AppTheme.textPrimary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.captionS.copyWith(
                color: active ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    selected: active,
    label: Text(label),
    onSelected: (_) => onTap(),
    selectedColor: const Color(0xFFE4F4F2),
    labelStyle: AppTextStyles.captionS.copyWith(
      color: active ? AppTheme.primaryColor : AppTheme.textPrimary,
      fontWeight: FontWeight.w900,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
      side: BorderSide(color: active ? AppTheme.reef : AppTheme.softBorder),
    ),
  );
}

class _FloatingMapButton extends StatelessWidget {
  const _FloatingMapButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.primaryColor,
    borderRadius: BorderRadius.circular(999),
    elevation: 5,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: AppTextStyles.captionS.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: .12),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 42,
        height: 42,
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
    ),
  );
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF7F1),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      'Ouvert',
      style: AppTextStyles.captionS.copyWith(
        color: AppTheme.reef,
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.label,
    this.iconColor = AppTheme.textSecondary,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionS.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyMapState extends StatelessWidget {
  const _EmptyMapState({required this.onFilters});

  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: AppTheme.shadowMd,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search_off, color: AppTheme.primaryColor, size: 32),
        const SizedBox(height: 8),
        Text('Aucune boutique trouvée', style: AppTextStyles.subtitleS),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onFilters,
          child: const Text('Modifier les filtres'),
        ),
      ],
    ),
  );
}

String _formatPrice(double value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    final remaining = rounded.length - i;
    buffer.write(rounded[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
  }
  return '$buffer FCFA';
}

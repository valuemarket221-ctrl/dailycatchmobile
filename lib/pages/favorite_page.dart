import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/models/product_offer.dart';
import 'package:myapp/services/product_offer_api_service.dart';
import 'package:myapp/utils/api_error_messages.dart';
import 'package:myapp/utils/favorite_store_ids.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:myapp/widgets/app_remote_image.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final ProductOfferApiService _productOfferApiService =
      ProductOfferApiService();
  var _itemsByStoreId = <String, _FavoriteItem>{};
  var _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    FavoriteStoreIds.load();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final offers = await _productOfferApiService.getProductOffers(limit: 100);
      if (!mounted) return;
      setState(() {
        _itemsByStoreId = _itemsFromOffers(offers);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _itemsByStoreId = {};
        _loadError = ApiErrorMessages.fromObject(error);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (context.canPop())
                    IconButton(
                      onPressed: () => safePop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.blueBic,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  Text('FAVORIS', style: _title),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadFavorites,
                    icon: const Icon(Icons.refresh, color: AppColors.blueBic),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_loadError != null) ...[
                _FavoriteNotice(message: _loadError!, onRetry: _loadFavorites),
                const SizedBox(height: 14),
              ],
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ValueListenableBuilder<Set<String>>(
                          valueListenable: FavoriteStoreIds.ids,
                          builder: (context, favoriteIds, _) {
                            final items =
                                favoriteIds
                                    .map((id) => _itemsByStoreId[id])
                                    .whereType<_FavoriteItem>()
                                    .toList()
                                  ..sort(
                                    (a, b) =>
                                        a.storeName.compareTo(b.storeName),
                                  );

                            if (items.isEmpty) {
                              return _FavoritesEmpty(
                                hasError: _loadError != null,
                                onExplore: () => context.go('/search'),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: _loadFavorites,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 18),
                                itemCount: items.length,
                                separatorBuilder:
                                    (_, __) => const Divider(
                                      height: 30,
                                      thickness: 1,
                                      color: Color(0xFFE6ECEC),
                                    ),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return _FavoriteTile(item: item);
                                },
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Map<String, _FavoriteItem> _itemsFromOffers(List<ProductOffer> offers) {
    final result = <String, _FavoriteItem>{};
    for (final offer in offers) {
      final current = result[offer.storeId];
      final next = _FavoriteItem.fromOffer(offer, current);
      result[offer.storeId] = next;
    }
    return result;
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.item});

  final _FavoriteItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/store/${item.storeId}'),
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 78,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppRemoteImage(
                path: item.image,
                width: 68,
                height: 68,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 17),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.storeName,
                    style: _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(item.distanceLabel, style: _distance),
                  const SizedBox(height: 4),
                  Text(
                    '${item.availableQuantity} paniers disponibles',
                    style: _stock,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => FavoriteStoreIds.toggle(item.storeId),
              icon: const Icon(
                Icons.favorite,
                size: 20,
                color: AppColors.blueBic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesEmpty extends StatelessWidget {
  const _FavoritesEmpty({required this.hasError, required this.onExplore});

  final bool hasError;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border, color: AppColors.blueBic, size: 42),
          const SizedBox(height: 14),
          Text(
            hasError ? 'Favoris indisponibles' : 'Aucun favori pour le moment',
            style: _name,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onExplore,
            child: Text('Explorer la carte', style: _link),
          ),
        ],
      ),
    );
  }
}

class _FavoriteNotice extends StatelessWidget {
  const _FavoriteNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFF59E0B)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: _notice)),
        TextButton(onPressed: onRetry, child: const Text('Réessayer')),
      ],
    ),
  );
}

class _FavoriteItem {
  const _FavoriteItem({
    required this.storeId,
    required this.storeName,
    required this.image,
    required this.availableQuantity,
    this.distanceKm,
  });

  final String storeId;
  final String storeName;
  final String image;
  final int availableQuantity;
  final double? distanceKm;

  String get distanceLabel =>
      distanceKm == null
          ? 'Distance indisponible'
          : '${distanceKm!.toStringAsFixed(1)} km';

  static _FavoriteItem fromOffer(ProductOffer offer, _FavoriteItem? current) {
    return _FavoriteItem(
      storeId: offer.storeId,
      storeName: offer.storeName,
      image:
          current?.image.isNotEmpty == true
              ? current!.image
              : offer.mediaUrls.isNotEmpty
              ? offer.mediaUrls.first
              : '',
      availableQuantity:
          (current?.availableQuantity ?? 0) + offer.availableQuantity,
      distanceKm: current?.distanceKm ?? offer.distanceKm,
    );
  }
}

final _title = GoogleFonts.poppins(
  fontSize: 17,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _name = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _distance = GoogleFonts.poppins(
  fontSize: 11.5,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF5A6A6D),
);
final _stock = GoogleFonts.poppins(
  fontSize: 10.5,
  fontWeight: FontWeight.w700,
  color: AppColors.blueBic,
);
final _link = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _notice = GoogleFonts.poppins(
  fontSize: 11.5,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF7C4A03),
);

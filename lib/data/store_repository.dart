import 'package:myapp/models/product_offer.dart';
import 'package:myapp/models/store.dart';
import 'package:myapp/services/product_offer_api_service.dart';

/// Repository pour les boutiques partenaires.
/// Source principale: API backend product-offers.
class StoreRepository {
  StoreRepository({
    ProductOfferApiService? productOfferApiService,
    bool? demoFallbackAllowed,
  }) : _productOfferApiService =
           productOfferApiService ?? ProductOfferApiService();

  final ProductOfferApiService _productOfferApiService;

  Stream<List<Store>> storesStream() async* {
    yield await _loadStores();
  }

  Future<Store?> getStore(String id) async {
    final stores = await _loadStores();
    return stores.where((store) => store.id == id).firstOrNull;
  }

  Future<List<Store>> getByCategory(String category) async {
    final stores = await _loadStores();
    return stores.where((store) => store.category == category).toList();
  }

  Future<List<Store>> _loadStores() async {
    final offers = await _productOfferApiService.getProductOffers();
    return _storesFromOffers(offers);
  }

  List<Store> _storesFromOffers(List<ProductOffer> offers) {
    final firstOfferByStore = <String, ProductOffer>{};
    final quantityByStore = <String, int>{};
    for (final offer in offers) {
      firstOfferByStore.putIfAbsent(offer.storeId, () => offer);
      quantityByStore.update(
        offer.storeId,
        (current) => current + offer.availableQuantity,
        ifAbsent: () => offer.availableQuantity,
      );
    }

    return firstOfferByStore.entries.map((entry) {
      final offer = entry.value;
      final image = offer.mediaUrls.isNotEmpty ? offer.mediaUrls.first : '';
      return Store(
        id: offer.storeId,
        name: offer.storeName,
        category:
            offer.category?.trim().isNotEmpty == true
                ? offer.category!.trim()
                : 'Non renseignée',
        distance:
            offer.distanceKm == null
                ? 'Distance indisponible'
                : '${offer.distanceKm!.toStringAsFixed(1)} km',
        originalPrice: offer.originalPrice,
        discountedPrice: offer.price,
        pickupTime: _pickupTime(offer.pickupStartsAt, offer.pickupEndsAt),
        productsLeft: quantityByStore[offer.storeId] ?? offer.availableQuantity,
        image: image,
        banner: image,
        rating: offer.storeRating,
        productsCount:
            quantityByStore[offer.storeId] ?? offer.availableQuantity,
        productTypes: [
          offer.category?.trim().isNotEmpty == true
              ? offer.category!.trim()
              : 'Non renseignée',
          'Panier surprise',
        ],
        lat: offer.hasValidCoordinates ? offer.latitude : null,
        lng: offer.hasValidCoordinates ? offer.longitude : null,
      );
    }).toList();
  }

  String _pickupTime(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Créneau non renseigné';
    String hhmm(DateTime date) =>
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${hhmm(start.toLocal())} - ${hhmm(end.toLocal())}';
  }
}

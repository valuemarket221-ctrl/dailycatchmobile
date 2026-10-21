import 'package:latlong2/latlong.dart';
import 'package:myapp/services/product_offer_api_service.dart';
import 'package:myapp/src/features/discovery/domain/basket.dart';

class BasketRepository {
  BasketRepository({ProductOfferApiService? productOfferApiService})
    : _productOfferApiService =
          productOfferApiService ?? ProductOfferApiService();

  final ProductOfferApiService _productOfferApiService;

  Stream<List<Basket>> getBaskets() async* {
    final offers = await _productOfferApiService.getProductOffers();
    yield offers.map((offer) {
      return Basket(
        id: offer.id,
        partnerName: offer.storeName,
        name: offer.name,
        image:
            offer.mediaUrls.isNotEmpty
                ? offer.mediaUrls.first
                : 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
        price: offer.price,
        rating: 4,
        pickupTime:
            offer.pickupStartsAt == null || offer.pickupEndsAt == null
                ? 'Créneau disponible'
                : '${_hhmm(offer.pickupStartsAt!.toLocal())} - ${_hhmm(offer.pickupEndsAt!.toLocal())}',
        location: LatLng(
          offer.latitude ?? 14.6928,
          offer.longitude ?? -17.4467,
        ),
      );
    }).toList();
  }

  String _hhmm(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

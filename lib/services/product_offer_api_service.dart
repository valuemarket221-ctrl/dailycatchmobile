import 'package:http/http.dart' as http;
import 'package:myapp/models/product_offer.dart';
import 'package:myapp/services/backend_api_client.dart';

class ProductOfferApiService {
  ProductOfferApiService({http.Client? client, String? baseUrl})
    : _api = BackendApiClient(client: client, baseUrl: baseUrl);

  final BackendApiClient _api;

  Future<List<ProductOffer>> getProductOffers({
    double? latitude,
    double? longitude,
    double radiusKm = 25,
  }) async {
    final body = await _api.get(
      '/api/v1/product-offers',
      authenticated: false,
      queryParameters: {
        if (latitude != null && longitude != null) ...{
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radiusKm': radiusKm.toString(),
        },
      },
    );

    final offersJson = body['offers'] as List<dynamic>;
    return offersJson
        .map((offer) => ProductOffer.fromJson(offer as Map<String, dynamic>))
        .toList();
  }
}

typedef ProductOfferApiException = BackendApiException;

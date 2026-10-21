import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/data/rescued_product_repository.dart';
import 'package:myapp/data/store_repository.dart';
import 'package:myapp/models/product_offer.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/services/product_offer_api_service.dart';

void main() {
  test(
    'empty backend catalog stays empty even with legacy fallback requested',
    () async {
      final api = _FakeProductOfferApiService();
      expect(
        await StoreRepository(
          productOfferApiService: api,
          demoFallbackAllowed: true,
        ).storesStream().first,
        isEmpty,
      );
      expect(
        await RescuedProductRepository(
          productOfferApiService: api,
          demoFallbackAllowed: true,
        ).getAvailableProducts(),
        isEmpty,
      );
    },
  );

  test('backend outage is never replaced with fixtures', () async {
    final api = _FakeProductOfferApiService(
      error: const BackendApiException(
        statusCode: 503,
        code: 'database_unavailable',
      ),
    );
    await expectLater(
      StoreRepository(
        productOfferApiService: api,
        demoFallbackAllowed: true,
      ).storesStream().first,
      throwsA(isA<BackendApiException>()),
    );
    await expectLater(
      RescuedProductRepository(
        productOfferApiService: api,
        demoFallbackAllowed: true,
      ).getAvailableProducts(),
      throwsA(isA<BackendApiException>()),
    );
  });

  test('maps backend offers into stores without demo fallback', () async {
    final repository = StoreRepository(
      productOfferApiService: _FakeProductOfferApiService(
        offers: const [
          ProductOffer(
            id: 'offer_1',
            storeId: 'store_yoff',
            storeName: 'Poissonnerie Yoff',
            name: 'Panier surprise',
            currency: 'xof',
            unitAmount: 3000,
            originalUnitAmount: 6000,
            availableQuantity: 3,
            category: 'Poisson',
            distanceKm: 0.4,
          ),
          ProductOffer(
            id: 'offer_2',
            storeId: 'store_yoff',
            storeName: 'Poissonnerie Yoff',
            name: 'Panier du soir',
            currency: 'xof',
            unitAmount: 3500,
            availableQuantity: 2,
          ),
        ],
      ),
      demoFallbackAllowed: false,
    );

    final stores = await repository.storesStream().first;

    expect(stores, hasLength(1));
    expect(stores.single.id, 'store_yoff');
    expect(stores.single.name, 'Poissonnerie Yoff');
    expect(stores.single.productsLeft, 5);
    expect(stores.single.rating, isNull);
    expect(stores.single.lat, isNull);
    expect(stores.single.lng, isNull);
    expect(stores.single.image, isEmpty);
  });

  test(
    'store repository rethrows API failures without demo fallback',
    () async {
      final repository = StoreRepository(
        productOfferApiService: _FakeProductOfferApiService(
          error: const BackendApiException(
            statusCode: 503,
            code: 'database_not_configured',
          ),
        ),
        demoFallbackAllowed: false,
      );

      expect(
        () => repository.storesStream().first,
        throwsA(
          isA<BackendApiException>().having(
            (error) => error.code,
            'code',
            'database_not_configured',
          ),
        ),
      );
    },
  );

  test('maps available backend offers into rescued products', () async {
    final repository = RescuedProductRepository(
      productOfferApiService: _FakeProductOfferApiService(
        offers: const [
          ProductOffer(
            id: 'offer_1',
            storeId: 'store_yoff',
            storeName: 'Poissonnerie Yoff',
            name: 'Panier surprise',
            currency: 'xof',
            unitAmount: 3000,
            availableQuantity: 3,
          ),
          ProductOffer(
            id: 'offer_empty',
            storeId: 'store_empty',
            storeName: 'Commerce vide',
            name: 'Panier vide',
            currency: 'xof',
            unitAmount: 3000,
            availableQuantity: 0,
          ),
        ],
      ),
      demoFallbackAllowed: false,
    );

    final products = await repository.getAvailableProducts();

    expect(products, hasLength(1));
    expect(products.single.id, 'offer_1');
    expect(products.single.partnerName, 'Poissonnerie Yoff');
    expect(products.single.originalPrice, products.single.discountedPrice);
    expect(products.single.ecoSavingsPercentage, 0);
    expect(products.single.imageUrl, isEmpty);
  });

  test(
    'rescued product repository rethrows API failures without demo fallback',
    () {
      final repository = RescuedProductRepository(
        productOfferApiService: _FakeProductOfferApiService(
          error: const BackendApiException(
            statusCode: 503,
            code: 'database_not_configured',
          ),
        ),
        demoFallbackAllowed: false,
      );

      expect(
        repository.getAvailableProducts,
        throwsA(
          isA<BackendApiException>().having(
            (error) => error.code,
            'code',
            'database_not_configured',
          ),
        ),
      );
    },
  );
}

class _FakeProductOfferApiService extends ProductOfferApiService {
  _FakeProductOfferApiService({this.offers = const [], this.error})
    : super(baseUrl: 'http://127.0.0.1:8080');

  final List<ProductOffer> offers;
  final BackendApiException? error;

  @override
  Future<List<ProductOffer>> getProductOffers({
    double? latitude,
    double? longitude,
    double radiusKm = 25,
    int limit = 100,
    int offset = 0,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    return offers;
  }
}

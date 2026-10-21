import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/product_offer.dart';

void main() {
  test('parses real store details without inventing missing ratings', () {
    final json = <String, dynamic>{
      'id': 'offer',
      'storeId': 'store',
      'storeName': 'Store',
      'name': 'Basket',
      'currency': 'eur',
      'unitAmount': 500,
      'availableQuantity': 1,
    };
    final missing = ProductOffer.fromJson(json);
    expect(missing.storeAddress, isNull);
    expect(missing.storeRating, isNull);
    expect(missing.storeReviewCount, 0);
    final actual = ProductOffer.fromJson({
      ...json,
      'storeAddress': '12 Rue du Port',
      'storeRating': 4.25,
      'storeReviewCount': 8,
    });
    expect(actual.storeAddress, '12 Rue du Port');
    expect(actual.storeRating, 4.25);
    expect(actual.storeReviewCount, 8);
  });

  ProductOffer offer(double? lat, double? lng) => ProductOffer(
    id: 'offer',
    storeId: 'store',
    storeName: 'Store',
    name: 'Basket',
    currency: 'eur',
    unitAmount: 500,
    availableQuantity: 1,
    latitude: lat,
    longitude: lng,
  );

  test('map only accepts complete valid coordinates', () {
    expect(offer(null, null).hasValidCoordinates, isFalse);
    expect(offer(52, null).hasValidCoordinates, isFalse);
    expect(offer(91, 13).hasValidCoordinates, isFalse);
    expect(offer(52, -181).hasValidCoordinates, isFalse);
    expect(offer(double.nan, 13).hasValidCoordinates, isFalse);
    expect(offer(52, double.infinity).hasValidCoordinates, isFalse);
    expect(offer(52.52, 13.405).hasValidCoordinates, isTrue);
    expect(offer(0, 0).hasValidCoordinates, isTrue);
  });
}

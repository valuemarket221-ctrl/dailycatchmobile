import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/demo/demo_mode.dart';
import 'package:myapp/demo/demo_client.dart';
import 'package:myapp/services/product_offer_api_service.dart';
import 'package:myapp/utils/favorite_store_ids.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('demo favorites match stores and removals persist', () async {
    const key = 'dailycatch_favorite_store_ids';
    SharedPreferences.setMockInitialValues({
      key: ['1', '2', '4', '5'],
    });
    await FavoriteStoreIds.load();
    final offers =
        await ProductOfferApiService(client: DemoClient()).getProductOffers();
    final stores = offers.map((offer) => offer.storeId).toSet();
    expect(FavoriteStoreIds.ids.value, {'store_yoff', 'store_ouakam'});
    expect(stores.containsAll(FavoriteStoreIds.ids.value), isTrue);
    await FavoriteStoreIds.toggle('store_yoff');
    await FavoriteStoreIds.toggle('store_ouakam');
    expect(FavoriteStoreIds.ids.value, isEmpty);
    expect((await SharedPreferences.getInstance()).getStringList(key), isEmpty);
    await FavoriteStoreIds.load();
    expect(FavoriteStoreIds.ids.value, isEmpty);
    await FavoriteStoreIds.toggle('store_yoff');
    expect(FavoriteStoreIds.contains('store_yoff'), isTrue);
    expect((await SharedPreferences.getInstance()).getStringList(key), [
      'store_yoff',
    ]);
  }, skip: !DemoMode.enabled);
}

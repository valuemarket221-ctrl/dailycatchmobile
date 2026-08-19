import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteStoreIds {
  FavoriteStoreIds._();

  static const _key = 'dailycatch_favorite_store_ids';
  static const _defaultIds = {'1', '2', '4', '5'};

  static final ValueNotifier<Set<String>> ids = ValueNotifier<Set<String>>({
    ..._defaultIds,
  });

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    if (saved != null) {
      ids.value = saved.toSet();
    }
  }

  static Future<void> toggle(String storeId) async {
    await load();
    final next = {...ids.value};
    if (!next.remove(storeId)) {
      next.add(storeId);
    }
    ids.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, next.toList()..sort());
  }

  static bool contains(String storeId) => ids.value.contains(storeId);
}

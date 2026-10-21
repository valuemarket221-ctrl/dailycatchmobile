import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/api_environment.dart';
import 'package:myapp/demo/demo_mode.dart';

class FavoriteStoreIds {
  FavoriteStoreIds._();

  static const _key = 'dailycatch_favorite_store_ids';
  static const _defaultIds = {'1', '2', '4', '5'};
  static const _demoIds = {'store_yoff', 'store_ouakam'};

  static final ValueNotifier<Set<String>> ids = ValueNotifier<Set<String>>(
    DemoMode.enabled
        ? {..._demoIds}
        : ApiEnvironment.isDemoFallbackAllowed
        ? {..._defaultIds}
        : <String>{},
  );

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    if (saved != null) {
      final restored = saved.toSet();
      // Only migrate obsolete fixtures; an intentionally empty list stays empty.
      if (DemoMode.enabled && restored.any(_defaultIds.contains)) {
        restored.removeAll(_defaultIds);
        restored.addAll(_demoIds);
        await prefs.setStringList(_key, restored.toList()..sort());
      }
      ids.value = restored;
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

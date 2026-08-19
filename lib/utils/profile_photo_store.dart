import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoStore {
  ProfilePhotoStore._();

  static const _assetKey = 'dailycatch_profile_photo_asset';
  static const _bytesKey = 'dailycatch_profile_photo_bytes';
  static const photos = [
    'assets/icon/icon.png',
    'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
    'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
    'assets/images/logo.png',
  ];

  static final ValueNotifier<String> asset = ValueNotifier<String>(
    photos.first,
  );
  static final ValueNotifier<Uint8List?> bytes = ValueNotifier<Uint8List?>(
    null,
  );
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_bytesKey);
    if (encoded != null && encoded.isNotEmpty) {
      try {
        bytes.value = base64Decode(encoded);
        return;
      } catch (_) {
        await prefs.remove(_bytesKey);
      }
    }

    final saved = prefs.getString(_assetKey);
    if (saved != null && photos.contains(saved)) {
      asset.value = saved;
    }
  }

  static Future<void> saveBytes(Uint8List data) async {
    bytes.value = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bytesKey, base64Encode(data));
  }

  static Future<void> next() async {
    final currentIndex = photos.indexOf(asset.value);
    final nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % photos.length;
    bytes.value = null;
    asset.value = photos[nextIndex];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bytesKey);
    await prefs.setString(_assetKey, asset.value);
  }
}

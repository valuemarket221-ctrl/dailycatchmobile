import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/demo/demo_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthSession {
  static const _isLoggedInKey = 'isLoggedIn';
  static const _emailKey = 'userEmail';
  static const _nameKey = 'userName';
  static const _phoneKey = 'userPhone';
  static const _roleKey = 'userRole';
  static const _tokenKey = 'localAuthToken';
  static const _routeKey = 'homeRoute';

  static bool get isDevelopmentAuthAllowed => false;

  static bool isLocalEmail(String email) => false;

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async => null;

  static Future<void> saveBackendSession({
    required Map<String, dynamic> user,
    required String homeRoute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_emailKey, user['email']?.toString() ?? '');
    await prefs.setString(
      _nameKey,
      user['displayName']?.toString() ?? 'DailyCatch',
    );
    await prefs.setString(_roleKey, user['role']?.toString() ?? 'client');
    await prefs.setString(_routeKey, homeRoute);
    await prefs.remove(_tokenKey);
  }

  static Future<String?> getBearerToken() async {
    if (DemoMode.enabled) return null;
    try {
      final firebaseToken =
          await FirebaseAuth.instance.currentUser?.getIdToken();
      if (firebaseToken != null && firebaseToken.isNotEmpty) {
        return firebaseToken;
      }
    } on FirebaseException {
      if (!isDevelopmentAuthAllowed) rethrow;
    }

    return null;
  }

  static Future<String> displayName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString(_nameKey)?.trim();
    if (storedName != null && storedName.isNotEmpty) return storedName;
    try {
      final firebaseName = FirebaseAuth.instance.currentUser?.displayName;
      if (firebaseName != null && firebaseName.trim().isNotEmpty) {
        return firebaseName.trim();
      }
    } on FirebaseException {
      // A display label must not crash the screen when auth is unavailable.
    }
    return 'DailyCatch';
  }

  static Future<Map<String, String>> profileSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': await displayName(),
      'email': prefs.getString(_emailKey) ?? '',
      'phone': prefs.getString(_phoneKey) ?? '',
    };
  }

  static Future<void> updateProfileSnapshot({
    required String name,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_phoneKey, phone);
  }

  static Future<String> initialRoute() async {
    if (!isDevelopmentAuthAllowed) {
      try {
        if (FirebaseAuth.instance.currentUser == null) return '/login';
      } on FirebaseException {
        return '/login';
      }
    }

    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_isLoggedInKey) ?? false)) {
      return '/login';
    }

    final role = prefs.getString(_roleKey);
    final storedRoute = prefs.getString(_routeKey);
    if (storedRoute != null && storedRoute.isNotEmpty) return storedRoute;

    return switch (role) {
      'admin' => '/admin/dashboard',
      'partner' => '/partner/mobile-dashboard',
      'support' => '/admin/dashboard',
      _ => '/home',
    };
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_routeKey);
    if (DemoMode.enabled) return;
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseException {
      if (!isDevelopmentAuthAllowed) rethrow;
    }
  }

  static Future<String> registerDemo({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    throw UnsupportedError('Demo registration is disabled');
  }
}

class LocalAuthException implements Exception {
  const LocalAuthException(this.message);

  final String message;
}

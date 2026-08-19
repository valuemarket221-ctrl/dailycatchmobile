import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/utils/api_environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthSession {
  static const _isLoggedInKey = 'isLoggedIn';
  static const _emailKey = 'userEmail';
  static const _nameKey = 'userName';
  static const _roleKey = 'userRole';
  static const _tokenKey = 'localAuthToken';

  static const _accounts = {
    'client@dailycatch.local': _LocalAccount(
      role: 'client',
      name: 'Client Test DailyCatch',
      route: '/home',
      token: 'dailycatch_local_client_token_0123456789abcdef',
      aliases: ['client'],
    ),
    'vendeur@dailycatch.local': _LocalAccount(
      role: 'partner',
      name: 'Vendeur Test DailyCatch',
      route: '/partner/mobile-dashboard',
      token: 'dailycatch_local_partner_token_0123456789abcdef',
      aliases: ['vendeur', 'partner'],
    ),
    'support@dailycatch.local': _LocalAccount(
      role: 'support',
      name: 'Support Test DailyCatch',
      route: '/admin/dashboard',
      token: 'dailycatch_local_support_token_0123456789abcdef',
      aliases: ['support'],
    ),
    'admin@dailycatch.local': _LocalAccount(
      role: 'admin',
      name: 'Admin Test DailyCatch',
      route: '/admin/dashboard',
      token: 'dailycatch_local_admin_token_0123456789abcdef',
      aliases: ['admin'],
    ),
  };

  static bool get isDevelopmentAuthAllowed => !kReleaseMode;

  static bool isLocalEmail(String email) {
    if (!isDevelopmentAuthAllowed) return false;
    return _accounts.containsKey(email.trim().toLowerCase());
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (!isDevelopmentAuthAllowed) return null;

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    final account = _accounts[normalizedEmail];
    if (account == null) return null;

    final passwordMatches =
        normalizedPassword == account.token ||
        account.aliases.contains(normalizedPassword.toLowerCase());
    if (!passwordMatches) {
      throw const LocalAuthException('Email ou mot de passe local incorrect.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_emailKey, normalizedEmail);
    await prefs.setString(_nameKey, account.name);
    await prefs.setString(_roleKey, account.role);
    await prefs.setString(_tokenKey, account.token);

    return account.route;
  }

  static Future<String?> getBearerToken() async {
    final firebaseToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (firebaseToken != null && firebaseToken.isNotEmpty) {
      return firebaseToken;
    }

    if (!isDevelopmentAuthAllowed) return null;

    final prefs = await SharedPreferences.getInstance();
    final localToken = prefs.getString(_tokenKey);
    if (localToken != null && localToken.isNotEmpty) return localToken;

    if (ApiEnvironment.apiKey.isNotEmpty) {
      return ApiEnvironment.apiKey;
    }

    return null;
  }

  static Future<String> initialRoute() async {
    if (!isDevelopmentAuthAllowed &&
        FirebaseAuth.instance.currentUser == null) {
      return '/login';
    }

    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_isLoggedInKey) ?? false)) {
      return '/login';
    }

    final role = prefs.getString(_roleKey);
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
    await prefs.remove(_roleKey);
    await prefs.remove(_tokenKey);
    await FirebaseAuth.instance.signOut();
  }
}

class LocalAuthException implements Exception {
  const LocalAuthException(this.message);

  final String message;
}

class _LocalAccount {
  const _LocalAccount({
    required this.role,
    required this.name,
    required this.route,
    required this.token,
    required this.aliases,
  });

  final String role;
  final String name;
  final String route;
  final String token;
  final List<String> aliases;
}

import 'package:flutter/material.dart';

/// Provider pour gérer la langue de l'application
class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('fr', 'FR');

  Locale get locale => _locale;

  // Liste des langues supportées
  static const List<Map<String, dynamic>> supportedLanguages = [
    {'code': 'fr', 'name': 'Français', 'country': 'FR'},
    {'code': 'en', 'name': 'English', 'country': 'US'},
    {'code': 'de', 'name': 'Deutsch', 'country': 'DE'},
    {'code': 'es', 'name': 'Español', 'country': 'ES'},
  ];

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    final lang = supportedLanguages.firstWhere(
      (l) => l['code'] == languageCode,
      orElse: () => supportedLanguages[0],
    );
    _locale = Locale(lang['code'], lang['country']);
    notifyListeners();
  }

  String getCurrentLanguageName() {
    final lang = supportedLanguages.firstWhere(
      (l) => l['code'] == _locale.languageCode,
      orElse: () => supportedLanguages[0],
    );
    return lang['name'] as String;
  }
}

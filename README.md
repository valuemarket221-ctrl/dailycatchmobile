# DailyCatch - Application Flutter

## 📱 Description

DailyCatch est une application mobile Flutter clonant le concept de **Too Good To Go** (TGTG), spécialisée dans la lutte contre le gaspillage alimentaire des produits de la mer. L'application permet aux utilisateurs de sauver des produits alimentaires à prix réduits auprès de partenaires commerciaux.

### Caractéristiques principales :
- 🐟 Sauvegarde de produits de la mer
- 🗺️ Carte interactive des boutiques partenaires
- 🔍 Recherche de produits et boutiques
- ⭐ Système de favoris
- 📱 Réservation avec code QR
- 👤 Gestion de profil utilisateur
- 📊 Panneau d'administration

---

## 🏗️ Architecture du Projet

```
myapp/
├── android/              # Configuration Android
├── ios/                 # Configuration iOS
├── lib/                 # Code source Flutter
│   ├── config/          # Configuration de l'application
│   │   └── router/      # Routes de navigation (go_router)
│   ├── data/            # Repository et sources de données
│   ├── models/          # Modèles de données
│   ├── pages/           # Écrans de l'application
│   │   ├── Admin/       # Écrans d'administration
│   │   └── prototypes/  # Écrans en prototype
│   ├── src/             # Code source organisé par features
│   │   └── features/    # Fonctionnalités (auth, discovery, orders)
│   └── widgets/         # Composants réutilisables
├── assets/              # Ressources (images, icônes, polices)
└── web/                # Configuration web
```

---

## 🚀 Installation et Configuration

### Prérequis

- Flutter 3.7.0 ou supérieur
- Dart 3.0.0 ou supérieur
- Android SDK (pour Android)
- Xcode (pour iOS)

### Installation

```bash
# Cloner le projet
git clone <url-du-repo>
cd myapp

# Installer les dépendances
flutter pub get

# Générer les fichiers de configuration Android
flutter create .

# Lancer l'application
flutter run
```

### Build Android

```bash
# Build debug
flutter build apk --debug

# Build release
flutter build apk --release

# Build App Bundle (pour Play Store)
flutter build appbundle --release
```

### Build iOS

```bash
# Build pour simulateur
flutter build ios --debug

# Build pour production
flutter build ipa --release
```

---

## 📱 Écrans de l'Application

### Écrans d'authentification

| Route | Écran | Description |
|-------|-------|-------------|
| `/` | SplashPage | Écran de lancement avec animation |
| `/login` | LoginPage | Connexion utilisateur |
| `/register` | RegisterPage | Inscription utilisateur |
| `/forgot-password` | ForgotPasswordPage | Mot de passe oublié |

### Écrans principaux (Bottom Navigation)

| Route | Écran | Description |
|-------|-------|-------------|
| `/home` | HomePage | Découverte des boutiques |
| `/map` | MapPage | Carte des boutiques |
| `/search` | SearchPage | Recherche de produits |
| `/favorites` | FavoritePage | Boutiques favorites |
| `/pickup` | PickupPage | Réservations avec QR |
| `/profile` | ProfilePage | Profil utilisateur |

### Écrans de détail

| Route | Écran | Description |
|-------|-------|-------------|
| `/store/:id` | StoreDetailPage | Détails d'une boutique |
| `/cart` | CartPage | Panier d'achat |
| `/payment` | PaymentPage | Paiement |
| `/order-confirmation` | OrderConfirmationPage | Confirmation de commande |

### Écrans de paramètres

| Route | Écran | Description |
|-------|-------|-------------|
| `/settings` | SettingsPage | Paramètres généraux |
| `/edit-profile` | EditProfilePage | Modifier le profil |
| `/change-password` | ChangePasswordPage | Changer le mot de passe |
| `/addresses` | AddressesPage | Gérer les adresses |
| `/payment-methods` | PaymentMethodsPage | Moyens de paiement |
| `/notifications-settings` | NotificationsPage | Notifications |
| `/orders` | OrderHistoryPage | Historique des commandes |
| `/help` | HelpPage | Aide |
| `/legal` | LegalPage | Mentions légales |

### Écrans d'administration

| Route | Écran | Description |
|-------|-------|-------------|
| `/admin/dashboard` | AdminDashboardPage | Tableau de bord |
| `/admin/partners` | AdminPartnersPage | Liste des partenaires |
| `/admin/partners/new` | PartnerRegistrationPage | Nouveau partenaire |
| `/admin/partners/pending` | PartnerValidationPage | Validation partenaires |
| `/admin/partners/:id` | PartnerDetailPage | Détails partenaire |
| `/admin/clients` | AdminClientsPage | Liste des clients |
| `/admin/clients/:id` | ClientDetailPage | Détails client |

---

## 🎨 Design et Thème

### Couleurs principales

| Nom | Code | Usage |
|-----|------|-------|
| Blue Bic | `#054242` | Couleur principale de l'app |
| White | `#FFFFFF` | Fond et textes |
| Grey | Variable | Textes secondaires |

### Configuration du thème

Le thème est configuré dans [`lib/constants.dart`](lib/constants.dart:1) :

```dart
class AppColors {
  static const Color blueBic = Color(0xFF054242);
  static const Color white = Colors.white;
}
```

### Utilisation des polices

L'application utilise **Google Fonts - Poppins** :

```dart
Text(
  'Texte',
  style: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
)
```

---

## 🔧 Navigation avec go_router

### Configuration du routeur

Le routeur est configuré dans [`lib/config/router/app_router.dart`](lib/config/router/app_router.dart:1) :

```dart
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    // ... autres routes
  ],
);
```

### Navigation entre écrans

```dart
// Navigation simple (remplace la route actuelle)
context.go('/home');

// Navigation avec pile (bouton retour fonctionne)
context.push('/store/1');

// Navigation avec paramètres
context.push('/store/${store['id']}', extra: store);

// Retour à l'écran précédent
context.pop();
```

### Notes sur la navigation

- **Onglets principaux** (Home, Map, Search, Favorites, Pickup, Profile) : Navigation avec `go()` car ce sont des onglets indépendants
- **Écrans de détail** (Store, Cart, Payment) : Navigation avec `push()` pour conserver le bouton retour
- **Paramètres et profil** : Navigation avec `push()`

---

## 📦 Dépendances Principales

| Dépendance | Version | Usage |
|------------|---------|-------|
| `flutter` | SDK | Framework principal |
| `google_fonts` | ^6.2.1 | Polices Google |
| `go_router` | ^17.0.0 | Navigation |
| `firebase_core` | ^2.27.0 | Firebase |
| `firebase_auth` | ^4.17.0 | Authentification |
| `cloud_firestore` | ^4.14.0 | Base de données |
| `flutter_map` | ^6.1.0 | Cartes |
| `geolocator` | ^9.0.1 | Géolocalisation |
| `image_picker` | ^1.0.4 | Photos (profil) |
| `url_launcher` | ^6.0.10 | Liens externes |
| `flutter_rating_bar` | ^4.0.0 | Notation |
| `badges` | ^2.0.1 | Badges |

### Ajout d'une dépendance

```bash
flutter pub add <nom_du_package>
```

---

## 🖼️ Assets et Ressources

### Structure des assets

```
assets/
├── icon/           # Icônes de l'app
│   └── icon.png
├── icones/        # Autres icônes
└── images/        # Images des produits
    ├── crevette.jpg
    ├── homard.jpg
    ├── langoustines.jpg
    └── saumon.jpg
```

### Configuration dans pubspec.yaml

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icon/
    - assets/icones/
```

### Utilisation d'une image

```dart
Image.asset('assets/images/saumon.jpg')
```

---

## 🔐 Configuration Firebase

### Fichiers sensibles (NE PAS COMMITTER)

Ces fichiers doivent être configurés localement et ignorés par Git :

- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)
- `lib/firebase_options.dart` (généré automatiquement)

### Initialisation Firebase

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

---

## 🧪 Tests

### Lancer les tests

```bash
# Tous les tests
flutter test

# Tests avec couverture
flutter test --coverage

# Tests spécifiques
flutter test test/widget_test.dart
```

---

## 🐛 Débogage

### Logs de l'application

```dart
// Pour déboguer
print('Variable: $variable');

// Pour les erreurs
debugPrint('Erreur: $error');
```

### Outils de développement

- **Flutter DevTools** : Profiler et déboguer l'app
- **Dart DevTools** : Analyse des performances
- **Firebase Console** : Monitoring Firebase

---

## 📱 Configuration par Plateforme

### Android

**Version minimum** : API 21 (Android 5.0)

**Permissions** (AndroidManifest.xml) :
- `CAMERA` - Pour les photos de profil
- `READ_EXTERNAL_STORAGE` - Lecture des fichiers
- `READ_MEDIA_IMAGES` - Images sur Android 13+

**Configuration** :
- `android/app/build.gradle.kts` : Version SDK, dépendances
- `android/key.properties` : Clés de signature (NE PAS COMMITTER)

### iOS

**Version minimum** : iOS 12.0

**Configuration** :
- `ios/Runner/Info.plist` : Permissions
- `ios/Podfile` : Dépendances CocoaPods

---

## 🚀 Déploiement

### Android (Play Store)

1. Modifier la version dans `pubspec.yaml`
2. Build release :
   ```bash
   flutter build appbundle --release
   ```
3. Uploader le fichier `.aab` sur Play Store Console

### iOS (App Store)

1. Modifier la version dans `pubspec.yaml`
2. Build release :
   ```bash
   flutter build ipa --release
   ```
3. Uploader sur App Store Connect via Xcode ou Transporter

---

## 📝 Conventions de Code

### Structure des fichiers

```dart
// lib/pages/nom_page.dart
import 'package:flutter/material.dart';
import 'package:myapp/constants.dart';

/// Description de la page
class NomPage extends StatefulWidget {
  const NomPage({super.key});

  @override
  State<NomPage> createState() => _NomPageState();
}

class _NomPageState extends State<NomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
}
```

### Nommage

| Type | Convention | Exemple |
|------|------------|---------|
| Fichiers | snake_case | `login_page.dart` |
| Classes | PascalCase | `LoginPage` |
| Variables | camelCase | `isLoading` |
| Constantes | camelCase | `primaryColor` |

### Style de code

- Utiliser `GoogleFonts.poppins()` pour tous les textes
- Couleur principale : `AppColors.blueBic`
- Rayon des bordures : `BorderRadius.circular(12)`
- Espacement standard : `16.0`

---

## 📚 Ressources Utiles

### Documentation Flutter
- [Documentation officielle](https://docs.flutter.dev/)
- [Cookbook Flutter](https://docs.flutter.dev/cookbook)
- [API Reference](https://api.flutter.dev/)

### Packages
- [Pub.dev](https://pub.dev/) - Packages Dart/Flutter
- [FlutterFire](https://firebase.flutter.dev/) - Documentation Firebase

### Design
- [Material Design 3](https://m3.material.io/)
- [Too Good To Go](https://www.toogoodtogo.com/) - Référence de design

---

## 🤝 Contribution

1. Créer une branche pour les modifications
2. Suivre les conventions de code
3. Tester les modifications
4. Soumettre une Pull Request

---

## 📄 Licence

Ce projet est sous licence MIT.

---

## 👨‍💻 Développé avec ❤️ par DailyCatch Team

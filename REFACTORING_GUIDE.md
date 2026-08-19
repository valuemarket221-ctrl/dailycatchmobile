# Guide de Refactorisation DailyCatch

## 📋 Résumé des Modifications

Ce document récapitule la refactorisation complète du frontend DailyCatch pour améliorer la qualité du code, la maintenabilité et la performance.

---

## 🎨 1. Styles Centralisés

### Fichiers Créés
- **`lib/styles/text_styles.dart`** - Styles de texte réutilisables
- **`lib/styles/app_theme.dart`** - Thème global de l'application

### Avantages
✅ Une source unique de vérité pour les styles  
✅ Cohérence visuelle à travers l'app  
✅ Facile à maintenir et mettre à jour  
✅ Support du Material 3 moderno

### Utilisation
```dart
// Avant
Text('Titre', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold))

// Après
Text('Titre', style: AppTextStyles.headingM)
```

---

## 🧩 2. Composants Réutilisables

### Nouveaux Composants
1. **`StoreCard`** - Affiche une boutique avec ses détails
2. **`CategoryFilter`** - Filtrage par catégories
3. **`EcoBanner`** - Bannière écologique
4. **`ActionButton`** - Bouton d'action primaire/secondaire

### Bénéfices
✅ Code DRY (Don't Repeat Yourself)  
✅ Tests et maintenance simplifiés  
✅ Réutilisation across pages  
✅ Props typées et documentées

### Exemple
```dart
StoreCard(
  store: store,
  onTap: () => navigateToDetails(store.id),
)
```

---

## 🛡️ 3. Sécurité - Variables d'Environnement

### Changement Critique
**Firebase keys** sortis du code → `lib/utils/environment.dart`

### Avant
```dart
const firebaseOptions = FirebaseOptions(
  apiKey: "replace_me_firebase_api_key",  // ❌ Hardcodé !
  ...
);
```

### Après
```dart
final firebaseOptions = FirebaseOptions(
  apiKey: Environment.firebaseApiKey,  // ✅ Sécurisé
  ...
);
```

### Pour Déployer
```bash
flutter run \
  --dart-define=FIREBASE_API_KEY=your_key \
  --dart-define=FIREBASE_PROJECT_ID=your_project
```

---

## 📊 4. Modèles Métier

### `Store` Model (`lib/models/store_model.dart`)
Structure améliorée avec :
- Propriétés calculées (discountPercentage, hasLowStock)
- Factory methods (fromJson, toJson)
- Copy constructor pour immuabilité

```dart
Store(
  id: '1',
  name: 'DailyCatch',
  category: 'Poissonnerie',
  discountPercentage: 67,  // Auto calculé
  hasLowStock: true,        // Auto calculé
)
```

---

## 🎯 5. Utilitaires Métier

### `StoreUtils` - Filtrage & Tri
```dart
// Filtrer par catégorie
var filtered = StoreUtils.filterByCategory(stores, 'Poisson');

// Trier
var sorted = StoreUtils.sortByDistance(stores);
var sorted = StoreUtils.sortByDiscount(stores);
var sorted = StoreUtils.sortByRating(stores);
```

### `Validators` - Validation de Formulaires
```dart
Validators.validateEmail('user@email.com');
Validators.validatePassword('12345678');
Validators.validatePhone('+33612345678');
```

### `Formatters` - Formatage de Données
```dart
AppFormatters.formatPrice(19.99);          // "19.99€"
AppFormatters.formatDiscount(67);          // "-67%"
AppFormatters.formatDistance(2.5);         // "2.5 km"
AppFormatters.formatDateRelative(date);    // "Il y a 2h"
```

---

## 🔄 6. Providers Améliorés

### `CartProvider`
- Gestion du panier avec ChangeNotifier
- Ajouter/supprimer/modifier articles
- Calculs automatiques (total, économies)

### `StoreProvider` (Nouveau)
- Filtrage avancé par catégorie
- Tri multiples (distance, remise, note)
- Recherche temps réel
- Gestion des favoris

```dart
Consumer<StoreProvider>(
  builder: (context, storeProvider, _) {
    storeProvider.setCategory('Poisson');
    storeProvider.setSortBy('discount');
    return ListView(
      children: storeProvider.filteredStores.map(...).toList()
    );
  }
)
```

---

## 🎨 7. Pages Refactorisées

### HomePage
- ✅ Utilise `StoreCard` au lieu de build inline
- ✅ `CategoryFilter` réutilisable
- ✅ `EcoBanner` composant séparé
- ✅ Logique de filtrage dans `StoreUtils`
- ✅ Styles via `AppTextStyles` & `AppTheme`
- ✅ Code réduit de ~400 à ~300 lignes

### LoginPage
- ✅ `ActionButton` pour les boutons
- ✅ Styles centralisés
- ✅ Error handling amélioré
- ✅ Try-catch pour les opérations async

---

## 📁 Structure Finale

```
lib/
├── models/
│   ├── store_model.dart       # Modèle Store amélioré
│   ├── rescued_product.dart
│   └── store.dart
├── providers/
│   ├── cart_provider.dart
│   ├── store_provider.dart    # Nouveau
│   ├── locale_provider.dart
│   └── auth_provider.dart
├── widgets/
│   ├── store_card.dart        # Nouveau
│   ├── category_filter.dart   # Nouveau
│   ├── eco_banner.dart        # Nouveau
│   ├── action_button.dart     # Nouveau
│   ├── bottom_nav_bar.dart    # Refactorisé
│   └── ...
├── styles/
│   ├── text_styles.dart       # Nouveau
│   ├── app_theme.dart         # Nouveau
│   └── ...
├── utils/
│   ├── environment.dart       # Nouveau
│   ├── store_utils.dart       # Nouveau
│   ├── validators.dart        # Nouveau
│   ├── formatters.dart        # Nouveau
│   └── ...
├── pages/
│   ├── home_page.dart         # Refactorisé
│   ├── login_page.dart        # Refactorisé
│   ├── ...
├── constants.dart
├── main.dart                  # Refactorisé
└── ...
```

---

## ✅ Checklist de Refactorisation

- [x] Styles centralisés créés
- [x] Composants réutilisables extraits
- [x] Sécurité Firebase améliorée
- [x] Modèles métier enrichis
- [x] Utilitaires métier créés
- [x] Providers améliorés
- [x] HomePage refactorisée
- [x] LoginPage refactorisée
- [ ] CartPage refactorisée
- [ ] Autres pages refactorisées (en priorité)
- [ ] Tests unitaires ajoutés
- [ ] Tests d'intégration ajoutés

---

## 🚀 Prochaines Étapes

### Phase 1 - Critique
1. Refactoriser les pages restantes (ProfilePage, SettingsPage, etc.)
2. Ajouter error handling complet
3. Implémenter les validations de formulaires

### Phase 2 - Important
1. Ajouter les tests unitaires
2. Optimiser les performances (lazy loading)
3. Implémenter la pagination

### Phase 3 - Nice-to-have
1. Ajouter des animations
2. Implémenter offline support
3. Ajouter des widgets avancés

---

## 📚 Ressources

- [Flutter Style Guide](https://dart.dev/guides/language/analysis-options)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/testing)

---

## 📝 Notes

- Tous les nouveaux fichiers respectent les conventions Dart
- Utilisez les `AppTextStyles` au lieu de `GoogleFonts` direct
- Utilisez les constantes `AppTheme` pour spacing, border radius, etc.
- Importez les utilitaires pour la validation et le formatage
- Loggez les erreurs avec `debugPrint` pour le débogage

---

**Dernière mise à jour**: 16 Avril 2026

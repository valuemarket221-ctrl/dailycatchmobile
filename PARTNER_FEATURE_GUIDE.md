# 📦 Guide Complet - Système Client & Vendeur

## 🎯 Vue d'ensemble

Le système DailyCatch supporte maintenant deux types d'utilisateurs :
1. **Clients** - Qui achètent des produits à prix réduits
2. **Vendeurs/Partenaires** - Qui vendent leurs produits avec des réductions

---

## 📋 Architecture

### Flow d'inscription

```
Accueil
  ↓
Cliquer "S'inscrire"
  ↓
Page Sélection Rôle (/role-selection)
  ├─ Je suis un Client → Register Client (/register-client)
  └─ Je suis un Vendeur → Register Partner (/register-partner)
```

---

## 👥 Types d'Utilisateurs

### 1. Client

**Route**: `/register-client`  
**Page**: `RegisterClientPage`

**Informations collectées**:
- Nom complet
- Email
- Téléphone
- Mot de passe

**Après inscription**: Accès au `/home` pour acheter des produits

**Pages accessibles**:
- Home (catalogue)
- Map (voir les boutiques)
- Search
- Favorites
- Cart
- Profile
- Orders history

---

### 2. Vendeur/Partenaire

**Route**: `/register-partner`  
**Page**: `RegisterPartnerPage` (formulaire multi-étapes)

**Étape 1 - Informations personnelles**:
- Nom complet
- Téléphone personnel
- Email
- Mot de passe

**Étape 2 - Informations de boutique**:
- Nom de la boutique
- Catégorie (Poissonnerie, Restaurant, etc.)
- Description
- Adresse
- Ville
- Téléphone de la boutique

**Étape 3 - Informations commerciales**:
- Numéro SIRET
- Numéro de TVA
- IBAN (compte bancaire)
- Site web (optionnel)

**Après inscription**: Accès au `/partner-dashboard`

---

## 🏪 Dashboard Partenaire

**Route**: `/partner-dashboard`  
**Page**: `PartnerDashboardPage`

### Sections

#### 1. Tableau de bord (Statistiques)
- Nombre de produits (12)
- Nombre d'offres (3)
- Nombre de commandes (24)
- Revenus totaux (1,240€)

#### 2. Actions principales
- **Ajouter un produit** → `/partner/add-product`
- **Créer une offre spéciale** → `/partner/add-pack`

#### 3. Gestion (Grid 2x3)
- **Produits** - Voir/gérer les produits → `/partner/products`
- **Offres** - Voir/gérer les offres → `/partner/packs`
- **Stock** - Gérer l'inventaire → `/partner/inventory`
- **Commandes** - Voir les commandes → `/partner/orders`
- **Horaires** - Éditer les horaires → `/partner/schedules`
- **Statistiques** - Analytics détaillées → `/partner/analytics`

---

## 🛍️ Gestion des Produits

### Ajouter un produit

**Route**: `/partner/add-product`  
**Page**: `AddProductPage`

**Formulaire**:
```
Informations du produit
├─ Nom du produit
├─ Description
└─ Catégorie

Tarification
├─ Prix original (€)
└─ Prix réduit (€)

Inventaire
├─ Quantité disponible
├─ Date d'expiration
└─ Allergènes (checkboxes)
```

**Allergens disponibles**:
- Arachides, Noix, Lait, Œufs
- Poisson, Gluten, Soja, Sésame

**Validation**:
- ✅ Tous les champs requis
- ✅ Prix réduit < Prix original
- ✅ Quantité > 0

---

### Liste des produits

**Route**: `/partner/products`  
**Page**: `ProductsListPage`

**Affichage**:
- Image (placeholder)
- Nom + Catégorie
- Prix original (barré)
- Prix réduit + Remise %
- Stock actuel
- Boutons: Edit | Delete

**Actions**:
- Ajouter un nouveau (+)
- Éditer un produit
- Supprimer un produit

---

## 🎁 Gestion des Offres/Packs

### Créer une offre

**Route**: `/partner/add-pack`  
**Page**: `AddPackPage`

**Formulaire**:
```
Informations de l'offre
├─ Nom de l'offre
└─ Description

Tarification
├─ Prix original (€)
└─ Prix réduit (€)

Quantité
├─ Nombre d'offres disponibles
├─ Temps de retrait estimé (min)
└─ Date d'expiration

Produits inclus
└─ Multi-select des produits
    (Checkboxes)
```

**Exemple d'offre**:
- Nom: "Pack Fruits de mer"
- Prix: 39.99€ → 19.99€
- Produits: Saumon + Crevettes + Homard + Moules
- Quantité: 3
- Retrait: 30 min

---

### Liste des offres

**Route**: `/partner/packs`  
**Page**: `PacksListPage`

**Affichage**:
- Icône (card giftcard)
- Nom + Nombre de produits
- Prix original (barré)
- Prix réduit + Remise %
- Stock actuel
- Boutons: Edit | Delete

**Actions**:
- Créer une nouvelle offre (+)
- Éditer une offre
- Supprimer une offre

---

## 📊 Modèles de Données

### Product Model

```dart
class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String category;
  final double originalPrice;
  final double discountedPrice;
  final String image;
  final int availableQuantity;
  final int totalQuantity;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final bool isActive;
  final List<String> allergens;
  
  // Computed
  int get discountPercentage { ... }
  bool get isExpiringSoon { ... }
  bool get isExpired { ... }
  bool get isLowStock { ... }
  bool get isSoldOut { ... }
}
```

### Pack Model

```dart
class Pack {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final String image;
  final List<String> productIds;
  final int availableQuantity;
  final int totalQuantity;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final bool isActive;
  final int estimatedPickupTime; // minutes
  
  // Computed
  int get discountPercentage { ... }
  double get savings { ... }
  bool get isLowStock { ... }
}
```

### StoreRegistration Model

```dart
class StoreRegistration {
  final String id;
  final String userId;
  final String storeName;
  final String storeCategory;
  // ... 15+ autres champs
}
```

---

## 🔄 Routes Partenaire

| Route | Page | Description |
|-------|------|-------------|
| `/register-partner` | RegisterPartnerPage | Inscription vendeur (3 étapes) |
| `/partner-dashboard` | PartnerDashboardPage | Tableau de bord principal |
| `/partner/add-product` | AddProductPage | Ajouter un produit |
| `/partner/add-pack` | AddPackPage | Créer une offre |
| `/partner/products` | ProductsListPage | Liste des produits |
| `/partner/packs` | PacksListPage | Liste des offres |
| `/partner/inventory` | Placeholder | Gestion du stock |
| `/partner/orders` | Placeholder | Commandes reçues |
| `/partner/schedules` | Placeholder | Horaires d'ouverture |
| `/partner/analytics` | Placeholder | Statistiques détaillées |

---

## 🔐 Sécurité & Validation

### Validateurs utilisés

- `validateEmail()` - Format email valide
- `validatePassword()` - Minimum 6 caractères
- `validatePhone()` - Format numéro de téléphone
- `validateName()` - Minimum 2 caractères
- `validateRequired()` - Champ obligatoire

### Données persistantes

```dart
// SharedPreferences stocke:
prefs.setBool('isLoggedIn', true);
prefs.setString('userType', 'partner'); // ou 'client'
prefs.setString('userName', name);
prefs.setString('userEmail', email);
prefs.setString('storeId', storeId); // pour partenaires
```

---

## 📱 UI Components Utilisés

### Composants Réutilisables
- `ActionButton` - Boutons primaires/secondaires
- `TextFormField` - Avec InputDecorationTheme
- `AppTextStyles` - Styles de texte centralisés
- `AppTheme` - Couleurs, spacings, shadows

### Patterns
- Multi-step form avec progress indicator
- Grid layout pour dashboard
- Card-based UI pour listes
- Mock data pour démos

---

## ✅ Checklist d'Implémentation Complète

- [x] Page de sélection de rôle
- [x] Inscription client (simple)
- [x] Inscription partenaire (3 étapes)
- [x] Dashboard partenaire (statistiques)
- [x] Ajouter produits (formulaire complet)
- [x] Ajouter offres/packs (multi-select)
- [x] Liste produits (avec actions)
- [x] Liste offres (avec actions)
- [x] Modèles Product & Pack
- [x] Modèle StoreRegistration
- [x] Routes et navigation
- [x] Utilisation AppTextStyles & AppTheme
- [ ] Intégration Firebase (NEXT)
- [ ] Edit produits/offres (NEXT)
- [ ] Gestion du stock (NEXT)
- [ ] Commandes et notifications (NEXT)
- [ ] Analytics détaillées (NEXT)
- [ ] Horaires d'ouverture (NEXT)

---

## 🚀 Prochaines Étapes

### Phase 1 - Important
1. Intégrer avec Firebase Firestore
2. Implémenter Edit pour produits/offres
3. Ajouter image picker pour produits
4. Ajouter suppression avec confirmation

### Phase 2 - Essential
1. Page gestion du stock (inventory)
2. Page commandes reçues (orders)
3. Notifications en temps réel
4. Analytics détaillées

### Phase 3 - Polish
1. Horaires d'ouverture
2. Messages clients
3. Statistiques avancées
4. Paramètres partenaire

---

## 📚 Fichiers Clés

**Modèles**:
- `lib/models/product_model.dart`
- `lib/models/pack_model.dart`
- `lib/models/store_registration_model.dart`

**Pages Partenaire**:
- `lib/pages/role_selection_page.dart`
- `lib/pages/register_partner_page.dart`
- `lib/pages/partner_dashboard_page.dart`
- `lib/pages/partner/add_product_page.dart`
- `lib/pages/partner/add_pack_page.dart`
- `lib/pages/partner/products_list_page.dart`
- `lib/pages/partner/packs_list_page.dart`

**Configuration**:
- `lib/config/router/app_router.dart` (routes)

---

**Status**: ✅ Implémentation Complète (Phase 1)  
**Date**: 16 Avril 2026

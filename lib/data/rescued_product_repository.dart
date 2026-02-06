import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/models/rescued_product.dart';

/// Repository pour gérer les opérations sur les produits "sauvés"
/// Couche d'abstraction entre l'application et Firebase Firestore
class RescuedProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'rescued_products';

  /// Collection reference
  CollectionReference get _collection => _firestore.collection(collectionName);

  /// Récupère tous les produits "sauvés" disponibles
  Future<List<RescuedProduct>> getAvailableProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await _collection
              .where('availableQuantity', isGreaterThan: 0)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        return RescuedProduct.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }

  /// Récupère les produits par catégorie
  Future<List<RescuedProduct>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot =
          await _collection
              .where('category', isEqualTo: category)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        return RescuedProduct.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des produits par catégorie: $e');
      return [];
    }
  }

  /// Récupère les produits proches d'une position
  Future<List<RescuedProduct>> getNearbyProducts(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // Note: Pour une vraie implémentation, utilisez GeoFirestore
      // Cette méthode retourne tous les produits avec tri par distance
      QuerySnapshot querySnapshot =
          await _collection.orderBy('createdAt', descending: true).get();

      List<RescuedProduct> products =
          querySnapshot.docs.map((doc) {
            return RescuedProduct.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

      // Filtrage par distance (simplifié)
      return products.where((product) {
        return product.distance <= radiusKm;
      }).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des produits proches: $e');
      return [];
    }
  }

  /// Récupère un produit par son ID
  Future<RescuedProduct?> getProductById(String id) async {
    try {
      DocumentSnapshot doc = await _collection.doc(id).get();
      if (doc.exists) {
        return RescuedProduct.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du produit: $e');
      return null;
    }
  }

  /// Crée un nouveau produit "sauvé"
  Future<String> createProduct(RescuedProduct product) async {
    try {
      DocumentReference docRef = await _collection.add(product.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Erreur lors de la création du produit: $e');
      throw Exception('Échec de la création du produit');
    }
  }

  /// Réserve un produit (décrémente la quantité disponible)
  Future<bool> reserveProduct(String productId) async {
    try {
      DocumentReference docRef = _collection.doc(productId);
      return _firestore
          .runTransaction((transaction) async {
            DocumentSnapshot snapshot = await transaction.get(docRef);
            if (!snapshot.exists) {
              throw Exception('Produit non trouvé');
            }
            Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
            int reservedQuantity = (data['reservedQuantity'] ?? 0) + 1;
            int availableQuantity = data['availableQuantity'] ?? 0;
            if (reservedQuantity > availableQuantity) {
              throw Exception('Plus de produits disponibles');
            }
            transaction.update(docRef, {'reservedQuantity': reservedQuantity});
            return true;
          })
          .then((value) => true, onError: (e) => false);
    } catch (e) {
      debugPrint('Erreur lors de la réservation du produit: $e');
      return false;
    }
  }

  /// Met à jour un produit existant
  Future<void> updateProduct(RescuedProduct product) async {
    try {
      await _collection.doc(product.id).update(product.toMap());
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du produit: $e');
      throw Exception('Échec de la mise à jour du produit');
    }
  }

  /// Supprime un produit
  Future<void> deleteProduct(String productId) async {
    try {
      await _collection.doc(productId).delete();
    } catch (e) {
      debugPrint('Erreur lors de la suppression du produit: $e');
      throw Exception('Échec de la suppression du produit');
    }
  }

  /// Recherche des produits par nom
  Future<List<RescuedProduct>> searchProducts(String query) async {
    try {
      QuerySnapshot querySnapshot =
          await _collection
              .where('name', isGreaterThanOrEqualTo: query)
              .where('name', isLessThanOrEqualTo: '${query}\uf8ff')
              .get();

      return querySnapshot.docs.map((doc) {
        return RescuedProduct.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Erreur lors de la recherche des produits: $e');
      return [];
    }
  }

  /// produits fictifs pour le développement et les tests
  static List<RescuedProduct> getMockProducts() {
    final now = DateTime.now();
    return [
      RescuedProduct(
        id: '1',
        name: 'Sacs de crevettes grises',
        description:
            'Sacs de 500g de crevettes grises fraiches, à récupérer aujourd\'hui avant 18h. Provenance: Côtes sénégalaises.',
        imageUrl: 'assets/images/crevette.jpg',
        originalPrice: 12.00,
        discountedPrice: 4.50,
        availableQuantity: 10,
        reservedQuantity: 3,
        partnerId: 'p1',
        partnerName: 'Poissonnerie du Port',
        partnerAddress: '15 Rue du Port, Dakar',
        pickupStartTime: now.subtract(const Duration(hours: 2)),
        pickupEndTime: now.add(const Duration(hours: 6)),
        createdAt: now.subtract(const Duration(days: 1)),
        category: 'Crustacés',
        distance: 0.8,
      ),
      RescuedProduct(
        id: '2',
        name: 'Plateau d\'huîtres n°3',
        description:
            'Douze huîtres n°3 du Bélon, servies dans leur coquille. À récupérer impérativement aujourd\'hui.',
        imageUrl: 'assets/images/crevette.jpg',
        originalPrice: 18.00,
        discountedPrice: 7.50,
        availableQuantity: 5,
        reservedQuantity: 1,
        partnerId: 'p2',
        partnerName: 'Coquillages & Crustacés',
        partnerAddress: '28 Avenue de la Plage, Dakar',
        pickupStartTime: now.subtract(const Duration(hours: 4)),
        pickupEndTime: now.add(const Duration(hours: 4)),
        createdAt: now.subtract(const Duration(days: 1)),
        category: 'Fruits de mer',
        distance: 1.2,
      ),
      RescuedProduct(
        id: '3',
        name: 'Filets de maquereau frais',
        description:
            'Trois filets de maquereau de 200g chacun, péchés ce matin. À consommer rapidement.',
        imageUrl: 'assets/images/saumon.jpg',
        originalPrice: 9.00,
        discountedPrice: 3.50,
        availableQuantity: 8,
        reservedQuantity: 2,
        partnerId: 'p3',
        partnerName: 'Halte Maritime',
        partnerAddress: '42 Quai des Pêcheurs, Dakar',
        pickupStartTime: now.subtract(const Duration(hours: 6)),
        pickupEndTime: now.add(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
        category: 'Poissons',
        distance: 2.0,
      ),
      RescuedProduct(
        id: '4',
        name: 'Sashimi thon rouge',
        description:
            '200g de thon rouge pour sashimi, qualité restaurant. À récupérer aujourd\'hui.',
        imageUrl: 'assets/images/saumon.jpg',
        originalPrice: 25.00,
        discountedPrice: 10.00,
        availableQuantity: 3,
        reservedQuantity: 0,
        partnerId: 'p4',
        partnerName: 'Sushi Master',
        partnerAddress: '105 Rue du Commerce, Dakar',
        pickupStartTime: now.subtract(const Duration(hours: 1)),
        pickupEndTime: now.add(const Duration(hours: 5)),
        createdAt: now.subtract(const Duration(days: 1)),
        category: 'Poissons',
        distance: 0.5,
      ),
      RescuedProduct(
        id: '5',
        name: 'Bisque de homard',
        description:
            'Deux litres de bisque de homard fait maison, à réchauffer. Date limite: aujourd\'hui.',
        imageUrl: 'assets/images/homard.jpg',
        originalPrice: 30.00,
        discountedPrice: 12.00,
        availableQuantity: 4,
        reservedQuantity: 1,
        partnerId: 'p5',
        partnerName: 'Le Grand Bleu',
        partnerAddress: '88 Boulevard Océan, Dakar',
        pickupStartTime: now.subtract(const Duration(hours: 3)),
        pickupEndTime: now.add(const Duration(hours: 7)),
        createdAt: now.subtract(const Duration(days: 1)),
        category: 'Fruits de mer',
        distance: 1.5,
      ),
      RescuedProduct(
        id: '6',
        name: 'Langoustines crues',
        description:
            '500g de langoustines crues, calibre 20/30. À cooker ce soir!',
        imageUrl: 'assets/images/langoustines.jpg',
        originalPrice: 22.00,
        discountedPrice: 8.50,
        availableQuantity: 6,
        reservedQuantity: 4,
        partnerId: 'p1',
        partnerName: 'Poissonnerie du Port',
        partnerAddress: '15 Rue du Port, Dakar',
        pickupStartTime: now.subtract(const Duration(hours: 5)),
        pickupEndTime: now.add(const Duration(hours: 3)),
        createdAt: now.subtract(const Duration(days: 1)),
        category: 'Crustacés',
        distance: 0.8,
      ),
    ];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/models/store.dart';

/// Repository pour les boutiques partenaires
/// Essaie Firestore en premier, sinon utilise les données mock
class StoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'stores';

  /// Stream temps-réel des boutiques depuis Firestore
  Stream<List<Store>> storesStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return Store.getMockStores();
      return snapshot.docs.map((doc) => Store.fromFirestore(doc)).toList();
    }).handleError((e) {
      debugPrint('StoreRepository error: $e');
      return Store.getMockStores();
    });
  }

  /// Récupère une boutique par son ID
  Future<Store?> getStore(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) return Store.fromFirestore(doc);
      // Fallback mock
      return Store.getMockStores().where((s) => s.id == id).firstOrNull;
    } catch (e) {
      debugPrint('getStore error: $e');
      return Store.getMockStores().where((s) => s.id == id).firstOrNull;
    }
  }

  /// Récupère les boutiques par catégorie
  Future<List<Store>> getByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      if (snapshot.docs.isEmpty) {
        return Store.getMockStores()
            .where((s) => s.category == category)
            .toList();
      }
      return snapshot.docs.map((doc) => Store.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('getByCategory error: $e');
      return Store.getMockStores()
          .where((s) => s.category == category)
          .toList();
    }
  }
}

import 'package:myapp/models/rescued_product.dart';
import 'package:myapp/services/product_offer_api_service.dart';

/// Repository pour gérer les opérations sur les produits "sauvés"
/// Couche d'abstraction entre l'application et l'API backend.
class RescuedProductRepository {
  RescuedProductRepository({
    ProductOfferApiService? productOfferApiService,
    bool? demoFallbackAllowed,
  }) : _productOfferApiService =
           productOfferApiService ?? ProductOfferApiService();

  final ProductOfferApiService _productOfferApiService;

  /// Récupère tous les produits "sauvés" disponibles
  Future<List<RescuedProduct>> getAvailableProducts() async {
    final apiProducts = await _getApiProducts();
    return apiProducts;
  }

  /// Récupère les produits par catégorie
  Future<List<RescuedProduct>> getProductsByCategory(String category) async {
    final products = await getAvailableProducts();
    return products.where((product) => product.category == category).toList();
  }

  /// Récupère les produits proches d'une position
  Future<List<RescuedProduct>> getNearbyProducts(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final apiProducts = await _getApiProducts(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
    return apiProducts;
  }

  /// Récupère un produit par son ID
  Future<RescuedProduct?> getProductById(String id) async {
    final apiProducts = await _getApiProducts();
    for (final product in apiProducts) {
      if (product.id == id) return product;
    }
    return null;
  }

  /// Les créations de paniers passent par l'espace vendeur et PartnerApiService.
  Future<String> createProduct(RescuedProduct product) async {
    throw UnsupportedError('createProduct must use PartnerApiService');
  }

  /// Les réservations passent par CheckoutService/PaymentApiService.
  Future<bool> reserveProduct(String productId) async {
    throw UnsupportedError('reserveProduct must use CheckoutService');
  }

  /// Les mises à jour de paniers passent par PartnerApiService.
  Future<void> updateProduct(RescuedProduct product) async {
    throw UnsupportedError('updateProduct must use PartnerApiService');
  }

  /// Les suppressions de paniers passent par PartnerApiService.
  Future<void> deleteProduct(String productId) async {
    throw UnsupportedError('deleteProduct must use PartnerApiService');
  }

  /// Recherche des produits par nom
  Future<List<RescuedProduct>> searchProducts(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    final products = await getAvailableProducts();
    return products.where((product) {
      return product.name.toLowerCase().contains(normalizedQuery) ||
          product.partnerName.toLowerCase().contains(normalizedQuery) ||
          product.category.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  Future<List<RescuedProduct>> _getApiProducts({
    double? latitude,
    double? longitude,
    double radiusKm = 25,
  }) async {
    final offers = await _productOfferApiService.getProductOffers(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
    return offers
        .where((offer) => offer.availableQuantity > 0)
        .map(RescuedProduct.fromOffer)
        .toList();
  }
}

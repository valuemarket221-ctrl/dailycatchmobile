import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/providers/partner_provider.dart';
import 'package:myapp/services/partner_api_service.dart';

class PartnerInventoryPage extends StatefulWidget {
  const PartnerInventoryPage({super.key});

  @override
  State<PartnerInventoryPage> createState() => _PartnerInventoryPageState();
}

class _PartnerInventoryPageState extends State<PartnerInventoryPage> {
  static const _storeId = 'store_port';
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  List<Product>? _apiProducts;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    try {
      final offers = await _partnerApiService.getStoreOffers(_storeId);
      if (!mounted) return;
      setState(() {
        _apiProducts = offers.map(_productFromApi).toList();
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiProducts = null;
        _loadError = 'Backend indisponible: stock de démonstration';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PartnerProvider>(
      builder: (context, provider, child) {
        final products = _apiProducts ?? provider.products;
        return Material(
          color: AppTheme.mutedSurface,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Disponibilités paniers',
                        style: AppTextStyles.headingM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildStats(products),
                      if (_loadError != null) ...[
                        const SizedBox(height: 12),
                        _buildWarningBanner(_loadError!),
                      ],
                      const SizedBox(height: 24),
                      _buildInventoryTable(context, products),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats(List<Product> products) {
    final lowStock =
        products.where((p) => p.quantity > 0 && p.quantity <= 5).length;
    final outOfStock = products.where((p) => p.quantity == 0).length;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Paniers publiés',
            _isLoading ? '...' : '${products.length}',
            Icons.inventory_2,
            const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            'Presque épuisés',
            _isLoading ? '...' : '$lowStock',
            Icons.warning_amber,
            const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            'Rupture',
            _isLoading ? '...' : '$outOfStock',
            Icons.error_outline,
            const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTextStyles.bodyS)),
          TextButton(onPressed: _loadInventory, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.headingM.copyWith(color: color)),
              Text(
                title,
                style: AppTextStyles.bodyS.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStockDialog(BuildContext context, Product product) {
    final qtyController = TextEditingController(
      text: product.quantity.toString(),
    );

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Modifier les paniers: ${product.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyController,
                  decoration: const InputDecoration(
                    labelText: 'Paniers disponibles',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Color(0xFFEF4444),
                        size: 32,
                      ),
                      onPressed: () {
                        int current = int.tryParse(qtyController.text) ?? 0;
                        if (current > 0) {
                          qtyController.text = (current - 1).toString();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF10B981),
                        size: 32,
                      ),
                      onPressed: () {
                        int current = int.tryParse(qtyController.text) ?? 0;
                        qtyController.text = (current + 1).toString();
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                ),
                onPressed: () {
                  final newQty = int.tryParse(qtyController.text) ?? 0;
                  context.read<PartnerProvider>().updateStock(
                    product.id,
                    newQty,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Disponibilité mise à jour!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );
  }

  Widget _buildInventoryTable(BuildContext context, List<Product> inventory) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mutedSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Panier',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'SKU',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Disponibles',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Seuil alerte',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Statut',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (inventory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                _isLoading
                    ? 'Chargement des disponibilités...'
                    : 'Aucun panier disponible',
              ),
            )
          else
            ...inventory.map((item) => _buildRow(context, item)),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, Product item) {
    Color statusColor;
    String status;
    if (item.quantity == 0) {
      statusColor = const Color(0xFFEF4444);
      status = 'Rupture';
    } else if (item.quantity <= 5) {
      statusColor = const Color(0xFFF59E0B);
      status = 'Presque épuisé';
    } else {
      statusColor = const Color(0xFF10B981);
      status = 'Disponible';
    }

    final skuSuffix =
        item.id.length <= 4
            ? item.id.toUpperCase()
            : item.id.substring(0, 4).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: AppTheme.softBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.name,
              style: AppTextStyles.bodyM,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              'SKU-$skuSuffix',
              style: AppTextStyles.bodyS.copyWith(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showStockDialog(context, item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${item.quantity}', style: AppTextStyles.bodyM),
                    const Icon(Icons.edit, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: Text('5', style: AppTextStyles.bodyM)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: AppTextStyles.bodyS.copyWith(color: statusColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Product _productFromApi(Map<String, dynamic> offer) {
    final unitAmount = ((offer['unit_amount'] as num?)?.toDouble() ?? 0);
    final originalAmount =
        ((offer['original_unit_amount'] as num?)?.toDouble() ?? 0);
    return Product(
      id: offer['id'] as String? ?? '',
      name: offer['name'] as String? ?? 'Panier surprise',
      description: offer['description'] as String? ?? '',
      originalPrice: originalAmount > 0 ? originalAmount : unitAmount,
      discountedPrice: unitAmount,
      quantity: (offer['available_quantity'] as num?)?.toInt() ?? 0,
      expiryDate: DateTime.tryParse(offer['pickup_ends_at'] as String? ?? ''),
    );
  }
}

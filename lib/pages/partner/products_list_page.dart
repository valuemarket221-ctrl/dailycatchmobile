import 'package:flutter/material.dart';
import 'package:myapp/services/partner_api_service.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/utils/api_environment.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  static const _fallbackStoreContext = PartnerStoreContext(
    storeId: 'store_port',
    storeName: 'Poissonnerie du Port',
    latitude: 14.6928,
    longitude: -17.4467,
  );

  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _offers = const [];
  PartnerStoreContext? _storeContext;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final storeContext = await _resolveStoreContext();
      final offers = await _partnerApiService.getStoreOffers(
        storeContext.storeId,
      );
      if (!mounted) return;
      setState(() {
        _storeContext = storeContext;
        _offers = offers;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offers =
            ApiEnvironment.isDemoFallbackAllowed
                ? _fallbackOffers
                : const <Map<String, dynamic>>[];
        _loadError =
            ApiEnvironment.isDemoFallbackAllowed
                ? 'Mode démonstration: connexion backend indisponible'
                : 'Paniers vendeur indisponibles.';
        _isLoading = false;
      });
    }
  }

  Future<PartnerStoreContext> _resolveStoreContext() async {
    final storeContext = await _partnerApiService.getMyStoreContext();
    if (storeContext != null) return storeContext;
    if (ApiEnvironment.isDemoFallbackAllowed) return _fallbackStoreContext;
    throw const PartnerApiException(
      statusCode: 404,
      message: 'partner_profile_missing',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.mutedSurface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Gestion des paniers vendeur',
                    style: AppTextStyles.headingM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _showAddOfferDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Publier un panier'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.reef,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResponsibilityBanner(),
                  if (_loadError != null) ...[
                    const SizedBox(height: 16),
                    _buildWarningBanner(_loadError!),
                  ],
                  const SizedBox(height: 24),
                  _buildHeaderStats(),
                  const SizedBox(height: 24),
                  _buildOffersTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilityBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.coastalInk,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.storefront, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Le vendeur publie les paniers visibles par les clients',
                  style: AppTextStyles.subtitleM.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'L’admin valide les partenaires et contrôle la qualité. Les paniers du jour sont créés ici par chaque commerce.',
                  style: AppTextStyles.bodyS.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.warningColor),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTextStyles.bodyS)),
          TextButton(onPressed: _loadOffers, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    final active = _offers.where((offer) => offer['active'] == true).length;
    final stock = _offers.fold<int>(
      0,
      (sum, offer) =>
          sum + ((offer['available_quantity'] as num?)?.toInt() ?? 0),
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Paniers publiés',
            '${_offers.length}',
            Icons.shopping_bag_outlined,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Actifs client',
            '$active',
            Icons.visibility_outlined,
            AppTheme.reef,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Stock restant',
            '$stock',
            Icons.inventory_2_outlined,
            AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.headingS.copyWith(color: color),
                ),
                Text(
                  title,
                  style: AppTextStyles.captionM.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text('Paniers du jour', style: AppTextStyles.headingS),
                ),
                Text(
                  _isLoading ? 'Chargement...' : '${_offers.length} offre(s)',
                  style: AppTextStyles.labelText,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_offers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                _isLoading
                    ? 'Chargement des paniers...'
                    : 'Aucun panier publié. Ajoutez votre premier panier du jour.',
                style: AppTextStyles.bodyM.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._offers.map(_buildOfferRow),
        ],
      ),
    );
  }

  Widget _buildOfferRow(Map<String, dynamic> offer) {
    final name = offer['name'] as String? ?? 'Panier surprise';
    final quantity = (offer['available_quantity'] as num?)?.toInt() ?? 0;
    final active = offer['active'] == true;
    final unitAmount = (offer['unit_amount'] as num?)?.toInt() ?? 0;
    final originalAmount = (offer['original_unit_amount'] as num?)?.toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.softBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.reef.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.set_meal, color: AppTheme.reef),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.subtitleS),
                const SizedBox(height: 3),
                Text(
                  offer['description'] as String? ??
                      'Panier surprise selon arrivage du jour',
                  style: AppTextStyles.captionM.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              _formatPrice(unitAmount),
              style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              originalAmount == null ? '-' : _formatPrice(originalAmount),
              style: AppTextStyles.bodyM.copyWith(
                color: AppTheme.textSecondary,
                decoration:
                    originalAmount == null ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
          Expanded(
            child: _buildStatusChip(
              quantity > 0 ? '$quantity dispo' : 'Épuisé',
              quantity > 0 ? AppTheme.reef : AppTheme.coral,
            ),
          ),
          Expanded(
            child: _buildStatusChip(
              active ? 'Visible' : 'Masqué',
              active ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Text(
          label,
          style: AppTextStyles.captionM.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _showAddOfferDialog() async {
    final nameController = TextEditingController(text: 'Panier pêche du jour');
    final descController = TextEditingController(
      text: 'Sélection surprise selon arrivage et invendus frais.',
    );
    final originalPriceController = TextEditingController(text: '9000');
    final reducedPriceController = TextEditingController(text: '3500');
    final quantityController = TextEditingController(text: '5');
    TimeOfDay start = const TimeOfDay(hour: 17, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 19, minute: 0);
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final original = int.tryParse(
                originalPriceController.text.trim(),
              );
              final reduced = int.tryParse(reducedPriceController.text.trim());
              final quantity = int.tryParse(quantityController.text.trim());

              if (nameController.text.trim().length < 2 ||
                  original == null ||
                  reduced == null ||
                  quantity == null ||
                  reduced <= 0 ||
                  original < reduced) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vérifiez le nom, les prix et la quantité.'),
                  ),
                );
                return;
              }

              setDialogState(() => isSubmitting = true);

              final now = DateTime.now();
              final pickupStart = DateTime(
                now.year,
                now.month,
                now.day,
                start.hour,
                start.minute,
              );
              final pickupEnd = DateTime(
                now.year,
                now.month,
                now.day,
                end.hour,
                end.minute,
              );

              try {
                final storeContext =
                    _storeContext ?? await _resolveStoreContext();
                await _partnerApiService.createOffer(
                  PartnerOfferRequest(
                    storeId: storeContext.storeId,
                    storeName: storeContext.storeName,
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    currency: 'xof',
                    unitAmount: reduced,
                    originalUnitAmount: original,
                    availableQuantity: quantity,
                    pickupStartsAt: pickupStart,
                    pickupEndsAt: pickupEnd,
                    latitude: storeContext.latitude,
                    longitude: storeContext.longitude,
                    active: true,
                  ),
                );
                if (!mounted) return;
                Navigator.of(this.context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Panier publié côté client.')),
                );
                await _loadOffers();
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Publication impossible pour le moment.'),
                  ),
                );
                setDialogState(() => isSubmitting = false);
              }
            }

            return AlertDialog(
              title: const Text('Publier un panier surprise'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom visible client',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description courte',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: originalPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Valeur réelle CFA',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: reducedPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Prix client CFA',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantité de paniers',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final value = await showTimePicker(
                                  context: context,
                                  initialTime: start,
                                );
                                if (value != null) {
                                  setDialogState(() => start = value);
                                }
                              },
                              icon: const Icon(Icons.schedule),
                              label: Text('Début ${start.format(context)}'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final value = await showTimePicker(
                                  context: context,
                                  initialTime: end,
                                );
                                if (value != null) {
                                  setDialogState(() => end = value);
                                }
                              },
                              icon: const Icon(Icons.schedule),
                              label: Text('Fin ${end.format(context)}'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : submit,
                  child:
                      isSubmitting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Publier'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatPrice(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      buffer.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(' ');
      }
    }
    return '$buffer F';
  }

  static final List<Map<String, dynamic>> _fallbackOffers = [
    {
      'id': 'demo_offer_1',
      'name': 'Panier pêche du jour',
      'description': 'Thiof, dorade ou filets selon arrivage.',
      'currency': 'xof',
      'unit_amount': 3500,
      'original_unit_amount': 9000,
      'available_quantity': 5,
      'active': true,
    },
    {
      'id': 'demo_offer_2',
      'name': 'Panier crevettes premium',
      'description': 'Crevettes fraîches en quantité limitée.',
      'currency': 'xof',
      'unit_amount': 5000,
      'original_unit_amount': 13000,
      'available_quantity': 2,
      'active': true,
    },
  ];
}

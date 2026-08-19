import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/providers/partner_provider.dart';
import 'package:myapp/services/partner_api_service.dart';
import 'package:myapp/utils/formatters.dart';

class PartnerOrdersPage extends StatefulWidget {
  const PartnerOrdersPage({super.key});

  @override
  State<PartnerOrdersPage> createState() => _PartnerOrdersPageState();
}

class _PartnerOrdersPageState extends State<PartnerOrdersPage> {
  static const _storeId = 'store_port';
  final PartnerApiService _partnerApiService = PartnerApiService();
  String _filter = 'Tous';
  bool _isLoading = true;
  String? _loadError;
  List<Order>? _apiOrders;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final reservations = await _partnerApiService.getStoreReservations(
        _storeId,
      );
      if (!mounted) return;
      setState(() {
        _apiOrders = reservations.map(_orderFromApi).toList();
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiOrders = null;
        _loadError = 'Backend indisponible: réservations de démonstration';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PartnerProvider>(
      builder: (context, provider, child) {
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
                        'Réservations',
                        style: AppTextStyles.headingM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 0,
                      child: FilledButton.icon(
                        onPressed: () => context.go('/partner/scan'),
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text(
                          'Scanner QR',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilters(provider),
                      if (_loadError != null) ...[
                        const SizedBox(height: 12),
                        _buildWarningBanner(_loadError!),
                      ],
                      const SizedBox(height: 24),
                      _buildOrdersTable(context, provider),
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

  Widget _buildFilters(PartnerProvider provider) {
    final filters = [
      'Tous',
      'En attente',
      'Confirmée',
      'Prête',
      'Retirée',
      'Annulée',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            filters
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (selected) => setState(() => _filter = f),
                      selectedColor: AppTheme.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
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
          TextButton(
            onPressed: _loadReservations,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    String orderId,
    String currentStatus,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Modifier le statut'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusOption(
                  context,
                  ctx,
                  orderId,
                  'En attente',
                  'En attente',
                  currentStatus,
                ),
                _buildStatusOption(
                  context,
                  ctx,
                  orderId,
                  'Confirmée',
                  'Confirmée',
                  currentStatus,
                ),
                _buildStatusOption(
                  context,
                  ctx,
                  orderId,
                  'Prête',
                  'Prête',
                  currentStatus,
                ),
                _buildStatusOption(
                  context,
                  ctx,
                  orderId,
                  'Retirée',
                  'Retirée',
                  currentStatus,
                ),
                _buildStatusOption(
                  context,
                  ctx,
                  orderId,
                  'Annulée',
                  'Annulée',
                  currentStatus,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  Widget _buildStatusOption(
    BuildContext dialogContext,
    BuildContext ctx,
    String orderId,
    String label,
    String value,
    String current,
  ) {
    return ListTile(
      leading: RadioGroup<String>(
        groupValue: current,
        onChanged: (v) {
          if (v == null) return;
          context.read<PartnerProvider>().updateOrderStatus(orderId, v);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statut mis à jour: $label'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
        child: Radio<String>(value: value),
      ),
      title: Text(label),
      onTap: () {
        context.read<PartnerProvider>().updateOrderStatus(orderId, value);
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut mis à jour: $label'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTable(BuildContext context, PartnerProvider provider) {
    final sourceOrders = _apiOrders ?? provider.orders;
    final orders =
        _filter == 'Tous'
            ? sourceOrders
            : sourceOrders.where((o) => o.status == _filter).toList();

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
                  child: Text(
                    'Réservation',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Client',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Articles',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Heure',
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
                Expanded(
                  child: Text(
                    'Actions',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                _isLoading
                    ? 'Chargement des réservations...'
                    : 'Aucune réservation',
              ),
            )
          else
            ...orders.map((o) => _buildOrderRow(context, o)),
        ],
      ),
    );
  }

  Widget _buildOrderRow(BuildContext context, Order order) {
    Color statusColor;
    switch (order.status) {
      case 'En attente':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'Confirmée':
        statusColor = const Color(0xFF3B82F6);
        break;
      case 'Prête':
        statusColor = const Color(0xFF10B981);
        break;
      case 'Retirée':
        statusColor = const Color(0xFF8B5CF6);
        break;
      case 'Annulée':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: AppTheme.softBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              order.id,
              style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              order.clientName,
              style: AppTextStyles.bodyM,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              order.items,
              style: AppTextStyles.bodyS.copyWith(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              AppFormatters.formatCfa(order.total),
              style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              order.time,
              style: AppTextStyles.bodyS.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap:
                  () =>
                      _showUpdateStatusDialog(context, order.id, order.status),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.status,
                      style: AppTextStyles.bodyS.copyWith(color: statusColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 16, color: statusColor),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed:
                  () =>
                      _showUpdateStatusDialog(context, order.id, order.status),
            ),
          ),
        ],
      ),
    );
  }

  Order _orderFromApi(Map<String, dynamic> reservation) {
    final items = (reservation['items'] as List<dynamic>? ?? const [])
        .map((item) {
          final map = item as Map<String, dynamic>;
          final quantity = (map['quantity'] as num?)?.toInt() ?? 1;
          return '$quantity x ${map['name'] ?? 'Panier'}';
        })
        .join(', ');
    final amount = ((reservation['amount'] as num?)?.toDouble() ?? 0);
    final createdAt = DateTime.tryParse(
      reservation['created_at'] as String? ?? '',
    );
    return Order(
      id: reservation['order_id'] as String? ?? 'Réservation',
      clientName: reservation['user_id'] as String? ?? 'Client',
      items: items.isEmpty ? 'Panier surprise' : items,
      total: amount,
      status: _mapApiStatus(reservation['status'] as String?),
      time:
          createdAt == null
              ? ''
              : '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
      createdAt: createdAt,
    );
  }

  String _mapApiStatus(String? status) {
    switch (status) {
      case 'pending_payment':
        return 'En attente';
      case 'paid':
        return 'Confirmée';
      case 'pickup_ready':
        return 'Prête';
      case 'picked_up':
        return 'Retirée';
      case 'canceled':
      case 'refund_pending':
      case 'refunded':
      case 'payment_failed':
        return 'Annulée';
      default:
        return 'En attente';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:myapp/services/partner_api_service.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/utils/formatters.dart';

class PartnerAnalyticsPage extends StatefulWidget {
  const PartnerAnalyticsPage({super.key});

  @override
  State<PartnerAnalyticsPage> createState() => _PartnerAnalyticsPageState();
}

class _PartnerAnalyticsPageState extends State<PartnerAnalyticsPage> {
  static const _storeId = 'store_port';
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _offers = const [];
  List<Map<String, dynamic>> _reservations = const [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final results = await Future.wait([
        _partnerApiService.getStoreOffers(_storeId),
        _partnerApiService.getStoreReservations(_storeId),
      ]);
      if (!mounted) return;
      setState(() {
        _offers = results[0];
        _reservations = results[1];
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offers = _fallbackOffers;
        _reservations = _fallbackReservations;
        _loadError = 'Backend indisponible: statistiques de démonstration';
        _isLoading = false;
      });
    }
  }

  int get _revenueAmount => _reservations.fold<int>(
    0,
    (sum, reservation) => sum + ((reservation['amount'] as num?)?.toInt() ?? 0),
  );

  int get _pickedUpCount =>
      _reservations.where((r) => r['status'] == 'picked_up').length;

  int get _canceledCount =>
      _reservations
          .where(
            (r) => [
              'canceled',
              'refund_pending',
              'refunded',
            ].contains(r['status']),
          )
          .length;

  double get _averageBasket =>
      _reservations.isEmpty ? 0 : _revenueAmount / _reservations.length;

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
                    'Statistiques',
                    style: AppTextStyles.headingM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: 'Avril 2026',
                      isDense: true,
                      underline: const SizedBox(),
                      items:
                          ['Avril 2026', 'Mars 2026', 'Février 2026']
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(
                                    m,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {},
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
                  if (_loadError != null) ...[
                    _buildWarningBanner(_loadError!),
                    const SizedBox(height: 16),
                  ],
                  _buildStats(),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 760) {
                        return Column(
                          children: [
                            _buildRevenueChart(),
                            const SizedBox(height: 16),
                            _buildTopProducts(),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildRevenueChart()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTopProducts()),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildOrdersChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Revenus',
            _isLoading ? '...' : AppFormatters.formatCfa(_revenueAmount),
            'réel',
            const Color(0xFF10B981),
            Icons.attach_money,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            'Réservations',
            _isLoading ? '...' : '${_reservations.length}',
            'réel',
            const Color(0xFF3B82F6),
            Icons.shopping_cart,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            'Paniers actifs',
            _isLoading
                ? '...'
                : '${_offers.where((o) => o['active'] == true).length}',
            'réel',
            const Color(0xFF8B5CF6),
            Icons.people,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            'Panier moyen',
            _isLoading ? '...' : AppFormatters.formatCfa(_averageBasket),
            'réel',
            const Color(0xFFF59E0B),
            Icons.shopping_bag,
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
          TextButton(onPressed: _loadAnalytics, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    String change,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                change,
                style: AppTextStyles.bodyS.copyWith(
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.headingM.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: AppTextStyles.bodyS.copyWith(color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    final revenueBase = (_revenueAmount / 1000).clamp(1, 4000);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenus quotidiens', style: AppTextStyles.headingS),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(40 + revenueBase * 0.02, 'L'),
                _bar(55 + _reservations.length * 3, 'M'),
                _bar(45 + _offers.length * 4, 'M'),
                _bar(80 + revenueBase * 0.015, 'J'),
                _bar(60 + _reservations.length * 4, 'V'),
                _bar(75 + _offers.length * 5, 'S'),
                _bar(45 + _pickedUpCount * 6, 'D'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double height, String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: AppTextStyles.bodyS.copyWith(color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildTopProducts() {
    final products = _topProducts();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paniers les plus sauvés', style: AppTextStyles.headingS),
          const SizedBox(height: 16),
          ...products.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'] as String, style: AppTextStyles.bodyM),
                        Text(
                          '${p['sales']} réservations',
                          style: AppTextStyles.bodyS.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppFormatters.formatCfa(p['revenue'] as num),
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart() {
    final total = _reservations.isEmpty ? 1 : _reservations.length;
    final pickedPercent = ((_pickedUpCount / total) * 100).round();
    final canceledPercent = ((_canceledCount / total) * 100).round();
    final pendingPercent = (100 - pickedPercent - canceledPercent).clamp(
      0,
      100,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Taux de récupération', style: AppTextStyles.headingS),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$pickedPercent%',
                      style: AppTextStyles.headingL.copyWith(
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      'Retirées',
                      style: AppTextStyles.bodyS.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$pendingPercent%',
                      style: AppTextStyles.headingL.copyWith(
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    Text(
                      'Non retirées',
                      style: AppTextStyles.bodyS.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$canceledPercent%',
                      style: AppTextStyles.headingL.copyWith(
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    Text(
                      'Annulées',
                      style: AppTextStyles.bodyS.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, Object>> _topProducts() {
    final stats = <String, ({int sales, double revenue})>{};
    for (final reservation in _reservations) {
      final items = reservation['items'] as List<dynamic>? ?? const [];
      final amount = ((reservation['amount'] as num?)?.toDouble() ?? 0);
      for (final item in items) {
        final map = item as Map<String, dynamic>;
        final name = map['name'] as String? ?? 'Panier surprise';
        final quantity = (map['quantity'] as num?)?.toInt() ?? 1;
        final previous = stats[name] ?? (sales: 0, revenue: 0.0);
        stats[name] = (
          sales: previous.sales + quantity,
          revenue: previous.revenue + amount,
        );
      }
    }

    if (stats.isEmpty) {
      return [
        {'name': 'Panier surprise', 'sales': 0, 'revenue': 0.0},
      ];
    }

    final rows =
        stats.entries
            .map(
              (entry) => {
                'name': entry.key,
                'sales': entry.value.sales,
                'revenue': entry.value.revenue,
              },
            )
            .toList()
          ..sort((a, b) => (b['sales'] as int).compareTo(a['sales'] as int));
    return rows.take(4).toList();
  }

  static final List<Map<String, dynamic>> _fallbackOffers = [
    {'id': 'demo_1', 'active': true},
    {'id': 'demo_2', 'active': true},
    {'id': 'demo_3', 'active': false},
  ];

  static final List<Map<String, dynamic>> _fallbackReservations = [
    {
      'order_id': 'DC-DEMO-001',
      'amount': 2500,
      'status': 'picked_up',
      'items': [
        {'name': 'Panier poisson', 'quantity': 1},
      ],
    },
    {
      'order_id': 'DC-DEMO-002',
      'amount': 1850,
      'status': 'paid',
      'items': [
        {'name': 'Panier crevettes', 'quantity': 1},
      ],
    },
  ];
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/pages/partner/products_list_page.dart';
import 'package:myapp/pages/partner/packs_list_page.dart';
import 'package:myapp/pages/partner/inventory_page.dart';
import 'package:myapp/pages/partner/orders_page.dart';
import 'package:myapp/pages/partner/schedules_page.dart';
import 'package:myapp/pages/partner/analytics_page.dart';
import 'package:myapp/services/partner_api_service.dart';
import 'package:myapp/utils/api_environment.dart';

class PartnerDashboardPage extends StatefulWidget {
  const PartnerDashboardPage({super.key});

  @override
  State<PartnerDashboardPage> createState() => _PartnerDashboardPageState();
}

class _PartnerDashboardPageState extends State<PartnerDashboardPage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.dashboard_outlined,
      'title': 'Dashboard',
      'widget': 'dashboard',
    },
    {
      'icon': Icons.shopping_bag_outlined,
      'title': 'Paniers',
      'widget': 'products',
    },
    {
      'icon': Icons.card_giftcard_outlined,
      'title': 'Surprises',
      'widget': 'packs',
    },
    {
      'icon': Icons.inventory_2_outlined,
      'title': 'Stock',
      'widget': 'inventory',
    },
    {
      'icon': Icons.shopping_cart_outlined,
      'title': 'Réservations',
      'widget': 'orders',
    },
    {
      'icon': Icons.schedule_outlined,
      'title': 'Horaires',
      'widget': 'schedules',
    },
    {
      'icon': Icons.bar_chart_outlined,
      'title': 'Statistiques',
      'widget': 'analytics',
    },
  ];

  Widget _getContent() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardContent();
      case 1:
        return const ProductsListPage();
      case 2:
        return const PacksListPage();
      case 3:
        return const PartnerInventoryPage();
      case 4:
        return const PartnerOrdersPage();
      case 5:
        return const PartnerSchedulesPage();
      case 6:
        return const PartnerAnalyticsPage();
      default:
        return _DashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mutedSurface,
      body: Row(
        children: [
          // Fixed Sidebar
          Container(
            width: 260,
            color: Colors.white,
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.set_meal,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'DailyCatch',
                          style: AppTextStyles.headingM.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Menu
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == index;
                      return InkWell(
                        onTap: () => setState(() => _selectedIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    )
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'],
                                size: 20,
                                color:
                                    isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item['title'],
                                  style: AppTextStyles.bodyM.copyWith(
                                    color:
                                        isSelected
                                            ? AppTheme.primaryColor
                                            : Colors.grey[600],
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Logout
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        'Déconnexion',
                        style: AppTextStyles.bodyM.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content Area
          Expanded(child: _getContent()),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  static const _fallbackStoreId = 'store_port';
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _offers = const [];
  List<Map<String, dynamic>> _reservations = const [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final storeId = await _resolveStoreId();
      final results = await Future.wait([
        _partnerApiService.getStoreOffers(storeId),
        _partnerApiService.getStoreReservations(storeId),
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
        _offers =
            ApiEnvironment.isDemoFallbackAllowed
                ? _fallbackOffers
                : const <Map<String, dynamic>>[];
        _reservations =
            ApiEnvironment.isDemoFallbackAllowed
                ? _fallbackReservations
                : const <Map<String, dynamic>>[];
        _loadError =
            ApiEnvironment.isDemoFallbackAllowed
                ? 'Backend indisponible: données de démonstration affichées'
                : 'Données vendeur indisponibles.';
        _isLoading = false;
      });
    }
  }

  Future<String> _resolveStoreId() async {
    final storeContext = await _partnerApiService.getMyStoreContext();
    if (storeContext != null) return storeContext.storeId;
    if (ApiEnvironment.isDemoFallbackAllowed) return _fallbackStoreId;
    throw const PartnerApiException(
      statusCode: 404,
      message: 'partner_profile_missing',
    );
  }

  int get _activeOffers =>
      _offers.where((offer) => offer['active'] == true).length;

  int get _availableQuantity => _offers.fold<int>(
    0,
    (sum, offer) => sum + ((offer['available_quantity'] as num?)?.toInt() ?? 0),
  );

  int get _revenueCents => _reservations.fold<int>(
    0,
    (sum, reservation) => sum + ((reservation['amount'] as num?)?.toInt() ?? 0),
  );

  String get _formattedRevenue => '${_formatCfa(_revenueCents)} F';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.white,
          child: Row(
            children: [
              Text('Espace vendeur', style: AppTextStyles.headingM),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => context.go('/partner/scan'),
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text('Scanner QR'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.go('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.go('/partner/commerce-settings'),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.person, color: Colors.white, size: 18),
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
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Paniers',
                        _isLoading ? '...' : _offers.length.toString(),
                        Icons.shopping_bag_outlined,
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Paniers actifs',
                        _isLoading ? '...' : _activeOffers.toString(),
                        Icons.card_giftcard_outlined,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Réservations',
                        _isLoading ? '...' : _reservations.length.toString(),
                        Icons.shopping_cart_outlined,
                        const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Revenus',
                        _isLoading ? '...' : _formattedRevenue,
                        Icons.account_balance_wallet_outlined,
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ventes estimées ce mois',
                              style: AppTextStyles.headingS,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isLoading ? '...' : _formattedRevenue,
                              style: AppTextStyles.headingL.copyWith(
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(height: 150, child: _buildChart()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Réservations récentes',
                              style: AppTextStyles.headingS,
                            ),
                            const SizedBox(height: 16),
                            if (_reservations.isEmpty)
                              Text(
                                _isLoading
                                    ? 'Chargement...'
                                    : 'Aucune réservation pour ce commerce.',
                                style: AppTextStyles.bodyM.copyWith(
                                  color: Colors.grey[600],
                                ),
                              )
                            else
                              ..._reservations
                                  .take(4)
                                  .map(
                                    (reservation) => _buildOrderRow(
                                      reservation['order_id'] as String? ??
                                          'Réservation',
                                      _formatReservationTime(
                                        reservation['created_at'],
                                      ),
                                      '${_formatCfa((reservation['amount'] as num?)?.toInt() ?? 0)} F',
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          TextButton(onPressed: _loadDashboard, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
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

  Widget _buildChart() {
    final base = _availableQuantity.clamp(1, 100);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bar(30 + base * 0.4, 'L'),
        _bar(35 + _activeOffers * 5, 'M'),
        _bar(40 + _reservations.length * 4, 'M'),
        _bar(55 + base * 0.3, 'J'),
        _bar(50 + _activeOffers * 6, 'V'),
        _bar(65 + _reservations.length * 5, 'S'),
        _bar(70 + base * 0.2, 'D'),
      ],
    );
  }

  Widget _bar(double height, String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 18,
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

  Widget _buildOrderRow(String order, String time, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(order, style: AppTextStyles.bodyM)),
          Text(
            time,
            style: AppTextStyles.bodyS.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatReservationTime(dynamic value) {
    if (value is! String) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return '';
    return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
  }

  String _formatCfa(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      buffer.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  static final List<Map<String, dynamic>> _fallbackOffers = [
    {'id': 'demo_1', 'active': true, 'available_quantity': 3},
    {'id': 'demo_2', 'active': true, 'available_quantity': 5},
    {'id': 'demo_3', 'active': false, 'available_quantity': 0},
  ];

  static final List<Map<String, dynamic>> _fallbackReservations = [
    {
      'order_id': 'DC-DEMO-001',
      'amount': 2500,
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'order_id': 'DC-DEMO-002',
      'amount': 1850,
      'created_at':
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    },
  ];
}

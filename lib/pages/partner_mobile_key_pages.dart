import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/partner_api_service.dart';
import 'package:myapp/services/payment_api_service.dart';
import 'package:myapp/widgets/partner_bottom_nav_bar.dart';

class _PartnerBasketDraft {
  static String name = 'Panier Poissons du jour';
  static String description = 'Sélection de poissons frais pêchés ce matin.';
  static String category = 'Poissons';
  static String weightEstimate = '3 - 4 kg';
  static int availableQuantity = 20;
  static int unitAmount = 10000;
  static int originalUnitAmount = 15000;
  static List<String> mediaUrls = [];

  static void reset() {
    name = 'Panier Poissons du jour';
    description = 'Sélection de poissons frais pêchés ce matin.';
    category = 'Poissons';
    weightEstimate = '3 - 4 kg';
    availableQuantity = 20;
    unitAmount = 10000;
    originalUnitAmount = 15000;
    mediaUrls = [];
  }
}

class PartnerMobileDashboardPage extends StatefulWidget {
  const PartnerMobileDashboardPage({super.key});

  @override
  State<PartnerMobileDashboardPage> createState() =>
      _PartnerMobileDashboardPageState();
}

class _PartnerMobileDashboardPageState
    extends State<PartnerMobileDashboardPage> {
  static const _storeId = 'store_yoff';
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _offers = const [];
  List<Map<String, dynamic>> _orders = const [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final results = await Future.wait<Object?>([
        _partnerApiService.getMyProfile(),
        _partnerApiService.getStoreOffers(_storeId),
        _partnerApiService.getStoreReservations(_storeId),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as Map<String, dynamic>?;
        _offers = (results[1] as List<Map<String, dynamic>>);
        _orders = (results[2] as List<Map<String, dynamic>>);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profile = _fallbackPartnerProfile;
        _offers = _fallbackPartnerOffers;
        _orders = _fallbackPartnerOrders;
        _loadError = null;
        _isLoading = false;
      });
    }
  }

  int get _activeOffers =>
      _offers.where((offer) => offer['active'] as bool? ?? true).length;

  int get _pendingOrders => _orders.where(_isOpenOrder).length;

  int get _soldBaskets =>
      _orders.fold<int>(0, (total, order) => total + _orderQuantity(order));

  int get _revenue => _orders
      .where((order) => !_isCanceledOrder(order))
      .fold<int>(0, (total, order) => total + _intValue(order['amount']));

  int get _pendingAmount => _orders
      .where(_isOpenOrder)
      .fold<int>(0, (total, order) => total + _intValue(order['amount']));

  int get _completedOrders =>
      _orders
          .where(
            (order) => _orderTabIndex(order) == 2 && !_isCanceledOrder(order),
          )
          .length;

  int get _commission => (_revenue * .10).round();

  int get _refunds => _orders
      .where(_isCanceledOrder)
      .fold<int>(0, (total, order) => total + _intValue(order['amount']));

  int get _availableBalance {
    final balance = _revenue - _commission - _refunds;
    return balance < 0 ? 0 : balance;
  }

  String get _ownerName => _readString(_profile, const [
    'ownerName',
    'owner_name',
    'name',
  ], 'Moussa');

  String get _storeName => _readString(_profile, const [
    'storeName',
    'store_name',
    'businessName',
  ], 'Poissonnerie Chez Moussa');

  String get _rating {
    final rating = _profile?['averageRating'] ?? _profile?['rating'];
    if (rating is num) return rating.toStringAsFixed(1).replaceAll('.', ',');
    final parsed = double.tryParse('$rating');
    return parsed == null
        ? '4,9'
        : parsed.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    return _PartnerScaffold(
      title: 'Dashboard vendeur',
      currentIndex: 0,
      child: RefreshIndicator(
        color: AppColors.blueBic,
        onRefresh: _loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 18),
          children: [
            if (_isLoading) const LinearProgressIndicator(minHeight: 2),
            if (_isLoading) const SizedBox(height: 14),
            _SellerHeader(
              ownerName: _ownerName,
              storeName: _storeName,
              rating: _rating,
            ),
            const SizedBox(height: 18),
            if (_loadError != null) ...[
              _PartnerNotice(message: _loadError!, onRetry: _loadDashboard),
              const SizedBox(height: 14),
            ],
            _FinanceHeroCard(
              availableBalance: _availableBalance,
              pendingAmount: _pendingAmount,
              onTapDetails: () => context.push('/partner/revenue-detail'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CompactStatCard(
                    icon: Icons.payments_outlined,
                    label: 'Revenu total',
                    value: _formatCfa(_revenue),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CompactStatCard(
                    icon: Icons.receipt_long_outlined,
                    label: 'Commandes',
                    value: '$_completedOrders',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CompactStatCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Paniers sauvés',
                    value: '$_soldBaskets',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CompactStatCard(
                    icon: Icons.star_rounded,
                    label: 'Note moyenne',
                    value: _rating,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Actions rapides', style: _label),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/partner/transactions'),
                  child: Text('Transactions', style: _green),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: [
                _FinanceQuickTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Versements',
                  subtitle: 'Retirer mes fonds',
                  onTap: () => context.push('/partner/payouts'),
                ),
                _FinanceQuickTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Paiement',
                  subtitle: 'Coordonnées',
                  onTap: () => context.push('/partner/payment-coordinates'),
                ),
                _FinanceQuickTile(
                  icon: Icons.folder_copy_outlined,
                  title: 'Documents',
                  subtitle: 'Pièces vendeur',
                  onTap: () => context.push('/partner/documents-mobile'),
                ),
                _FinanceQuickTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Validation',
                  subtitle: 'Statut du compte',
                  onTap: () => context.push('/partner/validation-status'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Pilotage', style: _label),
            const SizedBox(height: 12),
            _Panel(
              title: 'Commandes',
              subtitle: '$_pendingOrders en attente',
              action: 'Voir tout',
              onTap: () => context.go('/partner/orders'),
            ),
            const SizedBox(height: 12),
            _Panel(
              title: 'Paniers',
              subtitle: '$_activeOffers disponibles',
              action: 'Gérer',
              onTap: () => context.go('/partner/baskets'),
            ),
            const SizedBox(height: 12),
            _Panel(
              title: 'Retraits',
              subtitle: 'Scanner ou valider un code',
              action: 'Ouvrir',
              onTap: () => context.go('/partner/validated-pickups'),
            ),
          ],
        ),
      ),
    );
  }
}

class PartnerRevenueDetailPage extends StatelessWidget {
  const PartnerRevenueDetailPage({super.key});

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Détail revenus',
    child: _PartnerFinanceLoader(
      builder:
          (context, finance, reload) => Column(
            children: [
              const _PeriodPicker(label: 'Période', value: 'Ce mois'),
              const SizedBox(height: 18),
              _FinanceBreakdownCard(
                rows: [
                  ('Revenus', finance.grossRevenue),
                  ('Commission DailyCatch', -finance.commission),
                  ('Remboursements', -finance.refunds),
                  ('Net', finance.netRevenue),
                ],
              ),
              const Spacer(),
              _Button(
                label: 'Voir le détail des transactions',
                onTap: () => context.push('/partner/transactions'),
              ),
            ],
          ),
    ),
  );
}

class PartnerTransactionsPage extends StatefulWidget {
  const PartnerTransactionsPage({super.key});

  @override
  State<PartnerTransactionsPage> createState() =>
      _PartnerTransactionsPageState();
}

class _PartnerTransactionsPageState extends State<PartnerTransactionsPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Transactions',
    child: _PartnerFinanceLoader(
      builder: (context, finance, reload) {
        final transactions =
            finance.transactions.where((transaction) {
              return switch (_selectedTab) {
                1 => transaction.positive,
                2 => !transaction.positive,
                _ => true,
              };
            }).toList();

        return Column(
          children: [
            _Tabs(
              const ['Toutes', 'Revenus', 'Remboursements'],
              selectedIndex: _selectedTab,
              onChanged: (index) => setState(() => _selectedTab = index),
            ),
            const SizedBox(height: 18),
            if (transactions.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Aucune transaction pour cette période',
                    style: _sub,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _TransactionRow(
                      title: transaction.title,
                      date: transaction.date,
                      amount: transaction.formattedAmount,
                      positive: transaction.positive,
                    );
                  },
                ),
              ),
          ],
        );
      },
    ),
  );
}

class PartnerPayoutsPage extends StatelessWidget {
  const PartnerPayoutsPage({super.key});

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Versements',
    child: _PartnerFinanceLoader(
      builder:
          (context, finance, reload) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mes versements', style: _headline),
              const SizedBox(height: 16),
              _PayoutBalanceCard(
                amount: _formatCfa(finance.availableBalance),
                onTap: () => context.push('/partner/payment-coordinates'),
              ),
              const SizedBox(height: 22),
              Text('Derniers versements', style: _label),
              const SizedBox(height: 12),
              if (finance.payouts.isEmpty)
                Text('Aucun versement disponible', style: _sub)
              else
                for (final payout in finance.payouts)
                  _PayoutRow(payout.date, payout.formattedAmount),
              const Spacer(),
              _LightButton(
                'Voir l’historique',
                onTap: () => context.push('/partner/transactions'),
              ),
            ],
          ),
    ),
  );
}

class PartnerPaymentCoordinatesPage extends StatelessWidget {
  const PartnerPaymentCoordinatesPage({super.key});

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Coordonnées de paiement',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ajouter un moyen de paiement', style: _headline),
        const SizedBox(height: 18),
        _PaymentCoordinateTile(
          icon: Icons.phone_android_outlined,
          title: 'Mobile Money',
          subtitle: 'Orange, Wave, Free Money...',
          onTap:
              () => _showPartnerSnack(
                context,
                'Configuration Mobile Money prête à raccorder.',
              ),
        ),
        _PaymentCoordinateTile(
          icon: Icons.account_balance_outlined,
          title: 'Compte bancaire',
          subtitle: 'IBAN, banque et titulaire',
          onTap:
              () => _showPartnerSnack(
                context,
                'Configuration bancaire prête à raccorder.',
              ),
        ),
        _PaymentCoordinateTile(
          icon: Icons.storefront_outlined,
          title: 'Espèces',
          subtitle: 'Point de retrait partenaire',
          onTap:
              () => _showPartnerSnack(
                context,
                'Retrait en espèces marqué comme option disponible.',
              ),
        ),
        const Spacer(),
        _Button(
          label: 'Factures / relevés',
          onTap: () => context.push('/partner/invoices'),
        ),
      ],
    ),
  );
}

class PartnerInvoicesPage extends StatelessWidget {
  const PartnerInvoicesPage({super.key});

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Factures / Relevés',
    child: _PartnerFinanceLoader(
      builder:
          (context, finance, reload) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Relevés & factures', style: _headline),
              const SizedBox(height: 16),
              _PeriodPicker(label: 'Période', value: finance.currentPeriod),
              const SizedBox(height: 12),
              for (final invoice in finance.invoices) _InvoiceRow(invoice),
              const SizedBox(height: 24),
              Text('Vos factures sont générées chaque mois.', style: _muted),
            ],
          ),
    ),
  );
}

class _PartnerFinanceLoader extends StatefulWidget {
  const _PartnerFinanceLoader({required this.builder});

  final Widget Function(
    BuildContext context,
    _PartnerFinanceSnapshot finance,
    VoidCallback reload,
  )
  builder;

  @override
  State<_PartnerFinanceLoader> createState() => _PartnerFinanceLoaderState();
}

class _PartnerFinanceLoaderState extends State<_PartnerFinanceLoader> {
  final PartnerApiService _partnerApiService = PartnerApiService();
  late Future<_PartnerFinanceSnapshot> _financeFuture;

  @override
  void initState() {
    super.initState();
    _financeFuture = _loadPartnerFinance(_partnerApiService);
  }

  void _reload() {
    setState(() {
      _financeFuture = _loadPartnerFinance(_partnerApiService);
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_PartnerFinanceSnapshot>(
    future: _financeFuture,
    builder: (context, snapshot) {
      final finance = snapshot.data;
      if (finance == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blueBic),
        );
      }
      return widget.builder(context, finance, _reload);
    },
  );
}

Future<_PartnerFinanceSnapshot> _loadPartnerFinance(
  PartnerApiService partnerApiService,
) async {
  try {
    final results = await Future.wait<Object>([
      partnerApiService.getStoreReservations('store_yoff'),
      partnerApiService.getStorePickups('store_yoff'),
    ]);
    return _PartnerFinanceSnapshot(
      orders: (results[0] as List<Map<String, dynamic>>),
      pickups: (results[1] as List<Map<String, dynamic>>),
    );
  } catch (_) {
    return const _PartnerFinanceSnapshot(
      orders: _fallbackPartnerOrders,
      pickups: _fallbackPartnerPickups,
      isDemoMode: true,
    );
  }
}

class _PartnerFinanceSnapshot {
  const _PartnerFinanceSnapshot({
    required this.orders,
    required this.pickups,
    this.isDemoMode = false,
  });

  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> pickups;
  final bool isDemoMode;

  int get grossRevenue => orders
      .where((order) => !_isCanceledOrder(order))
      .fold<int>(0, (total, order) => total + _intValue(order['amount']));

  int get settledRevenue {
    final orderRevenue = orders
        .where(_isSettledOrder)
        .fold<int>(0, (total, order) => total + _intValue(order['amount']));
    return orderRevenue > 0 ? orderRevenue : pickupRevenue;
  }

  int get pickupRevenue => pickups.fold<int>(
    0,
    (total, pickup) => total + _intValue(pickup['amount']),
  );

  int get pendingAmount => orders
      .where(_isOpenOrder)
      .fold<int>(0, (total, order) => total + _intValue(order['amount']));

  int get commission => (grossRevenue * .10).round();

  int get refunds => orders
      .where(_isCanceledOrder)
      .fold<int>(0, (total, order) => total + _intValue(order['amount']));

  int get netRevenue {
    final value = grossRevenue - commission - refunds;
    return value < 0 ? 0 : value;
  }

  int get availableBalance {
    final settledCommission = (settledRevenue * .10).round();
    final value = settledRevenue - settledCommission - refunds;
    return value < 0 ? 0 : value;
  }

  String get currentPeriod => _formatMonthYear(DateTime.now());

  List<_FinanceMovement> get transactions {
    final movements = <_FinanceMovement>[];
    for (final order in orders) {
      final amount = _intValue(order['amount']);
      final canceled = _isCanceledOrder(order);
      final movementDate = _financeMovementDateTime(order);
      movements.add(
        _FinanceMovement(
          title:
              canceled
                  ? 'Remboursement ${_orderId(order)}'
                  : 'Commande ${_orderId(order)}',
          date: _financeMovementDate(order),
          sortKeyValue: movementDate?.toIso8601String(),
          amount: canceled ? -amount : amount,
        ),
      );
    }
    movements.sort((a, b) => b.sortKey.compareTo(a.sortKey));
    return movements;
  }

  List<_FinanceMovement> get payouts {
    return pickups.take(3).map((pickup) {
      return _FinanceMovement(
        title: 'Versement ${_pickupHistoryCode(pickup)}',
        date: _pickupHistoryDate(pickup),
        amount: _intValue(pickup['amount']),
      );
    }).toList();
  }

  List<String> get invoices {
    final now = DateTime.now();
    return List.generate(3, (index) {
      final date = DateTime(now.year, now.month - index, 1);
      return 'Relevé ${_formatMonthYear(date)}';
    });
  }
}

class _FinanceMovement {
  const _FinanceMovement({
    required this.title,
    required this.date,
    required this.amount,
    this.sortKeyValue,
  });

  final String title;
  final String date;
  final int amount;
  final String? sortKeyValue;

  bool get positive => amount >= 0;

  String get formattedAmount {
    final prefix = amount >= 0 ? '+' : '-';
    return '$prefix${_formatCfa(amount.abs())}';
  }

  String get sortKey => sortKeyValue ?? date;
}

class _SellerHeader extends StatelessWidget {
  const _SellerHeader({
    required this.ownerName,
    required this.storeName,
    required this.rating,
  });

  final String ownerName;
  final String storeName;
  final String rating;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD7E7E6), width: 2),
        ),
        child: const CircleAvatar(
          backgroundImage: AssetImage('assets/icon/icon.png'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonjour, $ownerName', style: _title),
            const SizedBox(height: 2),
            Text(storeName, style: _sub),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F8F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFE2A227), size: 15),
            const SizedBox(width: 3),
            Text(rating, style: _greenSmall),
          ],
        ),
      ),
    ],
  );
}

class _FinanceHeroCard extends StatelessWidget {
  const _FinanceHeroCard({
    required this.availableBalance,
    required this.pendingAmount,
    required this.onTapDetails,
  });

  final int availableBalance;
  final int pendingAmount;
  final VoidCallback onTapDetails;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTapDetails,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006C70), AppColors.blueBic],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueBic.withValues(alpha: .20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Solde disponible', style: _metricLabel),
              const Spacer(),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_formatCfa(availableBalance), style: _financeHeroAmount),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: .16), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: Color(0xFFA6E4DF),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text('En attente', style: _metricLabel),
              const Spacer(),
              Text(_formatCfa(pendingAmount), style: _whiteHeader),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 82),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFCFC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2ECEA)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.blueBic, size: 18),
        const SizedBox(height: 14),
        Text(value, style: _statValue),
        const SizedBox(height: 2),
        Text(
          label,
          style: _muted,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _FinanceQuickTile extends StatelessWidget {
  const _FinanceQuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E8E6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF142D31).withValues(alpha: .045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F4F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.blueBic, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _title),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: _muted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF789094)),
        ],
      ),
    ),
  );
}

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Text(label, style: _row),
        const Spacer(),
        Text(value, style: _title),
        const SizedBox(width: 6),
        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
      ],
    ),
  );
}

class _FinanceBreakdownCard extends StatelessWidget {
  const _FinanceBreakdownCard({required this.rows});

  final List<(String, int)> rows;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF142D31).withValues(alpha: .035),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children:
          rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            final item = entry.value;
            return _FinanceBreakdownRow(
              label: item.$1,
              amount: item.$2,
              prominent: isLast,
            );
          }).toList(),
    ),
  );
}

class _FinanceBreakdownRow extends StatelessWidget {
  const _FinanceBreakdownRow({
    required this.label,
    required this.amount,
    this.prominent = false,
  });

  final String label;
  final int amount;
  final bool prominent;

  @override
  Widget build(BuildContext context) => Container(
    height: prominent ? 58 : 52,
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFE8EEEE))),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: prominent ? _headline : _row,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            amount < 0 ? '-${_formatCfa(amount.abs())}' : _formatCfa(amount),
            style: prominent ? _headline : _title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.title,
    required this.date,
    required this.amount,
    required this.positive,
  });

  final String title;
  final String date;
  final String amount;
  final bool positive;

  @override
  Widget build(BuildContext context) => Container(
    height: 70,
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFE8EEEE))),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: positive ? const Color(0xFFEAF8F0) : const Color(0xFFFFEAEA),
            shape: BoxShape.circle,
          ),
          child: Icon(
            positive
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: positive ? const Color(0xFF2F8D52) : const Color(0xFFE34E4E),
            size: 17,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title, style: _title), Text(date, style: _muted)],
          ),
        ),
        Text(
          amount,
          style: _title.copyWith(
            color: positive ? const Color(0xFF2F8D52) : const Color(0xFFE34E4E),
          ),
        ),
      ],
    ),
  );
}

class _PayoutBalanceCard extends StatelessWidget {
  const _PayoutBalanceCard({required this.amount, required this.onTap});

  final String amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFCFC),
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Solde disponible', style: _row),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF789094)),
          ],
        ),
        const SizedBox(height: 10),
        Text(amount, style: _financeCardAmount),
        const SizedBox(height: 16),
        _Button(label: 'Demander un versement', onTap: onTap),
      ],
    ),
  );
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow(this.date, this.amount);

  final String date;
  final String amount;

  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.calendar_month_outlined, color: AppColors.blueBic),
        const SizedBox(width: 12),
        Expanded(child: Text(date, style: _row)),
        Text(amount, style: _title.copyWith(color: const Color(0xFF2F8D52))),
      ],
    ),
  );
}

class _PaymentCoordinateTile extends StatelessWidget {
  const _PaymentCoordinateTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E8E6)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.blueBic,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _title),
                Text(subtitle, style: _muted, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF789094)),
        ],
      ),
    ),
  );
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap:
        () => _showPartnerSnack(
          context,
          'Téléchargement du relevé à raccorder au module PDF.',
        ),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E8E6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: _row)),
          Text('Télécharger (PDF)', style: _green),
        ],
      ),
    ),
  );
}

bool _isOpenOrder(Map<String, dynamic> order) {
  final status = '${order['status'] ?? ''}'.toLowerCase().trim();
  return !_isSettledOrder(order) &&
      !_isCanceledOrder(order) &&
      status != 'draft';
}

bool _isSettledOrder(Map<String, dynamic> order) {
  final status = '${order['status'] ?? ''}'.toLowerCase().trim();
  return status == 'picked_up' ||
      status == 'completed' ||
      status == 'finished' ||
      status == 'validated' ||
      status == 'collected';
}

bool _isCanceledOrder(Map<String, dynamic> order) {
  final status = '${order['status'] ?? ''}'.toLowerCase().trim();
  return status == 'canceled' || status == 'cancelled' || status == 'refunded';
}

int _orderQuantity(Map<String, dynamic> order) {
  final items = order['items'];
  if (items is List && items.isNotEmpty) {
    return items.fold<int>(0, (total, item) {
      if (item is! Map<String, dynamic>) return total;
      return total + _intValue(item['quantity']);
    });
  }
  return 1;
}

String _readString(
  Map<String, dynamic>? source,
  List<String> keys,
  String fallback,
) {
  for (final key in keys) {
    final value = source?[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return fallback;
}

const _fallbackPartnerProfile = <String, dynamic>{
  'ownerName': 'Moussa Fall',
  'storeName': 'Poissonnerie Chez Moussa',
  'businessName': 'Poissonnerie Chez Moussa',
  'address': 'Almadies',
  'city': 'Dakar',
  'status': 'approved',
  'averageRating': 4.9,
  'openingHoursText': '08:00 - 20:00',
};

class PartnerBasketsPage extends StatefulWidget {
  const PartnerBasketsPage({super.key});

  @override
  State<PartnerBasketsPage> createState() => _PartnerBasketsPageState();
}

class _PartnerBasketsPageState extends State<PartnerBasketsPage> {
  static const _storeId = 'store_yoff';
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _offers = const [];
  int _selectedTab = 0;

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
      final offers = await _partnerApiService.getStoreOffers(_storeId);
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offers = _fallbackPartnerOffers;
        _loadError = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _setOfferActive(Map<String, dynamic> offer, bool active) async {
    final offerId = offer['id'] as String?;
    final previousOffers = List<Map<String, dynamic>>.from(_offers);

    setState(() {
      _offers =
          _offers
              .map(
                (entry) =>
                    identical(entry, offer) || entry['id'] == offerId
                        ? {...entry, 'active': active}
                        : entry,
              )
              .toList();
    });

    if (offerId == null || offerId.startsWith('demo_')) return;

    try {
      await _partnerApiService.setOfferActive(offerId, active);
      await _loadOffers();
    } catch (_) {
      if (!mounted) return;
      setState(() => _offers = previousOffers);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de modifier ce panier.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  Future<void> _deleteOffer(Map<String, dynamic> offer) async {
    final offerId = offer['id'] as String?;
    final previousOffers = List<Map<String, dynamic>>.from(_offers);

    setState(() {
      _offers = _offers.where((entry) => !identical(entry, offer)).toList();
    });

    if (offerId == null || offerId.startsWith('demo_')) return;

    try {
      await _partnerApiService.deleteOffer(offerId);
      await _loadOffers();
    } catch (_) {
      if (!mounted) return;
      setState(() => _offers = previousOffers);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de supprimer ce panier.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _visibleOffers =>
      _offers.where((offer) => _offerTabIndex(offer) == _selectedTab).toList();

  @override
  Widget build(BuildContext context) {
    final visibleOffers = _visibleOffers;

    return _PartnerScaffold(
      title: 'Mes paniers',
      currentIndex: 1,
      child: Column(
        children: [
          _Tabs(
            const ['Actifs', 'Brouillons', 'Terminés'],
            selectedIndex: _selectedTab,
            onChanged: (index) => setState(() => _selectedTab = index),
          ),
          const SizedBox(height: 22),
          if (_loadError != null) ...[
            Text(_loadError!, style: _muted, textAlign: TextAlign.center),
            const SizedBox(height: 12),
          ],
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(color: AppColors.blueBic),
            )
          else if (visibleOffers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Text(_emptyOfferMessage, style: _sub),
            )
          else
            Expanded(
              child: RefreshIndicator(
                color: AppColors.blueBic,
                onRefresh: _loadOffers,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: visibleOffers.length,
                  itemBuilder: (context, index) {
                    final offer = visibleOffers[index];
                    final active = offer['active'] as bool? ?? true;
                    return _BasketRow(
                      image: _assetForOffer(index),
                      title: offer['name'] as String? ?? 'Panier',
                      subtitle:
                          offer['category'] as String? ??
                          offer['weightEstimate'] as String? ??
                          'Panier surprise',
                      price: _formatCfa(offer['unitAmount']),
                      active: active,
                      onTap: () async {
                        await context.push(
                          '/partner/basket-detail',
                          extra: offer,
                        );
                        if (mounted) await _loadOffers();
                      },
                      onToggle:
                          () => _setOfferActive(offer, active ? false : true),
                      onDelete: () => _deleteOffer(offer),
                    );
                  },
                ),
              ),
            ),
          if (_isLoading || visibleOffers.isEmpty) const Spacer(),
          _Button(
            label: '+ Créer un panier',
            onTap: () => context.go('/partner/new-basket'),
          ),
        ],
      ),
    );
  }

  String get _emptyOfferMessage {
    return switch (_selectedTab) {
      1 => 'Aucun brouillon',
      2 => 'Aucun panier terminé',
      _ => 'Aucun panier actif',
    };
  }
}

const _fallbackPartnerOffers = [
  {
    'id': 'demo_1',
    'name': 'Panier',
    'category': 'Poisson varié',
    'unitAmount': 12000,
    'active': true,
  },
  {
    'id': 'demo_2',
    'name': 'Panier mixte',
    'category': 'Poissons & crustacés',
    'unitAmount': 16000,
    'active': true,
  },
];

int _offerTabIndex(Map<String, dynamic> offer) {
  final status =
      '${offer['status'] ?? offer['state'] ?? ''}'.toLowerCase().trim();
  final quantitySource =
      offer['availableQuantity'] ?? offer['available_quantity'];
  final quantity = quantitySource == null ? null : _intValue(quantitySource);
  if (status == 'draft' || status == 'brouillon') return 1;
  if (status == 'ended' ||
      status == 'expired' ||
      status == 'completed' ||
      status == 'sold_out' ||
      status == 'soldout' ||
      quantity == 0) {
    return 2;
  }
  final active = offer['active'] as bool? ?? true;
  return active ? 0 : 1;
}

String _formatCfa(Object? value) {
  final amount = _intValue(value);
  return '${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} CFA';
}

String _formatMonthYear(DateTime date) {
  const months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

DateTime? _dateTimeValue(Object? value) {
  if (value is DateTime) return value;
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

DateTime? _financeMovementDateTime(Map<String, dynamic> order) {
  return _dateTimeValue(
    order['paidAt'] ??
        order['paid_at'] ??
        order['completedAt'] ??
        order['completed_at'] ??
        order['updatedAt'] ??
        order['updated_at'] ??
        order['createdAt'] ??
        order['created_at'],
  );
}

String _financeMovementDate(Map<String, dynamic> order) {
  final parsed = _financeMovementDateTime(order);
  if (parsed == null) return _pickupSlot(order);

  final local = parsed.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year}';
}

int _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value'.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
}

String _assetForOffer(int index) {
  const assets = [
    'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
    'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
    'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
  ];
  return assets[index % assets.length];
}

class PartnerBasketDetailPage extends StatefulWidget {
  const PartnerBasketDetailPage({super.key, required this.offer});

  final Map<String, dynamic> offer;

  @override
  State<PartnerBasketDetailPage> createState() =>
      _PartnerBasketDetailPageState();
}

class _PartnerBasketDetailPageState extends State<PartnerBasketDetailPage> {
  late Map<String, dynamic> _offer;

  @override
  void initState() {
    super.initState();
    _offer = Map<String, dynamic>.from(widget.offer);
  }

  Future<void> _openEdit() async {
    final updated = await context.push<Map<String, dynamic>>(
      '/partner/basket-edit',
      extra: _offer,
    );
    if (updated == null || !mounted) return;
    setState(() => _offer = updated);
  }

  @override
  Widget build(BuildContext context) {
    final title = _offer['name'] as String? ?? 'Panier du jour';
    final description =
        _offer['description'] as String? ??
        'Produits variés selon arrivage\ndu jour.';
    final category = _offer['category'] as String? ?? 'Poissons';
    final quantity = _offer['availableQuantity'];

    return _PartnerShell(
      title: 'Détail panier',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: _headline),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(_formatCfa(_offer['unitAmount']), style: _price),
              if (_offer['originalUnitAmount'] != null) ...[
                const SizedBox(width: 22),
                Text(_formatCfa(_offer['originalUnitAmount']), style: _strike),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Text(description, style: _body),
          const SizedBox(height: 14),
          Text('${quantity ?? 0} disponibles', style: _green),
          const Divider(height: 34, color: Color(0xFFE1E8E6)),
          Text('Contenu possible', style: _label),
          const SizedBox(height: 10),
          Text(
            '• $category\n• Selon arrivage\n• Fraîcheur du jour',
            style: _body,
          ),
          const Spacer(),
          _Button(label: 'Modifier', onTap: _openEdit),
        ],
      ),
    );
  }
}

class PartnerBasketEditPage extends StatefulWidget {
  const PartnerBasketEditPage({super.key, required this.offer});

  final Map<String, dynamic> offer;

  @override
  State<PartnerBasketEditPage> createState() => _PartnerBasketEditPageState();
}

class _PartnerBasketEditPageState extends State<PartnerBasketEditPage> {
  final PartnerApiService _partnerApiService = PartnerApiService();
  late final TextEditingController _nameController;
  late final TextEditingController _unitAmountController;
  late final TextEditingController _originalAmountController;
  late final TextEditingController _quantityController;
  Uint8List? _selectedPhotoBytes;
  bool _isPickingPhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.offer['name'] as String? ?? 'Panier du jour',
    );
    _unitAmountController = TextEditingController(
      text: '${widget.offer['unitAmount'] ?? 12000}',
    );
    _originalAmountController = TextEditingController(
      text: '${widget.offer['originalUnitAmount'] ?? 16000}',
    );
    _quantityController = TextEditingController(
      text: '${widget.offer['availableQuantity'] ?? 10}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitAmountController.dispose();
    _originalAmountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final offerId = widget.offer['id'] as String?;
    if (offerId == null || offerId.startsWith('demo_')) {
      _safePartnerBack(context, fallback: '/partner/baskets');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = await _partnerApiService.updateOffer(offerId, {
        'name': _nameController.text.trim(),
        'unitAmount': _parseAmount(_unitAmountController.text),
        'originalUnitAmount': _parseAmount(_originalAmountController.text),
        'availableQuantity': _parseAmount(_quantityController.text),
      });
      if (!mounted) return;
      if (context.canPop()) {
        context.pop(updated);
      } else {
        context.go('/partner/baskets');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’enregistrer ce panier')),
      );
    }
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto) return;
    setState(() => _isPickingPhoto = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _selectedPhotoBytes = bytes);
      _showPartnerSnack(context, 'Photo mise à jour en prévisualisation.');
    } catch (_) {
      if (!mounted) return;
      _showPartnerSnack(context, 'Impossible d’ouvrir la galerie.');
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Modifier le panier',
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_selectedPhotoBytes == null)
                Image.asset(
                  'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
                  height: 106,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Image.memory(
                  _selectedPhotoBytes!,
                  height: 106,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Image.asset('assets/images/logo.png', width: 82),
            ],
          ),
        ),
        TextButton(
          onPressed: _isPickingPhoto ? null : _pickPhoto,
          child: Text(
            _isPickingPhoto ? 'Ouverture...' : 'Modifier la photo',
            style: _green,
          ),
        ),
        _EditableField('Titre', _nameController),
        _EditableField(
          'Prix',
          _unitAmountController,
          keyboardType: TextInputType.number,
        ),
        _EditableField(
          'Prix d’origine',
          _originalAmountController,
          keyboardType: TextInputType.number,
        ),
        _EditableField(
          'Quantité disponible',
          _quantityController,
          keyboardType: TextInputType.number,
        ),
        const Spacer(),
        _Button(
          label: _isSaving ? 'Enregistrement...' : 'Enregistrer',
          onTap: _save,
        ),
      ],
    ),
  );
}

int _parseAmount(String value) {
  return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

class PartnerOrdersMobilePage extends StatefulWidget {
  const PartnerOrdersMobilePage({super.key});

  @override
  State<PartnerOrdersMobilePage> createState() =>
      _PartnerOrdersMobilePageState();
}

class _PartnerOrdersMobilePageState extends State<PartnerOrdersMobilePage> {
  static const _storeId = 'store_yoff';
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _orders = const [];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final reservations = await _partnerApiService.getStoreReservations(
        _storeId,
      );
      if (!mounted) return;
      setState(() {
        _orders = reservations;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _orders = _fallbackPartnerOrders;
        _loadError = null;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _visibleOrders =>
      _orders.where((order) => _orderTabIndex(order) == _selectedTab).toList();

  @override
  Widget build(BuildContext context) {
    final visibleOrders = _visibleOrders;

    return _PartnerScaffold(
      title: 'Commandes reçues',
      currentIndex: 2,
      child: Column(
        children: [
          _Tabs(
            const ['En attente', 'À préparer', 'Terminées'],
            selectedIndex: _selectedTab,
            onChanged: (index) => setState(() => _selectedTab = index),
          ),
          const SizedBox(height: 24),
          if (_loadError != null) ...[
            Text(_loadError!, style: _muted, textAlign: TextAlign.center),
            const SizedBox(height: 12),
          ],
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(color: AppColors.blueBic),
            )
          else if (visibleOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Text(_emptyOrderMessage, style: _sub),
            )
          else
            Expanded(
              child: RefreshIndicator(
                color: AppColors.blueBic,
                onRefresh: _loadOrders,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: visibleOrders.length,
                  itemBuilder: (context, index) {
                    final order = visibleOrders[index];
                    return _OrderRow(
                      id: _orderId(order),
                      client: _clientName(order),
                      pickupSlot: _pickupSlot(order),
                      status: _statusLabel(order),
                      onTap:
                          () => context.push(
                            '/partner/order-detail',
                            extra: order,
                          ),
                    );
                  },
                ),
              ),
            ),
          if (_isLoading || visibleOrders.isEmpty) const Spacer(),
        ],
      ),
    );
  }

  String get _emptyOrderMessage {
    return switch (_selectedTab) {
      1 => 'Aucune commande à préparer',
      2 => 'Aucune commande terminée',
      _ => 'Aucune commande en attente',
    };
  }
}

const _fallbackPartnerOrders = [
  {
    'order_id': 'DC-1254',
    'user_id': 'Ibrahima Kane',
    'status': 'paid',
    'amount': 12000,
    'pickup_slot': 'Aujourd’hui, 14:00',
    'items': [
      {'name': 'Panier du jour', 'quantity': 1, 'unitAmount': 12000},
    ],
  },
  {
    'order_id': 'DC-1253',
    'user_id': 'Aïssatou G.',
    'status': 'paid',
    'amount': 10000,
    'pickup_slot': 'Aujourd’hui, 15:00',
    'items': [
      {'name': 'Panier mixte', 'quantity': 1, 'unitAmount': 10000},
    ],
  },
];

const _fallbackPartnerPickups = [
  {
    'clientName': 'Sophie Diop',
    'pickupCode': '5287',
    'amount': 10000,
    'createdAt': '2025-05-08T12:15:00.000Z',
  },
  {
    'clientName': 'Mamadou Fall',
    'pickupCode': '7412',
    'amount': 10000,
    'createdAt': '2025-05-08T12:02:00.000Z',
  },
  {
    'clientName': 'Awa Niang',
    'pickupCode': '5632',
    'amount': 8000,
    'createdAt': '2025-05-07T18:40:00.000Z',
  },
  {
    'clientName': 'Ibrahima Kane',
    'pickupCode': '8521',
    'amount': 10000,
    'createdAt': '2025-05-07T17:25:00.000Z',
  },
  {
    'clientName': 'Thiemo Ba',
    'pickupCode': '3478',
    'amount': 10000,
    'createdAt': '2025-05-07T12:05:00.000Z',
  },
];

String _orderId(Map<String, dynamic> order) {
  final value = order['orderId'] ?? order['order_id'] ?? 'DC-0000';
  final id = '$value';
  return id.startsWith('#') ? id : '#$id';
}

String _clientName(Map<String, dynamic> order) {
  return '${order['clientName'] ?? order['user_id'] ?? 'Client'}';
}

String _pickupSlot(Map<String, dynamic> order) {
  return '${order['pickupSlot'] ?? order['pickup_slot'] ?? 'Créneau à confirmer'}';
}

String _statusLabel(Map<String, dynamic> order) {
  return switch ('${order['status'] ?? ''}') {
    'paid' => 'En attente',
    'pending' => 'En attente',
    'pending_payment' => 'En attente',
    'confirmed' => 'En attente',
    'accepted' => 'À préparer',
    'preparing' => 'À préparer',
    'pickup_ready' => 'À préparer',
    'picked_up' => 'Terminée',
    'completed' => 'Terminée',
    'canceled' => 'Annulée',
    'cancelled' => 'Annulée',
    _ => 'En attente',
  };
}

int _orderTabIndex(Map<String, dynamic> order) {
  return switch ('${order['status'] ?? ''}'.toLowerCase().trim()) {
    'accepted' || 'preparing' || 'pickup_ready' => 1,
    'picked_up' || 'completed' || 'finished' || 'canceled' || 'cancelled' => 2,
    _ => 0,
  };
}

class PartnerOrderDetailMobilePage extends StatelessWidget {
  const PartnerOrderDetailMobilePage({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    return _PartnerShell(
      title: 'Détail commande',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Commande ${_orderId(order)}', style: _headline),
              ),
              const SizedBox(width: 10),
              _Badge(_statusLabel(order), color: const Color(0xFFFFF0D7)),
            ],
          ),
          const SizedBox(height: 34),
          _Info('Client', _clientName(order)),
          _Info('Panier', _orderItemsSummary(order)),
          const Divider(height: 36, color: Color(0xFFE1E8E6)),
          _Info('À retirer avant', _pickupSlot(order)),
          const SizedBox(height: 18),
          Text('Validation retrait', style: _label),
          const SizedBox(height: 10),
          Text(
            'Scannez ou saisissez le code présenté par le client.',
            style: _body,
          ),
          const Spacer(),
          _Button(
            label: 'Scanner le code',
            onTap: () => context.push('/partner/scan-code', extra: order),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.push('/partner/manual-code', extra: order),
            child: Text('Saisir manuellement', style: _green),
          ),
          const SizedBox(height: 12),
          _Button(
            label: 'Voir le profil client',
            onTap: () => context.push('/partner/client-profile'),
          ),
        ],
      ),
    );
  }
}

String _orderItemsSummary(Map<String, dynamic> order) {
  final items = order['items'];
  if (items is List && items.isNotEmpty) {
    final first = items.first as Map<String, dynamic>;
    final name = first['name'] ?? 'Panier';
    final quantity = first['quantity'] ?? 1;
    final amount =
        first['unitAmount'] ?? first['unit_amount'] ?? order['amount'];
    return '$name\n${_formatCfa(amount)}  ${quantity}x';
  }
  return 'Panier\n${_formatCfa(order['amount'])}  1x';
}

class PartnerScanCodePage extends StatelessWidget {
  const PartnerScanCodePage({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF1C2A2B),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed:
                      () => _safePartnerBack(
                        context,
                        fallback: '/partner/orders',
                      ),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Spacer(),
                Text('Scanner code retrait', style: _whiteHeader),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 36),
            Text('Scanner le code', style: _whiteTitle),
            const Spacer(),
            Container(
              width: 150,
              height: 58,
              alignment: Alignment.center,
              color: Colors.white.withValues(alpha: .65),
              child: Text('5287', style: _scanCode),
            ),
            const SizedBox(height: 36),
            Container(
              width: 230,
              height: 170,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/partner/manual-code', extra: order),
              child: Text('Saisir le code manuellement', style: _whiteLink),
            ),
          ],
        ),
      ),
    ),
  );
}

class PartnerPickupValidatedPage extends StatelessWidget {
  const PartnerPickupValidatedPage({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Retrait confirmé',
    child: Column(
      children: [
        const Spacer(),
        const Icon(Icons.check_circle, size: 118, color: Color(0xFF36B15D)),
        const SizedBox(height: 46),
        Text('Retrait validé !', style: _bigTitle),
        const SizedBox(height: 22),
        Text(
          'La commande ${_orderId(order)} a été\nretirée avec succès.',
          textAlign: TextAlign.center,
          style: _body,
        ),
        const Spacer(),
        _Button(label: 'OK', onTap: () => context.go('/partner/orders')),
      ],
    ),
  );
}

class PartnerActivityPage extends StatelessWidget {
  const PartnerActivityPage({super.key});

  @override
  Widget build(BuildContext context) => _PartnerScaffold(
    title: 'Activité validée',
    currentIndex: 0,
    child: Column(
      children: [
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E8E6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cette semaine', style: _row),
              const Icon(Icons.keyboard_arrow_down, size: 17),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _StatBox('8k', 'abonnés'),
        const _StatBox('318', 'commandes'),
        const _StatBox('450 000 CFA', 'Chiffre d’affaires'),
        const _StatBox('Coupons', 'En cours', danger: true),
      ],
    ),
  );
}

class PartnerStatsPage extends StatelessWidget {
  const PartnerStatsPage({super.key});

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Data maintenance',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E8E6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text('Cette semaine', style: _row),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
            height: 108,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 28),
        Text('CA mensuelle', style: _label),
        const SizedBox(height: 16),
        SizedBox(
          height: 178,
          child: CustomPaint(painter: _ChartPainter(), child: Container()),
        ),
        const Spacer(),
        _Button(
          label: 'Voir plus de stats',
          onTap: () => context.go('/partner/activity'),
        ),
      ],
    ),
  );
}

class PartnerCommerceSettingsPage extends StatefulWidget {
  const PartnerCommerceSettingsPage({super.key});

  @override
  State<PartnerCommerceSettingsPage> createState() =>
      _PartnerCommerceSettingsPageState();
}

class _PartnerCommerceSettingsPageState
    extends State<PartnerCommerceSettingsPage> {
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final profile = await _partnerApiService.getMyProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profile = _fallbackPartnerProfile;
        _loadError = null;
        _isLoading = false;
      });
    }
  }

  String get _storeName => _readString(_profile, const [
    'storeName',
    'store_name',
    'businessName',
  ], 'Poissonnerie Chez Moussa');

  String get _address {
    final address = _readString(_profile, const [
      'address',
      'streetAddress',
    ], 'Almadies');
    final city = _readString(_profile, const ['city'], 'Dakar');
    if (address.toLowerCase().contains(city.toLowerCase())) return address;
    return '$address, $city, Sénégal';
  }

  String get _hours {
    final openingHours = _profile?['openingHours'];
    if (openingHours is Map && openingHours.isNotEmpty) {
      final firstValue = openingHours.values.first.toString().trim();
      if (firstValue.isNotEmpty) return firstValue;
    }
    return _readString(_profile, const [
      'hours',
      'openingHoursText',
    ], '08:00 - 20:00');
  }

  String get _status {
    return switch (_profile?['status']?.toString()) {
      'approved' => 'Compte validé',
      'rejected' => 'Compte refusé',
      'pending_review' || 'pending' => 'En attente de validation',
      _ => 'Non soumis',
    };
  }

  @override
  Widget build(BuildContext context) => _PartnerScaffold(
    title: 'Paramètres commerce',
    currentIndex: 4,
    child: RefreshIndicator(
      color: AppColors.blueBic,
      onRefresh: _loadProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
          if (_isLoading) const SizedBox(height: 14),
          if (_loadError != null) ...[
            _PartnerNotice(message: _loadError!, onRetry: _loadProfile),
            const SizedBox(height: 14),
          ],
          Text('Mon commerce', style: _label),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
              height: 116,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 22),
          _Field('Nom du commerce', _storeName),
          _Field('Adresse', _address),
          _Field('Horaires', _hours),
          _Field('Statut', _status),
          const SizedBox(height: 8),
          _MenuRow(
            Icons.schedule_outlined,
            'Horaires d’ouverture',
            onTap: () => context.push('/partner/opening-hours'),
          ),
          _MenuRow(
            Icons.description_outlined,
            'Mes documents',
            onTap: () => context.push('/partner/documents-mobile'),
          ),
          _MenuRow(
            Icons.verified_outlined,
            'Validation du compte',
            onTap: () => context.push('/partner/validation-status'),
          ),
          _MenuRow(
            Icons.local_offer_outlined,
            'Promotions',
            onTap: () => context.push('/partner/promotions'),
          ),
          const SizedBox(height: 18),
        ],
      ),
    ),
  );
}

class PartnerNewBasketStepOnePage extends StatefulWidget {
  const PartnerNewBasketStepOnePage({super.key});

  @override
  State<PartnerNewBasketStepOnePage> createState() =>
      _PartnerNewBasketStepOnePageState();
}

class _PartnerNewBasketStepOnePageState
    extends State<PartnerNewBasketStepOnePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _weightController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _originalPriceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _PartnerBasketDraft.name);
    _descriptionController = TextEditingController(
      text: _PartnerBasketDraft.description,
    );
    _categoryController = TextEditingController(
      text: _PartnerBasketDraft.category,
    );
    _weightController = TextEditingController(
      text: _PartnerBasketDraft.weightEstimate,
    );
    _quantityController = TextEditingController(
      text: '${_PartnerBasketDraft.availableQuantity}',
    );
    _priceController = TextEditingController(
      text: '${_PartnerBasketDraft.unitAmount}',
    );
    _originalPriceController = TextEditingController(
      text: '${_PartnerBasketDraft.originalUnitAmount}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _categoryController.text.trim();
    final quantity = _parseAmount(_quantityController.text);
    final unitAmount = _parseAmount(_priceController.text);
    final originalUnitAmount = _parseAmount(_originalPriceController.text);

    if (name.isEmpty || category.isEmpty || quantity <= 0 || unitAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complétez le nom, la catégorie, la quantité et le prix.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    _PartnerBasketDraft.name = name;
    _PartnerBasketDraft.description =
        description.isEmpty ? _PartnerBasketDraft.description : description;
    _PartnerBasketDraft.category = category;
    _PartnerBasketDraft.weightEstimate =
        _weightController.text.trim().isEmpty
            ? _PartnerBasketDraft.weightEstimate
            : _weightController.text.trim();
    _PartnerBasketDraft.availableQuantity = quantity;
    _PartnerBasketDraft.unitAmount = unitAmount;
    _PartnerBasketDraft.originalUnitAmount =
        originalUnitAmount <= 0 ? unitAmount : originalUnitAmount;
    context.go('/partner/new-basket/photos');
  }

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Nouveau panier',
    child: Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const _Progress('1/4  Infos de base', .25),
              const SizedBox(height: 22),
              _EditableField('Nom du panier', _nameController),
              _EditableField(
                'Description',
                _descriptionController,
                maxLines: 3,
              ),
              _EditableField('Catégorie', _categoryController),
              _EditableField('Poids estimé', _weightController),
              _EditableField(
                'Quantité disponible',
                _quantityController,
                keyboardType: TextInputType.number,
              ),
              _EditableField(
                'Prix',
                _priceController,
                keyboardType: TextInputType.number,
              ),
              _EditableField(
                'Prix conseillé',
                _originalPriceController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        _Button(label: 'Suivant', onTap: _saveAndContinue),
      ],
    ),
  );
}

class PartnerNewBasketPhotosPage extends StatefulWidget {
  const PartnerNewBasketPhotosPage({super.key});

  @override
  State<PartnerNewBasketPhotosPage> createState() =>
      _PartnerNewBasketPhotosPageState();
}

class _PartnerNewBasketPhotosPageState
    extends State<PartnerNewBasketPhotosPage> {
  final PartnerApiService _partnerApiService = PartnerApiService();
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _remotePhotoUrls = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Nouveau panier',
    child: LayoutBuilder(
      builder: (context, constraints) {
        final photoHeight =
            ((constraints.maxWidth - 10) / 2).clamp(112.0, 142.0).toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Progress('2/4  Photos', .5),
            const SizedBox(height: 22),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ajoutez jusqu’à 6 photos', style: _label),
                    const SizedBox(height: 14),
                    GridView.builder(
                      itemCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: photoHeight,
                      ),
                      itemBuilder: (context, index) {
                        const assets = [
                          'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
                          'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
                          'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
                          'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
                        ];
                        return _PhotoBox(assets[index]);
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _isUploading ? null : _pickAndUploadOfferPhoto,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 104,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFBBD0D0),
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isUploading)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(Icons.add, size: 30),
                            const SizedBox(height: 8),
                            Text(
                              _remotePhotoUrls.isEmpty
                                  ? 'Ajouter des photos'
                                  : '${_remotePhotoUrls.length} photo(s) envoyée(s)',
                              style: _row,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            _Button(
              label: 'Suivant',
              onTap: () => context.go('/partner/recurring-slots'),
            ),
          ],
        );
      },
    ),
  );

  Future<void> _pickAndUploadOfferPhoto() async {
    if (_remotePhotoUrls.length >= 6) {
      _showMessage('Maximum 6 photos par panier.');
      return;
    }
    final photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
      maxWidth: 1800,
    );
    if (photo == null) return;

    setState(() => _isUploading = true);
    try {
      final bytes = await photo.readAsBytes();
      final storageUrl = await _partnerApiService.uploadOfferMediaBytes(
        fileName: photo.name,
        contentType: _contentTypeForFile(photo.name, fallback: 'image/jpeg'),
        bytes: bytes,
      );
      if (!mounted) return;
      setState(() {
        _remotePhotoUrls.add(storageUrl);
        _PartnerBasketDraft.mediaUrls = List.of(_remotePhotoUrls);
        _isUploading = false;
      });
      _showMessage('Photo envoyée.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      _showMessage('Upload impossible pour le moment.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins())),
    );
  }
}

class PartnerRecurringSlotsPage extends StatefulWidget {
  const PartnerRecurringSlotsPage({super.key});

  @override
  State<PartnerRecurringSlotsPage> createState() =>
      _PartnerRecurringSlotsPageState();
}

class _PartnerRecurringSlotsPageState extends State<PartnerRecurringSlotsPage> {
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isPublishing = false;

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Créneaux récurrents',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez les jours et créneaux\noù ce panier sera disponible',
          style: _body,
        ),
        const SizedBox(height: 26),
        Text('Répéter chaque semaine', style: _label),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
                  .map(
                    (d) => _DayChip(
                      d,
                      active: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'].contains(d),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 28),
        Text('Créneaux disponibles', style: _label),
        const SizedBox(height: 12),
        const _SwitchSlot('08:00 - 10:00', false),
        const _SwitchSlot('12:00 - 14:00', true),
        const _SwitchSlot('16:00 - 18:00', false),
        const SizedBox(height: 12),
        _LightButton(
          '+ Ajouter un créneau',
          onTap: () => context.push('/partner/calendar'),
        ),
        const Spacer(),
        _Button(
          label: _isPublishing ? 'Publication...' : 'Publier le panier',
          onTap: _isPublishing ? () {} : _publishBasket,
        ),
      ],
    ),
  );

  Future<void> _publishBasket() async {
    setState(() => _isPublishing = true);
    final now = DateTime.now();
    final firstSlotStart = DateTime(now.year, now.month, now.day, 17);
    final firstSlotEnd = DateTime(now.year, now.month, now.day, 19);
    final secondSlotStart = DateTime(now.year, now.month, now.day, 19);
    final secondSlotEnd = DateTime(now.year, now.month, now.day, 21);
    try {
      await _partnerApiService.createOffer(
        PartnerOfferRequest(
          storeId: 'store_yoff',
          storeName: 'Poissonnerie Yoff',
          name: _PartnerBasketDraft.name,
          description: _PartnerBasketDraft.description,
          category: _PartnerBasketDraft.category,
          weightEstimate: _PartnerBasketDraft.weightEstimate,
          unitAmount: _PartnerBasketDraft.unitAmount,
          originalUnitAmount: _PartnerBasketDraft.originalUnitAmount,
          availableQuantity: _PartnerBasketDraft.availableQuantity,
          pickupStartsAt: firstSlotStart,
          pickupEndsAt: firstSlotEnd,
          latitude: 14.7603,
          longitude: -17.4732,
          mediaUrls: _PartnerBasketDraft.mediaUrls,
          pickupSlots: [
            {
              'startsAt': firstSlotStart.toUtc().toIso8601String(),
              'endsAt': firstSlotEnd.toUtc().toIso8601String(),
              'availableQuantity': _PartnerBasketDraft.availableQuantity,
            },
            {
              'startsAt': secondSlotStart.toUtc().toIso8601String(),
              'endsAt': secondSlotEnd.toUtc().toIso8601String(),
              'availableQuantity': _PartnerBasketDraft.availableQuantity,
            },
          ],
        ),
      );
      if (!mounted) return;
      _PartnerBasketDraft.reset();
      setState(() => _isPublishing = false);
      context.go('/partner/basket-published');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Publication impossible pour le moment.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }
}

class PartnerCalendarPage extends StatelessWidget {
  const PartnerCalendarPage({super.key});

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Calendrier',
    child: Column(
      children: [
        Row(
          children: [
            const Icon(Icons.chevron_left),
            const Spacer(),
            Text('Mai 2025', style: _headline),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            35,
            (i) => Center(
              child: Text('${(i % 31) + 1}', style: i == 7 ? _green : _row),
            ),
          ),
        ),
        const Divider(height: 28),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('jeu. 6 mai 2025', style: _label),
        ),
        const SizedBox(height: 12),
        const _SwitchSlot('08:00 - 10:00', true),
        const _SwitchSlot('12:00 - 14:00', true),
        const _SwitchSlot('16:00 - 18:00', false),
        const Spacer(),
        _Button(
          label: 'Ajouter un créneau',
          onTap:
              () => _safePartnerBack(
                context,
                fallback: '/partner/recurring-slots',
              ),
        ),
      ],
    ),
  );
}

class PartnerOpeningHoursPage extends StatelessWidget {
  const PartnerOpeningHoursPage({super.key});

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Horaires d’ouverture',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Définissez vos horaires d’ouverture\npour les retraits',
          style: _body,
        ),
        const SizedBox(height: 24),
        for (final item in const [
          ('Lundi', '08:00  -  20:00'),
          ('Mardi', '08:00  -  20:00'),
          ('Mercredi', '08:00  -  20:00'),
          ('Jeudi', '08:00  -  20:00'),
          ('Vendredi', '08:00  -  22:00'),
          ('Samedi', '08:00  -  22:00'),
          ('Dimanche', '08:00  -  18:00'),
        ])
          _HourRow(item.$1, item.$2),
        const Spacer(),
        _Button(
          label: 'Enregistrer',
          onTap:
              () => _safePartnerBack(
                context,
                fallback: '/partner/commerce-settings',
              ),
        ),
      ],
    ),
  );
}

class PartnerDocumentsMobilePage extends StatefulWidget {
  const PartnerDocumentsMobilePage({super.key});

  @override
  State<PartnerDocumentsMobilePage> createState() =>
      _PartnerDocumentsMobilePageState();
}

class _PartnerDocumentsMobilePageState
    extends State<PartnerDocumentsMobilePage> {
  final PartnerApiService _partnerApiService = PartnerApiService();
  final Map<String, Map<String, dynamic>> _documentsByType = {};
  bool _isLoading = true;
  bool _isUploading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final documents = await _partnerApiService.getMyDocuments();
      final documentsByType = <String, Map<String, dynamic>>{};
      for (final document in documents) {
        final type = document['documentType']?.toString();
        if (type == null || type.isEmpty) continue;
        documentsByType.putIfAbsent(type, () => document);
      }

      if (!mounted) return;
      setState(() {
        _documentsByType
          ..clear()
          ..addAll(documentsByType);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Documents indisponibles pour le moment.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Mes documents',
    child: ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        if (_isLoading) const LinearProgressIndicator(minHeight: 2),
        if (_isLoading) const SizedBox(height: 12),
        if (_loadError != null) ...[
          _PartnerNotice(message: _loadError!, onRetry: _loadDocuments),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.blueBic),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ces documents sont nécessaires\npour la validation de votre compte.',
                  style: _row,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _DocumentRow(
          'Pièce d’identité',
          'Carte nationale d’identité',
          _isDocumentAdded('id_card'),
          statusText: _documentStatusText('id_card'),
          statusColor: _documentStatusColor('id_card'),
          onTap: () => _pickAndUploadDocument('id_card'),
        ),
        _DocumentRow(
          'Registre de commerce',
          'Extrait RCCM',
          _isDocumentAdded('business_registration'),
          statusText: _documentStatusText('business_registration'),
          statusColor: _documentStatusColor('business_registration'),
          onTap: () => _pickAndUploadDocument('business_registration'),
        ),
        _DocumentRow(
          'Attestation de domicile',
          'Moins de 3 mois',
          _isDocumentAdded('proof_of_address'),
          statusText: _documentStatusText('proof_of_address'),
          statusColor: _documentStatusColor('proof_of_address'),
          onTap: () => _pickAndUploadDocument('proof_of_address'),
        ),
        _UploadBox(
          isUploading: _isUploading,
          onTap: () => _pickAndUploadDocument('proof_of_address'),
        ),
        _DocumentRow(
          'Autorisation / Agrément',
          'Pour la vente de produits de la mer',
          _isDocumentAdded('license'),
          statusText: _documentStatusText('license'),
          statusColor: _documentStatusColor('license'),
          onTap: () => _pickAndUploadDocument('license'),
        ),
        _UploadBox(
          isUploading: _isUploading,
          onTap: () => _pickAndUploadDocument('license'),
        ),
        const SizedBox(height: 16),
        Text('Documents acceptés : PDF, JPG, PNG (max 5Mo)', style: _muted),
      ],
    ),
  );

  Future<void> _pickAndUploadDocument(String documentType) async {
    if (_isUploading) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    if (bytes.length > 5 * 1000 * 1000) {
      _showMessage('Document trop lourd. Maximum 5 Mo.');
      return;
    }

    setState(() => _isUploading = true);
    try {
      await _partnerApiService.uploadDocumentBytes(
        documentType: documentType,
        fileName: file.name,
        contentType: _contentTypeForFile(
          file.name,
          fallback: 'application/pdf',
        ),
        bytes: bytes,
      );
      if (!mounted) return;
      setState(() {
        _documentsByType[documentType] = {
          'documentType': documentType,
          'fileName': file.name,
          'status': 'pending_review',
        };
        _isUploading = false;
      });
      _showMessage('Document envoyé.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      _showMessage('Upload du document impossible.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins())),
    );
  }

  bool _isDocumentAdded(String documentType) {
    final status = _documentsByType[documentType]?['status']?.toString();
    return status != null && status != 'rejected';
  }

  String _documentStatusText(String documentType) {
    final status = _documentsByType[documentType]?['status']?.toString();
    return switch (status) {
      'approved' => 'Validé',
      'rejected' => 'Refusé',
      'pending_review' => 'En revue',
      _ => 'À ajouter',
    };
  }

  Color _documentStatusColor(String documentType) {
    final status = _documentsByType[documentType]?['status']?.toString();
    return switch (status) {
      'approved' => Colors.green,
      'rejected' => Colors.redAccent,
      'pending_review' => const Color(0xFFFFA726),
      _ => AppColors.greenTGTG,
    };
  }
}

class PartnerValidationStatusPage extends StatefulWidget {
  const PartnerValidationStatusPage({super.key});

  @override
  State<PartnerValidationStatusPage> createState() =>
      _PartnerValidationStatusPageState();
}

class _PartnerValidationStatusPageState
    extends State<PartnerValidationStatusPage> {
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _status;
  String? _rejectionReason;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final profile = await _partnerApiService.getMyProfile();
      if (!mounted) return;
      setState(() {
        _status = profile?['status']?.toString();
        _rejectionReason = profile?['rejectionReason']?.toString();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Statut indisponible pour le moment.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Validation compte',
    child: Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(minHeight: 2),
        if (_loadError != null) ...[
          _PartnerNotice(message: _loadError!, onRetry: _loadStatus),
          const SizedBox(height: 12),
        ],
        _currentStatusCard(context),
      ],
    ),
  );

  Widget _currentStatusCard(BuildContext context) {
    switch (_status) {
      case 'approved':
        return _StatusCard(
          Icons.check,
          'Compte validé',
          'Votre compte vendeur est maintenant\nvalidé. Vous pouvez publier.',
          'Créer un panier',
          Colors.green,
          () => context.go('/partner/new-basket'),
        );
      case 'rejected':
        return _StatusCard(
          Icons.close,
          'Compte refusé',
          _rejectionReason?.isNotEmpty == true
              ? _rejectionReason!
              : 'Veuillez vérifier les documents et\nsoumettre une nouvelle demande.',
          'Voir les détails',
          Colors.redAccent,
          () => context.go('/partner/documents-mobile'),
        );
      case 'pending_review':
      case 'pending':
        return _StatusCard(
          Icons.schedule,
          'En attente de validation',
          'Votre compte est en cours d’examen\npar notre équipe.',
          'Voir mes documents',
          const Color(0xFFFFA726),
          () => context.go('/partner/documents-mobile'),
        );
      default:
        return _StatusCard(
          Icons.storefront_outlined,
          'Compte non soumis',
          'Complétez votre profil commerce et\najoutez vos documents.',
          'Commencer',
          AppColors.blueBic,
          () => context.go('/partner/type'),
        );
    }
  }
}

class PartnerClientChatPage extends StatefulWidget {
  const PartnerClientChatPage({super.key});

  @override
  State<PartnerClientChatPage> createState() => _PartnerClientChatPageState();
}

class _PartnerClientChatPageState extends State<PartnerClientChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<_PartnerClientMessage> _messages = [
    const _PartnerClientMessage(
      'Bonjour, j’aimerais savoir si le panier de ce matin contient des crevettes ?',
      false,
    ),
    const _PartnerClientMessage(
      'Bonjour Sophie ! Oui, il y a des crevettes fraîches dans ce panier.',
      true,
    ),
    const _PartnerClientMessage('Parfait, je le réserve alors.', false),
    const _PartnerClientMessage(
      'Merci beaucoup ! Votre commande est confirmée.',
      true,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_PartnerClientMessage(text, true));
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed:
                      () => _safePartnerBack(
                        context,
                        fallback: '/partner/orders',
                      ),
                  icon: const Icon(Icons.arrow_back, color: AppColors.blueBic),
                ),
                const CircleAvatar(radius: 19, child: Text('SD')),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sophie D.', style: _title),
                      Text('Commande #DC-1254', style: _muted),
                    ],
                  ),
                ),
                IconButton(
                  onPressed:
                      () => _showPartnerSnack(
                        context,
                        'Appel vendeur-client prêt à raccorder.',
                      ),
                  icon: const Icon(Icons.phone, color: AppColors.blueBic),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(22),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(message.text, message.mine);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: _row,
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      hintStyle: _muted,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE1E8E6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.blueBic),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  backgroundColor: AppColors.blueBic,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PartnerClientMessage {
  const _PartnerClientMessage(this.text, this.mine);

  final String text;
  final bool mine;
}

class PartnerClientProfilePage extends StatelessWidget {
  const PartnerClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Détail client',
    child: Column(
      children: [
        const CircleAvatar(radius: 42, child: Text('SD')),
        const SizedBox(height: 12),
        Text('Sophie Diop', style: _headline),
        _Badge('Client régulier'),
        const SizedBox(height: 26),
        _Info('Téléphone', '+221 77 123 45 67'),
        _Info('Email', 'sophie.diop@email.com'),
        _Info('Membre depuis', '15 mars 2024'),
        _Info('Commandes', '28 commandes'),
        _Info('Total dépensé', '245 000 CFA'),
        const _Field('Notes', 'Cliente fidèle, ponctuelle\net respectueuse.'),
        const Spacer(),
        _Button(
          label: 'Voir ses commandes',
          onTap: () => context.go('/partner/orders'),
        ),
      ],
    ),
  );
}

class PartnerManualCodePage extends StatefulWidget {
  const PartnerManualCodePage({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  State<PartnerManualCodePage> createState() => _PartnerManualCodePageState();
}

class _PartnerManualCodePageState extends State<PartnerManualCodePage> {
  final PaymentApiService _paymentApiService = PaymentApiService();
  final TextEditingController _codeController = TextEditingController();
  bool _isValidating = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final orderId = _orderApiId(widget.order);
    final pickupCode = _codeController.text.trim();
    if (pickupCode.isEmpty) return;

    if (_isDemoOrder(widget.order)) {
      context.go('/partner/pickup-validated', extra: widget.order);
      return;
    }

    setState(() => _isValidating = true);
    try {
      await _paymentApiService.completePickup(
        orderId: orderId,
        pickupCode: pickupCode,
      );
      if (!mounted) return;
      context.go('/partner/pickup-validated', extra: widget.order);
    } catch (_) {
      if (!mounted) return;
      context.go('/partner/invalid-code', extra: widget.order);
    }
  }

  @override
  Widget build(BuildContext context) => _PartnerScaffold(
    title: 'Saisir le code',
    currentIndex: 3,
    child: Column(
      children: [
        Text('Entrez le code de retrait', style: _label),
        const SizedBox(height: 30),
        TextField(
          controller: _codeController,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          style: _code,
          decoration: InputDecoration(
            hintText: 'Code client',
            hintStyle: _muted,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1E8E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.blueBic),
            ),
          ),
        ),
        const Divider(height: 50),
        _Info('Commande ${_orderId(widget.order)}', ''),
        _Info('Client', _clientName(widget.order)),
        _Info('Heure de retrait', _pickupSlot(widget.order)),
        const Spacer(),
        _Button(
          label: _isValidating ? 'Validation...' : 'Valider le code',
          onTap: _validateCode,
        ),
      ],
    ),
  );
}

String _orderApiId(Map<String, dynamic> order) {
  return '${order['orderId'] ?? order['order_id'] ?? ''}'.replaceFirst('#', '');
}

bool _isDemoOrder(Map<String, dynamic> order) {
  final id = _orderApiId(order);
  return id.startsWith('DC-') || id.isEmpty;
}

class PartnerInvalidCodePage extends StatelessWidget {
  const PartnerInvalidCodePage({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Code invalide',
    child: Column(
      children: [
        const Spacer(),
        const Icon(Icons.cancel, size: 120, color: Colors.redAccent),
        const SizedBox(height: 34),
        Text('Code invalide', style: _bigTitle),
        const SizedBox(height: 16),
        Text(
          'Le code saisi n’est pas valide\nou a déjà été utilisé.',
          textAlign: TextAlign.center,
          style: _body,
        ),
        const SizedBox(height: 28),
        Text(
          '• Vérifiez le code et réessayez\n• Demandez au client de vérifier\n  son code de retrait',
          style: _body,
        ),
        const Spacer(),
        _Button(
          label: 'Réessayer',
          onTap: () => context.go('/partner/manual-code', extra: order),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed:
              () => _safePartnerBack(context, fallback: '/partner/orders'),
          child: Text('Annuler', style: _green),
        ),
      ],
    ),
  );
}

class PartnerValidatedPickupsPage extends StatefulWidget {
  const PartnerValidatedPickupsPage({super.key});

  @override
  State<PartnerValidatedPickupsPage> createState() =>
      _PartnerValidatedPickupsPageState();
}

class _PartnerValidatedPickupsPageState
    extends State<PartnerValidatedPickupsPage> {
  static const _storeId = 'store_yoff';
  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _pickups = const [];

  @override
  void initState() {
    super.initState();
    _loadPickups();
  }

  Future<void> _loadPickups() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final pickups = await _partnerApiService.getStorePickups(_storeId);
      if (!mounted) return;
      setState(() {
        _pickups = pickups;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pickups = _fallbackPartnerPickups;
        _loadError = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => _PartnerScaffold(
    title: 'Retraits validés',
    currentIndex: 3,
    child: Column(
      children: [
        _InputBox('Cette semaine'),
        const SizedBox(height: 16),
        if (_loadError != null) ...[
          Text(_loadError!, style: _muted, textAlign: TextAlign.center),
          const SizedBox(height: 12),
        ],
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: CircularProgressIndicator(color: AppColors.blueBic),
          )
        else if (_pickups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Text('Aucun retrait validé', style: _sub),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: AppColors.blueBic,
              onRefresh: _loadPickups,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _pickups.length,
                itemBuilder: (context, index) {
                  final pickup = _pickups[index];
                  return _PickupHistoryRow(
                    _pickupClientName(pickup),
                    _pickupHistoryCode(pickup),
                    _formatCfa(pickup['amount']),
                    dateLine: _pickupHistoryDate(pickup),
                  );
                },
              ),
            ),
          ),
        if (_isLoading || _pickups.isEmpty) const Spacer(),
      ],
    ),
  );
}

class PartnerPromotionsPage extends StatefulWidget {
  const PartnerPromotionsPage({super.key});

  @override
  State<PartnerPromotionsPage> createState() => _PartnerPromotionsPageState();
}

class _PartnerPromotionsPageState extends State<PartnerPromotionsPage> {
  static const _storeId = 'store_yoff';
  static const _fallbackPromotions = [
    {
      'title': '-10% sur les paniers poisson',
      'code': 'POISSON10',
      'active': true,
      'endsAt': '2027-05-30T23:59:59.000Z',
      'usageCount': 24,
    },
    {
      'title': 'Livraison gratuite',
      'code': 'LIVRAISON',
      'active': true,
      'endsAt': '2027-05-30T23:59:59.000Z',
      'usageCount': 15,
    },
    {
      'title': '-15% dès 3 paniers',
      'code': '3PANIERS',
      'active': false,
      'endsAt': '2027-06-10T23:59:59.000Z',
      'usageCount': 0,
    },
  ];

  final PartnerApiService _partnerApiService = PartnerApiService();
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _promotions = const [];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final promotions = await _partnerApiService.getStorePromotions(_storeId);
      if (!mounted) return;
      setState(() {
        _promotions = promotions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _promotions = _fallbackPromotions;
        _loadError = null;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _visiblePromotions =>
      _promotions
          .where((promotion) => _promotionTabIndex(promotion) == _selectedTab)
          .toList();

  Future<void> _setPromotionActive(
    Map<String, dynamic> promotion,
    bool active,
  ) async {
    final previousPromotions = List<Map<String, dynamic>>.from(_promotions);
    final promotionId = promotion['id'] as String?;

    setState(() {
      _promotions =
          _promotions
              .map(
                (entry) =>
                    identical(entry, promotion) || entry['id'] == promotionId
                        ? {...entry, 'active': active}
                        : entry,
              )
              .toList();
    });

    if (promotionId == null || promotionId.startsWith('demo_')) return;

    try {
      final updated = await _partnerApiService.setPromotionActive(
        promotionId,
        active,
      );
      if (!mounted) return;
      setState(() {
        _promotions =
            _promotions
                .map((entry) => entry['id'] == promotionId ? updated : entry)
                .toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _promotions = previousPromotions);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de modifier cette promotion.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visiblePromotions = _visiblePromotions;

    return _PartnerScaffold(
      title: 'Promotions',
      currentIndex: 3,
      child: Column(
        children: [
          _Tabs(
            const ['En cours', 'Passées'],
            selectedIndex: _selectedTab,
            onChanged: (index) => setState(() => _selectedTab = index),
          ),
          const SizedBox(height: 18),
          if (_loadError != null) ...[
            Text(_loadError!, style: _muted, textAlign: TextAlign.center),
            const SizedBox(height: 12),
          ],
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: CircularProgressIndicator(color: AppColors.blueBic),
            )
          else if (visiblePromotions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Text(_emptyPromotionMessage, style: _sub),
            )
          else
            Expanded(
              child: RefreshIndicator(
                color: AppColors.blueBic,
                onRefresh: _loadPromotions,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: visiblePromotions.length,
                  itemBuilder: (context, index) {
                    final promotion = visiblePromotions[index];
                    return _PromoRow(
                      promotion['title'] as String? ?? 'Promotion',
                      promotion['code'] as String? ?? 'CODE',
                      promotion['active'] as bool? ?? false,
                      detail: _promotionDetail(promotion),
                      onChanged:
                          (active) => _setPromotionActive(promotion, active),
                    );
                  },
                ),
              ),
            ),
          if (_isLoading || visiblePromotions.isEmpty) const Spacer(),
          if (!_isLoading && visiblePromotions.isNotEmpty)
            const SizedBox(height: 10),
          _Button(
            label: '+ Créer une promotion',
            onTap: () => context.go('/partner/create-promotion'),
          ),
        ],
      ),
    );
  }

  String get _emptyPromotionMessage {
    return _selectedTab == 0
        ? 'Aucune promotion en cours'
        : 'Aucune promotion passée';
  }
}

String _pickupClientName(Map<String, dynamic> pickup) {
  final explicitName = pickup['clientName']?.toString();
  if (explicitName != null && explicitName.isNotEmpty) return explicitName;

  final userId = pickup['clientUserId']?.toString() ?? 'Client DailyCatch';
  return userId
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        if (word.length <= 2) return word.toUpperCase();
        return '${word[0].toUpperCase()}${word.substring(1)}';
      })
      .join(' ');
}

String _pickupHistoryCode(Map<String, dynamic> pickup) {
  final pickupCode = pickup['pickupCode']?.toString();
  if (pickupCode != null && pickupCode.isNotEmpty) return pickupCode;

  final orderId = pickup['orderId']?.toString() ?? '';
  if (orderId.isEmpty) return 'N/A';
  return orderId.length <= 6 ? orderId : orderId.substring(orderId.length - 6);
}

String _pickupHistoryDate(Map<String, dynamic> pickup) {
  final parsed = DateTime.tryParse('${pickup['createdAt'] ?? ''}');
  if (parsed == null) return 'Date à confirmer';

  final local = parsed.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year} • '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String _promotionDetail(Map<String, dynamic> promotion) {
  final endsAt = DateTime.tryParse('${promotion['endsAt'] ?? ''}');
  final usageCount = promotion['usageCount'] ?? 0;
  final usageLabel = 'Utilisé $usageCount fois';

  if (endsAt == null) return usageLabel;

  final local = endsAt.toLocal();
  final date =
      '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year}';
  return 'Valable jusqu’au $date\n$usageLabel';
}

int _promotionTabIndex(Map<String, dynamic> promotion) {
  final active = promotion['active'] as bool? ?? false;
  final endsAt = DateTime.tryParse('${promotion['endsAt'] ?? ''}');
  final expired = endsAt != null && endsAt.isBefore(DateTime.now());
  return active && !expired ? 0 : 1;
}

class PartnerCreatePromotionPage extends StatefulWidget {
  const PartnerCreatePromotionPage({super.key});

  @override
  State<PartnerCreatePromotionPage> createState() =>
      _PartnerCreatePromotionPageState();
}

class _PartnerCreatePromotionPageState
    extends State<PartnerCreatePromotionPage> {
  static const _storeId = 'store_yoff';
  final PartnerApiService _partnerApiService = PartnerApiService();
  final TextEditingController _typeController = TextEditingController(
    text: 'Pourcentage',
  );
  final TextEditingController _valueController = TextEditingController(
    text: '15',
  );
  final TextEditingController _codeController = TextEditingController(
    text: 'DAILYCATCH15',
  );
  final TextEditingController _conditionsController = TextEditingController(
    text: 'Dès 2 paniers achetés',
  );
  final TextEditingController _startsAtController = TextEditingController(
    text: _defaultDate(DateTime.now()),
  );
  final TextEditingController _endsAtController = TextEditingController(
    text: _defaultDate(DateTime.now().add(const Duration(days: 30))),
  );
  bool _isSaving = false;

  @override
  void dispose() {
    _typeController.dispose();
    _valueController.dispose();
    _codeController.dispose();
    _conditionsController.dispose();
    _startsAtController.dispose();
    _endsAtController.dispose();
    super.dispose();
  }

  Future<void> _savePromotion() async {
    if (_isSaving) return;
    final code = _codeController.text.trim().toUpperCase();
    final value = _parseAmount(_valueController.text);
    if (code.length < 3 || value <= 0) {
      _showMessage('Renseignez un code promo et une valeur valide.');
      return;
    }

    setState(() => _isSaving = true);
    final startsAt = _parseDateInput(_startsAtController.text);
    final endsAt = _parseDateInput(_endsAtController.text, endOfDay: true);
    try {
      await _partnerApiService.createPromotion({
        'storeId': _storeId,
        'title': _promotionTitle(value),
        'code': code,
        'type': _promotionType,
        'value': value,
        'conditions': _conditionsController.text.trim(),
        if (startsAt != null) 'startsAt': startsAt.toUtc().toIso8601String(),
        if (endsAt != null) 'endsAt': endsAt.toUtc().toIso8601String(),
        'active': true,
      });
      if (!mounted) return;
      context.go('/partner/promotions');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage('Impossible de créer la promotion pour le moment.');
    }
  }

  String get _promotionType {
    final label = _typeController.text.toLowerCase();
    if (label.contains('livraison')) return 'free_delivery';
    if (label.contains('montant')) return 'fixed_amount';
    return 'percentage';
  }

  String _promotionTitle(int value) {
    if (_promotionType == 'free_delivery') return 'Livraison gratuite';
    if (_promotionType == 'fixed_amount') {
      return '${_formatCfa(value)} de réduction';
    }
    return '-$value% sur les paniers';
  }

  DateTime? _parseDateInput(String value, {bool endOfDay = false}) {
    final parts = value.trim().split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day, endOfDay ? 23 : 0, endOfDay ? 59 : 0);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins())),
    );
  }

  static String _defaultDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) => _PartnerShell(
    title: 'Créer une promotion',
    child: Column(
      children: [
        _EditableField('Type de promotion', _typeController),
        _EditableField(
          'Valeur',
          _valueController,
          keyboardType: TextInputType.number,
        ),
        _EditableField('Code promo', _codeController),
        _EditableField(
          'Conditions d’utilisation',
          _conditionsController,
          maxLines: 2,
        ),
        _EditableField('Date de début', _startsAtController),
        _EditableField('Date de fin', _endsAtController),
        const Spacer(),
        _Button(
          label: _isSaving ? 'Enregistrement...' : 'Enregistrer',
          onTap: _savePromotion,
        ),
      ],
    ),
  );
}

String _contentTypeForFile(String fileName, {required String fallback}) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.pdf')) return 'application/pdf';
  return fallback;
}

void _safePartnerBack(
  BuildContext context, {
  String fallback = '/partner/mobile-dashboard',
}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

void _showPartnerSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.blueBic,
      content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
    ),
  );
}

class _PartnerScaffold extends StatelessWidget {
  const _PartnerScaffold({
    required this.title,
    required this.child,
    required this.currentIndex,
  });
  final String title;
  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 48,
                  child:
                      context.canPop()
                          ? IconButton(
                            onPressed: () => _safePartnerBack(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.blueBic,
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: _header,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => context.go('/partner/stats'),
                  icon: const Icon(
                    Icons.tune,
                    color: AppColors.blueBic,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(child: child),
          ],
        ),
      ),
    ),
    bottomNavigationBar: PartnerBottomNavBar(currentIndex: currentIndex),
  );
}

class _PartnerShell extends StatelessWidget {
  const _PartnerShell({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 48,
                  child: IconButton(
                    onPressed: () => _safePartnerBack(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.blueBic,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: _header,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 82,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E8E6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(title, style: _title), Text(subtitle, style: _sub)],
          ),
          const Spacer(),
          Text(action, style: _green),
        ],
      ),
    ),
  );
}

class _Tabs extends StatelessWidget {
  const _Tabs(this.labels, {this.selectedIndex = 0, this.onChanged});

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children:
        labels.asMap().entries.map((entry) {
          final active = entry.key == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged?.call(entry.key),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFE7F4F3) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        active
                            ? const Color(0xFFB9DCDA)
                            : const Color(0xFFE1E8E6),
                  ),
                ),
                child: Text(entry.value, style: active ? _green : _row),
              ),
            ),
          );
        }).toList(),
  );
}

class _BasketRow extends StatelessWidget {
  const _BasketRow({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.active,
    required this.onTap,
    this.onToggle,
    this.onDelete,
  });
  final String image;
  final String title;
  final String subtitle;
  final String price;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E8E6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(image, width: 76, height: 76, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _title),
                Text(subtitle, style: _sub),
                const SizedBox(height: 6),
                Text(price, style: _price),
                Text('Aujourd’hui', style: _muted),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Badge(active ? 'Actif' : 'Inactif'),
              if (onToggle != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.blueBic),
                  onSelected: (value) {
                    if (value == 'toggle') onToggle?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(active ? 'Désactiver' : 'Activer'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer'),
                        ),
                      ],
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.id,
    required this.client,
    required this.pickupSlot,
    required this.status,
    required this.onTap,
  });
  final String id;
  final String client;
  final String pickupSlot;
  final String status;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 96,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFFFFF0D7),
            child: Icon(Icons.person, color: Color(0xFFD46A1F), size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: _title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  client,
                  style: _sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'À retirer avant $pickupSlot',
                  style: _row,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Badge(status),
              const SizedBox(height: 8),
              Text('Voir tout', style: _green),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {this.color = const Color(0xFFEAF8F0)});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: _greenSmall),
  );
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E8E6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value, style: _row),
        ),
      ],
    ),
  );
}

class _EditableField extends StatelessWidget {
  const _EditableField(
    this.label,
    this.controller, {
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: _row,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE1E8E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.blueBic),
            ),
          ),
        ),
      ],
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label, {required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 46,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8EEEE))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.blueBic),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: _title)),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF789094)),
        ],
      ),
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 92, child: Text(label, style: _label)),
        Expanded(child: Text(value, style: _row)),
      ],
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress(this.label, this.value);
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LinearProgressIndicator(
        value: value,
        color: AppColors.blueBic,
        backgroundColor: const Color(0xFFE1E8E6),
      ),
      const SizedBox(height: 10),
      Text(label, style: _green),
    ],
  );
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox(this.asset);
  final String asset;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 15),
          ),
        ),
      ],
    ),
  );
}

class _DayChip extends StatelessWidget {
  const _DayChip(this.label, {required this.active});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(
      color: active ? AppColors.blueBic : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE1E8E6)),
    ),
    child: Text(label, style: active ? _metricLabel : _row),
  );
}

class _SwitchSlot extends StatelessWidget {
  const _SwitchSlot(this.label, this.active);
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    decoration: BoxDecoration(
      color: active ? const Color(0xFFE6F6F5) : Colors.white,
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          left: 14,
          right: 72,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: active ? _green : _row,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Positioned(
          right: 8,
          child: Switch(
            value: active,
            activeThumbColor: AppColors.blueBic,
            onChanged: (_) {},
          ),
        ),
      ],
    ),
  );
}

class _LightButton extends StatelessWidget {
  const _LightButton(this.label, {required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 44,
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF7FAFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: _green),
    ),
  );
}

class _HourRow extends StatelessWidget {
  const _HourRow(this.day, this.value);
  final String day;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(child: Text(day, style: _label)),
        Container(
          height: 44,
          width: 132,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E8E6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value, style: _row),
        ),
      ],
    ),
  );
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow(
    this.title,
    this.subtitle,
    this.added, {
    this.statusText,
    this.statusColor,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final bool added;
  final String? statusText;
  final Color? statusColor;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 82,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8EEEE))),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.blueBic),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: _muted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              statusText ?? (added ? 'Ajouté' : 'À ajouter'),
              style: _green.copyWith(color: statusColor ?? AppColors.greenTGTG),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            added ? Icons.check_circle : Icons.chevron_right,
            color: AppColors.blueBic,
            size: 18,
          ),
        ],
      ),
    ),
  );
}

class _PartnerNotice extends StatelessWidget {
  const _PartnerNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFBD38D)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: Color(0xFFB7791F), size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: _muted)),
        TextButton(onPressed: onRetry, child: const Text('Réessayer')),
      ],
    ),
  );
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.isUploading, required this.onTap});
  final bool isUploading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: isUploading ? null : onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFBBD0D0),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          isUploading
              ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : Text('+ Ajouter le document', style: _green),
    ),
  );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard(
    this.icon,
    this.title,
    this.body,
    this.button,
    this.color,
    this.onTap,
  );
  final IconData icon;
  final String title;
  final String body;
  final String button;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: _headline)),
          ],
        ),
        const SizedBox(height: 12),
        Text(body, textAlign: TextAlign.center, style: _body),
        const SizedBox(height: 14),
        _Button(label: button, onTap: onTap),
      ],
    ),
  );
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble(this.text, this.mine);
  final String text;
  final bool mine;
  @override
  Widget build(BuildContext context) => Align(
    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(maxWidth: 230),
      decoration: BoxDecoration(
        color: mine ? AppColors.blueBic : const Color(0xFFF2F6F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: mine ? _metricLabel : _row),
    ),
  );
}

class _InputBox extends StatelessWidget {
  const _InputBox(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text, style: _row),
  );
}

class _PickupHistoryRow extends StatelessWidget {
  const _PickupHistoryRow(
    this.name,
    this.code,
    this.amount, {
    this.dateLine = '08/05/2025 • 12:15',
  });
  final String name;
  final String code;
  final String amount;
  final String dateLine;
  @override
  Widget build(BuildContext context) => Container(
    height: 84,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFE8EEEE))),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Code : $code\n$dateLine',
                style: _muted,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Flexible(
          child: Text(
            amount,
            style: _price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

class _PromoRow extends StatelessWidget {
  const _PromoRow(
    this.title,
    this.code,
    this.active, {
    this.detail,
    this.onChanged,
  });

  final String title;
  final String code;
  final bool active;
  final String? detail;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _title),
              Text(
                'Code : $code\n${detail ?? "Valable jusqu’au 30/05/2025\nUtilisé 24 fois"}',
                style: _muted,
              ),
            ],
          ),
        ),
        Switch(
          value: active,
          activeThumbColor: AppColors.blueBic,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _StatBox extends StatelessWidget {
  const _StatBox(this.value, this.label, {this.danger = false});
  final String value;
  final String label;
  final bool danger;
  @override
  Widget build(BuildContext context) => Container(
    height: 76,
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            value,
            style: danger ? _danger : _price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: _sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blueBic,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: _button),
    ),
  );
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid =
        Paint()
          ..color = const Color(0xFFE8EEEE)
          ..strokeWidth = 1;
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final line =
        Paint()
          ..color = AppColors.blueBic
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
    final path =
        Path()
          ..moveTo(0, size.height * .82)
          ..lineTo(size.width * .18, size.height * .68)
          ..lineTo(size.width * .36, size.height * .42)
          ..lineTo(size.width * .52, size.height * .62)
          ..lineTo(size.width * .72, size.height * .38)
          ..lineTo(size.width, size.height * .18);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final _header = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _whiteHeader = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _whiteTitle = GoogleFonts.poppins(
  fontSize: 18,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _title = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _headline = GoogleFonts.poppins(
  fontSize: 17,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _bigTitle = GoogleFonts.poppins(
  fontSize: 22,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _sub = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _body = GoogleFonts.poppins(
  fontSize: 12,
  height: 1.7,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _row = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _label = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF263B3E),
);
final _muted = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF718487),
);
final _price = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _statValue = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _financeHeroAmount = GoogleFonts.poppins(
  fontSize: 26,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _financeCardAmount = GoogleFonts.poppins(
  fontSize: 22,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _strike = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF8BA0A3),
  decoration: TextDecoration.lineThrough,
);
final _green = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _greenSmall = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _metricLabel = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: Colors.white.withValues(alpha: .86),
);
final _code = GoogleFonts.poppins(
  fontSize: 25,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _scanCode = GoogleFonts.poppins(
  fontSize: 42,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _whiteLink = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF8EE0D9),
  decoration: TextDecoration.underline,
);
final _danger = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.redAccent,
);

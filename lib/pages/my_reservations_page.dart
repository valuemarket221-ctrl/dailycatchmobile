import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/payment_api_service.dart';
import 'package:myapp/utils/api_environment.dart';
import 'package:myapp/utils/api_error_messages.dart';
import 'package:myapp/utils/formatters.dart';
import 'package:myapp/widgets/app_remote_image.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Écran "Mes réservations" - Historique des produits sauvés
/// Affiche les produits réservés avec leurs QR codes
class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  int _selectedFilter = 0; // 0: Actif, 1: Terminé
  final PaymentApiService _paymentApiService = PaymentApiService();
  bool _isLoading = true;
  String? _loadError;

  // Données fictives pour les réservations
  List<Reservation> _reservations =
      ApiEnvironment.isDemoFallbackAllowed
          ? List<Reservation>.of(_fallbackReservations)
          : <Reservation>[];

  static final _fallbackReservations = [
    Reservation(
      id: 'RES001',
      productName: 'Sacs de crevettes grises',
      partnerName: 'Poissonnerie du Port',
      partnerAddress: '15 Rue du Port, Dakar',
      price: 4500,
      originalPrice: 12000,
      pickupDate: DateTime.now().add(const Duration(days: 0, hours: 2)),
      status: ReservationStatus.active,
      qrCodeData: 'RES001|DailyCatch|4500',
      deliveryMode: 'pickup',
      pickupCode: 'RES001',
      imagePath: 'assets/images/crevette.jpg',
    ),
    Reservation(
      id: 'RES002',
      productName: 'Plateau d\'huîtres n°3',
      partnerName: 'Coquillages & Crustacés',
      partnerAddress: '28 Avenue de la Plage, Dakar',
      price: 7500,
      originalPrice: 18000,
      pickupDate: DateTime.now().add(const Duration(days: 1, hours: 4)),
      status: ReservationStatus.active,
      qrCodeData: 'RES002|DailyCatch|7500',
      deliveryMode: 'pickup',
      pickupCode: 'RES002',
      imagePath: 'assets/images/langoustines.jpg',
    ),
    Reservation(
      id: 'RES003',
      productName: 'Filets de maquereau frais',
      partnerName: 'Halte Maritime',
      partnerAddress: '42 Quai des Pêcheurs, Dakar',
      price: 3500,
      originalPrice: 9000,
      pickupDate: DateTime.now().subtract(const Duration(days: 1)),
      status: ReservationStatus.completed,
      qrCodeData: 'RES003|DailyCatch|3500',
      deliveryMode: 'pickup',
      pickupCode: 'RES003',
      imagePath: 'assets/images/saumon.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final orders = await _paymentApiService.getMyOrders();
      if (!mounted) return;
      setState(() {
        _reservations = orders.map(reservationFromOrderSummary).toList();
        _loadError = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _reservations =
            ApiEnvironment.isDemoFallbackAllowed
                ? List<Reservation>.of(_fallbackReservations)
                : <Reservation>[];
        final message = ApiErrorMessages.fromObject(error);
        _loadError =
            ApiEnvironment.isDemoFallbackAllowed
                ? '$message Réservations de démonstration affichées.'
                : message;
        _isLoading = false;
      });
    }
  }

  List<Reservation> get _filteredReservations {
    if (_selectedFilter == 0) {
      return _reservations
          .where((r) => r.status == ReservationStatus.active)
          .toList();
    } else {
      return _reservations
          .where(
            (r) =>
                r.status == ReservationStatus.completed ||
                r.status == ReservationStatus.cancelled,
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes sauvés',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.blueBic,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildFilterButton('Actifs', 0),
                _buildFilterButton('Terminés', 1),
              ],
            ),
          ),

          // Statistiques
          _buildStatsCard(),
          if (_loadError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildWarningBanner(_loadError!),
            ),

          const SizedBox(height: 16),

          // Liste des réservations
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blueBic,
                      ),
                    )
                    : _filteredReservations.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredReservations.length,
                      itemBuilder: (context, index) {
                        return _buildReservationCard(
                          _filteredReservations[index],
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildWarningBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: GoogleFonts.poppins(fontSize: 12)),
          ),
          TextButton(
            onPressed: _loadReservations,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, int index) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blueBic : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final activeCount =
        _reservations.where((r) => r.status == ReservationStatus.active).length;
    final completedCount =
        _reservations
            .where((r) => r.status == ReservationStatus.completed)
            .length;
    final totalSaved = _reservations
        .where((r) => r.status == ReservationStatus.active)
        .fold<double>(0, (sum, r) => sum + (r.originalPrice - r.price));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blueBic, AppColors.blueBic.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.shopping_bag,
              value: '$activeCount',
              label: 'Sauvés actifs',
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle,
              value: '$completedCount',
              label: 'Récupérés',
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.savings,
              value: AppFormatters.formatCfa(totalSaved),
              label: 'Économisés',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final isActive = reservation.status == ReservationStatus.active;
    final timeRemaining = reservation.pickupDate.difference(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () => context.push('/reservation-detail', extra: reservation),
        child: Column(
          children: [
            // En-tête avec statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? AppColors.blueBic.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Réservation #${reservation.id}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.blueBic : Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'À récupérer' : 'Terminé',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Produit
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppRemoteImage(
                          path: reservation.imagePath,
                          width: 60,
                          height: 60,
                          cacheWidth: 160,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reservation.productName,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              reservation.partnerName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Prix
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(
                              AppFormatters.formatCfa(
                                reservation.originalPrice,
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              AppFormatters.formatCfa(reservation.price),
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueBic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${_discountPercent(reservation)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Horaire de retrait
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive
                            ? '${reservation.isDelivery ? 'Livraison prévue' : 'Récupérez'} avant ${_formatDate(reservation.pickupDate)}'
                            : '${reservation.isDelivery ? 'Livré' : 'Récupéré'} le ${_formatDateFull(reservation.pickupDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isActive ? Colors.red : Colors.grey[600],
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  // Adresse
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.blueBic,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reservation.partnerAddress,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.blueBic,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Compte à rebours pour actifs
                  if (isActive && timeRemaining.inHours > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Plus que ${timeRemaining.inHours}h ${timeRemaining.inMinutes % 60}min',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Bouton QR Code pour actifs
                  if (isActive)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => context.push(
                                  '/withdrawal-code',
                                  extra: reservation,
                                ),
                            icon: const Icon(
                              Icons.qr_code_2,
                              color: Colors.black,
                            ),
                            label: Text(
                              'QR Code',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.yellowColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _cancelReservation(reservation),
                            icon: const Icon(Icons.close),
                            label: Text(
                              'Annuler',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Bouton évaluer pour terminés
                  if (!isActive)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.go('/rate-review');
                        },
                        icon: const Icon(
                          Icons.rate_review,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Évaluer',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenTGTG,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 0
                ? (_isLoading ? 'Chargement...' : 'Aucune réservation active')
                : 'Aucune réservation terminée',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 0
                ? 'Allez sauver des paniers !'
                : 'Vos sauvés récupérés apparaîtront ici',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          if (_selectedFilter == 0)
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la liste des produits
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueBic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Voir les paniers',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _discountPercent(Reservation reservation) {
    if (reservation.originalPrice <= 0 || reservation.price <= 0) return 0;
    return ((1 - reservation.price / reservation.originalPrice) * 100)
        .clamp(0, 99)
        .round();
  }

  String _formatDate(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateFull(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    try {
      await _paymentApiService.cancelOrder(
        reservation.id,
        reason: 'Annulation utilisateur',
      );
      if (!mounted) return;
      setState(() {
        _reservations =
            _reservations
                .map(
                  (item) =>
                      item.id == reservation.id
                          ? item.copyWith(status: ReservationStatus.cancelled)
                          : item,
                )
                .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Réservation annulée', style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Annulation indisponible pour cette réservation.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Reservation reservationFromOrderSummary(OrderSummary order) {
  final firstItem = order.items.isEmpty ? null : order.items.first;
  final quantity = (firstItem?['quantity'] as num?)?.toInt() ?? 1;
  final unitAmount =
      ((firstItem?['unitAmount'] as num?)?.toInt() ?? order.amount);
  final originalUnitAmount =
      (firstItem?['originalUnitAmount'] as num?)?.toInt();
  final name = firstItem?['name'] as String? ?? 'Panier surprise';
  final storeName =
      (firstItem?['storeName'] as String?) ??
      (firstItem?['storeId'] as String?) ??
      'Commerce DailyCatch';
  final mediaUrls =
      (firstItem?['mediaUrls'] as List<dynamic>? ?? const [])
          .map((url) => url.toString())
          .where((url) => url.trim().isNotEmpty)
          .toList();

  return Reservation(
    id: order.id,
    productName: quantity > 1 ? '$quantity x $name' : name,
    partnerName: storeName,
    partnerAddress: _storeAddressFor(storeName),
    price: order.amount.toDouble(),
    originalPrice:
        ((originalUnitAmount ?? (unitAmount * 2)) * quantity).toDouble(),
    pickupDate: _pickupDateFor(order),
    status: _statusFromOrder(order.status),
    qrCodeData: '${order.id}|${order.pickupCode}',
    pickupCode: order.pickupCode,
    deliveryMode: order.deliveryMode,
    imagePath:
        mediaUrls.isNotEmpty
            ? mediaUrls.first
            : 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
  );
}

ReservationStatus _statusFromOrder(String status) {
  switch (status) {
    case 'picked_up':
      return ReservationStatus.completed;
    case 'canceled':
    case 'refund_pending':
    case 'refunded':
    case 'payment_failed':
      return ReservationStatus.cancelled;
    default:
      return ReservationStatus.active;
  }
}

DateTime _pickupDateFor(OrderSummary order) {
  final slot = order.pickupSlot;
  if (slot == null || slot.trim().isEmpty) {
    return order.createdAt.add(const Duration(hours: 4));
  }

  final parsed = DateTime.tryParse(slot);
  if (parsed != null) return parsed;

  return order.createdAt.add(const Duration(hours: 4));
}

String _storeAddressFor(String storeName) {
  final normalized = storeName.toLowerCase();
  if (normalized.contains('yoff')) return 'Marché de Yoff, Dakar';
  if (normalized.contains('soumbédioune') || normalized.contains('soumbed')) {
    return 'Soumbédioune, Dakar';
  }
  return 'Dakar, Sénégal';
}

/// Modèle de réservation
class Reservation {
  final String id;
  final String productName;
  final String partnerName;
  final String partnerAddress;
  final double price;
  final double originalPrice;
  final DateTime pickupDate;
  final ReservationStatus status;
  final String qrCodeData;
  final String deliveryMode;
  final String pickupCode;
  final String imagePath;

  bool get isDelivery => deliveryMode == 'delivery';

  Reservation({
    required this.id,
    required this.productName,
    required this.partnerName,
    required this.partnerAddress,
    required this.price,
    required this.originalPrice,
    required this.pickupDate,
    required this.status,
    required this.qrCodeData,
    this.pickupCode = '',
    this.imagePath = 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
    this.deliveryMode = 'pickup',
  });

  Reservation copyWith({
    String? id,
    String? productName,
    String? partnerName,
    String? partnerAddress,
    double? price,
    double? originalPrice,
    DateTime? pickupDate,
    ReservationStatus? status,
    String? qrCodeData,
    String? deliveryMode,
    String? pickupCode,
    String? imagePath,
  }) {
    return Reservation(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      partnerName: partnerName ?? this.partnerName,
      partnerAddress: partnerAddress ?? this.partnerAddress,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      pickupDate: pickupDate ?? this.pickupDate,
      status: status ?? this.status,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      pickupCode: pickupCode ?? this.pickupCode,
      imagePath: imagePath ?? this.imagePath,
      deliveryMode: deliveryMode ?? this.deliveryMode,
    );
  }
}

enum ReservationStatus { active, completed, cancelled }

/// Écran d'affichage du QR Code
class QRCodePage extends StatelessWidget {
  final Reservation reservation;

  const QRCodePage({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Code de retrait',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou icône
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.yellowColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  size: 60,
                  color: AppColors.blueBic,
                ),
              ),

              const SizedBox(height: 24),

              // Titre
              Text(
                'Présentez ce QR Code',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'au partenaire pour récupérer votre panier',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // QR Code simulé (avec Container)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: reservation.qrCodeData,
                  version: QrVersions.auto,
                  size: 250,
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Code de réservation
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Code: ${reservation.id}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Informations
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Panier', reservation.productName),
                      const Divider(),
                      _buildInfoRow('Partenaire', reservation.partnerName),
                      const Divider(),
                      _buildInfoRow(
                        'Prix payé',
                        AppFormatters.formatCfa(reservation.price),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Alerte
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Présentez ce QR Code avant ${_formatDate(reservation.pickupDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Painter personnalisé pour dessiner un QR Code simulé
class QRCustomPainter extends CustomPainter {
  final String data;

  QRCustomPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    final gridSize = 25;
    final cellSize = size.width / gridSize;

    // Génère un motif basé sur les données
    final hash = data.hashCode.abs();
    final random = Random(hash);

    // Dessine le cadre du QR Code
    canvas.drawRect(Rect.fromLTWH(0, 0, cellSize * 7, cellSize * 7), paint);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cellSize * 7, cellSize),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cellSize, cellSize * 7),
      Paint()..color = Colors.white,
    );

    // Coins du QR Code
    _drawPositionPattern(canvas, Offset(0, 0), cellSize);
    _drawPositionPattern(
      canvas,
      Offset(size.width - cellSize * 7, 0),
      cellSize,
    );
    _drawPositionPattern(
      canvas,
      Offset(0, size.height - cellSize * 7),
      cellSize,
    );

    // Remplit le QR Code avec un motif basé sur les données
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        // Saute les zones de position
        if (_isPositionPatternZone(row, col, gridSize)) continue;

        // Génère un motif pseudo-aléatoire basé sur les données
        if (random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize,
              row * cellSize,
              cellSize * 0.7,
              cellSize * 0.7,
            ),
            paint,
          );
        }
      }
    }
  }

  bool _isPositionPatternZone(int row, int col, int size) {
    // Coin haut-gauche
    if (row < 8 && col < 8) return true;
    // Coin haut-droit
    if (row < 8 && col >= size - 8) return true;
    // Coin bas-gauche
    if (row >= size - 8 && col < 8) return true;
    return false;
  }

  void _drawPositionPattern(Canvas canvas, Offset offset, double cellSize) {
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;

    // Carré blanc au centre
    canvas.drawRect(
      Rect.fromLTWH(
        offset.dx + cellSize * 2,
        offset.dy + cellSize * 2,
        cellSize * 3,
        cellSize * 3,
      ),
      white,
    );

    // Carré noir au centre
    canvas.drawRect(
      Rect.fromLTWH(
        offset.dx + cellSize * 3,
        offset.dy + cellSize * 3,
        cellSize,
        cellSize,
      ),
      black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

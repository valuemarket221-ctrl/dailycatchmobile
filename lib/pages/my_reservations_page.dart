import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

/// Écran "Mes réservations" - Historique des produits sauvés
/// Affiche les produits réservés avec leurs QR codes
class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  int _selectedFilter = 0; // 0: Actif, 1: Terminé

  // Données fictives pour les réservations
  final List<Reservation> _reservations = [
    Reservation(
      id: 'RES001',
      productName: 'Sacs de crevettes grises',
      partnerName: 'Poissonnerie du Port',
      partnerAddress: '15 Rue du Port, Dakar',
      price: 4.50,
      originalPrice: 12.00,
      pickupDate: DateTime.now().add(const Duration(days: 0, hours: 2)),
      status: ReservationStatus.active,
      qrCodeData: 'RES001|DailyCatch|4.50',
    ),
    Reservation(
      id: 'RES002',
      productName: 'Plateau d\'huîtres n°3',
      partnerName: 'Coquillages & Crustacés',
      partnerAddress: '28 Avenue de la Plage, Dakar',
      price: 7.50,
      originalPrice: 18.00,
      pickupDate: DateTime.now().add(const Duration(days: 1, hours: 4)),
      status: ReservationStatus.active,
      qrCodeData: 'RES002|DailyCatch|7.50',
    ),
    Reservation(
      id: 'RES003',
      productName: 'Filets de maquereau frais',
      partnerName: 'Halte Maritime',
      partnerAddress: '42 Quai des Pêcheurs, Dakar',
      price: 3.50,
      originalPrice: 9.00,
      pickupDate: DateTime.now().subtract(const Duration(days: 1)),
      status: ReservationStatus.completed,
      qrCodeData: 'RES003|DailyCatch|3.50',
    ),
  ];

  List<Reservation> get _filteredReservations {
    if (_selectedFilter == 0) {
      return _reservations
          .where((r) => r.status == ReservationStatus.active)
          .toList();
    } else {
      return _reservations
          .where((r) => r.status == ReservationStatus.completed)
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
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
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

          const SizedBox(height: 16),

          // Liste des réservations
          Expanded(
            child:
                _filteredReservations.isEmpty
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
          colors: [AppColors.blueBic, AppColors.blueBic.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.shopping_bag,
            value: '$activeCount',
            label: 'Sauvés actifs',
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            value: '$completedCount',
            label: 'Récupérés',
          ),
          _buildStatItem(
            icon: Icons.savings,
            value: '${totalSaved.toStringAsFixed(1)}€',
            label: 'Économisés',
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
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
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
      elevation: 4,
      child: Column(
        children: [
          // En-tête avec statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? AppColors.blueBic.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Réservation #${reservation.id}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.blueBic : Colors.grey,
                  ),
                ),
                Container(
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.yellowColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: AppColors.blueBic,
                        size: 30,
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
                    Text(
                      '${reservation.originalPrice.toStringAsFixed(2)}€',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${reservation.price.toStringAsFixed(2)}€',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueBic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${((1 - reservation.price / reservation.originalPrice) * 100).round()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Horaire de retrait
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      isActive
                          ? 'Récupérez avant ${_formatDate(reservation.pickupDate)}'
                          : 'Récupéré le ${_formatDateFull(reservation.pickupDate)}',
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
                      color: Colors.red.withOpacity(0.1),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/pickup');
                      },
                      icon: const Icon(Icons.qr_code_2, color: Colors.black),
                      label: Text(
                        'Voir le QR Code',
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

                // Bouton évaluer pour terminés
                if (!isActive)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/rate-review');
                      },
                      icon: const Icon(Icons.rate_review, color: Colors.white),
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
                ? 'Aucune réservation active'
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
                ? 'Allez sauver des produits!'
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
                'Voir les produits',
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

  String _formatDate(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateFull(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
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
  });
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
                  color: AppColors.yellowColor.withOpacity(0.2),
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
                'au partenaire pour récupérer votre produit',
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: const Size(250, 250),
                  painter: QRCustomPainter(data: reservation.qrCodeData),
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
                      _buildInfoRow('Produit', reservation.productName),
                      const Divider(),
                      _buildInfoRow('Partenaire', reservation.partnerName),
                      const Divider(),
                      _buildInfoRow(
                        'Prix payé',
                        '${reservation.price.toStringAsFixed(2)}€',
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
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
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

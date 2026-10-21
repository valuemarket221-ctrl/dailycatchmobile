import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/payment_api_service.dart';

class RateReviewPage extends StatefulWidget {
  const RateReviewPage({super.key});

  @override
  State<RateReviewPage> createState() => _RateReviewPageState();
}

class _RateReviewPageState extends State<RateReviewPage> {
  int _rating = 0;
  int _selectedAspect = -1;
  final TextEditingController _commentController = TextEditingController();
  final PaymentApiService _paymentApiService = PaymentApiService();
  var _orders = <OrderSummary>[];
  var _isLoading = true;
  String? _loadError;

  final List<Map<String, dynamic>> aspects = [
    {'icon': Icons.access_time, 'label': 'Respect de l\'horaire'},
    {'icon': Icons.restaurant, 'label': 'Qualité du panier'},
    {'icon': Icons.person, 'label': 'Accueil'},
    {'icon': Icons.inventory_2, 'label': 'Emballage'},
  ];

  List<OrderSummary> get _reviewableOrders =>
      _orders.where((order) => _canReview(order.status)).toList();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final orders = await _paymentApiService.getMyOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Avis indisponibles pour le moment.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Avis',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unrated orders section
              Text(
                'À évaluer',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_loadError != null)
                _buildStateMessage(
                  icon: Icons.cloud_off_outlined,
                  title: 'Avis indisponibles',
                  message: _loadError!,
                  actionLabel: 'Réessayer',
                  onAction: _loadOrders,
                )
              else ...[
                ..._reviewableOrders.map(_buildOrderCard),
                if (_reviewableOrders.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun avis à donner',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 32),

              // Rating guide
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: AppColors.greenTGTG,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pourquoi évaluer ?',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTip('Votre avis aide d\'autres utilisateurs'),
                    _buildTip('Vous aidez les commerces à s\'améliorer'),
                    _buildTip('Contribuez à la communauté TGTG'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderSummary order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.greenTGTG.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.store, color: AppColors.greenTGTG, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _storeName(order),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _dateLabel(order),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Star rating
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                    _showRatingBottomSheet(context, order);
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _rating == 0 ? 'Appuyez pour noter' : '$_rating étoiles',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _rating == 0 ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingBottomSheet(BuildContext context, OrderSummary order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Évaluer ${_storeName(order)}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  Text(
                    _rating > 0 ? '$_rating étoiles' : 'Sélectionnez une note',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Aspects
                  Text(
                    'Qu\'avez-vous pensé à...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        aspects.asMap().entries.map<Widget>((entry) {
                          final index = entry.key;
                          final aspect = entry.value;
                          final isSelected = _selectedAspect == index;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  aspect['icon'],
                                  size: 18,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.greenTGTG,
                                ),
                                const SizedBox(width: 6),
                                Text(aspect['label']),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedAspect = selected ? index : -1;
                              });
                            },
                            selectedColor: AppColors.greenTGTG,
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Comment
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Partagez votre expérience (optionnel)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenTGTG,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _submitReview(order),
                      child: Text(
                        'Envoyer mon avis',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _submitReview(OrderSummary order) async {
    if (_rating == 0) return;

    final aspect =
        _selectedAspect >= 0 ? aspects[_selectedAspect]['label'] as String : '';
    final comment = [
      if (aspect.isNotEmpty) 'Aspect: $aspect',
      if (_commentController.text.trim().isNotEmpty)
        _commentController.text.trim(),
    ].join('\n');

    try {
      await _paymentApiService.reviewOrder(
        orderId: order.id,
        rating: _rating,
        comment: comment.isEmpty ? null : comment,
      );
      if (!mounted) return;
      setState(() {
        _orders = _orders.where((item) => item.id != order.id).toList();
        _rating = 0;
        _selectedAspect = -1;
        _commentController.clear();
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Merci pour votre avis !',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.greenTGTG,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Avis non envoyé: le retrait doit être validé avant notation.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool _canReview(String status) {
    switch (status.toLowerCase()) {
      case 'picked_up':
      case 'completed':
      case 'delivered':
      case 'fulfilled':
        return true;
      default:
        return false;
    }
  }

  String _storeName(OrderSummary order) {
    final firstItem = order.items.isEmpty ? null : order.items.first;
    return firstItem?['storeName']?.toString() ??
        firstItem?['store_name']?.toString() ??
        'Commerce';
  }

  String _dateLabel(OrderSummary order) {
    final date = order.createdAt;
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  Widget _buildStateMessage({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.greenTGTG, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

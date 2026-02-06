import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Page Paiement - Clone TGTG
class PaymentPage extends StatefulWidget {
  final Map<String, dynamic>? paymentData;

  const PaymentPage({super.key, this.paymentData});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedPaymentMethod = 0;
  String _selectedTimeSlot = '';
  
  final List<String> _timeSlots = [
    'Aujourd\'hui 18:00 - 19:00',
    'Aujourd\'hui 19:00 - 20:00',
    'Aujourd\'hui 20:00 - 21:00',
    'Demain 12:00 - 13:00',
    'Demain 18:00 - 19:00',
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Payer en magasin',
      'icon': Icons.store,
      'description': 'Payez directement lors du retrait',
    },
    {
      'name': 'Carte bancaire',
      'icon': Icons.credit_card,
      'description': 'Visa, Mastercard, etc.',
    },
    {
      'name': 'Apple Pay',
      'icon': Icons.phone_iphone,
      'description': 'Paiement rapide et sécurisé',
    },
    {
      'name': 'Google Pay',
      'icon': Icons.payment,
      'description': 'Paiement avec Google Pay',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTimeSlot = _timeSlots[0];
  }

  @override
  Widget build(BuildContext context) {
    final produit = widget.paymentData?['produit'] as Map<String, dynamic>? ?? {};
    final quantity = widget.paymentData?['quantity'] as int? ?? 1;
    final double price = double.parse(produit['prix']?.toString() ?? '0');
    final double total = price * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Paiement',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Product summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.blueBic,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produit['nom'] as String? ?? 'Produit',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Quantité: $quantity',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)}€',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueBic,
                  ),
                ),
              ],
            ),
          ),
          
          // Time slot selection
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Créneau de retrait',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._timeSlots.map(
                    (slot) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeSlot = slot;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedTimeSlot == slot
                              ? AppColors.blueBic.withValues(alpha: 0.1)
                              : Colors.white,
                          border: Border.all(
                            color: _selectedTimeSlot == slot
                                ? AppColors.blueBic
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: _selectedTimeSlot == slot
                                  ? AppColors.blueBic
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                slot,
                                style: GoogleFonts.poppins(
                                  color: _selectedTimeSlot == slot
                                      ? AppColors.blueBic
                                      : Colors.black,
                                ),
                              ),
                            ),
                            if (_selectedTimeSlot == slot)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.blueBic,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment method
                  Text(
                    'Méthode de paiement',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._paymentMethods.asMap().entries.map(
                    (entry) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPaymentMethod = entry.key;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedPaymentMethod == entry.key
                              ? AppColors.blueBic.withValues(alpha: 0.1)
                              : Colors.white,
                          border: Border.all(
                            color: _selectedPaymentMethod == entry.key
                                ? AppColors.blueBic
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              entry.value['icon'] as IconData,
                              color: _selectedPaymentMethod == entry.key
                                  ? AppColors.blueBic
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.value['name'] as String,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedPaymentMethod == entry.key
                                          ? AppColors.blueBic
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    entry.value['description'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedPaymentMethod == entry.key)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.blueBic,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom bar with total and pay button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total à payer:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)}€',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueBic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _confirmPayment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueBic,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Confirmer le paiement',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  void _confirmPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer le paiement',
          style: GoogleFonts.poppins(),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir confirmer ce paiement de ${(double.parse(widget.paymentData?['produit']?['prix']?.toString() ?? '0') * (widget.paymentData?['quantity'] ?? 1)).toStringAsFixed(2)}€ ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.push('/order-confirmation');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueBic,
            ),
            child: Text(
              'Confirmer',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

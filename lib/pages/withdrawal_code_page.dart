import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/pages/my_reservations_page.dart';
import 'package:myapp/services/payment_api_service.dart';
import 'package:myapp/utils/api_error_messages.dart';

class WithdrawalCodePage extends StatefulWidget {
  const WithdrawalCodePage({super.key, this.reservationId, this.reservation});

  final String? reservationId;
  final Reservation? reservation;

  @override
  State<WithdrawalCodePage> createState() => _WithdrawalCodePageState();
}

class _WithdrawalCodePageState extends State<WithdrawalCodePage> {
  final PaymentApiService _paymentApiService = PaymentApiService();
  Reservation? _reservation;
  var _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
    if (_reservation == null) _loadReservation();
  }

  Future<void> _loadReservation() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final orders = await _paymentApiService.getMyOrders();
      if (!mounted) return;
      final requestedId = widget.reservationId;
      final match =
          requestedId == null || requestedId.isEmpty
              ? (orders.isEmpty ? null : orders.first)
              : _findOrder(orders, requestedId);
      setState(() {
        _reservation =
            match == null ? null : reservationFromOrderSummary(match);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = ApiErrorMessages.fromObject(error);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservation = _reservation;
    final pickupCode = reservation?.pickupCode ?? '';
    final visibleCode =
        pickupCode.isEmpty
            ? ('CODE', 'INDISPONIBLE')
            : _compactCode(pickupCode);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blueBic),
                  )
                  : Column(
                    children: [
                      Text('CODE DE RETRAIT', style: _title),
                      const SizedBox(height: 52),
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 112,
                        color: AppColors.blueBic,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Montrez ce code au commerçant\npour retirer votre panier',
                        textAlign: TextAlign.center,
                        style: _description,
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E9E9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(visibleCode.$1, style: _code),
                            if (visibleCode.$2.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(visibleCode.$2, style: _code),
                            ],
                            const SizedBox(height: 26),
                            Text(
                              reservation == null
                                  ? (_loadError ?? 'Code non disponible')
                                  : 'Code valable aujourd’hui',
                              textAlign: TextAlign.center,
                              style: _small,
                            ),
                            const SizedBox(height: 5),
                            if (reservation != null)
                              Text(
                                _formatWindow(reservation.pickupDate),
                                style: _slot,
                              )
                            else
                              TextButton(
                                onPressed: _loadReservation,
                                child: Text('Réessayer', style: _link),
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text('Ne partagez pas ce code', style: _warning),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: () => context.go('/order-tracking'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.blueBic,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('OK, compris', style: _button),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

OrderSummary? _findOrder(List<OrderSummary> orders, String orderId) {
  for (final order in orders) {
    if (order.id == orderId) return order;
  }
  return null;
}

(String, String) _compactCode(String code) {
  final clean =
      code
          .replaceFirst('dc_pickup_', '')
          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
          .toUpperCase();
  if (clean.length <= 8) return (clean, '');
  final tail = clean.substring(clean.length - 8);
  return (tail.substring(0, 4), tail.substring(4));
}

String _formatWindow(DateTime date) {
  final startsAt =
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  final endsAt = date.add(const Duration(hours: 2));
  return '$startsAt - ${endsAt.hour.toString().padLeft(2, '0')}:${endsAt.minute.toString().padLeft(2, '0')}';
}

final _title = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _description = GoogleFonts.poppins(
  fontSize: 12,
  height: 1.65,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _code = GoogleFonts.poppins(
  fontSize: 31,
  fontWeight: FontWeight.w900,
  height: 1.05,
  color: AppColors.blueBic,
);
final _small = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF718487),
);
final _slot = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _link = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _warning = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF879395),
);
final _button = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);

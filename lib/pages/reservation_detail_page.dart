import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/pages/my_reservations_page.dart';
import 'package:myapp/services/payment_api_service.dart';
import 'package:myapp/utils/api_error_messages.dart';
import 'package:myapp/utils/formatters.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:myapp/widgets/app_remote_image.dart';

class ReservationDetailPage extends StatefulWidget {
  const ReservationDetailPage({super.key, this.reservation});

  final Reservation? reservation;

  @override
  State<ReservationDetailPage> createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  final PaymentApiService _paymentApiService = PaymentApiService();
  Reservation? _reservation;
  var _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
    if (_reservation == null) _loadFallbackReservation();
  }

  Future<void> _loadFallbackReservation() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final orders = await _paymentApiService.getMyOrders();
      if (!mounted) return;
      setState(() {
        _reservation =
            orders.isEmpty ? null : reservationFromOrderSummary(orders.first);
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blueBic),
                  )
                  : reservation == null
                  ? _EmptyReservationDetail(
                    message: _loadError ?? 'Aucune réservation disponible.',
                    onRetry: _loadFallbackReservation,
                  )
                  : _ReservationDetailContent(reservation: reservation),
        ),
      ),
    );
  }
}

class _ReservationDetailContent extends StatelessWidget {
  const _ReservationDetailContent({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final isActive = reservation.status == ReservationStatus.active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => safePop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
            ),
            Expanded(child: Text('Réservation', style: _title)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              AppRemoteImage(
                path: reservation.imagePath,
                height: 112,
                width: double.infinity,
                cacheWidth: 720,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.12),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 16,
                right: 12,
                child: Text(
                  reservation.partnerName,
                  style: _heroTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 12,
                top: 42,
                right: 12,
                child: Text(
                  reservation.productName,
                  style: _heroSub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _Row(
          label: 'Statut',
          value: _statusText(reservation.status),
          green: isActive,
        ),
        const Divider(height: 26),
        _Row(label: 'Date', value: _formatDay(reservation.pickupDate)),
        _Row(label: 'Créneau', value: _formatTime(reservation.pickupDate)),
        const SizedBox(height: 18),
        Text('Adresse', style: _label),
        Text(reservation.partnerAddress, style: _value),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => context.push('/order-tracking', extra: reservation),
          child: Text('Voir sur la carte', style: _green),
        ),
        const Divider(height: 30),
        _Row(label: 'Code de réservation', value: reservation.id),
        const Divider(height: 30),
        _Row(
          label: 'Total payé',
          value: AppFormatters.formatCfa(reservation.price),
        ),
        const Spacer(),
        if (isActive)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed:
                  () => context.push('/withdrawal-code', extra: reservation),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blueBic,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Voir le code', style: _button),
            ),
          ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              TextButton(
                onPressed:
                    () => context.push('/cancel-order', extra: reservation),
                child: Text('Annuler', style: _green),
              ),
            const SizedBox(width: 14),
            TextButton(
              onPressed:
                  () => context.push('/refund-request', extra: reservation),
              child: Text('Signaler un problème', style: _green),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _EmptyReservationDetail extends StatelessWidget {
  const _EmptyReservationDetail({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => safePop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
            ),
            Expanded(child: Text('Réservation', style: _title)),
          ],
        ),
        const Spacer(),
        const Icon(
          Icons.shopping_bag_outlined,
          size: 54,
          color: AppColors.blueBic,
        ),
        const SizedBox(height: 14),
        Text(message, style: _value, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        TextButton(onPressed: onRetry, child: Text('Réessayer', style: _green)),
        const Spacer(),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.green = false});
  final String label;
  final String value;
  final bool green;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _label)),
          Flexible(
            child: Text(
              value,
              style: green ? _confirmed : _value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

String _statusText(ReservationStatus status) {
  return switch (status) {
    ReservationStatus.active => 'Confirmée',
    ReservationStatus.completed => 'Terminée',
    ReservationStatus.cancelled => 'Annulée',
  };
}

String _formatDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) return 'Aujourd’hui';
  if (day == today.add(const Duration(days: 1))) return 'Demain';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatTime(DateTime date) {
  final startsAt =
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  final endsAt = date.add(const Duration(hours: 2));
  return '$startsAt - ${endsAt.hour.toString().padLeft(2, '0')}:${endsAt.minute.toString().padLeft(2, '0')}';
}

final _title = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _heroTitle = GoogleFonts.poppins(
  fontSize: 17,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _heroSub = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);
final _label = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _value = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _green = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.greenTGTG,
);
final _confirmed = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: Colors.green,
);
final _button = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);

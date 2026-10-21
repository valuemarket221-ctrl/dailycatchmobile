import 'package:flutter/material.dart';
import 'package:myapp/pages/my_reservations_page.dart';

/// Ancien écran de suivi statique conservé comme alias.
/// Le suivi réel est alimenté par `PaymentApiService.getMyOrders()`.
class CommandePage extends StatelessWidget {
  const CommandePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyReservationsPage();
  }
}

import 'package:flutter/material.dart';
import 'package:myapp/pages/payment_page.dart';

/// Ancienne page de paiement conservée comme alias.
/// Le checkout réel passe par `PaymentPage` et `PaymentApiService`.
class PaiementPage extends StatelessWidget {
  const PaiementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaymentPage();
  }
}

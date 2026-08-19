import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class ReservationDetailPage extends StatelessWidget {
  const ReservationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                  ),
                  Text('Réservation', style: _title),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
                      height: 105,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      left: 12,
                      top: 16,
                      child: Text('Poissonnerie Yoff', style: _heroTitle),
                    ),
                    Positioned(
                      left: 12,
                      top: 42,
                      child: Text('Panier surprise', style: _heroSub),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _Row(label: 'Date', value: 'Confirmé', green: true),
              const Divider(height: 26),
              const _Row(label: 'Date', value: 'Aujourd’hui'),
              const _Row(label: 'Créneau', value: '17:00 - 19:00'),
              const SizedBox(height: 18),
              Text('Adresse', style: _label),
              Text('Marché de Yoff, Dakar, Sénégal', style: _value),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => context.push('/order-tracking'),
                child: Text('Voir sur la carte', style: _green),
              ),
              const Divider(height: 30),
              const _Row(label: 'Code de réservation', value: 'DCYF24'),
              const Divider(height: 30),
              const _Row(label: 'Total payé', value: '3 000 FCFA'),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => context.push('/withdrawal-code'),
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
                  TextButton(
                    onPressed: () => context.push('/cancel-order'),
                    child: Text('Annuler', style: _green),
                  ),
                  const SizedBox(width: 14),
                  TextButton(
                    onPressed: () => context.push('/refund-request'),
                    child: Text('Signaler un problème', style: _green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
          Text(value, style: green ? _confirmed : _value),
        ],
      ),
    );
  }
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

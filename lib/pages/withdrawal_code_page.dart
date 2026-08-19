import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class WithdrawalCodePage extends StatelessWidget {
  const WithdrawalCodePage({super.key, this.reservationId});

  final String? reservationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
          child: Column(
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
                    Text('DCYF24', style: _code),
                    const SizedBox(height: 8),
                    Text('A6B7', style: _code),
                    const SizedBox(height: 26),
                    Text('Code valable aujourd’hui', style: _small),
                    const SizedBox(height: 5),
                    Text('17:00 - 19:00', style: _slot),
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

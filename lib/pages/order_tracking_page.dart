import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapPainter())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF31575C)),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 196,
            left: 0,
            right: 0,
            child: Icon(Icons.location_on, size: 44, color: AppColors.blueBic),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 22,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Poissonnerie Yoff', style: _sheetTitle),
                  const SizedBox(height: 8),
                  Text('Préparation en cours', style: _status),
                  const SizedBox(height: 8),
                  Text(
                    'Votre panier est en cours de préparation.',
                    style: _subtitle,
                  ),
                  const Divider(height: 32, color: Color(0xFFE4EAEA)),
                  const _Step(
                    label: 'Votre réservation confirmée',
                    state: _StepState.done,
                    isFirst: true,
                  ),
                  const _Step(
                    label: 'Préparation en cours',
                    state: _StepState.active,
                  ),
                  const _Step(
                    label: 'Prêt à être récupéré',
                    state: _StepState.pending,
                  ),
                  const _Step(
                    label: 'Récupéré',
                    state: _StepState.pending,
                    isLast: true,
                  ),
                  const Divider(height: 28, color: Color(0xFFE4EAEA)),
                  Center(
                    child: Text('Besoin d’aide ? Contactez-nous', style: _help),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, active, pending }

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.state,
    this.isFirst = false,
    this.isLast = false,
  });

  final String label;
  final _StepState state;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final active = state != _StepState.pending;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isFirst)
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 1.5,
                      height: 24,
                      color: const Color(0xFFD9E3E3),
                    ),
                  ),
                if (!isLast)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 1.5,
                      height: 24,
                      color: const Color(0xFFD9E3E3),
                    ),
                  ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: active ? AppColors.blueBic : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          active ? AppColors.blueBic : const Color(0xFFD3DDDD),
                      width: 2,
                    ),
                  ),
                  child:
                      state == _StepState.done
                          ? const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                          : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(label, style: active ? _stepActive : _stepPending),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFF1EFE9), BlendMode.src);
    final water = Paint()..color = const Color(0xFFCFECF7);
    final road =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke;
    final smallRoad =
        Paint()
          ..color = const Color(0xFFD8D7D0)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * .57, 0)
        ..cubicTo(
          size.width * .62,
          size.height * .14,
          size.width * .42,
          size.height * .2,
          size.width * .54,
          size.height * .34,
        )
        ..cubicTo(
          size.width * .76,
          size.height * .52,
          size.width * .46,
          size.height * .64,
          size.width,
          size.height * .78,
        )
        ..lineTo(size.width, 0)
        ..close(),
      water,
    );

    for (var i = 0; i < 13; i++) {
      final y = size.height * (.06 + i * .07);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 28), smallRoad);
    }
    for (var i = 0; i < 8; i++) {
      final x = size.width * (.08 + i * .12);
      canvas.drawLine(Offset(x, 0), Offset(x - 75, size.height), smallRoad);
    }
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .18, 0)
        ..cubicTo(
          size.width * .45,
          size.height * .2,
          size.width * .32,
          size.height * .42,
          size.width * .66,
          size.height,
        ),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final _sheetTitle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _status = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _subtitle = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF6E7D80),
);
final _stepActive = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _stepPending = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF9CA8AA),
);
final _help = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF718487),
);

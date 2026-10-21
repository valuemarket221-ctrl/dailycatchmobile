import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class DailyCatchWordmark extends StatelessWidget {
  const DailyCatchWordmark({
    super.key,
    this.color = AppColors.blueBic,
    this.fontSize = 32,
  });

  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      'DailyCatch',
      maxLines: 1,
      style: GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    ),
  );
}

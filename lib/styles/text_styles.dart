import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Styles de texte centralisés pour toute l'application
class AppTextStyles {
  // ── Titres ──────────────────────────────────────
  static TextStyle get headingXL => GoogleFonts.poppins(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.08,
  );

  static TextStyle get headingL => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.12,
  );

  static TextStyle get headingM => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle get headingS => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.18,
  );

  // ── Subtitres ──────────────────────────────────
  static TextStyle get subtitleM => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get subtitleS => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  // ── Body ────────────────────────────────────────
  static TextStyle get bodyL => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.45,
  );

  static TextStyle get bodyM => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.42,
  );

  static TextStyle get bodyS => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.35,
  );

  // ── Captions ────────────────────────────────────
  static TextStyle get captionL => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get captionM => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get captionS => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  // ── Hints & Labels ──────────────────────────────
  static TextStyle get hintText => GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.grey[400],
    letterSpacing: 0,
  );

  static TextStyle get labelText => GoogleFonts.poppins(
    fontSize: 13,
    color: Colors.grey[600],
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
}

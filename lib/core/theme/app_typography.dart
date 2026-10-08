import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextStyle headlineXl(Color color) {
    return GoogleFonts.ibmPlexSans(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
      letterSpacing: -0.02 * 24,
      color: color,
    );
  }

  static TextStyle headlineLg(Color color) {
    return GoogleFonts.ibmPlexSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 24 / 18,
      letterSpacing: -0.015 * 18,
      color: color,
    );
  }

  static TextStyle headlineMd(Color color) {
    return GoogleFonts.ibmPlexSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 20 / 14,
      letterSpacing: -0.01 * 14,
      color: color,
    );
  }

  static TextStyle bodyLg(Color color) {
    return GoogleFonts.ibmPlexSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: color,
    );
  }

  static TextStyle bodyMd(Color color) {
    return GoogleFonts.ibmPlexSans(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 18 / 13,
      color: color,
    );
  }

  static TextStyle bodySm(Color color) {
    return GoogleFonts.ibmPlexSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 16 / 12,
      color: color,
    );
  }

  static TextStyle monoData(Color color, {FontWeight fontWeight = FontWeight.w400}) {
    return GoogleFonts.spaceMono(
      fontSize: 12,
      fontWeight: fontWeight,
      height: 16 / 12,
      letterSpacing: -0.01 * 12,
      color: color,
    );
  }

  static TextStyle monoCaption(Color color, {FontWeight fontWeight = FontWeight.w400}) {
    return GoogleFonts.spaceMono(
      fontSize: 11,
      fontWeight: fontWeight,
      height: 14 / 11,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle monoShortcut(Color color, {FontWeight fontWeight = FontWeight.w700}) {
    return GoogleFonts.spaceMono(
      fontSize: 10,
      fontWeight: fontWeight,
      height: 12 / 10,
      letterSpacing: 0.04 * 10,
      color: color,
    );
  }

  static TextStyle monoTimer(Color color) {
    return GoogleFonts.spaceMono(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 38 / 32,
      letterSpacing: 0.02 * 32,
      color: color,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  // Primary Typeface: Instrument Serif
  static TextStyle get instrumentSerif =>
      GoogleFonts.instrumentSerif(color: AppColors.inkBlack);

  static TextStyle get displayLarge =>
      instrumentSerif.copyWith(fontSize: 48, fontStyle: FontStyle.italic);

  static TextStyle get displayLargeApp =>
      instrumentSerif.copyWith(fontSize: 64, fontStyle: FontStyle.italic);

  static TextStyle get heading1 =>
      instrumentSerif.copyWith(fontSize: 32, fontWeight: FontWeight.normal);

  static TextStyle get heading2 =>
      instrumentSerif.copyWith(fontSize: 24, fontWeight: FontWeight.normal);

  static TextStyle get cardTitle =>
      instrumentSerif.copyWith(fontSize: 22, fontWeight: FontWeight.normal);

  static TextStyle get pullQuote =>
      instrumentSerif.copyWith(fontSize: 18, fontStyle: FontStyle.italic);

  // Secondary Typeface: Quicksand
  static TextStyle get quicksand =>
      GoogleFonts.quicksand(color: AppColors.darkGray);

  static TextStyle get bodyText =>
      quicksand.copyWith(fontSize: 15, fontWeight: FontWeight.normal, height: 1.7);

  static TextStyle get uiLabel => quicksand.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get button => quicksand.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get metadata => quicksand.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.midGray,
  );

  // Monospace: JetBrains Mono
  static TextStyle get jetBrainsMono =>
      GoogleFonts.jetBrainsMono(color: AppColors.darkGray);

  static TextStyle get tag => jetBrainsMono.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
  );

  static TextStyle get streakCounter =>
      jetBrainsMono.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
}

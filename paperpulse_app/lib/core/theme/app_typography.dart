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

  // Secondary Typeface: Geist (Using Open Sans or Roboto as fallback if Geist isn't in Google Fonts, but Geist is available now)
  // According to Google Fonts, it's 'Geist' or 'Geist Mono'
  // Let's use it or fallback to Inter / Roboto
  static TextStyle get geist => GoogleFonts.geist(color: AppColors.darkGray);

  static TextStyle get bodyText =>
      geist.copyWith(fontSize: 15, fontWeight: FontWeight.normal, height: 1.7);

  static TextStyle get uiLabel => geist.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500, // Medium
  );

  static TextStyle get button => geist.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
  );

  static TextStyle get metadata => geist.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.midGray,
  );

  // Monospace: Geist Mono
  static TextStyle get geistMono =>
      GoogleFonts.geistMono(color: AppColors.darkGray);

  static TextStyle get tag => geistMono.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing:
        0.1, // Note: letterSpacing in Flutter is logical pixels, not ems directly. Using small value.
  );

  static TextStyle get streakCounter =>
      geistMono.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
}

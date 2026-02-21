import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.paperWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sageGreen,
        brightness: Brightness.light,
        primary: AppColors.inkBlack,
        secondary: AppColors.sageGreen,
        surface: AppColors.paperWhite,
        error: AppColors.cherryBlossom,
        onPrimary: AppColors.paperWhite,
        onSecondary: AppColors.inkBlack,
        onSurface: AppColors.inkBlack,
        onError: AppColors.inkBlack,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paperWhite,
        foregroundColor: AppColors.inkBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading1,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        headlineLarge: AppTypography.heading1,
        headlineMedium: AppTypography.heading2,
        titleLarge: AppTypography.cardTitle,
        bodyLarge: AppTypography.bodyText,
        bodyMedium: AppTypography.bodyText.copyWith(fontSize: 14),
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.uiLabel,
        labelSmall: AppTypography.metadata,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sageGreen,
          foregroundColor: AppColors.inkBlack,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.paperWhite,
        elevation: 4, // Approx 0 8px 32px rgba(0,0,0,0.08)
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightGray, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.paperWhite,
        selectedItemColor: AppColors.inkBlack,
        unselectedItemColor: AppColors.midGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTypography.metadata.copyWith(
          color: AppColors.inkBlack,
        ),
        unselectedLabelStyle: AppTypography.metadata,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.inkBlack,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sageGreen,
        brightness: Brightness.dark,
        primary: AppColors.paperWhite,
        secondary: AppColors.sageGreen,
        surface: AppColors.inkBlack,
        error: AppColors.cherryBlossom,
        onPrimary: AppColors.inkBlack,
        onSecondary: AppColors.inkBlack,
        onSurface: AppColors.paperWhite,
        onError: AppColors.inkBlack,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.inkBlack,
        foregroundColor: AppColors.paperWhite,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading1.copyWith(
          color: AppColors.paperWhite,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.paperWhite,
        ),
        headlineLarge: AppTypography.heading1.copyWith(
          color: AppColors.paperWhite,
        ),
        headlineMedium: AppTypography.heading2.copyWith(
          color: AppColors.paperWhite,
        ),
        titleLarge: AppTypography.cardTitle.copyWith(
          color: AppColors.paperWhite,
        ),
        bodyLarge: AppTypography.bodyText.copyWith(color: AppColors.paperWhite),
        bodyMedium: AppTypography.bodyText.copyWith(
          color: AppColors.paperWhite,
          fontSize: 14,
        ),
        labelLarge: AppTypography.button.copyWith(color: AppColors.inkBlack),
        labelMedium: AppTypography.uiLabel.copyWith(
          color: AppColors.paperWhite,
        ),
        labelSmall: AppTypography.metadata.copyWith(color: AppColors.lightGray),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sageGreen,
          foregroundColor: AppColors.inkBlack,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkGray,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.midGray, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.inkBlack,
        selectedItemColor: AppColors.sageGreen,
        unselectedItemColor: AppColors.lightGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTypography.metadata.copyWith(
          color: AppColors.sageGreen,
        ),
        unselectedLabelStyle: AppTypography.metadata.copyWith(
          color: AppColors.lightGray,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
    );
  }
}

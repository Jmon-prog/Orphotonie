// ============================================================
// Fichier : lib/core/theme/app_theme.dart
// Description : Thème Material 3 de l'application Orphotonie.
//               Palette douce adaptée aux enfants. Polices Nunito + Baloo2.
//               Thèmes clair et sombre. Responsive via LayoutBuilder.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette de couleurs Orphotonie
abstract class AppColors {
  // Couleur principale — bleu-violet doux (accessible)
  static const primary = Color(0xFF6A5AE0);
  static const primaryContainer = Color(0xFFE8E5FF);
  static const onPrimary = Colors.white;

  // Couleur secondaire — vert menthe
  static const secondary = Color(0xFF4CAF82);
  static const secondaryContainer = Color(0xFFD8F4E8);

  // Couleur tertiaire — orange pêche
  static const tertiary = Color(0xFFFF8A65);
  static const tertiaryContainer = Color(0xFFFFE0D4);

  // Fond clair
  static const surface = Color(0xFFF8F7FF);
  static const background = Color(0xFFF0EFF9);
  static const error = Color(0xFFD32F2F);
}

abstract class AppTheme {
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.secondary,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.tertiary,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: Color(0xFF1C1B1F),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Nunito pour le corps, Baloo2 pour les titres enfants
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge:
            GoogleFonts.baloo2(fontSize: 57, fontWeight: FontWeight.w700),
        displayMedium:
            GoogleFonts.baloo2(fontSize: 45, fontWeight: FontWeight.w700),
        displaySmall:
            GoogleFonts.baloo2(fontSize: 36, fontWeight: FontWeight.w700),
        headlineLarge:
            GoogleFonts.baloo2(fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium:
            GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall:
            GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
              GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3D35A8),
      secondary: AppColors.secondary,
      surface: Color(0xFF1C1B2E),
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme:
          GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.baloo2(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.baloo2(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

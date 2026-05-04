// ============================================================
// Fichier : lib/core/theme/typography.dart
// Description : Configuration typographique Orphotonie.
//               Nunito (corps) + Baloo2 (titres enfant).
//               Tailles minimales WCAG : 16sp corps, 14sp caption.
//               Supporte MediaQuery.textScaleFactor.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Construit le [TextTheme] de l'application.
///
/// - Corps : Nunito (lisible, diacritiques FR complets).
/// - Titres display/headline : Baloo2 (ludique, adapté aux enfants).
/// - Taille min corps : 16sp. Caption : 14sp.
abstract class AppTypography {
  /// Taille minimale du corps de texte (WCAG).
  static const double bodyMinSize = 16.0;

  /// Taille minimale des labels / captions (WCAG).
  static const double captionMinSize = 14.0;

  /// TextTheme clair (fond clair, texte sombre).
  static TextTheme textTheme({Color? bodyColor}) {
    final base = GoogleFonts.nunitoTextTheme();
    final c = bodyColor ?? const Color(0xFF1C1B1F);
    return base.copyWith(
      // Titres enfant — Baloo2
      displayLarge: GoogleFonts.baloo2(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: c,
      ),
      displayMedium: GoogleFonts.baloo2(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: c,
      ),
      displaySmall: GoogleFonts.baloo2(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: c,
      ),
      headlineLarge: GoogleFonts.baloo2(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      headlineMedium: GoogleFonts.baloo2(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      headlineSmall: GoogleFonts.baloo2(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      // Corps — Nunito ≥ 16sp
      titleLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      titleSmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: c,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: c,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c,
      ),
      // Labels — ≥ 14sp
      labelLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: c,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: c,
      ),
    );
  }
}

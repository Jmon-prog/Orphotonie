// ============================================================
// Fichier : lib/core/theme/typography.dart
// Description : Configuration typographique Orphotonie.
//               Nunito (corps) + Baloo2 (titres enfant).
//               Tailles minimales WCAG : 16sp corps, 14sp caption.
//               Supporte MediaQuery.textScaleFactor.
// ============================================================

import 'package:flutter/material.dart';

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
    const base = TextTheme();
    final c = bodyColor ?? const Color(0xFF1C1B1F);
    return base.copyWith(
      // Titres enfant — Baloo2
      displayLarge: TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: c,),
      displayMedium: TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: c,),
      displaySmall: TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: c,),
      headlineLarge: TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: c,),
      headlineMedium: TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: c,),
      headlineSmall: TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: c,),
      // Corps — Nunito ≥ 16sp
      titleLarge: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: c,),
      titleMedium: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: c,),
      titleSmall: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c,),
      bodyLarge: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: c,),
      bodyMedium: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: c,),
      bodySmall: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: c,),
      // Labels — ≥ 14sp
      labelLarge: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: c,),
      labelMedium: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c,),
      labelSmall: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c,),
    );
  }
}

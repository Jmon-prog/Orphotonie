// ============================================================
// Fichier : lib/core/layout/breakpoints.dart
//
// Définition des breakpoints utilisés dans toute l'application.
// Inspirés des breakpoints Material Design 3 et adaptés au
// contexte orthophonique (téléphone → tableau blanc interactif).
//
// Usage :
//   final size = Breakpoints.of(context);
//   if (size == ScreenSize.compact) { ... }
// ============================================================

import 'package:flutter/widgets.dart';

/// Taille d'écran logique déterminée par la largeur disponible.
enum ScreenSize {
  /// < 600 dp — Téléphone portrait
  compact,

  /// 600–839 dp — Téléphone paysage / Tablette portrait
  medium,

  /// 840–1199 dp — Tablette paysage / Grand écran
  expanded,

  /// 1200–1599 dp — Desktop / Laptop
  large,

  /// ≥ 1600 dp — Écran large / TV / Tableau blanc interactif
  extraLarge,
}

/// Grille de breakpoints de l'application Orphotonie.
///
/// Utiliser [Breakpoints.of] pour obtenir la taille courante depuis
/// n'importe quel widget. Les valeurs sont les largeurs minimales
/// pour entrer dans la catégorie.
abstract final class Breakpoints {
  // Largeurs minimales (dp)
  static const double compact    = 0;      // < 600 dp  → Téléphone portrait
  static const double medium     = 600;    // 600–839   → Téléphone paysage / Tablette portrait
  static const double expanded   = 840;    // 840–1199  → Tablette paysage / Grand écran
  static const double large      = 1200;   // 1200–1599 → Desktop / Laptop
  static const double extraLarge = 1600;   // ≥ 1600    → Écran large / TV / Tableau blanc

  /// Retourne la [ScreenSize] correspondant à la largeur de la fenêtre courante.
  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < medium)     return ScreenSize.compact;
    if (width < expanded)   return ScreenSize.medium;
    if (width < large)      return ScreenSize.expanded;
    if (width < extraLarge) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }

  /// Vrai si l'écran est en mode paysage sur téléphone compact.
  /// Cas spécifique : hauteur réduite (~360 dp), navigation en Rail.
  static bool isLandscapePhone(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    return size.width < medium && orientation == Orientation.landscape;
  }

  /// Vrai pour les mises en page qui nécessitent un NavigationRail
  /// (medium ou téléphone en paysage).
  static bool useRail(BuildContext context) {
    final screenSize = of(context);
    return screenSize == ScreenSize.medium || isLandscapePhone(context);
  }

  /// Vrai pour les mises en page qui nécessitent un Drawer permanent
  /// (expanded, large, extraLarge).
  static bool useDrawer(BuildContext context) {
    final screenSize = of(context);
    return screenSize == ScreenSize.expanded ||
        screenSize == ScreenSize.large ||
        screenSize == ScreenSize.extraLarge;
  }
}

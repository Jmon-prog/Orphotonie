// ============================================================
// Fichier : lib/core/theme/app_spacing.dart
// Description : Tokens d'espacement et de rayon de l'application.
//               Utiliser ces constantes partout plutôt que des valeurs
//               littérales pour garantir la cohérence visuelle.
// ============================================================

import 'package:flutter/material.dart' show BorderRadius, Radius;

/// Espacement — grille de 4 dp.
///
/// Toutes les valeurs sont des multiples de 4 pour s'aligner sur la grille
/// Material Design. Utiliser ces constantes plutôt que des littéraux afin
/// de garantir la cohérence et de simplifier les ajustements globaux.
abstract class AppSpacing {
  /// 4 dp — séparation interne minimale, icône/label.
  static const double xxs = 4;

  /// 8 dp — padding interne compact (chip, badge).
  static const double xs = 8;

  /// 12 dp — padding interne card légère.
  static const double s = 12;

  /// 16 dp — espacement standard (padding écran, ListTile).
  static const double m = 16;

  /// 20 dp — espace entre blocs proches.
  static const double ml = 20;

  /// 24 dp — espacement large (entre sections).
  static const double l = 24;

  /// 32 dp — espacement très large (entre groupes).
  static const double xl = 32;

  /// 48 dp — espace héroïque (illustration + texte).
  static const double xxl = 48;

  /// 64 dp — espacement exceptionnel (splash / onboarding).
  static const double xxxl = 64;

  // ---- Padding fréquents (shortcuts) ----

  /// Padding horizontal standard des écrans.
  static const double screenHorizontal = m;

  /// Padding vertical standard des écrans.
  static const double screenVertical = l;

  /// Padding interne des cartes.
  static const double cardPadding = m;

  /// Espace entre deux éléments de liste.
  static const double listItemGap = xs;

  /// Espace entre icon et label dans un bouton.
  static const double iconLabelGap = xs;
}

/// Rayons de bordure — cohérents avec Material 3 Shape Scale.
///
/// Chaque constante est disponible en valeur scalaire ([double]) et en
/// objet prêt à l'emploi ([BorderRadius]) via les alias `border*`.
abstract class AppRadius {
  /// 4 dp — chip, tag.
  static const double xs = 4;

  /// 8 dp — petits éléments (badge, tooltip).
  static const double s = 8;

  /// 12 dp — champs de saisie, boutons.
  static const double m = 12;

  /// 16 dp — cartes, dialogues compacts.
  static const double l = 16;

  /// 24 dp — bottomSheet, grands panneaux.
  static const double xl = 24;

  /// 28 dp — FAB, boutons circulaires.
  static const double xxl = 28;

  // ---- BorderRadius utilitaires ----

  /// 4 dp sous forme de [BorderRadius] — chip, tag.
  static const borderXs = BorderRadius.all(Radius.circular(xs));

  /// 8 dp sous forme de [BorderRadius] — petits éléments (badge, tooltip).
  static const borderS = BorderRadius.all(Radius.circular(s));

  /// 12 dp sous forme de [BorderRadius] — champs de saisie, boutons.
  static const borderM = BorderRadius.all(Radius.circular(m));

  /// 16 dp sous forme de [BorderRadius] — cartes, dialogues compacts.
  static const borderL = BorderRadius.all(Radius.circular(l));

  /// 24 dp sous forme de [BorderRadius] — bottomSheet, grands panneaux.
  static const borderXl = BorderRadius.all(Radius.circular(xl));
}

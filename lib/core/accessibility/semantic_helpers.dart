// ============================================================
// Fichier : lib/core/accessibility/semantic_helpers.dart
// Description : Helpers réutilisables pour Semantics().
//               Simplifie l'ajout d'informations d'accessibilité
//               sur les éléments interactifs (boutons, cartes, etc.).
// ============================================================

import 'package:flutter/material.dart';

/// Enveloppe un widget dans un [Semantics] avec un label lisible.
///
/// Utiliser sur tout élément interactif sans texte visible (icônes, images).
Widget semanticLabel(String label, Widget child) {
  return Semantics(
    label: label,
    child: child,
  );
}

/// Enveloppe un widget dans un [Semantics] de type bouton.
///
/// Indique au lecteur d'écran que l'élément est activable.
Widget semanticButton(String label, Widget child) {
  return Semantics(
    label: label,
    button: true,
    child: child,
  );
}

/// Enveloppe un widget dans un [Semantics] d'en-tête.
///
/// Utile pour les titres de section dans les listes.
Widget semanticHeader(String label, Widget child) {
  return Semantics(
    label: label,
    header: true,
    child: child,
  );
}

/// Enveloppe un widget dans un [Semantics] d'image.
Widget semanticImage(String description, Widget child) {
  return Semantics(
    label: description,
    image: true,
    child: child,
  );
}

/// Exclut un widget de l'arbre sémantique.
///
/// Utiliser sur les éléments purement décoratifs (fond, séparateur…).
Widget semanticExclude(Widget child) {
  return ExcludeSemantics(child: child);
}

/// Merge les nœuds sémantiques enfants en un seul.
///
/// Utile pour les cartes contenant plusieurs textes
/// qui doivent être lus comme un bloc.
Widget semanticMerge(Widget child) {
  return MergeSemantics(child: child);
}

/// Extension sur [Widget] pour chaîner les Semantics.
extension SemanticsX on Widget {
  /// Ajoute un label sémantique au widget.
  Widget withSemanticLabel(String label) => semanticLabel(label, this);

  /// Marque le widget comme bouton accessible.
  Widget withSemanticButton(String label) => semanticButton(label, this);

  /// Marque le widget comme en-tête accessible.
  Widget withSemanticHeader(String label) => semanticHeader(label, this);

  /// Marque le widget comme image accessible.
  Widget withSemanticImage(String description) =>
      semanticImage(description, this);

  /// Exclut le widget de l'arbre sémantique.
  Widget excludeFromSemantics() => semanticExclude(this);

  /// Fusionne les sous-nœuds sémantiques.
  Widget mergeSemantics() => semanticMerge(this);
}

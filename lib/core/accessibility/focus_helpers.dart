// ============================================================
// Fichier : lib/core/accessibility/focus_helpers.dart
// Description : Helpers pour la gestion du focus et la navigation
//               clavier/manette sur desktop et tablette.
//               Assure un parcours logique des éléments interactifs.
// ============================================================

import 'package:flutter/material.dart';

/// Wrapper qui impose un ordre de focus explicite dans un écran.
///
/// Utiliser dans les layouts complexes pour garantir que la navigation
/// Tab/Shift+Tab suit un ordre logique (haut→bas, gauche→droite).
class FocusOrderGroup extends StatelessWidget {
  const FocusOrderGroup({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: child,
    );
  }
}

/// Assigne un ordre numérique de focus à un widget.
///
/// Plus la valeur est basse, plus le widget reçoit le focus tôt.
class FocusOrdered extends StatelessWidget {
  const FocusOrdered({
    super.key,
    required this.order,
    required this.child,
  });

  /// Ordre de priorité (0 = premier focus).
  final double order;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(order),
      child: child,
    );
  }
}

/// Extension sur [Widget] pour chaîner l'ordre de focus.
extension FocusOrderX on Widget {
  /// Assigne un ordre de focus au widget.
  Widget withFocusOrder(double order) =>
      FocusOrdered(order: order, child: this);
}

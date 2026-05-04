// ============================================================
// Fichier : lib/core/widgets/max_width_container.dart
//
// Conteneur centré avec contrainte de largeur maximale.
// Utilisé en mode ExtraLarge (≥ 1600 dp) pour éviter que le
// contenu ne s'étire sur toute la largeur d'un grand écran.
//
// La largeur maximale par défaut est 1200 dp, conformément aux
// recommandations Material Design 3 pour les grands écrans.
// ============================================================

import 'package:flutter/material.dart';

/// Centre le [child] horizontalement et le contraint à [maxWidth].
///
/// Sur les petits écrans, le widget est transparent (pas de marge).
/// Sur les grands écrans, des marges latérales apparaissent.
///
/// Usage :
/// ```dart
/// MaxWidthContainer(
///   child: myContent,
/// )
/// ```
class MaxWidthContainer extends StatelessWidget {
  const MaxWidthContainer({
    required this.child,
    this.maxWidth = 1200,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget child;

  /// Largeur maximale du contenu en dp (défaut : 1200).
  final double maxWidth;

  /// Padding interne appliqué au contenu.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

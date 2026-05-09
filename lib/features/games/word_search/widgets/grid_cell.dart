// ============================================================
// Fichier : lib/features/games/word_search/widgets/grid_cell.dart
// Description : Cellule individuelle de la grille de mots cachés.
//               Lettre + couleur de fond selon état.
//               Taille min 44dp (accessibilité tactile).
// ============================================================

import 'package:flutter/material.dart';

/// Cellule de la grille de mots cachés.
class GridCell extends StatelessWidget {
  const GridCell({
    super.key,
    required this.letter,
    required this.size,
    this.highlightColor,
    this.isSelected = false,
  });

  /// Lettre affichée.
  final String letter;

  /// Taille de la cellule.
  final double size;

  /// Couleur de surbrillance (mot trouvé).
  final Color? highlightColor;

  /// Cellule dans la sélection en cours.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;

    if (highlightColor != null) {
      bgColor = highlightColor!.withValues(alpha: 0.3);
      textColor = highlightColor!;
    } else if (isSelected) {
      bgColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
    } else {
      bgColor = theme.colorScheme.surface;
      textColor = theme.colorScheme.onSurface;
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: isSelected ? 2 : 0.5,
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight:
              highlightColor != null || isSelected
                  ? FontWeight.bold
                  : FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

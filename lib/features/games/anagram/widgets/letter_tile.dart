// ============================================================
// Fichier : lib/features/games/anagram/widgets/letter_tile.dart
// Description : Tuile de lettre draggable et tappable pour le jeu
//               Anagramme. Micro-rebond à la pose. Responsive.
// ============================================================

import 'package:flutter/material.dart';

/// Tuile représentant une lettre dans le jeu Anagramme.
///
/// Supporte :
/// - Tap pour sélectionner/placer
/// - Drag-and-drop (touch + souris)
/// - Indice révélé (couleur verte fixe)
/// - Responsive via [size]
class LetterTile extends StatelessWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.index,
    this.onTap,
    this.isRevealed = false,
    this.isEmpty = false,
    this.size = 52,
    this.isDraggable = true,
  });

  /// Lettre affichée (null si vide).
  final String? letter;

  /// Index de la tuile dans sa zone.
  final int index;

  /// Callback au tap.
  final VoidCallback? onTap;

  /// Lettre révélée par l'aide (style fixe, non déplaçable).
  final bool isRevealed;

  /// Emplacement vide (pas de lettre).
  final bool isEmpty;

  /// Taille de la tuile (côté du carré).
  final double size;

  /// Peut être glissé (drag).
  final bool isDraggable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isEmpty || letter == null) {
      return _buildSlot(colorScheme);
    }

    final tile = _buildTile(colorScheme);

    if (!isDraggable || isRevealed) return tile;

    return Draggable<int>(
      data: index,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: _buildTile(colorScheme, feedback: true),
      ),
      childWhenDragging: _buildSlot(colorScheme),
      child: tile,
    );
  }

  Widget _buildTile(ColorScheme colorScheme, {bool feedback = false}) {
    final bgColor =
        isRevealed ? Colors.green.shade100 : colorScheme.primaryContainer;
    final borderColor =
        isRevealed ? Colors.green.shade400 : colorScheme.primary.withAlpha(80);

    return Semantics(
      label: 'Lettre $letter',
      button: !isRevealed,
      child: GestureDetector(
        onTap: isRevealed ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: feedback ? size * 1.1 : size,
          height: feedback ? size * 1.1 : size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: feedback
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            letter ?? '',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: isRevealed
                  ? Colors.green.shade800
                  : colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(ColorScheme colorScheme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha(40),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
    );
  }
}

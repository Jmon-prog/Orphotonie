// ============================================================
// Fichier : lib/features/games/word_search/widgets/word_grid.dart
// Description : Grille interactive de mots cachés.
//               Gestion tactile (glissement) et souris (clic-drag).
//               Surbrillance en temps réel pendant la sélection.
//               Responsive, accessible.
// ============================================================

import 'package:flutter/material.dart';
import 'grid_cell.dart';

/// Grille interactive de mots cachés.
///
/// Gère la sélection par glissement (mobile) et clic-drag (desktop).
class WordGrid extends StatelessWidget {
  const WordGrid({
    super.key,
    required this.grid,
    required this.gridSize,
    required this.highlightedCells,
    required this.currentSelection,
    required this.onCellDown,
    required this.onCellMove,
    required this.onSelectionEnd,
    this.cellSize = 44,
  });

  /// Grille de lettres [row][col].
  final List<List<String>> grid;

  /// Taille NxN.
  final int gridSize;

  /// Cellules surlignées (mots trouvés).
  final Map<(int, int), Color> highlightedCells;

  /// Sélection en cours.
  final List<(int, int)> currentSelection;

  /// Callback début de sélection.
  final void Function(int row, int col) onCellDown;

  /// Callback glissement.
  final void Function(int row, int col) onCellMove;

  /// Callback fin de sélection.
  final VoidCallback onSelectionEnd;

  /// Taille de chaque cellule.
  final double cellSize;

  /// Calcule la cellule sous le doigt/curseur.
  (int, int)? _cellFromOffset(Offset offset) {
    final row = (offset.dy / cellSize).floor();
    final col = (offset.dx / cellSize).floor();
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) return null;
    return (row, col);
  }

  @override
  Widget build(BuildContext context) {
    final selectionSet = currentSelection.toSet();

    return Semantics(
      label: 'Grille de mots cachés, $gridSize par $gridSize',
      child: GestureDetector(
        onPanStart: (details) {
          final cell = _cellFromOffset(details.localPosition);
          if (cell != null) onCellDown(cell.$1, cell.$2);
        },
        onPanUpdate: (details) {
          final cell = _cellFromOffset(details.localPosition);
          if (cell != null) onCellMove(cell.$1, cell.$2);
        },
        onPanEnd: (_) => onSelectionEnd(),
        child: SizedBox(
          width: cellSize * gridSize,
          height: cellSize * gridSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(gridSize, (row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(gridSize, (col) {
                  final pos = (row, col);
                  return GridCell(
                    letter: grid[row][col],
                    size: cellSize,
                    highlightColor: highlightedCells[pos],
                    isSelected: selectionSet.contains(pos),
                  );
                }),
              );
            }),
          ),
        ),
      ),
    );
  }
}

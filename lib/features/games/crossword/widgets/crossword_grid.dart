// ============================================================
// Fichier : lib/features/games/crossword/widgets/crossword_grid.dart
// Description : Grille interactive de mots croisés.
//               Gère le tap sur cellule et l'affichage.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../crossword_generator.dart';
import '../crossword_state.dart';
import 'crossword_cell.dart';

/// Grille de mots croisés interactive.
class CrosswordGridWidget extends StatelessWidget {
  const CrosswordGridWidget({
    super.key,
    required this.gridData,
    required this.userInput,
    required this.cellStates,
    required this.selection,
    required this.cellSize,
    required this.onCellTap,
  });

  /// Données de la grille.
  final CrosswordGrid gridData;

  /// Saisie utilisateur.
  final Map<(int, int), String> userInput;

  /// États des cellules.
  final Map<(int, int), CellState> cellStates;

  /// Sélection active.
  final CrosswordSelection? selection;

  /// Taille d'une cellule.
  final double cellSize;

  /// Callback au tap sur une cellule.
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    // Calculer les numéros par position
    final numberMap = <(int, int), int>{};
    for (final p in gridData.placements) {
      if (p.number != null) {
        final key = (p.startRow, p.startCol);
        // Garder le plus petit numéro si plusieurs mots commencent ici
        if (!numberMap.containsKey(key) || p.number! < numberMap[key]!) {
          numberMap[key] = p.number!;
        }
      }
    }

    // Cellules du mot sélectionné
    final selectedCells = <(int, int)>{};
    (int, int)? activeCellPos;
    if (selection != null) {
      final placement = gridData.placements[selection!.placementIndex];
      final cells = placement.cells;
      selectedCells.addAll(cells);
      if (selection!.cellIndex < cells.length) {
        activeCellPos = cells[selection!.cellIndex];
      }
    }

    return Semantics(
      label: 'Grille de mots croisés',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(gridData.rows, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(gridData.cols, (col) {
              final letter = gridData.grid[row][col];
              final isBlack = letter == null;
              final pos = (row, col);

              return CrosswordCell(
                size: cellSize,
                letter: letter,
                userLetter: userInput[pos],
                cellState: cellStates[pos],
                isBlack: isBlack,
                isSelected: activeCellPos == pos,
                isInSelectedWord: selectedCells.contains(pos),
                number: numberMap[pos],
                onTap: isBlack ? null : () => onCellTap(row, col),
              );
            }),
          );
        }),
      ),
    );
  }
}

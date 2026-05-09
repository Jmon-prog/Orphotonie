// ============================================================
// Fichier : lib/features/games/crossword/widgets/crossword_cell.dart
// Description : Cellule individuelle de la grille de mots croisés.
//               3 types : noire, vide, lettre.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../crossword_state.dart';

/// Cellule de la grille de mots croisés.
class CrosswordCell extends StatelessWidget {
  const CrosswordCell({
    super.key,
    required this.size,
    this.letter,
    this.userLetter,
    this.cellState,
    this.isBlack = false,
    this.isSelected = false,
    this.isInSelectedWord = false,
    this.number,
    this.onTap,
  });

  /// Taille de la cellule.
  final double size;

  /// Lettre correcte (null = case noire ou vide).
  final String? letter;

  /// Lettre saisie par l'utilisateur.
  final String? userLetter;

  /// État de la cellule.
  final CellState? cellState;

  /// Case noire.
  final bool isBlack;

  /// Cellule active (curseur).
  final bool isSelected;

  /// Cellule dans le mot sélectionné.
  final bool isInSelectedWord;

  /// Numéro de début de mot.
  final int? number;

  /// Callback au tap.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isBlack) {
      return SizedBox(
        width: size,
        height: size,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(color: Colors.black54, width: 0.5),
          ),
        ),
      );
    }

    // Couleur de fond
    Color bgColor;
    if (isSelected) {
      bgColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.4);
    } else if (isInSelectedWord) {
      bgColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    } else if (cellState == CellState.correct) {
      bgColor = Colors.green.withValues(alpha: 0.2);
    } else if (cellState == CellState.revealed) {
      bgColor = Colors.orange.withValues(alpha: 0.2);
    } else {
      bgColor = Colors.white;
    }

    // Couleur du texte
    Color textColor;
    if (cellState == CellState.correct) {
      textColor = Colors.green.shade800;
    } else if (cellState == CellState.revealed) {
      textColor = Colors.orange.shade800;
    } else {
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: _accessibilityLabel(),
        child: SizedBox(
          width: size,
          height: size,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black38,
                width: isSelected ? 2 : 0.5,
              ),
            ),
            child: Stack(
              children: [
                // Numéro
                if (number != null)
                  Positioned(
                    top: 1,
                    left: 2,
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontSize: size * 0.25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                // Lettre
                if (userLetter != null)
                  Center(
                    child: Text(
                      userLetter!,
                      style: TextStyle(
                        fontSize: size * 0.5,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _accessibilityLabel() {
    if (isBlack) return 'Case noire';
    final parts = <String>[];
    if (number != null) parts.add('Numéro $number');
    if (userLetter != null) {
      parts.add('Lettre $userLetter');
    } else {
      parts.add('Case vide');
    }
    if (cellState == CellState.correct) parts.add('Correct');
    if (cellState == CellState.revealed) parts.add('Révélé');
    return parts.join(', ');
  }
}

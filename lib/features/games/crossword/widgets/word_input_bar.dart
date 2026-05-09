// ============================================================
// Fichier : lib/features/games/crossword/widgets/word_input_bar.dart
// Description : Barre de saisie pour le mot sélectionné.
//               Affiche le numéro, l'orientation et le clavier.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../crossword_generator.dart';
import '../crossword_state.dart';

/// Barre de saisie du mot sélectionné.
class WordInputBar extends StatelessWidget {
  const WordInputBar({
    super.key,
    required this.placement,
    required this.selection,
    required this.userInput,
    required this.cellStates,
    required this.isCompleted,
    required this.onLetter,
    required this.onDelete,
    required this.onHint,
  });

  /// Mot sélectionné.
  final CrosswordPlacement placement;

  /// Sélection courante.
  final CrosswordSelection selection;

  /// Saisie utilisateur.
  final Map<(int, int), String> userInput;

  /// États des cellules.
  final Map<(int, int), CellState> cellStates;

  /// Mot déjà complété.
  final bool isCompleted;

  /// Callback : saisie d'une lettre.
  final void Function(String letter) onLetter;

  /// Callback : suppression.
  final VoidCallback onDelete;

  /// Callback : indice.
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    final cells = placement.cells;
    final orientation =
        placement.orientation == WordOrientation.horizontal ? '→' : '↓';

    return Semantics(
      label: 'Barre de saisie : ${placement.number} $orientation',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête : numéro + orientation + indice
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isCompleted
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${placement.number ?? '?'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  orientation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    placement.clue,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isCompleted)
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline),
                    tooltip: 'Indice (-20 pts)',
                    onPressed: onHint,
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Cases du mot
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cells.length, (i) {
                final (r, c) = cells[i];
                final letter = userInput[(r, c)];
                final state = cellStates[(r, c)];
                final isActive = i == selection.cellIndex;

                Color borderColor;
                Color bgColor;
                if (state == CellState.correct) {
                  borderColor = Colors.green;
                  bgColor = Colors.green.withValues(alpha: 0.15);
                } else if (state == CellState.revealed) {
                  borderColor = Colors.orange;
                  bgColor = Colors.orange.withValues(alpha: 0.15);
                } else if (isActive) {
                  borderColor = Theme.of(context).colorScheme.primary;
                  bgColor =
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
                } else {
                  borderColor = Colors.grey.shade400;
                  bgColor = Colors.white;
                }

                return Container(
                  width: 32,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(
                      color: borderColor,
                      width: isActive ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      letter ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: state == CellState.correct
                            ? Colors.green.shade800
                            : state == CellState.revealed
                                ? Colors.orange.shade800
                                : Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Service pour intercepter les touches physiques (desktop).
class CrosswordKeyboardHandler extends StatelessWidget {
  const CrosswordKeyboardHandler({
    super.key,
    required this.child,
    required this.onLetter,
    required this.onDelete,
    required this.focusNode,
  });

  final Widget child;
  final void Function(String letter) onLetter;
  final VoidCallback onDelete;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        final key = event.logicalKey;

        // Lettres A-Z
        if (key.keyLabel.length == 1 &&
            RegExp(r'[a-zA-Z]').hasMatch(key.keyLabel)) {
          onLetter(key.keyLabel.toUpperCase());
          return;
        }

        // Suppression
        if (key == LogicalKeyboardKey.backspace ||
            key == LogicalKeyboardKey.delete) {
          onDelete();
        }
      },
      child: child,
    );
  }
}

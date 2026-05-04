// ============================================================
// Fichier : lib/features/games/fill_blank/widgets/word_with_blanks.dart
// Description : Affichage du mot avec lacunes.
//               Lettres visibles + emplacements vides (soulignés).
//               Lettres révélées par aide en vert.
//               Responsive, accessible.
// ============================================================

import 'package:flutter/material.dart';

/// Affiche le mot avec ses lacunes.
///
/// [display] : liste de lettres (null = lacune à remplir).
/// [answers] : lettres saisies par l'utilisateur.
/// [revealedPositions] : indices révélés par l'aide.
/// [isCorrect] : résultat (null = en cours, true/false).
class WordWithBlanks extends StatelessWidget {
  const WordWithBlanks({
    super.key,
    required this.display,
    this.answers = const {},
    this.revealedPositions = const {},
    this.isCorrect,
    this.tileSize = 44,
    this.onBlankTap,
    this.selectedBlankIndex,
  });

  /// Liste des lettres (null = lacune).
  final List<String?> display;

  /// Réponses utilisateur : index → lettre.
  final Map<int, String> answers;

  /// Positions révélées par l'aide.
  final Set<int> revealedPositions;

  /// Résultat de la validation.
  final bool? isCorrect;

  /// Taille de chaque tuile.
  final double tileSize;

  /// Callback quand une lacune est tappée (mode frappe).
  final void Function(int index)? onBlankTap;

  /// Index de la lacune sélectionnée.
  final int? selectedBlankIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Mot avec lacunes',
      child: Wrap(
        spacing: 4,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(display.length, (i) {
          final letter = display[i];
          final isBlank = letter == null;
          final isRevealed = revealedPositions.contains(i);
          final answer = answers[i];
          final isSelected = selectedBlankIndex == i;

          if (!isBlank && !isRevealed) {
            // Lettre visible (non masquée)
            return _LetterBox(
              letter: letter,
              size: tileSize,
              color: theme.colorScheme.surfaceContainerHighest,
              textColor: theme.colorScheme.onSurface,
            );
          }

          if (isRevealed) {
            // Lettre révélée par aide
            return _LetterBox(
              letter: display[i] ?? answer ?? '_',
              size: tileSize,
              color: Colors.green.shade100,
              textColor: Colors.green.shade800,
              borderColor: Colors.green,
            );
          }

          // Lacune
          final hasAnswer = answer != null && answer.isNotEmpty;

          Color bgColor;
          Color borderCol;

          if (isCorrect == true && hasAnswer) {
            bgColor = Colors.green.shade50;
            borderCol = Colors.green;
          } else if (isCorrect == false && hasAnswer) {
            bgColor = Colors.red.shade50;
            borderCol = Colors.red;
          } else if (isSelected) {
            bgColor = theme.colorScheme.primaryContainer;
            borderCol = theme.colorScheme.primary;
          } else {
            bgColor = theme.colorScheme.surface;
            borderCol = theme.colorScheme.outline;
          }

          return GestureDetector(
            onTap: onBlankTap != null ? () => onBlankTap!(i) : null,
            child: Semantics(
              label: hasAnswer
                  ? 'Lacune remplie : $answer'
                  : 'Lacune vide, position ${i + 1}',
              button: onBlankTap != null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: tileSize,
                height: tileSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border(
                    bottom: BorderSide(
                      color: borderCol,
                      width: isSelected ? 3 : 2,
                    ),
                  ),
                ),
                child: Text(
                  hasAnswer ? answer : '_',
                  style: TextStyle(
                    fontSize: tileSize * 0.5,
                    fontWeight: FontWeight.bold,
                    color: hasAnswer
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Boîte simple pour une lettre fixe.
class _LetterBox extends StatelessWidget {
  const _LetterBox({
    required this.letter,
    required this.size,
    required this.color,
    required this.textColor,
    this.borderColor,
  });

  final String letter;
  final double size;
  final Color color;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

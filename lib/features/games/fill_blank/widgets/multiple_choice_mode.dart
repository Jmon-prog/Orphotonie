// ============================================================
// Fichier : lib/features/games/fill_blank/widgets/multiple_choice_mode.dart
// Description : Mode choix multiple du jeu Mot Lacunaire.
//               4 boutons de proposition, feedback visuel.
//               Responsive, accessible.
// ============================================================

import 'package:flutter/material.dart';

/// Mode choix multiple : 4 boutons de proposition.
class MultipleChoiceMode extends StatelessWidget {
  const MultipleChoiceMode({
    super.key,
    required this.choices,
    required this.onChoiceSelected,
    this.isCorrect,
    this.selectedChoice,
    this.correctAnswer,
  });

  /// Les 4 propositions.
  final List<String> choices;

  /// Callback quand un choix est fait.
  final void Function(String choice) onChoiceSelected;

  /// Résultat de la dernière tentative.
  final bool? isCorrect;

  /// Choix sélectionné (pour feedback).
  final String? selectedChoice;

  /// Réponse correcte (affichée après erreur).
  final String? correctAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Choix multiple : sélectionnez la bonne réponse',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: choices.map((choice) {
          final isSelected = selectedChoice == choice;
          final isAnswer = correctAnswer == choice;

          Color? bgColor;
          Color? borderColor;
          Color? textColor;

          if (isCorrect == true && isSelected) {
            bgColor = Colors.green.shade100;
            borderColor = Colors.green;
            textColor = Colors.green.shade800;
          } else if (isCorrect == false && isSelected) {
            bgColor = Colors.red.shade100;
            borderColor = Colors.red;
            textColor = Colors.red.shade800;
          } else if (isCorrect == false && isAnswer) {
            // Montre la bonne réponse après erreur
            bgColor = Colors.green.shade50;
            borderColor = Colors.green.shade300;
            textColor = Colors.green.shade700;
          } else {
            bgColor = theme.colorScheme.surfaceContainerLow;
            borderColor = theme.colorScheme.outlineVariant;
            textColor = theme.colorScheme.onSurface;
          }

          final disabled = isCorrect != null;

          return Semantics(
            label: 'Proposition : $choice',
            button: true,
            selected: isSelected,
            child: Material(
              color: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2),
              ),
              child: InkWell(
                onTap: disabled ? null : () => onChoiceSelected(choice),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Text(
                    choice,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: textColor,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

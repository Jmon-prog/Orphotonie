// ============================================================
// Fichier : lib/features/games/hangman/widgets/used_letters.dart
// Description : Affichage des lettres déjà essayées dans le jeu Pendu.
//               Séparées en correctes (vert) et incorrectes (rouge).
// ============================================================

import 'package:flutter/material.dart';

/// Liste des lettres déjà essayées.
class UsedLetters extends StatelessWidget {
  const UsedLetters({
    super.key,
    required this.correctLetters,
    required this.incorrectLetters,
  });

  /// Lettres trouvées dans le mot.
  final Set<String> correctLetters;

  /// Lettres absentes du mot.
  final Set<String> incorrectLetters;

  @override
  Widget build(BuildContext context) {
    if (correctLetters.isEmpty && incorrectLetters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Lettres essayées : ${[
        ...correctLetters,
        ...incorrectLetters,
      ].join(", ")}',
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          ...correctLetters.map(
            (l) => _chip(context, l, Colors.green),
          ),
          ...incorrectLetters.map(
            (l) => _chip(context, l, Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String letter, MaterialColor color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }
}

// ============================================================
// Fichier : lib/features/games/hangman/widgets/letter_keyboard.dart
// Description : Clavier A-Z pour le jeu Pendu.
//               Désactive les lettres déjà essayées.
//               Responsive : grille adaptative selon la largeur.
//               Semantics sur chaque touche.
// ============================================================

import 'package:flutter/material.dart';

/// Clavier alphabétique A-Z.
///
/// Les lettres déjà essayées sont désactivées et colorées
/// (vert = correcte, rouge = incorrecte).
class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({
    super.key,
    required this.usedLetters,
    required this.correctLetters,
    required this.onLetterTap,
    this.enabled = true,
  });

  /// Lettres déjà essayées (correctes + incorrectes).
  final Set<String> usedLetters;

  /// Lettres correctement trouvées.
  final Set<String> correctLetters;

  /// Callback quand une lettre est tappée.
  final void Function(String letter) onLetterTap;

  /// Clavier actif (false si le mot est terminé).
  final bool enabled;

  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul de la taille des touches selon la largeur
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth < 400 ? 9 : 13;
        final keySize =
            ((maxWidth - (columns - 1) * 4) / columns).clamp(32.0, 48.0);

        return Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: _alphabet.split('').map((letter) {
            final isUsed = usedLetters.contains(letter);
            final isCorrect = correctLetters.contains(letter);
            final isIncorrect = isUsed && !isCorrect;

            return _KeyButton(
              letter: letter,
              size: keySize,
              isUsed: isUsed,
              isCorrect: isCorrect,
              isIncorrect: isIncorrect,
              enabled: enabled && !isUsed,
              onTap: () => onLetterTap(letter),
            );
          }).toList(),
        );
      },
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.letter,
    required this.size,
    required this.isUsed,
    required this.isCorrect,
    required this.isIncorrect,
    required this.enabled,
    required this.onTap,
  });

  final String letter;
  final double size;
  final bool isUsed;
  final bool isCorrect;
  final bool isIncorrect;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bgColor;
    Color textColor;

    if (isCorrect) {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    } else if (isIncorrect) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade400;
    } else {
      bgColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    }

    return Semantics(
      label: 'Lettre $letter${isUsed ? ", déjà essayée" : ", non essayée"}',
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUsed
                  ? Colors.transparent
                  : colorScheme.primary.withAlpha(60),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.bold,
              color: enabled ? textColor : textColor.withAlpha(100),
            ),
          ),
        ),
      ),
    );
  }
}

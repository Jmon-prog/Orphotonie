// ============================================================
// Fichier : lib/features/games/hangman/widgets/word_display.dart
// Description : Affichage du mot à deviner avec emplacements _ _ _.
//               Révélation animée des lettres trouvées.
//               Responsive, accessible.
// ============================================================

import 'package:flutter/material.dart';

/// Affiche le mot à deviner : lettres trouvées + emplacements vides.
class WordDisplay extends StatelessWidget {
  const WordDisplay({
    super.key,
    required this.revealedWord,
    this.tileSize = 44,
    this.isGameOver = false,
    this.fullWord,
  });

  /// Lettres révélées (null = pas encore trouvé).
  final List<String?> revealedWord;

  /// Taille de chaque emplacement.
  final double tileSize;

  /// La partie est terminée (afficher le mot complet en rouge si perdu).
  final bool isGameOver;

  /// Mot complet (affiché en cas de défaite).
  final String? fullWord;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<String?> letters = isGameOver && fullWord != null
        ? fullWord!.toUpperCase().split('').cast<String?>()
        : revealedWord;
    final isLost = isGameOver && revealedWord.any((l) => l == null);

    return Semantics(
      label: _accessibilityLabel(),
      child: Wrap(
        spacing: 6,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(letters.length, (i) {
          final letter = letters[i];
          final wasRevealed =
              i < revealedWord.length && revealedWord[i] != null;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey('$i-$letter'),
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: letter != null
                        ? (isLost && !wasRevealed
                            ? Colors.red.shade400
                            : colorScheme.primary)
                        : colorScheme.outline.withAlpha(100),
                    width: 3,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: letter != null
                  ? Text(
                      letter,
                      style: TextStyle(
                        fontSize: tileSize * 0.55,
                        fontWeight: FontWeight.bold,
                        color: isLost && !wasRevealed
                            ? Colors.red.shade600
                            : colorScheme.onSurface,
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }

  String _accessibilityLabel() {
    final buffer = StringBuffer('Mot : ');
    for (final l in revealedWord) {
      buffer.write(l ?? 'inconnu');
      buffer.write(' ');
    }
    return buffer.toString().trim();
  }
}

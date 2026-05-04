// ============================================================
// Fichier : lib/features/games/word_search/widgets/word_list_panel.dart
// Description : Liste des mots à trouver dans la grille.
//               Check/uncheck, barré quand trouvé, couleur associée.
//               Accessible.
// ============================================================

import 'package:flutter/material.dart';

/// Panneau affichant la liste des mots à trouver.
class WordListPanel extends StatelessWidget {
  const WordListPanel({
    super.key,
    required this.words,
    required this.foundWords,
    required this.wordColors,
  });

  /// Tous les mots à trouver.
  final List<String> words;

  /// Mots déjà trouvés.
  final Set<String> foundWords;

  /// Couleur attribuée à chaque mot trouvé.
  final Map<String, Color> wordColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Liste des mots à trouver',
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: words.map((word) {
          final isFound = foundWords.contains(word);
          final color = wordColors[word];

          return Semantics(
            label: isFound ? '$word trouvé' : '$word à trouver',
            child: Chip(
              avatar: Icon(
                isFound ? Icons.check_circle : Icons.circle_outlined,
                size: 18,
                color: isFound ? color ?? Colors.green : theme.colorScheme.outline,
              ),
              label: Text(
                word,
                style: TextStyle(
                  decoration: isFound ? TextDecoration.lineThrough : null,
                  color: isFound
                      ? color ?? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                  fontWeight: isFound ? FontWeight.normal : FontWeight.w500,
                ),
              ),
              backgroundColor: isFound
                  ? (color ?? Colors.green).withOpacity(0.1)
                  : theme.colorScheme.surfaceContainerLow,
              side: BorderSide(
                color: isFound
                    ? color ?? Colors.green
                    : theme.colorScheme.outlineVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

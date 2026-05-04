// ============================================================
// Fichier : lib/features/games/word_search/widgets/timer_display.dart
// Description : Affichage du chronomètre du jeu Mots Cachés.
//               Compact, accessible.
// ============================================================

import 'package:flutter/material.dart';

/// Affichage du chronomètre.
class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.label,
  });

  /// Temps formaté (ex: "3:42").
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Chronomètre : $label',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

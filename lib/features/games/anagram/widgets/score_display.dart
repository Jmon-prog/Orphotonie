// ============================================================
// Fichier : lib/features/games/anagram/widgets/score_display.dart
// Description : Affichage du score, progression et timer optionnel
//               pour le jeu Anagramme. Responsive.
// ============================================================

import 'package:flutter/material.dart';

/// Barre d'information affichant le score, la progression et les indices.
class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({
    super.key,
    required this.totalScore,
    required this.progressLabel,
    required this.hintsUsed,
  });

  /// Score total cumulé.
  final int totalScore;

  /// Texte de progression ("3 / 10").
  final String progressLabel;

  /// Nombre d'indices utilisés pour le mot courant.
  final int hintsUsed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Score $totalScore points, progression $progressLabel',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Progression
            _InfoChip(
              icon: Icons.format_list_numbered,
              label: progressLabel,
              color: colorScheme.primary,
              textTheme: textTheme,
            ),

            // Score
            _InfoChip(
              icon: Icons.star,
              label: '$totalScore pts',
              color: Colors.amber.shade700,
              textTheme: textTheme,
            ),

            // Indices utilisés
            if (hintsUsed > 0)
              _InfoChip(
                icon: Icons.lightbulb_outline,
                label: '$hintsUsed aide${hintsUsed > 1 ? 's' : ''}',
                color: Colors.orange,
                textTheme: textTheme,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final Color color;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Fichier : lib/features/stats/presentation/widgets/success_rate_bar.dart
// Description : Barre de progression du taux de réussite.
//               Couleur dégradée vert/orange/rouge selon le taux.
//               Responsive. Accessible.
// ============================================================

import 'package:flutter/material.dart';

/// Barre horizontale affichant un taux de réussite (0-100%).
class SuccessRateBar extends StatelessWidget {
  const SuccessRateBar({
    super.key,
    required this.rate,
    this.label,
    this.height = 24,
  });

  /// Taux de réussite (0-100).
  final double rate;

  /// Libellé affiché à gauche (ex : « Anagramme »).
  final String? label;

  /// Hauteur de la barre.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedRate = rate.clamp(0, 100).toDouble();
    final color = _colorForRate(clampedRate);

    return Semantics(
      label:
          '${label ?? "Taux de réussite"} : ${clampedRate.round()} pour cent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label!, style: theme.textTheme.bodyMedium),
                  Text(
                    '${clampedRate.round()} %',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: SizedBox(
              height: height,
              child: Stack(
                children: [
                  // Fond
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  // Progression
                  FractionallySizedBox(
                    widthFactor: clampedRate / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Couleur selon le taux : rouge < 40, orange < 70, vert >= 70.
  Color _colorForRate(double rate) {
    if (rate < 40) return Colors.red;
    if (rate < 70) return Colors.orange;
    return Colors.green;
  }
}

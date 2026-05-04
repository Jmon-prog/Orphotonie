// ============================================================
// Fichier : lib/features/stats/presentation/widgets/activity_chart.dart
// Description : Barres horizontales du taux de réussite par activité.
//               Responsive. Accessible.
// ============================================================

import 'package:flutter/material.dart';
import '../../data/stats_repository.dart';
import 'success_rate_bar.dart';

/// Graphique en barres des taux de réussite par type d'activité.
class ActivityChart extends StatelessWidget {
  const ActivityChart({
    super.key,
    required this.stats,
  });

  /// Statistiques par activité.
  final List<ActivityStats> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Aucune activité enregistrée.'),
      );
    }

    return Semantics(
      label: 'Taux de réussite par activité',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            SuccessRateBar(
              label: _displayName(stats[i].activityType),
              rate: stats[i].successRate,
            ),
            if (i < stats.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  /// Nom d'affichage lisible pour un type d'activité.
  String _displayName(String activityType) {
    const names = {
      'anagramme': 'Anagramme',
      'pendu': 'Pendu',
      'mot_lacunaire': 'Mot lacunaire',
      'mots_caches': 'Mots cachés',
      'mots_croises': 'Mots croisés',
      'flashcard': 'Flashcard',
      'definition_qcm': 'QCM Définition',
      'syllables': 'Syllabes',
      'memory': 'Memory',
    };
    return names[activityType] ?? activityType;
  }
}

// ============================================================
// Fichier : lib/features/sharing/screens/stats_report_screen.dart
// Description : Écran de rapport de progression reçu par URL.
//               Affiche un snapshot de statistiques partagé via
//               orphotonie://stats?d=ORPH-STAT-...
//               Lecture seule — aucune écriture en base.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/sharing/stats_share_encoder.dart';
import '../../../core/widgets/app_bar.dart';

/// Écran de visualisation d'un rapport de progression partagé.
///
/// Reçoit un [StatsSnapshot] encodé dans une URL et l'affiche en lecture seule.
class StatsReportScreen extends StatelessWidget {
  const StatsReportScreen({
    super.key,
    required this.snapshot,
  });

  /// Snapshot de statistiques à afficher.
  final StatsSnapshot snapshot;

  static const _periodLabels = {
    'week': 'Semaine',
    'month': 'Mois',
    'all': 'Tout',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final periodLabel = _periodLabels[snapshot.period] ?? snapshot.period;

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Rapport — ${snapshot.childName}',
        actions: [
          Semantics(
            label: 'Copier le lien du rapport',
            child: IconButton(
              icon: const Icon(Icons.link),
              tooltip: 'Copier le lien',
              onPressed: () {
                // Réencode pour copier l'URL
                final encoder = StatsShareEncoder();
                final url = encoder.generateStatsUrl(snapshot);
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lien copié ✓')),
                );
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête : identité + période
                    _buildHeader(theme, periodLabel),

                    const SizedBox(height: 20),

                    // Bannière lecture seule
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Rapport reçu par lien — lecture seule. '
                              'Exporté le ${snapshot.exportDate.isNotEmpty ? snapshot.exportDate : "—"}.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Indicateurs globaux
                    _buildGlobalStats(theme, isWide),

                    const SizedBox(height: 24),

                    // Taux par activité
                    if (snapshot.activityStats.isNotEmpty) ...[
                      Text(
                        'Taux de réussite par activité',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...snapshot.activityStats
                          .map((a) => _ActivityRow(stat: a)),
                      const SizedBox(height: 24),
                    ],

                    // Mots difficiles
                    if (snapshot.difficultWords.isNotEmpty) ...[
                      Text(
                        'Mots à retravailler',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: snapshot.difficultWords
                            .map(
                              (mot) => Chip(
                                avatar: const Icon(
                                  Icons.warning_amber_outlined,
                                  size: 16,
                                ),
                                label: Text(mot),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String periodLabel) {
    final initial = snapshot.childName.isNotEmpty
        ? snapshot.childName[0].toUpperCase()
        : '?';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.childName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Période : $periodLabel',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: snapshot.currentStreak > 0 ? Colors.orange : null,
                ),
                Text(
                  '${snapshot.currentStreak}j',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: snapshot.currentStreak > 0 ? Colors.orange : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('streak', style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStats(ThemeData theme, bool isWide) {
    final items = [
      _StatTile(
        label: 'Taux global',
        value: '${snapshot.globalSuccessRate.toStringAsFixed(0)} %',
        icon: Icons.percent,
        color: snapshot.globalSuccessRate >= 70
            ? Colors.green
            : snapshot.globalSuccessRate >= 50
                ? Colors.orange
                : Colors.red,
      ),
      _StatTile(
        label: 'Mots vus',
        value: '${snapshot.totalWordsSeen}',
        icon: Icons.visibility,
        color: theme.colorScheme.primary,
      ),
      _StatTile(
        label: 'Maîtrisés',
        value: '${snapshot.wordsMastered}',
        icon: Icons.star,
        color: Colors.amber,
      ),
      _StatTile(
        label: 'En cours',
        value: '${snapshot.wordsInProgress}',
        icon: Icons.hourglass_bottom,
        color: Colors.blue,
      ),
    ];

    return isWide
        ? Row(
            children: items
                .map(
                  (t) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: t,
                    ),
                  ),
                )
                .toList(),
          )
        : Column(
            children: items
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: t,
                  ),
                )
                .toList(),
          );
  }
}

// ---------------------------------------------------------------------------
// Widgets internes
// ---------------------------------------------------------------------------

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.stat});

  final ActivitySnapshotStat stat;

  static const _activityLabels = {
    'anagram': 'Anagramme',
    'hangman': 'Pendu',
    'fill_blank': 'Mot lacunaire',
    'word_search': 'Mots cachés',
    'crossword': 'Mots croisés',
    'srs': 'Révisions SRS',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rate = stat.successRate;
    final label = _activityLabels[stat.activityType] ?? stat.activityType;
    final color = rate >= 70
        ? Colors.green
        : rate >= 50
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              Text(
                '${rate.toStringAsFixed(0)} % (${stat.successes}/${stat.totalAttempts})',
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

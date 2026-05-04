// ============================================================
// Fichier : lib/features/stats/presentation/word_progress_screen.dart
// Description : Écran de détail de la progression d'un mot.
//               Boîte Leitner, prochaine révision, historique.
//               Responsive. Accessible. 100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../stats/data/stats_repository.dart';
import '../../stats/stats_providers.dart';

/// Écran de détail de la progression d'un mot individuel.
class WordProgressScreen extends ConsumerStatefulWidget {
  const WordProgressScreen({
    super.key,
    required this.wordId,
    required this.mot,
    required this.profileId,
  });

  final int wordId;
  final String mot;
  final int profileId;

  @override
  ConsumerState<WordProgressScreen> createState() => _WordProgressScreenState();
}

class _WordProgressScreenState extends ConsumerState<WordProgressScreen> {
  WordStats? _wordStats;
  List<WordAttempt> _attempts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(statsRepositoryProvider);
      final stats = await repo.getWordStats(
        wordId: widget.wordId,
        profileId: widget.profileId,
      );
      final attempts = await repo.getWordAttemptHistory(
        wordId: widget.wordId,
        profileId: widget.profileId,
      );
      if (mounted) {
        setState(() {
          _wordStats = stats;
          _attempts = attempts;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mot),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _wordStats == null
              ? const Center(child: Text('Aucune donnée pour ce mot.'))
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final stats = _wordStats!;
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : 16,
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte récapitulative
                _buildSummaryCard(context, stats),
                const SizedBox(height: 20),

                // Boîte Leitner visuelle
                _buildLeitnerBoxes(context, stats),
                const SizedBox(height: 20),

                // Prochaine révision
                _buildNextReview(context, stats),
                const SizedBox(height: 20),

                // Historique des tentatives
                Text(
                  'Historique des tentatives',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildAttemptHistory(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, WordStats stats) {
    final theme = Theme.of(context);
    final rateColor = stats.successRate >= 70
        ? Colors.green
        : stats.successRate >= 40
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Taux circulaire
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: stats.successRate / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(rateColor),
                  ),
                  Center(
                    child: Semantics(
                      label:
                          'Taux de réussite : ${stats.successRate.round()} pour cent',
                      child: Text(
                        '${stats.successRate.round()}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: rateColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.nbSuccess} / ${stats.nbSeen} réussites',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _masteryLabel(stats.masteryLevel),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _masteryColor(stats.masteryLevel),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeitnerBoxes(BuildContext context, WordStats stats) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Boîte Leitner', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final box = index + 1;
            final isCurrent = box == stats.leitnerBox;
            return Expanded(
              child: Semantics(
                label: 'Boîte $box${isCurrent ? ", position actuelle" : ""}',
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrent
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$box',
                      style: TextStyle(
                        color: isCurrent
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNextReview(BuildContext context, WordStats stats) {
    final theme = Theme.of(context);
    final nextReview = stats.nextReview;

    String reviewText;
    if (nextReview == null) {
      reviewText = 'Pas encore planifiée';
    } else {
      final now = DateTime.now();
      final diff = nextReview.difference(now);
      if (diff.isNegative) {
        reviewText = 'À réviser maintenant';
      } else if (diff.inDays == 0) {
        reviewText = 'Aujourd\'hui';
      } else if (diff.inDays == 1) {
        reviewText = 'Demain';
      } else {
        reviewText = 'Dans ${diff.inDays} jours';
      }
    }

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.schedule,
          color: theme.colorScheme.primary,
        ),
        title: const Text('Prochaine révision'),
        subtitle: Text(reviewText),
      ),
    );
  }

  Widget _buildAttemptHistory(BuildContext context) {
    if (_attempts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Aucune tentative enregistrée.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _attempts.length,
      itemBuilder: (context, index) {
        final attempt = _attempts[index];
        return ListTile(
          leading: Icon(
            attempt.success ? Icons.check_circle : Icons.cancel,
            color: attempt.success ? Colors.green : Colors.red,
          ),
          title: Text(
            attempt.success ? 'Réussi' : 'Échoué',
          ),
          subtitle: Text(
            '${attempt.firstTry ? "1er essai" : "Réessai"}'
            '${attempt.hintUsed ? " · Indice utilisé" : ""}',
          ),
          trailing: attempt.durationMs > 0
              ? Text('${(attempt.durationMs / 1000).toStringAsFixed(1)}s')
              : null,
        );
      },
    );
  }

  String _masteryLabel(int level) {
    const labels = {
      0: 'Nouveau',
      1: 'En cours',
      2: 'Bien',
      3: 'Maîtrisé',
    };
    return labels[level] ?? 'Inconnu';
  }

  Color _masteryColor(int level) {
    const colors = {
      0: Colors.grey,
      1: Colors.orange,
      2: Colors.blue,
      3: Colors.green,
    };
    return colors[level] ?? Colors.grey;
  }
}

// ============================================================
// Fichier : lib/features/stats/presentation/progress_dashboard_screen.dart
// Description : Tableau de bord praticien — progression globale,
//               taux par activité, heatmap, mots difficiles.
//               Export PDF local. Responsive. Accessible.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stats/data/stats_repository.dart';
import '../../stats/stats_providers.dart';
import '../pdf/progress_pdf_generator.dart';
import 'widgets/success_rate_bar.dart';
import 'widgets/activity_heatmap.dart';
import 'widgets/activity_chart.dart';
import 'widgets/difficult_words_list.dart';
import 'word_progress_screen.dart';
import '../../../core/sharing/sharing_providers.dart';

/// Tableau de bord de progression d'un enfant.
class ProgressDashboardScreen extends ConsumerStatefulWidget {
  const ProgressDashboardScreen({
    super.key,
    required this.profileId,
    required this.childName,
  });

  final int profileId;
  final String childName;

  @override
  ConsumerState<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState
    extends ConsumerState<ProgressDashboardScreen> {
  StatsPeriod _period = StatsPeriod.month;
  ProgressSummary? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = ref.read(statsRepositoryProvider);
      final summary = await repo.getProgressSummary(
        profileId: widget.profileId,
        period: _period,
      );
      if (mounted) {
        setState(() {
          _summary = summary;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Impossible de charger les statistiques.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progression de ${widget.childName}'),
        actions: [
          // Partage par URL
          Semantics(
            button: true,
            label: 'Partager le rapport par lien',
            child: IconButton(
              icon: const Icon(Icons.link),
              tooltip: 'Partager le lien',
              onPressed: _summary != null ? _shareStatsUrl : null,
            ),
          ),
          Semantics(
            button: true,
            label: 'Exporter en PDF',
            child: IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Exporter PDF',
              onPressed: _summary != null ? _exportPdf : null,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final summary = _summary!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sélecteur de période
                _buildPeriodSelector(context),
                const SizedBox(height: 20),

                // Ligne résumé
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildSummaryCard(context, summary)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStreakCard(context, summary)),
                    ],
                  )
                else ...[
                  _buildSummaryCard(context, summary),
                  const SizedBox(height: 12),
                  _buildStreakCard(context, summary),
                ],
                const SizedBox(height: 20),

                // Heatmap
                _buildSection(
                  context,
                  icon: Icons.calendar_month,
                  title: 'Activité (12 derniers mois)',
                  child: ActivityHeatmap(data: summary.heatmap),
                ),
                const SizedBox(height: 20),

                // Taux par activité
                _buildSection(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Par activité',
                  child: ActivityChart(stats: summary.activityStats),
                ),
                const SizedBox(height: 20),

                // Mots difficiles
                _buildSection(
                  context,
                  icon: Icons.warning_amber,
                  title: 'Mots en difficulté (< 50 %)',
                  child: DifficultWordsList(
                    words: summary.difficultWords,
                    onWordTap: (word) => _navigateToWordProgress(word),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Semantics(
      label: 'Sélecteur de période',
      child: SegmentedButton<StatsPeriod>(
        segments: const [
          ButtonSegment(
            value: StatsPeriod.week,
            label: Text('Semaine'),
            icon: Icon(Icons.calendar_view_week),
          ),
          ButtonSegment(
            value: StatsPeriod.month,
            label: Text('Mois'),
            icon: Icon(Icons.calendar_view_month),
          ),
          ButtonSegment(
            value: StatsPeriod.total,
            label: Text('Total'),
            icon: Icon(Icons.calendar_today),
          ),
        ],
        selected: {_period},
        onSelectionChanged: (selected) {
          setState(() => _period = selected.first);
          _loadData();
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ProgressSummary summary) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Taux de réussite',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SuccessRateBar(
              rate: summary.globalSuccessRate,
              height: 28,
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.globalSuccessRate.round()} %',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (summary.periodComparison != null) ...[
              const SizedBox(height: 4),
              _buildTrendBadge(context, summary.periodComparison!),
            ],
            const SizedBox(height: 8),
            Text(
              '${summary.wordsMastered} mots maîtrisés · '
              '${summary.wordsInProgress} en cours',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// Badge de tendance : affiche l'évolution vs la période précédente.
  Widget _buildTrendBadge(BuildContext context, PeriodComparison comparison) {
    final delta = comparison.delta;
    final Color color;
    final IconData icon;
    if (comparison.isImproving) {
      color = Colors.green;
      icon = Icons.trending_up;
    } else if (comparison.isRegressing) {
      color = Colors.red;
      icon = Icons.trending_down;
    } else {
      color = Colors.grey;
      icon = Icons.trending_flat;
    }
    final sign = delta >= 0 ? '+' : '';
    final periodLabel =
        _period == StatsPeriod.week ? 'semaine précédente' : 'mois précédent';

    return Semantics(
      label:
          'Évolution : $sign${delta.round()} points par rapport à la $periodLabel',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            '$sign${delta.round()} pts vs $periodLabel',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, ProgressSummary summary) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Régularité',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color:
                      summary.currentStreak > 0 ? Colors.orange : Colors.grey,
                  size: 36,
                ),
                const SizedBox(width: 8),
                Text(
                  '${summary.currentStreak}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  summary.currentStreak <= 1 ? 'jour' : 'jours consécutifs',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.totalWordsSeen} mots vus au total',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  void _navigateToWordProgress(WordStats word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordProgressScreen(
          wordId: word.wordId,
          mot: word.mot,
          profileId: widget.profileId,
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    try {
      await ProgressPdfGenerator.generateAndOpen(
        childName: widget.childName,
        summary: _summary!,
        period: _period,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la génération du PDF.'),
          ),
        );
      }
    }
  }

  /// Génère un lien URL contenant un snapshot des statistiques et le copie.
  ///
  /// L'URL `orphotonie://stats?d=ORPH-STAT-...` peut être partagée par SMS
  /// ou messagerie. Sur mobile, l'ouvrir affiche ce rapport en lecture seule.
  void _shareStatsUrl() {
    if (_summary == null) return;
    try {
      final encoder = ref.read(statsShareEncoderProvider);
      final snapshot = encoder.summaryToSnapshot(
        summary: _summary!,
        childName: widget.childName,
        period: _period,
      );
      final url = encoder.generateStatsUrl(snapshot);

      Clipboard.setData(ClipboardData(text: url));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lien du rapport copié dans le presse-papiers ✓\n'
            'Partagez-le par SMS ou messagerie.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du lien : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ============================================================
// Fichier : lib/features/stats/pdf/progress_pdf_generator.dart
// Description : Génération de rapport PDF de progression.
//               100 % local — package `pdf` + `printing`.
//               Contenu : en-tête, taux par activité, tableau mots,
//               mots difficiles, recommandations.
// ============================================================

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/stats_repository.dart';

/// Génère un rapport PDF de progression et l'ouvre pour impression.
class ProgressPdfGenerator {
  ProgressPdfGenerator._();

  /// Génère le PDF et ouvre l'aperçu d'impression.
  static Future<void> generateAndOpen({
    required String childName,
    required ProgressSummary summary,
    required StatsPeriod period,
  }) async {
    final pdf = _buildPdf(
      childName: childName,
      summary: summary,
      period: period,
    );

    await Printing.layoutPdf(
      onLayout: (format) async {
        final raw = await pdf.save();
        return raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes);
      },
      name: 'Progression_$childName.pdf',
    );
  }

  static pw.Document _buildPdf({
    required String childName,
    required ProgressSummary summary,
    required StatsPeriod period,
  }) {
    final pdf = pw.Document(
      title: 'Rapport de progression — $childName',
      author: 'Orphotonie',
      compress: false,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(childName, period),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildGlobalStats(summary, period: period),
          pw.SizedBox(height: 20),
          _buildActivityTable(summary.activityStats),
          pw.SizedBox(height: 20),
          _buildDifficultWordsTable(summary.difficultWords),
          pw.SizedBox(height: 20),
          _buildRecommendations(summary),
        ],
      ),
    );

    return pdf;
  }

  // -------------------------------------------------------------------
  // En-tête
  // -------------------------------------------------------------------

  static pw.Widget _buildHeader(String childName, StatsPeriod period) {
    final now = DateTime.now();
    final periodLabel = _periodLabel(period);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Rapport de progression',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Enfant : $childName',
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            'Période : $periodLabel · '
            'Exporté le ${now.day}/${now.month}/${now.year}',
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey600,
            ),
          ),
          pw.Divider(),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Pied de page
  // -------------------------------------------------------------------

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} / ${context.pagesCount}',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey500,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Statistiques globales
  // -------------------------------------------------------------------

  static pw.Widget _buildGlobalStats(
    ProgressSummary summary, {
    StatsPeriod? period,
  }) {
    // Libellé de tendance (si disponible et période non totale)
    String? trendText;
    if (summary.periodComparison != null &&
        period != null &&
        period != StatsPeriod.total) {
      final delta = summary.periodComparison!.delta;
      final sign = delta >= 0 ? '+' : '';
      final periodLabel =
          period == StatsPeriod.week ? 'sem. préc.' : 'mois préc.';
      trendText = '$sign${delta.round()} pts vs $periodLabel';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _statBox(
                'Taux de réussite',
                trendText != null
                    ? '${summary.globalSuccessRate.round()} % ($trendText)'
                    : '${summary.globalSuccessRate.round()} %',
              ),
              _statBox(
                'Mots maîtrisés',
                '${summary.wordsMastered}',
              ),
              _statBox(
                'Mots en cours',
                '${summary.wordsInProgress}',
              ),
              _statBox(
                'Streak',
                '${summary.currentStreak} j',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _statBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // Tableau taux par activité
  // -------------------------------------------------------------------

  static pw.Widget _buildActivityTable(List<ActivityStats> stats) {
    if (stats.isEmpty) {
      return pw.Text(
        'Aucune activité enregistrée.',
        style: const pw.TextStyle(color: PdfColors.grey500),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Taux de réussite par activité',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          headers: ['Activité', 'Tentatives', 'Réussites', 'Taux'],
          data: stats
              .map(
                (s) => [
                  _activityDisplayName(s.activityType),
                  '${s.totalAttempts}',
                  '${s.successes}',
                  '${s.successRate.round()} %',
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // Tableau mots difficiles
  // -------------------------------------------------------------------

  static pw.Widget _buildDifficultWordsTable(List<WordStats> words) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Mots en difficulté (< 50 % de réussite)',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        if (words.isEmpty)
          pw.Text(
            'Aucun mot en difficulté.',
            style: const pw.TextStyle(color: PdfColors.green800),
          )
        else
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey200,
            ),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            headers: [
              'Mot',
              'Dictionnaire',
              'Réussites',
              'Essais',
              'Taux',
              'Boîte',
            ],
            data: words
                .map(
                  (w) => [
                    w.mot,
                    w.dictionaryName.isEmpty ? '—' : w.dictionaryName,
                    '${w.nbSuccess}',
                    '${w.nbSeen}',
                    '${w.successRate.round()} %',
                    '${w.leitnerBox}',
                  ],
                )
                .toList(),
          ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // Recommandations textuelles
  // -------------------------------------------------------------------

  static pw.Widget _buildRecommendations(ProgressSummary summary) {
    final tips = <String>[];

    if (summary.globalSuccessRate < 50) {
      tips.add(
        'Le taux de réussite global est bas (${summary.globalSuccessRate.round()} %). '
        'Réduire le nombre de mots par session pour consolider les acquis.',
      );
    }

    if (summary.difficultWords.length > 5) {
      tips.add(
        '${summary.difficultWords.length} mots sont en difficulté. '
        'Travailler ces mots en isolation avant de les réintroduire dans les jeux.',
      );
    }

    if (summary.currentStreak == 0) {
      tips.add(
        'Aucune session récente. Reprendre des sessions courtes et régulières '
        'pour maintenir la progression.',
      );
    } else if (summary.currentStreak >= 7) {
      tips.add(
        'Excellente régularité (${summary.currentStreak} jours consécutifs) ! '
        'Maintenir ce rythme.',
      );
    }

    // Identifier l'activité la plus faible
    if (summary.activityStats.length > 1) {
      final weakest = summary.activityStats.reduce(
        (a, b) => a.successRate < b.successRate ? a : b,
      );
      if (weakest.successRate < 60) {
        tips.add(
          'L\'activité « ${_activityDisplayName(weakest.activityType)} » '
          'a le plus faible taux (${weakest.successRate.round()} %). '
          'Envisager un travail ciblé sur ce type d\'exercice.',
        );
      }
    }

    if (tips.isEmpty) {
      tips.add(
        'La progression est bonne. Continuer avec les sessions régulières.',
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Recommandations',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        ...tips.map(
          (tip) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: const pw.TextStyle(fontSize: 11)),
                pw.Expanded(
                  child: pw.Text(
                    tip,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // Utilitaires
  // -------------------------------------------------------------------

  static String _periodLabel(StatsPeriod period) {
    switch (period) {
      case StatsPeriod.week:
        return 'Cette semaine';
      case StatsPeriod.month:
        return 'Ce mois';
      case StatsPeriod.total:
        return 'Depuis le début';
    }
  }

  static String _activityDisplayName(String activityType) {
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

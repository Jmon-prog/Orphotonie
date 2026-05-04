// ============================================================
// Fichier : lib/features/dictionaries/pdf/exercise_pdf_generator.dart
// Description : Générateur de fiches d'exercices imprimables au format PDF.
//               Quatre types : liste de mots, anagramme, mot lacunaire,
//               mots cachés. Génère optionnellement une page de corrigé.
//               Utilise la police Nunito embarquée (assets) — 100 % hors-ligne.
// ============================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/string_utils.dart';
import '../../games/crossword/crossword_generator.dart';
import '../../games/word_search/word_search_generator.dart';

// ---------------------------------------------------------------------------
// Enum des types d'exercices
// ---------------------------------------------------------------------------

/// Types d'exercices disponibles pour l'impression.
enum ExerciseType {
  wordList('Liste de mots', 'Lire et mémoriser les mots et leurs définitions.'),
  anagram(
    'Anagramme',
    'Remets les lettres dans le bon ordre pour retrouver les mots.',
  ),
  gapFill(
    'Mot lacunaire',
    'Complète les lettres manquantes pour retrouver chaque mot.',
  ),
  wordSearch('Mots cachés', 'Retrouve tous les mots cachés dans la grille.'),
  crossword(
    'Mots croisés',
    'Complète la grille en t\'appuyant sur les définitions.',
  );

  const ExerciseType(this.label, this.instructions);

  /// Libellé affiché à l'utilisateur.
  final String label;

  /// Consigne imprimée en tête de fiche.
  final String instructions;
}

// ---------------------------------------------------------------------------
// Générateur principal
// ---------------------------------------------------------------------------

/// Génère et ouvre (via le système d'impression natif) une fiche d'exercice.
class ExercisePdfGenerator {
  ExercisePdfGenerator._();

  /// Génère une fiche d'exercice et ouvre le gestionnaire d'impression.
  ///
  /// [dictionaryName] nom du dictionnaire (affiché dans l'en-tête).
  /// [words] liste de mots du dictionnaire.
  /// [type] type d'exercice à générer.
  /// [includeAnswerKey] ajoute une page de corrigé si `true`.
  static Future<void> generateAndOpen({
    required String dictionaryName,
    required List<Word> words,
    required ExerciseType type,
    required bool includeAnswerKey,
  }) async {
    // Polices PDF standard (Helvetica) : embarquées dans tout lecteur PDF,
    // support Latin-1 (accents français inclus), aucun chargement d'asset
    // requis → pas d'erreur DataView sur Flutter Web.
    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );

    final pdf = pw.Document(
      title: '${type.label} — $dictionaryName',
      author: 'Orphotonie',
      // compress: false améliore la compatibilité sur Flutter Web (dart2js
      // peut avoir des bugs avec l'implémentation zlib dans certains contextes).
      compress: false,
    );

    // Filtrer les mots trop courts pour la grille de mots cachés
    final usableWords = type == ExerciseType.wordSearch
        ? words.where((w) => w.mot.length >= 3).toList()
        : words;

    if (usableWords.isEmpty) return;

    switch (type) {
      case ExerciseType.wordList:
        _addWordListPages(pdf, dictionaryName, usableWords, theme);
      case ExerciseType.anagram:
        _addAnagramPages(
          pdf,
          dictionaryName,
          usableWords,
          theme,
          includeAnswerKey,
        );
      case ExerciseType.gapFill:
        _addGapFillPages(
          pdf,
          dictionaryName,
          usableWords,
          theme,
          includeAnswerKey,
        );
      case ExerciseType.wordSearch:
        _addWordSearchPage(
          pdf,
          dictionaryName,
          usableWords,
          theme,
          includeAnswerKey,
        );
      case ExerciseType.crossword:
        _addCrosswordPage(
          pdf,
          dictionaryName,
          usableWords,
          theme,
          includeAnswerKey,
        );
    }

    final safeName = dictionaryName
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim()
        .replaceAll(' ', '_');
    await Printing.layoutPdf(
      onLayout: (format) async {
        final raw = await pdf.save();
        // Sur Flutter Web, pdf.save() peut retourner un Uint8List dont le
        // buffer sous-jacent a un offsetInBytes > 0. On extrait la vue
        // correcte pour que le package printing crée un DataView valide.
        return raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes);
      },
      name: '${safeName}_${type.label}.pdf',
    );
  }

  // =========================================================================
  // LISTE DE MOTS
  // =========================================================================

  static void _addWordListPages(
    pw.Document pdf,
    String dictionaryName,
    List<Word> words,
    pw.ThemeData theme,
  ) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) =>
            _buildHeader(ctx, dictionaryName, ExerciseType.wordList),
        footer: _buildFooter,
        build: (ctx) {
          return [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: const {
                0: pw.FractionColumnWidth(0.28),
                1: pw.FractionColumnWidth(0.72),
              },
              children: [
                // En-tête du tableau
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('Mot', bold: true),
                    _tableCell('Définition', bold: true),
                  ],
                ),
                // Lignes de données
                ...words.map(
                  (word) => pw.TableRow(
                    children: [
                      _tableCell(word.mot, bold: true),
                      _tableCell(word.definition ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );
  }

  // =========================================================================
  // ANAGRAMME
  // =========================================================================

  static void _addAnagramPages(
    pw.Document pdf,
    String dictionaryName,
    List<Word> words,
    pw.ThemeData theme,
    bool includeAnswerKey,
  ) {
    // Préparer les mots mélangés (graine déterministe pour reproductibilité)
    final items = words.map((w) {
      final letters = w.mot.toUpperCase().split('');
      final rng = Random(w.mot.hashCode ^ 0xDEAD);
      // Mélanger jusqu'à obtenir une permutation différente de l'original
      for (var attempt = 0; attempt < 20; attempt++) {
        letters.shuffle(rng);
        if (letters.join() != w.mot.toUpperCase()) break;
      }
      return (word: w, shuffled: letters.join());
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) =>
            _buildHeader(ctx, dictionaryName, ExerciseType.anagram),
        footer: _buildFooter,
        build: (ctx) => [
          pw.Text(
            ExerciseType.anagram.instructions,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          pw.Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 18),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${index + 1}.',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    // Lettres mélangées
                    pw.Row(
                      children: [
                        pw.Text(
                          'Lettres :  ',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        ..._letterBoxes(item.shuffled.split(''), filled: true),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    // Cases réponse vides
                    pw.Row(
                      children: [
                        pw.Text(
                          'Réponse : ',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        ..._letterBoxes(
                          List.filled(item.word.mot.length, ''),
                          filled: false,
                        ),
                      ],
                    ),
                    // Définition comme indice si disponible
                    if (item.word.definition?.isNotEmpty == true) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Indice : ${item.word.definition}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );

    if (includeAnswerKey) {
      _addAnswerKeyPage(
        pdf,
        dictionaryName,
        'Anagramme — Corrigé',
        words,
        theme,
      );
    }
  }

  // =========================================================================
  // MOT LACUNAIRE
  // =========================================================================

  static void _addGapFillPages(
    pw.Document pdf,
    String dictionaryName,
    List<Word> words,
    pw.ThemeData theme,
    bool includeAnswerKey,
  ) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) =>
            _buildHeader(ctx, dictionaryName, ExerciseType.gapFill),
        footer: _buildFooter,
        build: (ctx) => [
          pw.Text(
            ExerciseType.gapFill.instructions,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          pw.Column(
            children: words.asMap().entries.map((entry) {
              final index = entry.key;
              final word = entry.value;
              final letters = word.mot.toUpperCase().split('');
              // Masque reproductible : garder la 1re lettre, ~45 % masqués
              final rng = Random(word.mot.hashCode ^ 0xBEEF);
              final mask = List.generate(letters.length, (j) {
                if (j == 0) return false; // Première lettre toujours visible
                return rng.nextDouble() < 0.45;
              });

              // Construire le texte lacunaire : C H _ E _
              final gapped = letters
                  .asMap()
                  .entries
                  .map((e) {
                    return mask[e.key] ? ' _' : ' ${e.value}';
                  })
                  .join('')
                  .trim();

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 14),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: '${index + 1}.  ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.TextSpan(
                            text: gapped,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (word.definition?.isNotEmpty == true) ...[
                      pw.SizedBox(height: 3),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 24),
                        child: pw.Text(
                          word.definition!,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );

    if (includeAnswerKey) {
      _addAnswerKeyPage(
        pdf,
        dictionaryName,
        'Mot lacunaire — Corrigé',
        words,
        theme,
      );
    }
  }

  // =========================================================================
  // MOTS CACHÉS
  // =========================================================================

  static void _addWordSearchPage(
    pw.Document pdf,
    String dictionaryName,
    List<Word> words,
    pw.ThemeData theme,
    bool includeAnswerKey,
  ) {
    // Limiter à 12 mots pour que la grille reste lisible sur A4
    final limited = words.take(12).toList();

    // Construire la correspondance forme diacritique → forme ASCII
    final originalByStripped = <String, String>{};
    for (final w in limited) {
      originalByStripped[stripAccents(w.mot).toUpperCase()] = w.mot;
    }

    final generator =
        WordSearchGenerator(difficulty: WordSearchDifficulty.normal);
    final wordGrid = generator.generate(
      originalByStripped.keys.toList(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(ctx, dictionaryName, ExerciseType.wordSearch),
            pw.SizedBox(height: 10),
            pw.Text(
              ExerciseType.wordSearch.instructions,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 14),
            // Grille centrée
            pw.Center(child: _buildGridWidget(wordGrid, answerMode: false)),
            pw.SizedBox(height: 18),
            // Liste des mots à trouver
            pw.Text(
              'Mots à trouver :',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 12,
              runSpacing: 6,
              children: wordGrid.placedWords.map((placed) {
                final original = originalByStripped[placed.word] ?? placed.word;
                return pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    original,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                );
              }).toList(),
            ),
            pw.Spacer(),
            _buildFooter(ctx),
          ],
        ),
      ),
    );

    if (includeAnswerKey) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: const pw.EdgeInsets.all(40),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                ctx,
                dictionaryName,
                ExerciseType.wordSearch,
                subtitle: 'Corrigé',
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Les lettres en surbrillance forment les mots de la liste.',
                style:
                    const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 14),
              pw.Center(child: _buildGridWidget(wordGrid, answerMode: true)),
              pw.Spacer(),
              _buildFooter(ctx),
            ],
          ),
        ),
      );
    }
  }

  // =========================================================================
  // MOTS CROISÉS
  // =========================================================================

  static void _addCrosswordPage(
    pw.Document pdf,
    String dictionaryName,
    List<Word> words,
    pw.ThemeData theme,
    bool includeAnswerKey,
  ) {
    // Préparer les entrées — strip accents pour la grille, définition comme indice
    final entries = words
        .where((w) => w.mot.length >= 2)
        .map(
          (w) => CrosswordEntry(
            word: stripAccents(w.mot),
            clue: w.definition ?? w.mot,
          ),
        )
        .toList();

    if (entries.isEmpty) return;

    final grid = CrosswordGenerator().generate(entries);

    if (grid.placements.isEmpty) return;

    // Calcul de la taille de cellule pour tenir sur A4 paysage si besoin
    final maxDim = max(grid.rows, grid.cols);
    final double cellSize = maxDim <= 15 ? 22.0 : (maxDim <= 20 ? 17.0 : 13.0);

    void addPage({required bool answerMode}) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                ctx,
                dictionaryName,
                ExerciseType.crossword,
                subtitle: answerMode ? 'Corrigé' : null,
              ),
              pw.SizedBox(height: 8),
              if (!answerMode)
                pw.Text(
                  ExerciseType.crossword.instructions,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              pw.SizedBox(height: 10),
              // Grille + indices côte à côte
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Grille
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildCrosswordGrid(
                          grid,
                          cellSize: cellSize,
                          answerMode: answerMode,
                        ),
                      ],
                    ),
                    pw.SizedBox(width: 16),
                    // Indices
                    pw.Expanded(
                      child: _buildCrosswordClues(grid, theme),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),
              _buildFooter(ctx),
            ],
          ),
        ),
      );
    }

    addPage(answerMode: false);
    if (includeAnswerKey) addPage(answerMode: true);
  }

  /// Grille de mots croisés en format tableau PDF.
  static pw.Widget _buildCrosswordGrid(
    CrosswordGrid grid, {
    required double cellSize,
    required bool answerMode,
  }) {
    // Construire un set des cellules actives et des numéros
    final activeCells = <String, String?>{}; // 'r,c' → lettre
    for (final p in grid.placements) {
      for (int i = 0; i < p.word.length; i++) {
        final (r, c) = p.cells[i];
        activeCells['$r,$c'] = p.word[i];
      }
    }
    final numberedCells = <String, int>{}; // 'r,c' → numéro
    for (final p in grid.placements) {
      if (p.number != null) {
        numberedCells['${p.startRow},${p.startCol}'] = p.number!;
      }
    }

    return pw.Table(
      defaultColumnWidth: pw.FixedColumnWidth(cellSize),
      children: List.generate(grid.rows, (r) {
        return pw.TableRow(
          children: List.generate(grid.cols, (c) {
            final key = '$r,$c';
            final letter = activeCells[key];
            final num = numberedCells[key];
            final isActive = letter != null;

            return pw.Container(
              width: cellSize,
              height: cellSize,
              decoration: pw.BoxDecoration(
                color: isActive ? PdfColors.white : PdfColors.grey800,
                border: isActive
                    ? pw.Border.all(color: PdfColors.grey600, width: 0.5)
                    : null,
              ),
              child: isActive
                  ? pw.Stack(
                      children: [
                        if (num != null)
                          pw.Positioned(
                            top: 1,
                            left: 2,
                            child: pw.Text(
                              '$num',
                              style: pw.TextStyle(
                                fontSize: cellSize * 0.28,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ),
                        pw.Center(
                          child: pw.Text(
                            answerMode ? letter : '',
                            style: pw.TextStyle(
                              fontSize: cellSize * 0.52,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : pw.SizedBox(),
            );
          }),
        );
      }),
    );
  }

  /// Colonne d'indices horizontaux / verticaux.
  static pw.Widget _buildCrosswordClues(
    CrosswordGrid grid,
    pw.ThemeData theme,
  ) {
    pw.Widget clueRow(CrosswordPlacement p) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: '${p.number}. ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
              ),
              pw.TextSpan(
                text: p.clue,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (grid.horizontalClues.isNotEmpty) ...[
          pw.Text(
            'HORIZONTAL',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          ...grid.horizontalClues.map(clueRow),
          pw.SizedBox(height: 8),
        ],
        if (grid.verticalClues.isNotEmpty) ...[
          pw.Text(
            'VERTICAL',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          ...grid.verticalClues.map(clueRow),
        ],
      ],
    );
  }

  // =========================================================================
  // PAGE DE CORRIGÉ (liste de mots, anagramme, mot lacunaire)
  // =========================================================================

  static void _addAnswerKeyPage(
    pw.Document pdf,
    String dictionaryName,
    String subtitle,
    List<Word> words,
    pw.ThemeData theme,
  ) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _buildHeader(
          ctx,
          dictionaryName,
          ExerciseType
              .wordList, // Type non utilisé — subtitle surcharge le titre
          subtitle: subtitle,
        ),
        footer: _buildFooter,
        build: (ctx) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const {
              0: pw.FixedColumnWidth(28),
              1: pw.FractionColumnWidth(0.3),
              2: pw.FractionColumnWidth(0.65),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _tableCell('N°', bold: true),
                  _tableCell('Mot', bold: true),
                  _tableCell('Définition', bold: true),
                ],
              ),
              ...words.asMap().entries.map(
                    (entry) => pw.TableRow(
                      children: [
                        _tableCell('${entry.key + 1}'),
                        _tableCell(entry.value.mot, bold: true),
                        _tableCell(entry.value.definition ?? ''),
                      ],
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // WIDGETS UTILITAIRES
  // =========================================================================

  /// Construit la grille de mots cachés en format tableau PDF.
  static pw.Widget _buildGridWidget(
    WordSearchGrid grid, {
    required bool answerMode,
  }) {
    // Calculer les cellules appartenant à des mots placés
    final wordCellSet = <String>{};
    if (answerMode) {
      for (final placed in grid.placedWords) {
        for (final cell in placed.cells) {
          wordCellSet.add('${cell.$1},${cell.$2}');
        }
      }
    }

    const cellSize = 22.0;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      defaultColumnWidth: const pw.FixedColumnWidth(cellSize),
      children: grid.grid.asMap().entries.map((rowEntry) {
        final r = rowEntry.key;
        return pw.TableRow(
          children: rowEntry.value.asMap().entries.map((colEntry) {
            final c = colEntry.key;
            final isHighlighted = answerMode && wordCellSet.contains('$r,$c');
            return pw.Container(
              width: cellSize,
              height: cellSize,
              alignment: pw.Alignment.center,
              decoration: isHighlighted
                  ? const pw.BoxDecoration(color: PdfColors.yellow100)
                  : null,
              child: pw.Text(
                colEntry.value,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: isHighlighted ? PdfColors.blue900 : PdfColors.black,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  /// Cases de lettres pour l'anagramme (remplies ou vides).
  static List<pw.Widget> _letterBoxes(
    List<String> letters, {
    required bool filled,
  }) {
    return letters.map((letter) {
      return pw.Container(
        width: 22,
        height: 22,
        margin: const pw.EdgeInsets.symmetric(horizontal: 1),
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey500),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
          color: filled ? PdfColors.grey100 : PdfColors.white,
        ),
        child: filled
            ? pw.Text(
                letter,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              )
            : null,
      );
    }).toList();
  }

  /// Cellule de tableau avec texte.
  static pw.Widget _tableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // =========================================================================
  // EN-TÊTE & PIED DE PAGE
  // =========================================================================

  static pw.Widget _buildHeader(
    pw.Context ctx,
    String dictionaryName,
    ExerciseType type, {
    String? subtitle,
  }) {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                subtitle ?? type.label,
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Dictionnaire : $dictionaryName',
                style:
                    const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Orphotonie',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Text(
                '$day/$month/${now.year}',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Orphotonie — Fiche d\'exercice imprimable',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DIALOGUE PUBLIC — réutilisable depuis plusieurs écrans
// =============================================================================

/// Dialogue de sélection du type d'exercice à générer en PDF.
/// Utilisé depuis [WordListScreen] et [FichesExercicesScreen].
class PrintExerciseDialog extends StatefulWidget {
  const PrintExerciseDialog({
    super.key,
    required this.dictionaryName,
    required this.words,
  });

  /// Nom du dictionnaire affiché dans l'en-tête du PDF.
  final String dictionaryName;

  /// Mots du dictionnaire.
  final List<Word> words;

  @override
  State<PrintExerciseDialog> createState() => _PrintExerciseDialogState();
}

class _PrintExerciseDialogState extends State<PrintExerciseDialog> {
  ExerciseType _selectedType = ExerciseType.wordList;
  bool _includeAnswerKey = true;
  bool _generating = false;

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      await ExercisePdfGenerator.generateAndOpen(
        dictionaryName: widget.dictionaryName,
        words: widget.words,
        type: _selectedType,
        includeAnswerKey: _includeAnswerKey,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Imprimer les exercices'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.words.length} mot${widget.words.length > 1 ? 's' : ''} — ${widget.dictionaryName}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Type d\'exercice',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            ...ExerciseType.values.map(
              (type) => RadioListTile<ExerciseType>(
                value: type,
                groupValue: _selectedType,
                onChanged: _generating
                    ? null
                    : (v) => setState(() => _selectedType = v!),
                title: Text(type.label),
                subtitle: type == ExerciseType.wordSearch
                    ? Text(
                        'Limité aux 12 premiers mots (min. 3 lettres).',
                        style: theme.textTheme.bodySmall,
                      )
                    : null,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _includeAnswerKey,
              onChanged: _generating
                  ? null
                  : (v) => setState(() => _includeAnswerKey = v),
              title: const Text('Inclure le corrigé'),
              subtitle: const Text('Ajoute une page de réponses à la suite.'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _generating ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _generating ? null : _generate,
          icon: _generating
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.print_outlined),
          label: const Text('Générer'),
        ),
      ],
    );
  }
}

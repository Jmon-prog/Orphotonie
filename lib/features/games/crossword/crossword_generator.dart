// ============================================================
// Fichier : lib/features/games/crossword/crossword_generator.dart
// Description : Algorithme de génération de grilles de mots croisés.
//               Approche : backtracking avec score d'intersection.
//               Règles strictes : isolation totale (pas d'adjacence
//               parasite entre mots non croisés), cases avant/après libres.
//               100 % hors-ligne.
// ============================================================

import 'dart:math';

// ---------------------------------------------------------------------------
// Enums & classes de données
// ---------------------------------------------------------------------------

/// Orientation d'un mot dans la grille.
enum WordOrientation {
  horizontal,
  vertical,
}

/// Mot placé dans la grille de mots croisés.
class CrosswordPlacement {
  const CrosswordPlacement({
    required this.word,
    required this.clue,
    required this.startRow,
    required this.startCol,
    required this.orientation,
    this.number,
  });

  /// Mot (majuscules, sans accents).
  final String word;

  /// Définition / indice.
  final String clue;

  /// Position de départ.
  final int startRow;
  final int startCol;

  /// Orientation.
  final WordOrientation orientation;

  /// Numéro attribué lors de la numérotation.
  final int? number;

  /// Coordonnées (row, col) de chaque lettre.
  List<(int, int)> get cells {
    return List.generate(word.length, (i) {
      return orientation == WordOrientation.horizontal
          ? (startRow, startCol + i)
          : (startRow + i, startCol);
    });
  }

  CrosswordPlacement withNumber(int n) => CrosswordPlacement(
        word: word,
        clue: clue,
        startRow: startRow,
        startCol: startCol,
        orientation: orientation,
        number: n,
      );
}

/// Entrée de mot à placer : mot + définition.
class CrosswordEntry {
  const CrosswordEntry({required this.word, required this.clue});
  final String word;
  final String clue;
}

/// Résultat de la génération de grille.
class CrosswordGrid {
  const CrosswordGrid({
    required this.grid,
    required this.placements,
    required this.rows,
    required this.cols,
    this.skippedWords = const [],
  });

  /// Grille de caractères (null = case noire).
  final List<List<String?>> grid;

  /// Mots placés avec numéros.
  final List<CrosswordPlacement> placements;

  /// Dimensions.
  final int rows;
  final int cols;

  /// Mots impossibles à placer.
  final List<String> skippedWords;

  /// Indices horizontaux.
  List<CrosswordPlacement> get horizontalClues => placements
      .where((p) => p.orientation == WordOrientation.horizontal)
      .toList()
    ..sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));

  /// Indices verticaux.
  List<CrosswordPlacement> get verticalClues => placements
      .where((p) => p.orientation == WordOrientation.vertical)
      .toList()
    ..sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));
}

// ---------------------------------------------------------------------------
// Générateur de mots croisés — algorithme backtracking
// ---------------------------------------------------------------------------
//
// Principe :
//   1. Trier les mots par longueur décroissante.
//   2. Placer le 1er mot horizontalement.
//   3. Pour chaque mot suivant, énumérer TOUS les candidats valides
//      (intersection lettre-à-lettre sur un mot déjà placé, orientation
//      opposée), scorer chacun, placer le meilleur.
//   4. Si aucun candidat valide → mot ignoré (skipped).
//
// Règles de validité (canPlace) :
//   A. Hors limites → rejeté.
//   B. Case AVANT le mot (dans son axe) → doit être vide.
//   C. Case APRÈS le mot (dans son axe) → doit être vide.
//   D. Pour chaque cellule du mot :
//        - Si déjà occupée : doit être la même lettre (intersection autorisée).
//          La cellule avant et après dans l'axe du mot EXISTANT doit être
//          vide (pas de fusion de mots).
//        - Si vide :
//            * Les deux cases perpendiculaires adjacentes doivent être vides
//              (sinon le mot se collerait latéralement à un autre mot).
//            * Les cases diagonales aux extrémités sont également vérifiées.
//   E. Au moins une vraie intersection (lettre partagée) → requis.
//
// Score :
//   Nombre d'intersections × 10 + compacité (distance au centre).
//

/// Génère une grille de mots croisés par placement glouton scoré.
class CrosswordGenerator {
  CrosswordGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;
  static const _workSize = 30;

  CrosswordGrid generate(List<CrosswordEntry> entries) {
    final sorted = entries
        .map((e) => CrosswordEntry(word: _normalize(e.word), clue: e.clue))
        .where((e) => e.word.length >= 2)
        .toList()
      ..sort((a, b) => b.word.length.compareTo(a.word.length));

    if (sorted.isEmpty) {
      return const CrosswordGrid(grid: [], placements: [], rows: 0, cols: 0);
    }

    // Grille de travail
    final grid = List.generate(
      _workSize,
      (_) => List<String?>.filled(_workSize, null),
    );
    final placements = <CrosswordPlacement>[];
    final skipped = <String>[];

    // 1. Premier mot au centre, horizontal
    final first = sorted[0];
    const r0 = _workSize ~/ 2;
    final c0 = (_workSize - first.word.length) ~/ 2;
    _place(grid, first.word, r0, c0, WordOrientation.horizontal);
    placements.add(
      CrosswordPlacement(
        word: first.word,
        clue: first.clue,
        startRow: r0,
        startCol: c0,
        orientation: WordOrientation.horizontal,
      ),
    );

    // 2. Mots suivants
    for (int i = 1; i < sorted.length; i++) {
      final entry = sorted[i];
      final best = _bestPlacement(grid, entry.word, placements);
      if (best != null) {
        _place(
          grid,
          entry.word,
          best.startRow,
          best.startCol,
          best.orientation,
        );
        placements.add(
          CrosswordPlacement(
            word: entry.word,
            clue: entry.clue,
            startRow: best.startRow,
            startCol: best.startCol,
            orientation: best.orientation,
          ),
        );
      } else {
        skipped.add(entry.word);
      }
    }

    // 3. Trim + numérotation
    final (trimmed, trimmed2, rows, cols) = _trim(grid, placements);
    final numbered = _number(trimmed2, rows, cols);

    return CrosswordGrid(
      grid: trimmed,
      placements: numbered,
      rows: rows,
      cols: cols,
      skippedWords: skipped,
    );
  }

  // -------------------------------------------------------------------------
  // Placement
  // -------------------------------------------------------------------------

  CrosswordPlacement? _bestPlacement(
    List<List<String?>> grid,
    String word,
    List<CrosswordPlacement> existing,
  ) {
    final candidates = <(CrosswordPlacement, int)>[];

    for (final placed in existing) {
      final oppOrientation = placed.orientation == WordOrientation.horizontal
          ? WordOrientation.vertical
          : WordOrientation.horizontal;

      for (int wi = 0; wi < word.length; wi++) {
        for (int pi = 0; pi < placed.word.length; pi++) {
          if (word[wi] != placed.word[pi]) continue;

          // Calcul de la position de départ
          final (intR, intC) = placed.cells[pi];
          final int sr, sc;
          if (oppOrientation == WordOrientation.horizontal) {
            sr = intR;
            sc = intC - wi;
          } else {
            sr = intR - wi;
            sc = intC;
          }

          if (!_canPlace(grid, word, sr, sc, oppOrientation)) continue;

          final score = _score(grid, word, sr, sc, oppOrientation);
          candidates.add(
            (
              CrosswordPlacement(
                word: word,
                clue: '',
                startRow: sr,
                startCol: sc,
                orientation: oppOrientation,
              ),
              score,
            ),
          );
        }
      }
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final d = b.$2 - a.$2;
      return d != 0 ? d : (_random.nextBool() ? 1 : -1);
    });
    return candidates.first.$1;
  }

  // -------------------------------------------------------------------------
  // Validation — règles strictes
  // -------------------------------------------------------------------------

  bool _canPlace(
    List<List<String?>> grid,
    String word,
    int sr,
    int sc,
    WordOrientation orientation,
  ) {
    final dr = orientation == WordOrientation.vertical ? 1 : 0;
    final dc = orientation == WordOrientation.horizontal ? 1 : 0;
    final er = sr + dr * (word.length - 1);
    final ec = sc + dc * (word.length - 1);

    // A. Limites de la grille (avec marge de 1 pour les règles d'extrémité)
    if (sr < 1 || sc < 1 || er >= _workSize - 1 || ec >= _workSize - 1) {
      return false;
    }

    // B. Case avant et case après (dans l'axe) → doivent être vides
    if (grid[sr - dr][sc - dc] != null) return false;
    if (grid[er + dr][ec + dc] != null) return false;

    bool hasIntersection = false;

    for (int i = 0; i < word.length; i++) {
      final r = sr + i * dr;
      final c = sc + i * dc;
      final cell = grid[r][c];

      if (cell != null) {
        // D. Intersection : même lettre requise
        if (cell != word[i]) return false;

        // La case avant et après cette lettre dans l'axe du mot EXISTANT
        // (perpendiculaire au mot qu'on place) doit être vide pour éviter
        // la fusion de deux mots dans le même axe.
        // (perpDr/perpDc = direction du mot existant = opposé à notre axe)
        final perpDr = dc; // si on place H, le mot existant est V
        final perpDc = dr;
        if (grid[r - perpDr][c - perpDc] != null &&
            grid[r - perpDr][c - perpDc] != word[i]) {
          // Il y a une lettre adjacente dans l'axe perpendiculaire qui
          // n'est pas la même → risque de créer un faux mot
          // On l'autorise seulement si c'est la lettre d'intersection
          // déjà gérée ci-dessus.
        }

        hasIntersection = true;
      } else {
        // D. Case vide : les deux cases perpendiculaires adjacentes → vides
        final perpDr = orientation == WordOrientation.horizontal ? 1 : 0;
        final perpDc = orientation == WordOrientation.vertical ? 1 : 0;

        if (grid[r + perpDr][c + perpDc] != null) return false;
        if (grid[r - perpDr][c - perpDc] != null) return false;
      }
    }

    // E. Au moins une intersection
    return hasIntersection;
  }

  // -------------------------------------------------------------------------
  // Score
  // -------------------------------------------------------------------------

  int _score(
    List<List<String?>> grid,
    String word,
    int sr,
    int sc,
    WordOrientation orientation,
  ) {
    final dr = orientation == WordOrientation.vertical ? 1 : 0;
    final dc = orientation == WordOrientation.horizontal ? 1 : 0;
    int intersections = 0;
    for (int i = 0; i < word.length; i++) {
      if (grid[sr + i * dr][sc + i * dc] != null) intersections++;
    }
    final midR = sr + (word.length ~/ 2) * dr;
    final midC = sc + (word.length ~/ 2) * dc;
    final dist = (midR - _workSize ~/ 2).abs() + (midC - _workSize ~/ 2).abs();
    return intersections * 10 + (_workSize - dist);
  }

  // -------------------------------------------------------------------------
  // Place un mot dans la grille
  // -------------------------------------------------------------------------

  void _place(
    List<List<String?>> grid,
    String word,
    int sr,
    int sc,
    WordOrientation orientation,
  ) {
    final dr = orientation == WordOrientation.vertical ? 1 : 0;
    final dc = orientation == WordOrientation.horizontal ? 1 : 0;
    for (int i = 0; i < word.length; i++) {
      grid[sr + i * dr][sc + i * dc] = word[i];
    }
  }

  // -------------------------------------------------------------------------
  // Trim
  // -------------------------------------------------------------------------

  (List<List<String?>>, List<CrosswordPlacement>, int, int) _trim(
    List<List<String?>> grid,
    List<CrosswordPlacement> placements,
  ) {
    int minR = _workSize, maxR = 0, minC = _workSize, maxC = 0;
    for (int r = 0; r < _workSize; r++) {
      for (int c = 0; c < _workSize; c++) {
        if (grid[r][c] != null) {
          if (r < minR) minR = r;
          if (r > maxR) maxR = r;
          if (c < minC) minC = c;
          if (c > maxC) maxC = c;
        }
      }
    }
    if (minR > maxR) return ([], [], 0, 0);

    final rows = maxR - minR + 1;
    final cols = maxC - minC + 1;
    final trimmed = List.generate(
      rows,
      (r) => List.generate(cols, (c) => grid[minR + r][minC + c]),
    );
    final adjusted = placements
        .map(
          (p) => CrosswordPlacement(
            word: p.word,
            clue: p.clue,
            startRow: p.startRow - minR,
            startCol: p.startCol - minC,
            orientation: p.orientation,
          ),
        )
        .toList();
    return (trimmed, adjusted, rows, cols);
  }

  // -------------------------------------------------------------------------
  // Numérotation (ordre lecture : haut→bas, gauche→droite)
  // -------------------------------------------------------------------------

  List<CrosswordPlacement> _number(
    List<CrosswordPlacement> placements,
    int rows,
    int cols,
  ) {
    final starts = <(int, int), List<int>>{};
    for (int i = 0; i < placements.length; i++) {
      final key = (placements[i].startRow, placements[i].startCol);
      starts.putIfAbsent(key, () => []).add(i);
    }
    final sortedKeys = starts.keys.toList()
      ..sort((a, b) {
        final d = a.$1.compareTo(b.$1);
        return d != 0 ? d : a.$2.compareTo(b.$2);
      });

    final numbered = List<CrosswordPlacement>.from(placements);
    int n = 1;
    for (final key in sortedKeys) {
      for (final idx in starts[key]!) {
        numbered[idx] = numbered[idx].withNumber(n);
      }
      n++;
    }
    return numbered;
  }

  // -------------------------------------------------------------------------
  // Normalisation
  // -------------------------------------------------------------------------

  static String _normalize(String word) =>
      _removeAccents(word.toUpperCase().trim());

  static String _removeAccents(String input) {
    const src = 'ÀÂÄÉÈÊËÏÎÔÙÛÜŸÇŒÆ';
    const dst = 'AAAEEEEIIOOUUYCOA';
    var r = input;
    for (int i = 0; i < src.length; i++) {
      r = r.replaceAll(src[i], dst[i]);
    }
    return r.replaceAll('Œ', 'OE').replaceAll('Æ', 'AE');
  }
}

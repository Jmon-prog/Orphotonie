// ============================================================
// Fichier : lib/features/games/word_search/word_search_generator.dart
// Description : Algorithme de génération de grille de mots cachés.
//               Placement local, gestion intersections, remplissage
//               pondéré par fréquence des lettres françaises.
//               100 % hors-ligne.
// ============================================================

import 'dart:math';

// ---------------------------------------------------------------------------
// Enums & classes de données
// ---------------------------------------------------------------------------

/// Difficulté du jeu de mots cachés.
enum WordSearchDifficulty {
  /// 8×8, horizontal + vertical.
  easy,

  /// 10×10, + diagonale ↘.
  normal,

  /// 12×12, toutes directions.
  hard,
}

/// Direction de placement d'un mot.
enum Direction {
  /// Gauche → droite.
  right(0, 1),

  /// Haut → bas.
  down(1, 0),

  /// Diagonale ↘.
  downRight(1, 1),

  /// Droite → gauche.
  left(0, -1),

  /// Bas → haut.
  up(-1, 0),

  /// Diagonale ↙.
  downLeft(1, -1),

  /// Diagonale ↗.
  upRight(-1, 1),

  /// Diagonale ↖.
  upLeft(-1, -1);

  const Direction(this.dr, this.dc);

  /// Décalage en ligne.
  final int dr;

  /// Décalage en colonne.
  final int dc;
}

/// Position d'un mot placé dans la grille.
class PlacedWord {
  const PlacedWord({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
  });

  final String word;
  final int startRow;
  final int startCol;
  final Direction direction;

  /// Retourne les coordonnées (row, col) de chaque lettre du mot.
  List<(int, int)> get cells {
    return List.generate(word.length, (i) {
      return (startRow + i * direction.dr, startCol + i * direction.dc);
    });
  }
}

/// Résultat de la génération de grille.
class WordSearchGrid {
  const WordSearchGrid({
    required this.grid,
    required this.placedWords,
    required this.size,
    this.skippedWords = const [],
  });

  /// Grille de lettres [row][col].
  final List<List<String>> grid;

  /// Mots placés avec leurs positions.
  final List<PlacedWord> placedWords;

  /// Taille de la grille (NxN).
  final int size;

  /// Mots impossibles à placer.
  final List<String> skippedWords;
}

// ---------------------------------------------------------------------------
// Générateur de grille
// ---------------------------------------------------------------------------

/// Génère une grille de mots cachés.
class WordSearchGenerator {
  WordSearchGenerator({
    this.difficulty = WordSearchDifficulty.normal,
    Random? random,
  }) : _random = random ?? Random();

  final WordSearchDifficulty difficulty;
  final Random _random;

  /// Nombre max de tentatives pour placer un mot.
  static const _maxPlacementAttempts = 100;

  /// Taille de grille par difficulté.
  int get gridSize {
    switch (difficulty) {
      case WordSearchDifficulty.easy:
        return 8;
      case WordSearchDifficulty.normal:
        return 10;
      case WordSearchDifficulty.hard:
        return 12;
    }
  }

  /// Directions autorisées par difficulté.
  List<Direction> get _allowedDirections {
    switch (difficulty) {
      case WordSearchDifficulty.easy:
        return [Direction.right, Direction.down];
      case WordSearchDifficulty.normal:
        return [Direction.right, Direction.down, Direction.downRight];
      case WordSearchDifficulty.hard:
        return Direction.values.toList();
    }
  }

  /// Fréquences des lettres en français (pour remplissage réaliste).
  static const _frenchLetterFrequencies = <String, double>{
    'E': 14.7, 'A': 7.6, 'S': 7.9, 'I': 7.5, 'N': 7.1, 'T': 7.2,
    'R': 6.6, 'U': 6.3, 'L': 5.5, 'O': 5.4, 'D': 3.7, 'C': 3.3,
    'P': 3.0, 'M': 3.0, 'V': 1.6, 'G': 1.1, 'F': 1.1, 'B': 0.9,
    'Q': 1.4, 'H': 0.7, 'X': 0.4, 'J': 0.5, 'Y': 0.3, 'Z': 0.1,
    'K': 0.05, 'W': 0.05,
  };

  /// Table de sélection pondérée pré-calculée.
  late final List<String> _weightedLetters = _buildWeightedLetters();

  List<String> _buildWeightedLetters() {
    final letters = <String>[];
    for (final entry in _frenchLetterFrequencies.entries) {
      final count = (entry.value * 10).round();
      for (int i = 0; i < count; i++) {
        letters.add(entry.key);
      }
    }
    return letters;
  }

  /// Génère une lettre aléatoire pondérée par fréquence française.
  String _randomLetter() {
    return _weightedLetters[_random.nextInt(_weightedLetters.length)];
  }

  /// Génère la grille complète.
  ///
  /// [words] : mots à placer (sans accents, en majuscules de préférence).
  WordSearchGrid generate(List<String> words) {
    final size = gridSize;

    // Grille vide (null = case libre)
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));

    // Normaliser et séparer mots valides / trop longs
    final normalized = words.map((w) => _normalize(w)).toList();
    final skippedWords = <String>[];
    final valid = <String>[];
    for (final w in normalized) {
      if (w.isEmpty) continue;
      if (w.length > size) {
        skippedWords.add(w);
      } else {
        valid.add(w);
      }
    }
    // Trier par longueur décroissante (les longs d'abord)
    valid.sort((a, b) => b.length.compareTo(a.length));

    final placedWords = <PlacedWord>[];

    for (final word in valid) {
      final placed = _tryPlaceWord(grid, word, size);
      if (placed != null) {
        placedWords.add(placed);
      } else {
        skippedWords.add(word);
      }
    }

    // Remplir les cases vides
    final filledGrid = grid.map((row) {
      return row.map((cell) => cell ?? _randomLetter()).toList();
    }).toList();

    return WordSearchGrid(
      grid: filledGrid,
      placedWords: placedWords,
      size: size,
      skippedWords: skippedWords,
    );
  }

  /// Tente de placer un mot dans la grille.
  PlacedWord? _tryPlaceWord(
    List<List<String?>> grid,
    String word,
    int size,
  ) {
    final directions = List<Direction>.from(_allowedDirections)
      ..shuffle(_random);

    // Tenter des positions aléatoires
    for (int attempt = 0; attempt < _maxPlacementAttempts; attempt++) {
      final dir = directions[attempt % directions.length];
      final startRow = _random.nextInt(size);
      final startCol = _random.nextInt(size);

      if (_canPlace(grid, word, startRow, startCol, dir, size)) {
        _placeWord(grid, word, startRow, startCol, dir);
        return PlacedWord(
          word: word,
          startRow: startRow,
          startCol: startCol,
          direction: dir,
        );
      }
    }

    return null;
  }

  /// Vérifie si le mot peut être placé à cette position.
  bool _canPlace(
    List<List<String?>> grid,
    String word,
    int startRow,
    int startCol,
    Direction dir,
    int size,
  ) {
    for (int i = 0; i < word.length; i++) {
      final r = startRow + i * dir.dr;
      final c = startCol + i * dir.dc;

      // Hors limites
      if (r < 0 || r >= size || c < 0 || c >= size) return false;

      final existing = grid[r][c];
      // Case occupée par une autre lettre
      if (existing != null && existing != word[i]) return false;
    }
    return true;
  }

  /// Place le mot dans la grille.
  void _placeWord(
    List<List<String?>> grid,
    String word,
    int startRow,
    int startCol,
    Direction dir,
  ) {
    for (int i = 0; i < word.length; i++) {
      final r = startRow + i * dir.dr;
      final c = startCol + i * dir.dc;
      grid[r][c] = word[i];
    }
  }

  /// Normalise un mot : majuscules, pas d'accents.
  String _normalize(String word) {
    return _removeAccents(word.toUpperCase().trim());
  }

  /// Retire les accents d'une chaîne.
  static String _removeAccents(String input) {
    const withAccents = 'ÀÂÄÉÈÊËÏÎÔÙÛÜŸÇŒÆ';
    const withoutAccents = 'AAAEEEEIIOOUUYCOA';
    var result = input;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    // Ligatures : Œ → OE, Æ → AE (déjà partiellement traité)
    result = result.replaceAll('Œ', 'OE').replaceAll('Æ', 'AE');
    return result;
  }

  /// Vérifie si un mot a été trouvé par sélection.
  ///
  /// [selectedCells] : coordonnées (row, col) sélectionnées.
  /// [placedWords] : mots placés.
  /// Retourne le mot trouvé ou null.
  static PlacedWord? checkSelection(
    List<(int, int)> selectedCells,
    List<PlacedWord> placedWords,
  ) {
    for (final placed in placedWords) {
      final wordCells = placed.cells;
      if (_cellsMatch(selectedCells, wordCells)) {
        return placed;
      }
      // Accepter aussi la sélection dans le sens inverse
      if (_cellsMatch(selectedCells, wordCells.reversed.toList())) {
        return placed;
      }
    }
    return null;
  }

  /// Compare deux listes de cellules.
  static bool _cellsMatch(
    List<(int, int)> a,
    List<(int, int)> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].$1 != b[i].$1 || a[i].$2 != b[i].$2) return false;
    }
    return true;
  }

  /// Vérifie qu'une sélection est en ligne droite (alignement valide).
  static bool isValidSelection(List<(int, int)> cells) {
    if (cells.length < 2) return false;
    final dr = cells[1].$1 - cells[0].$1;
    final dc = cells[1].$2 - cells[0].$2;

    // Doit être une direction unitaire ou nulle
    if (dr.abs() > 1 || dc.abs() > 1) return false;
    if (dr == 0 && dc == 0) return false;

    for (int i = 2; i < cells.length; i++) {
      final expectedR = cells[0].$1 + i * dr;
      final expectedC = cells[0].$2 + i * dc;
      if (cells[i].$1 != expectedR || cells[i].$2 != expectedC) return false;
    }
    return true;
  }

  /// Calcule les cellules entre deux positions (début/fin) en ligne droite.
  static List<(int, int)> cellsBetween(
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    final dr = (endRow - startRow).sign;
    final dc = (endCol - startCol).sign;
    final steps = [
      (endRow - startRow).abs(),
      (endCol - startCol).abs(),
    ].reduce((a, b) => a > b ? a : b);

    if (steps == 0) return [(startRow, startCol)];

    // Vérifier alignement
    final rowDiff = (endRow - startRow).abs();
    final colDiff = (endCol - startCol).abs();
    if (rowDiff != 0 && colDiff != 0 && rowDiff != colDiff) {
      return []; // Pas aligné
    }

    return List.generate(steps + 1, (i) {
      return (startRow + i * dr, startCol + i * dc);
    });
  }
}

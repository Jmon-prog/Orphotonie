// ============================================================
// Fichier : lib/features/games/hangman/hangman_logic.dart
// Description : Logique métier du jeu Pendu.
//               Gestion des lettres proposées, victoire/défaite,
//               scoring et aides progressives.
//               Accents gérés : le clavier A-Z permet de révéler
//               les lettres accentuées (E → É, È, Ê, Ë).
//               100 % hors-ligne, aucune dépendance réseau.
// ============================================================

import '../../../core/utils/string_utils.dart';

/// Résultat d'une proposition de lettre.
enum LetterResult {
  /// Lettre présente dans le mot.
  correct,

  /// Lettre absente du mot.
  incorrect,

  /// Lettre déjà essayée.
  alreadyUsed,
}

/// Niveau de difficulté du jeu.
enum HangmanDifficulty {
  /// 8 erreurs max + indice catégorie affiché.
  easy(maxErrors: 8),

  /// 6 erreurs max.
  normal(maxErrors: 6),

  /// 5 erreurs max + pas d'indice.
  hard(maxErrors: 5);

  const HangmanDifficulty({required this.maxErrors});

  /// Nombre d'erreurs maximum avant la défaite.
  final int maxErrors;
}

/// Score calculé à la fin d'un mot.
class HangmanScore {
  const HangmanScore({
    required this.points,
    required this.hintsUsed,
    required this.won,
    required this.errorsCount,
    required this.durationMs,
  });

  /// Points obtenus.
  final int points;

  /// Nombre d'indices utilisés.
  final int hintsUsed;

  /// Le joueur a-t-il trouvé le mot ?
  final bool won;

  /// Nombre d'erreurs commises.
  final int errorsCount;

  /// Durée totale en millisecondes.
  final int durationMs;
}

/// Logique métier du jeu Pendu.
///
/// Gère l'état du mot à deviner, les lettres essayées,
/// la progression des erreurs et les aides.
class HangmanLogic {
  HangmanLogic(
    this.word, {
    this.difficulty = HangmanDifficulty.normal,
  })  : _displayLetters = word.toUpperCase().split(''),
        _baseLetters = stripAccents(word.toUpperCase()).split('');

  /// Mot original.
  final String word;

  /// Difficulté choisie.
  final HangmanDifficulty difficulty;

  /// Lettres du mot en majuscules (avec accents — pour l'affichage).
  final List<String> _displayLetters;

  /// Lettres de base sans diacritiques (pour la comparaison clavier A-Z).
  final List<String> _baseLetters;

  /// Lettres de base correctement devinées (sans accents).
  final Set<String> _correctLetters = {};
  Set<String> get correctLetters => Set.unmodifiable(_correctLetters);

  /// Lettres de base incorrectes essayées.
  final Set<String> _incorrectLetters = {};
  Set<String> get incorrectLetters => Set.unmodifiable(_incorrectLetters);

  /// Toutes les lettres essayées (base).
  Set<String> get usedLetters => {..._correctLetters, ..._incorrectLetters};

  /// Nombre d'erreurs courantes.
  int get errorsCount => _incorrectLetters.length;

  /// Nombre maximum d'erreurs avant défaite.
  int get maxErrors => difficulty.maxErrors;

  /// Progression de la mascotte (0.0 → 1.0).
  double get mascotProgress =>
      maxErrors > 0 ? (errorsCount / maxErrors).clamp(0.0, 1.0) : 0.0;

  /// État de la mascotte (0 = intact, 8 = perdu).
  int get mascotState => (mascotProgress * 8).round().clamp(0, 8);

  /// Le mot est complètement révélé (victoire).
  bool get isWon {
    final uniqueBases = _baseLetters.toSet();
    return uniqueBases.every((b) => _correctLetters.contains(b));
  }

  /// Nombre max d'erreurs atteint (défaite).
  bool get isLost => errorsCount >= maxErrors;

  /// La partie est terminée.
  bool get isGameOver => isWon || isLost;

  /// Nombre d'indices utilisés.
  int _hintsUsed = 0;
  int get hintsUsed => _hintsUsed;

  /// Représentation actuelle du mot avec les lettres révélées.
  /// La lettre accentuée (ex : È) est affichée dès que sa base (E) est devinée.
  List<String?> get revealedWord {
    return List.generate(_displayLetters.length, (i) {
      return _correctLetters.contains(_baseLetters[i])
          ? _displayLetters[i]
          : null;
    });
  }

  /// Propose une lettre (A-Z, sans accent).
  ///
  /// La comparaison se fait sur la lettre de base : proposer 'E' révèle
  /// toutes les positions È, É, Ê, Ë du mot.
  LetterResult guessLetter(String letter) {
    final base = stripAccents(letter.toUpperCase());
    if (base.length != 1) return LetterResult.incorrect;
    if (isGameOver) return LetterResult.alreadyUsed;

    if (usedLetters.contains(base)) {
      return LetterResult.alreadyUsed;
    }

    if (_baseLetters.contains(base)) {
      _correctLetters.add(base);
      return LetterResult.correct;
    } else {
      _incorrectLetters.add(base);
      return LetterResult.incorrect;
    }
  }

  /// Aide 1 : révèle la première lettre non encore trouvée (-20 pts).
  /// Retourne la lettre de base révélée ou null si tout est déjà révélé.
  String? revealFirstLetter() {
    for (final base in _baseLetters) {
      if (!_correctLetters.contains(base)) {
        _correctLetters.add(base);
        _hintsUsed++;
        return base;
      }
    }
    return null;
  }

  /// Aide 2 : révèle une lettre aléatoire non encore trouvée (-15 pts).
  /// Retourne la lettre de base révélée ou null si tout est déjà révélé.
  String? revealRandomLetter() {
    final unrevealed = _baseLetters
        .toSet()
        .where((b) => !_correctLetters.contains(b))
        .toList();
    if (unrevealed.isEmpty) return null;

    unrevealed.shuffle();
    final base = unrevealed.first;
    _correctLetters.add(base);
    _hintsUsed++;
    return base;
  }

  /// Calcule le score à la fin du mot.
  ///
  /// Barème :
  /// - Victoire sans erreur ni aide : 100 pts
  /// - Victoire ≤ 2 erreurs : 80 pts
  /// - Victoire ≤ 4 erreurs : 60 pts
  /// - Victoire > 4 erreurs : 40 pts
  /// - Défaite : 10 pts (participation)
  /// - Chaque aide utilisée : -10 pts (min 0)
  HangmanScore computeScore({required int durationMs}) {
    int points;

    if (!isWon) {
      points = 10;
    } else if (errorsCount == 0 && _hintsUsed == 0) {
      points = 100;
    } else if (errorsCount <= 2) {
      points = 80;
    } else if (errorsCount <= 4) {
      points = 60;
    } else {
      points = 40;
    }

    // Pénalité aides
    points = (points - _hintsUsed * 10).clamp(0, 100);

    return HangmanScore(
      points: points,
      hintsUsed: _hintsUsed,
      won: isWon,
      errorsCount: errorsCount,
      durationMs: durationMs,
    );
  }
}

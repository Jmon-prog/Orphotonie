// ============================================================
// Fichier : lib/features/games/anagram/anagram_logic.dart
// Description : Algorithme du jeu Anagramme.
//               Mélange Fisher-Yates, vérification de réponse,
//               scoring, aide (révélation d'une lettre).
//               100 % hors-ligne, aucune dépendance réseau.
// ============================================================

import 'dart:math';

/// Résultat d'une tentative de résolution d'anagramme.
enum AnagramResult { correct, incorrect }

/// Score calculé à la fin d'une résolution.
class AnagramScore {
  const AnagramScore({
    required this.points,
    required this.hintsUsed,
    required this.firstTry,
    required this.durationMs,
  });

  /// Points obtenus (100 / 60 / 30 / 10).
  final int points;

  /// Nombre d'indices utilisés.
  final int hintsUsed;

  /// Résolu du premier coup sans aide.
  final bool firstTry;

  /// Durée totale en millisecondes.
  final int durationMs;
}

/// Logique métier du jeu Anagramme.
///
/// Mélange les lettres d'un mot avec Fisher-Yates, propose une aide
/// progressive (révéler une lettre), et calcule le score.
class AnagramLogic {
  AnagramLogic(this.word, {Random? random})
      : _random = random ?? Random(),
        _letters = word.toUpperCase().split('');

  /// Mot original (en majuscules).
  final String word;

  /// Lettres du mot dans l'ordre correct.
  final List<String> _letters;

  final Random _random;

  /// Nombre d'indices utilisés.
  int _hintsUsed = 0;
  int get hintsUsed => _hintsUsed;

  /// Nombre de tentatives incorrectes.
  int _attempts = 0;
  int get attempts => _attempts;

  /// Positions déjà révélées par l'aide.
  final Set<int> _revealedPositions = {};
  Set<int> get revealedPositions => Set.unmodifiable(_revealedPositions);

  /// Mélange les lettres avec Fisher-Yates.
  /// Garantit que le résultat ≠ le mot original.
  /// Pour les mots d'1 lettre ou toutes lettres identiques, retourne tel quel.
  List<String> shuffle() {
    final shuffled = List<String>.from(_letters);
    // Cas dégénéré : impossible de mélanger différemment
    if (_letters.length <= 1 || _letters.toSet().length == 1) {
      return shuffled;
    }

    // Fisher-Yates shuffle avec garantie ≠ original
    int maxAttempts = 20;
    do {
      for (int i = shuffled.length - 1; i > 0; i--) {
        final j = _random.nextInt(i + 1);
        final tmp = shuffled[i];
        shuffled[i] = shuffled[j];
        shuffled[j] = tmp;
      }
      maxAttempts--;
    } while (_listEquals(shuffled, _letters) && maxAttempts > 0);

    return shuffled;
  }

  /// Vérifie si la proposition est correcte (insensible à la casse).
  AnagramResult check(List<String> proposal) {
    final normalized = proposal.map((l) => l.toUpperCase()).toList();
    if (_listEquals(normalized, _letters)) {
      return AnagramResult.correct;
    }
    _attempts++;
    return AnagramResult.incorrect;
  }

  /// Révèle la prochaine lettre non encore révélée et pas déjà
  /// correctement placée par l'utilisateur.
  /// [currentSlots] : état actuel des emplacements réponse.
  /// Retourne l'index et la lettre révélée, ou null si toutes les
  /// positions sont déjà correctes ou déjà révélées.
  ({int index, String letter})? revealHint([List<String?>? currentSlots]) {
    final slots = currentSlots ?? List<String?>.filled(_letters.length, null);
    for (int i = 0; i < _letters.length; i++) {
      if (!_revealedPositions.contains(i) && slots[i] != _letters[i]) {
        _revealedPositions.add(i);
        _hintsUsed++;
        return (index: i, letter: _letters[i]);
      }
    }
    return null;
  }

  /// Calcule le score final.
  AnagramScore computeScore({required int durationMs}) {
    final int points;
    if (_hintsUsed == 0 && _attempts == 0) {
      points = 100;
    } else if (_hintsUsed <= 1) {
      points = 60;
    } else if (_hintsUsed <= 2) {
      points = 30;
    } else {
      points = 10;
    }

    return AnagramScore(
      points: points,
      hintsUsed: _hintsUsed,
      firstTry: _hintsUsed == 0 && _attempts == 0,
      durationMs: durationMs,
    );
  }

  /// Comparaison de listes sans dépendance externe.
  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ============================================================
// Fichier : lib/features/games/fill_blank/fill_blank_logic.dart
// Description : Logique métier du jeu Mot Lacunaire.
//               Génération de lacunes, 3 modes (frappe, choix, pool),
//               distracteurs phonétiques, scoring.
//               100 % hors-ligne, aucune dépendance réseau.
// ============================================================

import 'dart:math';
import '../../../core/utils/string_utils.dart';

/// Mode de jeu du mot lacunaire.
enum FillBlankMode {
  /// Frappe libre dans les cases vides (difficile).
  freeInput,

  /// Choix multiple parmi 4 propositions (moyen).
  multipleChoice,

  /// Lettres à replacer par drag-and-drop (facile).
  letterPool,
}

/// Résultat d'une vérification.
enum FillBlankResult { correct, incorrect }

/// Score calculé à la fin d'un mot.
class FillBlankScore {
  const FillBlankScore({
    required this.points,
    required this.hintsUsed,
    required this.firstTry,
    required this.durationMs,
  });

  final int points;
  final int hintsUsed;
  final bool firstTry;
  final int durationMs;
}

/// Représente une lacune dans le mot.
class Blank {
  const Blank({
    required this.index,
    required this.letter,
  });

  /// Position dans le mot (0-based).
  final int index;

  /// Lettre correcte attendue (majuscule).
  final String letter;
}

/// Logique du jeu Mot Lacunaire.
///
/// Génère les lacunes d'un mot, valide la réponse,
/// et fournit les distracteurs ou le pool de lettres selon le mode.
class FillBlankLogic {
  FillBlankLogic(
    this.word, {
    this.mode = FillBlankMode.freeInput,
    Random? random,
  })  : _random = random ?? Random(),
        _normalizedWord = word.toUpperCase().split('') {
    _generateBlanks();
  }

  /// Mot original.
  final String word;

  /// Mode de jeu.
  final FillBlankMode mode;

  final Random _random;

  /// Lettres du mot en majuscules.
  final List<String> _normalizedWord;

  /// Lacunes générées.
  late final List<Blank> _blanks;
  List<Blank> get blanks => List.unmodifiable(_blanks);

  /// Nombre de tentatives incorrectes.
  int _attempts = 0;
  int get attempts => _attempts;

  /// Nombre d'indices utilisés.
  int _hintsUsed = 0;
  int get hintsUsed => _hintsUsed;

  /// Positions déjà révélées par aide.
  final Set<int> _revealedPositions = {};
  Set<int> get revealedPositions => Set.unmodifiable(_revealedPositions);

  /// Représentation du mot avec les lacunes (null = lacune).
  List<String?> get wordWithBlanks {
    final result = List<String?>.from(_normalizedWord);
    for (final blank in _blanks) {
      if (!_revealedPositions.contains(blank.index)) {
        result[blank.index] = null;
      }
    }
    return result;
  }

  /// Nombre de lacunes à remplir (hors révélées).
  int get remainingBlanks =>
      _blanks.where((b) => !_revealedPositions.contains(b.index)).length;

  // -----------------------------------------------------------------------
  // Lettres difficiles à privilégier pour les lacunes
  // -----------------------------------------------------------------------
  static const _hardLetters = {
    'É', 'È', 'Ê', 'Ë', 'À', 'Â', 'Ô', 'Û', 'Ù', 'Ü',
    'Î', 'Ï', 'Ç', 'Œ', 'Æ',
    // Lettres souvent problématiques
    'H', 'Y', 'X', 'K', 'W', 'Q',
  };

  static const _vowels = {
    'A',
    'E',
    'I',
    'O',
    'U',
    'Y',
    'É',
    'È',
    'Ê',
    'Ë',
    'À',
    'Â',
    'Ô',
    'Û',
    'Ù',
    'Ü',
    'Î',
    'Ï',
  };

  // -----------------------------------------------------------------------
  // Génération des lacunes
  // -----------------------------------------------------------------------

  /// Génère les lacunes selon la longueur du mot.
  ///
  /// Règles :
  /// - ≥ 1 lacune, ≤ 50 % du mot
  /// - Préfère les lettres difficiles / voyelles
  /// - Évite la 1ère lettre
  void _generateBlanks() {
    final length = _normalizedWord.length;

    // Nombre de lacunes : 1 pour 3-4, 2 pour 5-7, 3 pour 8+
    int count;
    if (length <= 2) {
      count = 1;
    } else if (length <= 4) {
      count = 1;
    } else if (length <= 7) {
      count = 2;
    } else {
      count = 3;
    }

    // Ne pas dépasser 50 % du mot
    count = count.clamp(1, (length / 2).floor().clamp(1, length));

    // Indices candidats (exclure la 1ère lettre)
    final candidates = List.generate(length - 1, (i) => i + 1);

    // Trier : lettres difficiles d'abord, puis voyelles, puis le reste
    candidates.sort((a, b) {
      final la = _normalizedWord[a];
      final lb = _normalizedWord[b];
      final scoreA = _letterPriority(la);
      final scoreB = _letterPriority(lb);
      if (scoreA != scoreB) return scoreB.compareTo(scoreA);
      return _random.nextInt(3) - 1; // départage aléatoire
    });

    // Sélectionner [count] indices
    final selected = candidates.take(count).toList()..sort();

    _blanks = selected
        .map((i) => Blank(index: i, letter: _normalizedWord[i]))
        .toList();
  }

  /// Priorité d'une lettre pour la lacune (plus élevé = plus souvent masqué).
  int _letterPriority(String letter) {
    if (_hardLetters.contains(letter)) return 3;
    if (_vowels.contains(letter)) return 2;
    return 1;
  }

  // -----------------------------------------------------------------------
  // Vérification
  // -----------------------------------------------------------------------

  /// Vérifie que les lettres proposées correspondent aux lacunes.
  ///
  /// La comparaison est insensible aux diacritiques (mode frappe libre et pool) :
  /// taper 'e' est accepté pour la lacune 'È'.
  ///
  /// [answers] : map index → lettre proposée.
  FillBlankResult check(Map<int, String> answers) {
    for (final blank in _blanks) {
      if (_revealedPositions.contains(blank.index)) continue;
      final proposed = answers[blank.index]?.toUpperCase();
      if (proposed == null ||
          stripAccents(proposed) != stripAccents(blank.letter)) {
        _attempts++;
        return FillBlankResult.incorrect;
      }
    }
    return FillBlankResult.correct;
  }

  /// Vérifie la réponse du mode choix multiple.
  ///
  /// [answer] : chaîne choisie parmi les propositions.
  FillBlankResult checkChoice(String answer) {
    // La réponse correcte est la concaténation des lettres manquantes
    final correct = _blanks
        .where((b) => !_revealedPositions.contains(b.index))
        .map((b) => b.letter)
        .join();
    if (answer.toUpperCase() == correct) {
      return FillBlankResult.correct;
    }
    _attempts++;
    return FillBlankResult.incorrect;
  }

  // -----------------------------------------------------------------------
  // Mode Choix Multiple — distracteurs
  // -----------------------------------------------------------------------

  /// Génère les propositions pour le mode choix multiple.
  ///
  /// Retourne 4 chaînes : la bonne réponse + 3 distracteurs.
  /// Les distracteurs sont construits par substitution phonétique.
  List<String> generateChoices() {
    final correct = _blanks
        .where((b) => !_revealedPositions.contains(b.index))
        .map((b) => b.letter)
        .join();

    final distractors = _generateDistractors(correct);

    final choices = [correct, ...distractors];
    choices.shuffle(_random);
    return choices;
  }

  /// Crée 3 distracteurs phonétiquement proches.
  List<String> _generateDistractors(String correct) {
    // Substitutions phonétiques courantes en français
    const substitutions = {
      'A': ['E', 'O', 'AN'],
      'E': ['A', 'I', 'EU'],
      'I': ['Y', 'E', 'U'],
      'O': ['AU', 'OU', 'A'],
      'U': ['OU', 'EU', 'I'],
      'Y': ['I', 'IE', 'E'],
      'AN': ['EN', 'ON', 'AM'],
      'EN': ['AN', 'IN', 'EM'],
      'IN': ['AIN', 'EN', 'UN'],
      'ON': ['AN', 'OM', 'EN'],
      'OU': ['O', 'AU', 'U'],
      'AU': ['O', 'OU', 'EAU'],
      'EU': ['E', 'OE', 'U'],
      'AI': ['EI', 'E', 'AY'],
      'EI': ['AI', 'E', 'AY'],
      'OI': ['OA', 'OU', 'UA'],
      'É': ['È', 'AI', 'ER'],
      'È': ['É', 'AI', 'EI'],
      'Ê': ['É', 'È', 'AI'],
      'Ç': ['S', 'SS', 'C'],
      'PH': ['F', 'FF', 'V'],
    };

    final distractors = <String>{};

    // Essayer des substitutions sur le segment correct
    for (final entry in substitutions.entries) {
      if (distractors.length >= 3) break;
      if (correct.contains(entry.key)) {
        for (final sub in entry.value) {
          if (distractors.length >= 3) break;
          final d = correct.replaceFirst(entry.key, sub);
          if (d != correct && !distractors.contains(d)) {
            distractors.add(d);
          }
        }
      }
    }

    // Compléter avec des variations si pas assez
    while (distractors.length < 3) {
      final chars = correct.split('');
      if (chars.isEmpty) {
        distractors.add('${correct}E');
        continue;
      }
      final idx = _random.nextInt(chars.length);
      final original = chars[idx];
      // Remplacer par une voyelle ou consonne aléatoire
      final replacements = _vowels.contains(original)
          ? ['A', 'E', 'I', 'O', 'U']
          : ['B', 'D', 'F', 'G', 'L', 'M', 'N', 'P', 'R', 'S', 'T'];
      final replacement = replacements[_random.nextInt(replacements.length)];
      chars[idx] = replacement;
      final d = chars.join();
      if (d != correct && !distractors.contains(d)) {
        distractors.add(d);
      }
    }

    return distractors.take(3).toList();
  }

  // -----------------------------------------------------------------------
  // Mode Pool — lettres à replacer
  // -----------------------------------------------------------------------

  /// Génère le pool de lettres pour le mode 3.
  ///
  /// Contient les lettres manquantes + [lureCount] leurres.
  List<String> generateLetterPool({int lureCount = 2}) {
    final correct = _blanks
        .where((b) => !_revealedPositions.contains(b.index))
        .map((b) => b.letter)
        .toList();

    // Leurres : lettres plausibles
    final lures = <String>[];
    final allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final usedInWord = _normalizedWord.toSet();

    for (int i = 0; i < lureCount; i++) {
      final candidates = allLetters
          .where((l) => !correct.contains(l) && !lures.contains(l))
          .toList();
      // Préférer les lettres présentes dans le mot (plus confusantes)
      final inWord = candidates.where((l) => usedInWord.contains(l)).toList();
      if (inWord.isNotEmpty) {
        lures.add(inWord[_random.nextInt(inWord.length)]);
      } else if (candidates.isNotEmpty) {
        lures.add(candidates[_random.nextInt(candidates.length)]);
      }
    }

    final pool = [...correct, ...lures];
    pool.shuffle(_random);
    return pool;
  }

  // -----------------------------------------------------------------------
  // Aide
  // -----------------------------------------------------------------------

  /// Révèle la prochaine lacune non trouvée.
  /// Retourne la [Blank] révélée ou null si tout est révélé.
  Blank? revealHint() {
    for (final blank in _blanks) {
      if (!_revealedPositions.contains(blank.index)) {
        _revealedPositions.add(blank.index);
        _hintsUsed++;
        return blank;
      }
    }
    return null;
  }

  // -----------------------------------------------------------------------
  // Scoring
  // -----------------------------------------------------------------------

  /// Calcule le score.
  ///
  /// Barème :
  /// - Correct premier coup sans aide : 100 pts
  /// - Correct ≤ 1 erreur : 70 pts
  /// - Correct > 1 erreur : 40 pts
  /// - Chaque aide : -15 pts (min 0)
  /// - Bonus mode difficile (freeInput) : +10 pts
  FillBlankScore computeScore({required int durationMs}) {
    int points;

    if (_attempts == 0 && _hintsUsed == 0) {
      points = 100;
    } else if (_attempts <= 1) {
      points = 70;
    } else {
      points = 40;
    }

    // Bonus mode difficile
    if (mode == FillBlankMode.freeInput) {
      points += 10;
    }

    // Pénalité aides
    points = (points - _hintsUsed * 15).clamp(0, 110);

    return FillBlankScore(
      points: points,
      hintsUsed: _hintsUsed,
      firstTry: _attempts == 0 && _hintsUsed == 0,
      durationMs: durationMs,
    );
  }
}

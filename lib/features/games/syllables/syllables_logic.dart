// ============================================================
// Fichier : lib/features/games/syllables/syllables_logic.dart
// Description : Logique du jeu Roue des Syllabes.
//               Découpe orthographique des syllabes françaises.
//               Gère les digrammes vocaliques (ou, au, eau, ai…),
//               les digrammes consonantiques (ch, ph, gn, qu…)
//               et les groupes consonantiques inséparables (bl, tr…).
//               100 % hors-ligne, aucune dépendance réseau.
// ============================================================

import 'dart:math';

/// Résultat d'une tentative.
enum SyllablesResult { correct, incorrect }

/// Logique de la remise en ordre des syllabes d'un mot.
class SyllablesLogic {
  SyllablesLogic(this.mot, this.syllables, {Random? random})
      : _random = random ?? Random();

  /// Mot original.
  final String mot;

  /// Syllabes orthographiques dans l'ordre correct (ex : ['cha', 'peau']).
  final List<String> syllables;

  final Random _random;

  int _attempts = 0;
  int get attempts => _attempts;

  bool _solved = false;
  bool get isSolved => _solved;

  /// Mélange les syllabes (garantit ordre ≠ original si ≥ 2 syllabes).
  List<String> shuffle() {
    if (syllables.length <= 1) return List.from(syllables);
    final shuffled = List<String>.from(syllables);
    int maxTries = 20;
    do {
      for (int i = shuffled.length - 1; i > 0; i--) {
        final j = _random.nextInt(i + 1);
        final tmp = shuffled[i];
        shuffled[i] = shuffled[j];
        shuffled[j] = tmp;
      }
      maxTries--;
    } while (_listsEqual(shuffled, syllables) && maxTries > 0);
    return shuffled;
  }

  /// Vérifie si la proposition est correcte.
  SyllablesResult check(List<String> proposal) {
    _attempts++;
    if (_listsEqual(proposal, syllables)) {
      _solved = true;
      return SyllablesResult.correct;
    }
    return SyllablesResult.incorrect;
  }

  /// Calcule le score (50 pts premier essai, 30 pts 2e, 10 pts après).
  int computeScore() {
    if (_attempts == 1) return 50;
    if (_attempts == 2) return 30;
    return 10;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Découpage orthographique
  // ---------------------------------------------------------------------------

  /// Découpe un mot français en syllabes **orthographiques**.
  ///
  /// Gère :
  /// - Trigramme vocalique : eau
  /// - Digrammes vocaliques : ou, au, ai, ei, oi, eu, ui, ay…
  /// - Digrammes consonantiques (= une seule consonne) : ch, ph, th, gn, qu
  /// - Groupes consonantiques inséparables : bl, br, cl, cr, dr, fl, fr,
  ///   gl, gr, pl, pr, tr, vr, sc, sp, st
  ///
  /// Exemples : "chapeau" → ["cha","peau"], "ballon" → ["bal","lon"],
  ///            "princesse" → ["prin","ces","se"]
  static List<String> orthographicSplit(String mot) {
    if (mot.isEmpty) return [mot];
    final lower = mot.toLowerCase();

    // 1. Tokenisation en unités graphémiques avec position dans la chaîne
    final units = <_GraphUnit>[];
    int i = 0;
    while (i < lower.length) {
      // Trigramme vocalique : eau
      if (i + 2 < lower.length && lower.substring(i, i + 3) == 'eau') {
        units.add(_GraphUnit(mot.substring(i, i + 3), true, i));
        i += 3;
        continue;
      }
      if (i + 1 < lower.length) {
        final di = lower.substring(i, i + 2);
        // Digrammes vocaliques
        if (const {
          'ou',
          'au',
          'ai',
          'ei',
          'oi',
          'eu',
          'ui',
          'ay',
          'ey',
          'oy',
          'uy',
          'œu',
        }.contains(di)) {
          units.add(_GraphUnit(mot.substring(i, i + 2), true, i));
          i += 2;
          continue;
        }
        // Digrammes consonantiques (agissent comme une seule consonne)
        if (const {'ch', 'ph', 'th', 'gn', 'qu'}.contains(di)) {
          units.add(_GraphUnit(mot.substring(i, i + 2), false, i));
          i += 2;
          continue;
        }
      }
      // Caractère unique
      final c = lower[i];
      final isV = 'aeiouàâèéêëîïôùûüyœæ'.contains(c);
      units.add(_GraphUnit(mot.substring(i, i + 1), isV, i));
      i++;
    }

    // 2. Indices des voyelles (noyaux syllabiques)
    final vowelIdx = <int>[
      for (int j = 0; j < units.length; j++)
        if (units[j].isVowel) j,
    ];
    // Monosyllabe : une seule voyelle ou aucune
    if (vowelIdx.length <= 1) return [mot];

    // Groupes consonantiques qui restent avec la voyelle suivante
    const inseparable = {
      'bl',
      'br',
      'cl',
      'cr',
      'dr',
      'fl',
      'fr',
      'gl',
      'gr',
      'pl',
      'pr',
      'tr',
      'vr',
      'sc',
      'sp',
      'st',
    };

    // 3. Points de coupure (indices dans `units`)
    final splitAt = <int>[0];

    for (int v = 0; v < vowelIdx.length - 1; v++) {
      final v1 = vowelIdx[v];
      final v2 = vowelIdx[v + 1];
      // Consonnes entre v1 et v2
      final cons = <int>[for (int j = v1 + 1; j < v2; j++) j];

      if (cons.isEmpty) {
        // Hiatus V1V2 → coupe entre les deux voyelles
        splitAt.add(v2);
      } else if (cons.length == 1) {
        // VCV → V-CV : la consonne va avec la voyelle suivante
        splitAt.add(cons.first);
      } else {
        // 2+ consonnes : vérifier si les deux dernières forment un groupe inséparable
        final lastPair =
            (units[cons[cons.length - 2]].text + units[cons.last].text)
                .toLowerCase();
        if (inseparable.contains(lastPair)) {
          // Groupe inséparable en fin de cluster :
          // 2 consonnes inséparables → V-[CL]V (les deux suivent)
          // 3+ consonnes inséparables → VC-[CL]V (première reste)
          splitAt.add(
            cons.length == 2 ? cons.first : cons[cons.length - 2],
          );
        } else {
          // Coupure après la première consonne : VC-CV
          splitAt.add(cons[1]);
        }
      }
    }

    // 4. Reconstruction des syllabes à partir des positions
    final result = <String>[];
    for (int s = 0; s < splitAt.length; s++) {
      final startUnit = splitAt[s];
      final endUnit = s + 1 < splitAt.length ? splitAt[s + 1] : units.length;
      final charStart = units[startUnit].charPos;
      final charEnd =
          endUnit < units.length ? units[endUnit].charPos : mot.length;
      final syl = mot.substring(charStart, charEnd);
      if (syl.isNotEmpty) result.add(syl);
    }

    return result.isEmpty ? [mot] : result;
  }
}

/// Unité graphémique : un caractère ou un digramme/trigramme.
class _GraphUnit {
  const _GraphUnit(this.text, this.isVowel, this.charPos);
  final String text;
  final bool isVowel;
  final int charPos; // position dans la chaîne originale
}

// ============================================================
// Fichier : test/unit/anagram_logic_test.dart
// Description : Tests unitaires de AnagramLogic.
//               Vérifie : shuffle ≠ original, check correct/incorrect,
//               scoring, aide progressive, cas dégénérés.
// ============================================================

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/games/anagram/anagram_logic.dart';

void main() {
  // ── shuffle ────────────────────────────────────────────────────────────────
  group('shuffle()', () {
    test('retourne toutes les lettres du mot', () {
      final logic = AnagramLogic('CHAT');
      final shuffled = logic.shuffle();
      expect(shuffled.length, equals(4));
      expect(shuffled.toList()..sort(), equals(['A', 'C', 'H', 'T']));
    });

    test('mélange ≠ mot original (mot normal)', () {
      // Avec seed fixe pour reproductibilité
      final logic = AnagramLogic('CHEVAL', random: Random(42));
      final shuffled = logic.shuffle();
      // Doit contenir les mêmes lettres
      expect(shuffled.toList()..sort(), equals('CHEVAL'.split('')..sort()));
      // Doit être différent de l'original
      expect(shuffled.join(), isNot(equals('CHEVAL')));
    });

    test('mélange possible pour un mot de 2 lettres différentes', () {
      final logic = AnagramLogic('AB', random: Random(1));
      final shuffled = logic.shuffle();
      expect(shuffled.join(), equals('BA'));
    });

    test('mot d\'1 lettre → retourne tel quel', () {
      final logic = AnagramLogic('A');
      final shuffled = logic.shuffle();
      expect(shuffled, equals(['A']));
    });

    test('toutes lettres identiques → retourne tel quel', () {
      final logic = AnagramLogic('AAA');
      final shuffled = logic.shuffle();
      expect(shuffled, equals(['A', 'A', 'A']));
    });

    test('insensible à la casse en entrée', () {
      final logic = AnagramLogic('chat');
      final shuffled = logic.shuffle();
      // Toutes les lettres sont en majuscules
      expect(shuffled.every((l) => l == l.toUpperCase()), isTrue);
    });
  });

  // ── check ──────────────────────────────────────────────────────────────────
  group('check()', () {
    test('proposition correcte → AnagramResult.correct', () {
      final logic = AnagramLogic('CHAT');
      final result = logic.check(['C', 'H', 'A', 'T']);
      expect(result, equals(AnagramResult.correct));
    });

    test('proposition correcte en minuscules → correct (insensible casse)', () {
      final logic = AnagramLogic('CHAT');
      final result = logic.check(['c', 'h', 'a', 't']);
      expect(result, equals(AnagramResult.correct));
    });

    test('proposition incorrecte → AnagramResult.incorrect', () {
      final logic = AnagramLogic('CHAT');
      final result = logic.check(['T', 'A', 'H', 'C']);
      expect(result, equals(AnagramResult.incorrect));
    });

    test('tentatives incorrectes incrémentent le compteur', () {
      final logic = AnagramLogic('CHAT');
      expect(logic.attempts, equals(0));
      logic.check(['T', 'A', 'H', 'C']);
      expect(logic.attempts, equals(1));
      logic.check(['A', 'C', 'H', 'T']);
      expect(logic.attempts, equals(2));
    });

    test('tentative correcte n\'incrémente pas', () {
      final logic = AnagramLogic('CHAT');
      logic.check(['C', 'H', 'A', 'T']);
      expect(logic.attempts, equals(0));
    });
  });

  // ── revealHint ─────────────────────────────────────────────────────────────
  group('revealHint()', () {
    test('révèle la première lettre non révélée', () {
      final logic = AnagramLogic('CHAT');
      final hint = logic.revealHint();
      expect(hint, isNotNull);
      expect(hint!.index, equals(0));
      expect(hint.letter, equals('C'));
      expect(logic.hintsUsed, equals(1));
    });

    test('révèle les lettres séquentiellement', () {
      final logic = AnagramLogic('AB');
      final h1 = logic.revealHint();
      final h2 = logic.revealHint();
      expect(h1!.letter, equals('A'));
      expect(h2!.letter, equals('B'));
      expect(logic.hintsUsed, equals(2));
    });

    test('retourne null quand toutes les lettres sont révélées', () {
      final logic = AnagramLogic('AB');
      logic.revealHint();
      logic.revealHint();
      final h3 = logic.revealHint();
      expect(h3, equals(null));
      expect(logic.hintsUsed, equals(2)); // pas incrémenté
    });

    test('revealedPositions contient les index révélés', () {
      final logic = AnagramLogic('CHAT');
      logic.revealHint();
      logic.revealHint();
      expect(logic.revealedPositions, equals({0, 1}));
    });
  });

  // ── computeScore ──────────────────────────────────────────────────────────
  group('computeScore()', () {
    test('100 pts : premier essai, sans aide', () {
      final logic = AnagramLogic('CHAT');
      logic.check(['C', 'H', 'A', 'T']); // correct
      final score = logic.computeScore(durationMs: 5000);
      expect(score.points, equals(100));
      expect(score.firstTry, isTrue);
      expect(score.hintsUsed, equals(0));
      expect(score.durationMs, equals(5000));
    });

    test('60 pts : 1 aide utilisée', () {
      final logic = AnagramLogic('CHAT');
      logic.revealHint();
      final score = logic.computeScore(durationMs: 8000);
      expect(score.points, equals(60));
      expect(score.firstTry, isFalse);
    });

    test('30 pts : 2 aides utilisées', () {
      final logic = AnagramLogic('CHAT');
      logic.revealHint();
      logic.revealHint();
      final score = logic.computeScore(durationMs: 10000);
      expect(score.points, equals(30));
    });

    test('10 pts : 3+ aides utilisées', () {
      final logic = AnagramLogic('CHAT');
      logic.revealHint();
      logic.revealHint();
      logic.revealHint();
      final score = logic.computeScore(durationMs: 15000);
      expect(score.points, equals(10));
    });

    test('60 pts : pas d\'aide mais tentatives incorrectes', () {
      final logic = AnagramLogic('CHAT');
      logic.check(['T', 'A', 'H', 'C']); // incorrect
      logic.check(['C', 'H', 'A', 'T']); // correct
      final score = logic.computeScore(durationMs: 7000);
      // 0 hints, mais 1 attempt → firstTry = false → 60 pts
      expect(score.points, equals(60));
      expect(score.firstTry, isFalse);
    });
  });

  // ── _listEquals ────────────────────────────────────────────────────────────
  group('_listEquals (via check)', () {
    test('longueurs différentes → incorrect', () {
      final logic = AnagramLogic('CHAT');
      final result = logic.check(['C', 'H', 'A']);
      expect(result, equals(AnagramResult.incorrect));
    });
  });
}

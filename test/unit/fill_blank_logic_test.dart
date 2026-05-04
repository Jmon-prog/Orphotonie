// ============================================================
// Fichier : test/unit/fill_blank_logic_test.dart
// Description : Tests unitaires pour FillBlankLogic.
//               Couverture : génération lacunes, vérification 3 modes,
//               distracteurs, pool, aide, scoring.
// ============================================================

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/games/fill_blank/fill_blank_logic.dart';

void main() {
  group('FillBlankLogic', () {
    // -------------------------------------------------------------------
    // Génération des lacunes
    // -------------------------------------------------------------------
    group('génération des lacunes', () {
      test('mot de 3-4 lettres → 1 lacune', () {
        final logic = FillBlankLogic('CHAT', random: Random(42));
        expect(logic.blanks.length, 1);
      });

      test('mot de 5-7 lettres → 2 lacunes', () {
        final logic = FillBlankLogic('MAISON', random: Random(42));
        expect(logic.blanks.length, 2);
      });

      test('mot de 8+ lettres → 3 lacunes', () {
        final logic = FillBlankLogic('CHASSEUR', random: Random(42));
        expect(logic.blanks.length, 3);
      });

      test('ne masque jamais la 1ère lettre', () {
        for (int seed = 0; seed < 20; seed++) {
          final logic = FillBlankLogic('ELEPHANT', random: Random(seed));
          for (final blank in logic.blanks) {
            expect(
              blank.index,
              greaterThan(0),
              reason: 'seed=$seed, index=${blank.index}',
            );
          }
        }
      });

      test('ne dépasse pas 50 % du mot', () {
        final logic = FillBlankLogic('AB', random: Random(42));
        expect(logic.blanks.length, 1);
        // 1 lacune sur 2 lettres = 50 %
      });

      test('mot d\'une lettre → 0 lacune (rien à masquer sauf 1ère)', () {
        // Mot d'une lettre : la 1ère est protégée, donc 0 candidat,
        // mais on clamp à 1 → pas de candidat disponible
        // Le code doit gérer gracieusement
        final logic = FillBlankLogic('A', random: Random(42));
        // Avec un seul caractère, candidates est vide → blanks vide
        expect(logic.blanks.isEmpty, isTrue);
      });

      test('préfère les lettres difficiles (accents)', () {
        // CHÂTEAU contient Â et E — devrait préférer Â
        final logic = FillBlankLogic('CHÂTEAU', random: Random(0));
        final blankedLetters = logic.blanks.map((b) => b.letter).toSet();
        // Au moins une lettre accentuée ou voyelle
        expect(
          blankedLetters.any(
            (l) => 'ÉÈÊËÀÂÔÛÙÜÎÏÇ'.contains(l) || 'AEIOU'.contains(l),
          ),
          isTrue,
        );
      });

      test('wordWithBlanks contient null aux positions lacunaires', () {
        final logic = FillBlankLogic('CHAT', random: Random(42));
        final display = logic.wordWithBlanks;
        expect(display.length, 4);
        expect(display[0], isNotNull, reason: '1ère lettre protégée');
        final nullCount = display.where((l) => l == null).length;
        expect(nullCount, logic.blanks.length);
      });
    });

    // -------------------------------------------------------------------
    // Vérification — mode frappe / pool
    // -------------------------------------------------------------------
    group('check (mode frappe / pool)', () {
      test('réponse correcte', () {
        final logic = FillBlankLogic('CHAT', random: Random(42));
        final answers = {
          for (final b in logic.blanks) b.index: b.letter,
        };
        expect(logic.check(answers), FillBlankResult.correct);
        expect(logic.attempts, 0);
      });

      test('réponse incorrecte incrémente attempts', () {
        final logic = FillBlankLogic('CHAT', random: Random(42));
        final answers = {
          for (final b in logic.blanks) b.index: 'Z',
        };
        expect(logic.check(answers), FillBlankResult.incorrect);
        expect(logic.attempts, 1);
      });

      test('insensible à la casse', () {
        final logic = FillBlankLogic('CHAT', random: Random(42));
        final answers = {
          for (final b in logic.blanks) b.index: b.letter.toLowerCase(),
        };
        expect(logic.check(answers), FillBlankResult.correct);
      });
    });

    // -------------------------------------------------------------------
    // Vérification — mode choix multiple
    // -------------------------------------------------------------------
    group('checkChoice', () {
      test('bonne réponse', () {
        final logic = FillBlankLogic(
          'MAISON',
          mode: FillBlankMode.multipleChoice,
          random: Random(42),
        );
        final correct = logic.blanks.map((b) => b.letter).join();
        expect(logic.checkChoice(correct), FillBlankResult.correct);
      });

      test('mauvaise réponse', () {
        final logic = FillBlankLogic(
          'MAISON',
          mode: FillBlankMode.multipleChoice,
          random: Random(42),
        );
        expect(logic.checkChoice('ZZ'), FillBlankResult.incorrect);
        expect(logic.attempts, 1);
      });

      test('insensible à la casse', () {
        final logic = FillBlankLogic(
          'MAISON',
          mode: FillBlankMode.multipleChoice,
          random: Random(42),
        );
        final correct = logic.blanks.map((b) => b.letter).join().toLowerCase();
        expect(logic.checkChoice(correct), FillBlankResult.correct);
      });
    });

    // -------------------------------------------------------------------
    // Choix multiples — distracteurs
    // -------------------------------------------------------------------
    group('generateChoices', () {
      test('retourne 4 propositions', () {
        final logic = FillBlankLogic(
          'CHASSEUR',
          mode: FillBlankMode.multipleChoice,
          random: Random(42),
        );
        final choices = logic.generateChoices();
        expect(choices.length, 4);
      });

      test('contient la bonne réponse', () {
        final logic = FillBlankLogic(
          'CHASSEUR',
          mode: FillBlankMode.multipleChoice,
          random: Random(42),
        );
        final correct = logic.blanks.map((b) => b.letter).join();
        final choices = logic.generateChoices();
        expect(choices, contains(correct));
      });

      test('distracteurs ≠ réponse correcte', () {
        final logic = FillBlankLogic(
          'CHASSEUR',
          mode: FillBlankMode.multipleChoice,
          random: Random(42),
        );
        final correct = logic.blanks.map((b) => b.letter).join();
        final choices = logic.generateChoices();
        final others = choices.where((c) => c != correct);
        expect(others.length, 3);
      });

      test('pas de doublon dans les choix', () {
        for (int seed = 0; seed < 10; seed++) {
          final logic = FillBlankLogic(
            'MAISON',
            mode: FillBlankMode.multipleChoice,
            random: Random(seed),
          );
          final choices = logic.generateChoices();
          expect(
            choices.toSet().length,
            choices.length,
            reason: 'seed=$seed doublons: $choices',
          );
        }
      });
    });

    // -------------------------------------------------------------------
    // Pool de lettres (mode 3)
    // -------------------------------------------------------------------
    group('generateLetterPool', () {
      test('contient toutes les lettres manquantes', () {
        final logic = FillBlankLogic(
          'MAISON',
          mode: FillBlankMode.letterPool,
          random: Random(42),
        );
        final pool = logic.generateLetterPool();
        for (final blank in logic.blanks) {
          expect(pool, contains(blank.letter));
        }
      });

      test('contient des leurres en plus', () {
        final logic = FillBlankLogic(
          'MAISON',
          mode: FillBlankMode.letterPool,
          random: Random(42),
        );
        final pool = logic.generateLetterPool(lureCount: 2);
        expect(pool.length, logic.blanks.length + 2);
      });

      test('pool mélangé (pas toujours dans le même ordre)', () {
        final orders = <String>{};
        for (int seed = 0; seed < 10; seed++) {
          final logic = FillBlankLogic(
            'ELEPHANT',
            mode: FillBlankMode.letterPool,
            random: Random(seed),
          );
          orders.add(logic.generateLetterPool().join());
        }
        // Au moins 2 ordres différents sur 10 essais
        expect(orders.length, greaterThan(1));
      });
    });

    // -------------------------------------------------------------------
    // Aide
    // -------------------------------------------------------------------
    group('revealHint', () {
      test('révèle la prochaine lacune', () {
        final logic = FillBlankLogic('MAISON', random: Random(42));
        final hint = logic.revealHint();
        expect(hint, isNotNull);
        expect(logic.hintsUsed, 1);
        expect(logic.revealedPositions, contains(hint!.index));
      });

      test('ne révèle pas deux fois la même lacune', () {
        final logic = FillBlankLogic('MAISON', random: Random(42));
        final first = logic.revealHint();
        final second = logic.revealHint();
        expect(first!.index, isNot(equals(second?.index)));
      });

      test('retourne null quand toutes les lacunes sont révélées', () {
        final logic = FillBlankLogic('CHAT', random: Random(42));
        // CHAT a 1 lacune
        logic.revealHint();
        expect(logic.revealHint(), isNull);
      });

      test('remainingBlanks décrémente après hint', () {
        final logic = FillBlankLogic('MAISON', random: Random(42));
        final before = logic.remainingBlanks;
        logic.revealHint();
        expect(logic.remainingBlanks, before - 1);
      });

      test('wordWithBlanks se met à jour après hint', () {
        final logic = FillBlankLogic('MAISON', random: Random(42));
        final hint = logic.revealHint()!;
        final display = logic.wordWithBlanks;
        expect(display[hint.index], hint.letter);
      });
    });

    // -------------------------------------------------------------------
    // Scoring
    // -------------------------------------------------------------------
    group('computeScore', () {
      test('parfait sans erreur ni aide : 100 pts (modes moyen/facile)', () {
        final logic = FillBlankLogic(
          'CHAT',
          mode: FillBlankMode.multipleChoice,
          random: Random(42),
        );
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, 100);
        expect(score.firstTry, isTrue);
      });

      test('bonus +10 en mode freeInput', () {
        final logic = FillBlankLogic(
          'CHAT',
          mode: FillBlankMode.freeInput,
          random: Random(42),
        );
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, 110);
      });

      test('≤ 1 erreur : 70 pts', () {
        final logic = FillBlankLogic('CHAT', random: Random(42));
        logic.check({for (final b in logic.blanks) b.index: 'Z'}); // 1 erreur
        final score = logic.computeScore(durationMs: 5000);
        // freeInput bonus +10 → 80
        expect(score.points, 80);
        expect(score.firstTry, isFalse);
      });

      test('> 1 erreur : 40 pts', () {
        final logic = FillBlankLogic(
          'CHAT',
          mode: FillBlankMode.letterPool,
          random: Random(42),
        );
        logic.check({for (final b in logic.blanks) b.index: 'Z'});
        logic.check({for (final b in logic.blanks) b.index: 'Y'});
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, 40);
      });

      test('pénalité aide : -15 pts par aide', () {
        final logic = FillBlankLogic(
          'MAISON',
          mode: FillBlankMode.multipleChoice,
          random: Random(42),
        );
        logic.revealHint();
        final score = logic.computeScore(durationMs: 5000);
        // base 70 (hintsUsed>0 → pas parfait, 0 erreur → ≤1) - 15 = 55
        expect(score.points, 55);
      });

      test('score ne descend pas sous 0', () {
        final logic = FillBlankLogic(
          'ELEPHANT',
          mode: FillBlankMode.multipleChoice,
          random: Random(42),
        );
        // Utiliser toutes les aides + erreurs
        logic.revealHint();
        logic.revealHint();
        logic.revealHint();
        logic.check({});
        logic.check({});
        logic.check({});
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, greaterThanOrEqualTo(0));
      });
    });

    // -------------------------------------------------------------------
    // Modes
    // -------------------------------------------------------------------
    group('modes', () {
      test('FillBlankMode.freeInput est le défaut', () {
        final logic = FillBlankLogic('TEST');
        expect(logic.mode, FillBlankMode.freeInput);
      });

      test('les 3 modes sont accessibles', () {
        expect(FillBlankMode.values.length, 3);
      });
    });
  });
}

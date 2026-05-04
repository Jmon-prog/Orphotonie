// ============================================================
// Fichier : test/unit/hangman_logic_test.dart
// Description : Tests unitaires pour HangmanLogic.
//               Couverture : guessLetter, revealedWord, victoire/défaite,
//               aides, scoring, difficulté.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/games/hangman/hangman_logic.dart';

void main() {
  group('HangmanLogic', () {
    // -------------------------------------------------------------------
    // guessLetter
    // -------------------------------------------------------------------
    group('guessLetter', () {
      test('lettre correcte présente dans le mot', () {
        final logic = HangmanLogic('CHAT');
        final result = logic.guessLetter('C');
        expect(result, LetterResult.correct);
        expect(logic.correctLetters, contains('C'));
        expect(logic.errorsCount, 0);
      });

      test('lettre incorrecte absente du mot', () {
        final logic = HangmanLogic('CHAT');
        final result = logic.guessLetter('Z');
        expect(result, LetterResult.incorrect);
        expect(logic.incorrectLetters, contains('Z'));
        expect(logic.errorsCount, 1);
      });

      test('lettre déjà essayée retourne alreadyUsed', () {
        final logic = HangmanLogic('CHAT');
        logic.guessLetter('C');
        final result = logic.guessLetter('C');
        expect(result, LetterResult.alreadyUsed);
        expect(logic.errorsCount, 0);
      });

      test('insensible à la casse', () {
        final logic = HangmanLogic('Chat');
        final result = logic.guessLetter('c');
        expect(result, LetterResult.correct);
        expect(logic.correctLetters, contains('C'));
      });

      test('ignore les propositions après game over', () {
        final logic = HangmanLogic('AB', difficulty: HangmanDifficulty.hard);
        // 5 erreurs pour perdre en hard
        for (final l in ['Z', 'Y', 'X', 'W', 'V']) {
          logic.guessLetter(l);
        }
        expect(logic.isLost, isTrue);
        final result = logic.guessLetter('A');
        expect(result, LetterResult.alreadyUsed);
      });
    });

    // -------------------------------------------------------------------
    // revealedWord
    // -------------------------------------------------------------------
    group('revealedWord', () {
      test('affiche null pour les lettres non trouvées', () {
        final logic = HangmanLogic('CHAT');
        expect(logic.revealedWord, [null, null, null, null]);
      });

      test('révèle toutes les occurrences d\'une lettre', () {
        final logic = HangmanLogic('MAMAN');
        logic.guessLetter('M');
        expect(logic.revealedWord, ['M', null, 'M', null, null]);
      });

      test('mot complet après toutes les lettres trouvées', () {
        final logic = HangmanLogic('OUI');
        logic.guessLetter('O');
        logic.guessLetter('U');
        logic.guessLetter('I');
        expect(logic.revealedWord, ['O', 'U', 'I']);
      });
    });

    // -------------------------------------------------------------------
    // victoire / défaite
    // -------------------------------------------------------------------
    group('victoire / défaite', () {
      test('victoire quand toutes les lettres trouvées', () {
        final logic = HangmanLogic('AB');
        logic.guessLetter('A');
        expect(logic.isWon, isFalse);
        logic.guessLetter('B');
        expect(logic.isWon, isTrue);
        expect(logic.isLost, isFalse);
        expect(logic.isGameOver, isTrue);
      });

      test('défaite en mode normal (6 erreurs)', () {
        final logic = HangmanLogic('AB');
        for (final l in ['Z', 'Y', 'X', 'W', 'V', 'U']) {
          logic.guessLetter(l);
        }
        expect(logic.isLost, isTrue);
        expect(logic.isWon, isFalse);
        expect(logic.isGameOver, isTrue);
        expect(logic.errorsCount, 6);
      });

      test('défaite en mode facile (8 erreurs)', () {
        final logic = HangmanLogic('A', difficulty: HangmanDifficulty.easy);
        for (final l in ['Z', 'Y', 'X', 'W', 'V', 'U', 'T', 'S']) {
          logic.guessLetter(l);
        }
        expect(logic.isLost, isTrue);
        expect(logic.errorsCount, 8);
      });

      test('défaite en mode difficile (5 erreurs)', () {
        final logic = HangmanLogic('A', difficulty: HangmanDifficulty.hard);
        for (final l in ['Z', 'Y', 'X', 'W', 'V']) {
          logic.guessLetter(l);
        }
        expect(logic.isLost, isTrue);
        expect(logic.errorsCount, 5);
      });
    });

    // -------------------------------------------------------------------
    // mascotState
    // -------------------------------------------------------------------
    group('mascotState', () {
      test('état 0 au début', () {
        final logic = HangmanLogic('TEST');
        expect(logic.mascotState, 0);
        expect(logic.mascotProgress, 0.0);
      });

      test('état progresse avec les erreurs', () {
        final logic = HangmanLogic('TEST');
        logic.guessLetter('Z'); // 1 erreur sur 6
        expect(logic.mascotState, greaterThan(0));
      });

      test('état 8 à la défaite', () {
        final logic = HangmanLogic('A');
        for (final l in ['Z', 'Y', 'X', 'W', 'V', 'U']) {
          logic.guessLetter(l);
        }
        expect(logic.mascotState, 8);
        expect(logic.mascotProgress, 1.0);
      });
    });

    // -------------------------------------------------------------------
    // aides
    // -------------------------------------------------------------------
    group('aides', () {
      test('revealFirstLetter révèle la première lettre non trouvée', () {
        final logic = HangmanLogic('CHAT');
        final letter = logic.revealFirstLetter();
        expect(letter, 'C');
        expect(logic.correctLetters, contains('C'));
        expect(logic.hintsUsed, 1);
      });

      test('revealFirstLetter passe à la suivante si première déjà trouvée',
          () {
        final logic = HangmanLogic('CHAT');
        logic.guessLetter('C');
        final letter = logic.revealFirstLetter();
        expect(letter, 'H');
        expect(logic.hintsUsed, 1);
      });

      test('revealRandomLetter révèle une lettre non trouvée', () {
        final logic = HangmanLogic('AB');
        logic.guessLetter('A');
        final letter = logic.revealRandomLetter();
        expect(letter, 'B');
        expect(logic.correctLetters, contains('B'));
        expect(logic.hintsUsed, 1);
      });

      test('revealFirstLetter retourne null si tout révélé', () {
        final logic = HangmanLogic('AB');
        logic.guessLetter('A');
        logic.guessLetter('B');
        expect(logic.revealFirstLetter(), isNull);
      });

      test('revealRandomLetter retourne null si tout révélé', () {
        final logic = HangmanLogic('A');
        logic.guessLetter('A');
        expect(logic.revealRandomLetter(), isNull);
      });

      test('aides cumulées incrémentent hintsUsed', () {
        final logic = HangmanLogic('ABCD');
        logic.revealFirstLetter(); // A
        logic.revealRandomLetter(); // B, C ou D
        expect(logic.hintsUsed, 2);
      });
    });

    // -------------------------------------------------------------------
    // computeScore
    // -------------------------------------------------------------------
    group('computeScore', () {
      test('victoire parfaite : 100 pts', () {
        final logic = HangmanLogic('AB');
        logic.guessLetter('A');
        logic.guessLetter('B');
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, 100);
        expect(score.won, isTrue);
        expect(score.hintsUsed, 0);
        expect(score.errorsCount, 0);
      });

      test('victoire ≤ 2 erreurs : 80 pts', () {
        final logic = HangmanLogic('AB');
        logic.guessLetter('Z');
        logic.guessLetter('Y');
        logic.guessLetter('A');
        logic.guessLetter('B');
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, 80);
        expect(score.errorsCount, 2);
      });

      test('victoire ≤ 4 erreurs : 60 pts', () {
        final logic = HangmanLogic('AB');
        for (final l in ['Z', 'Y', 'X', 'W']) {
          logic.guessLetter(l);
        }
        logic.guessLetter('A');
        logic.guessLetter('B');
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, 60);
      });

      test('victoire > 4 erreurs : 40 pts', () {
        final logic = HangmanLogic('AB', difficulty: HangmanDifficulty.easy);
        for (final l in ['Z', 'Y', 'X', 'W', 'V']) {
          logic.guessLetter(l);
        }
        logic.guessLetter('A');
        logic.guessLetter('B');
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, 40);
      });

      test('défaite : 10 pts', () {
        final logic = HangmanLogic('AB');
        for (final l in ['Z', 'Y', 'X', 'W', 'V', 'U']) {
          logic.guessLetter(l);
        }
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, 10);
        expect(score.won, isFalse);
      });

      test('pénalité aide : -10 pts par aide', () {
        final logic = HangmanLogic('ABC');
        logic.revealFirstLetter(); // A, -10
        logic.revealFirstLetter(); // B, -10
        logic.guessLetter('C');
        final score = logic.computeScore(durationMs: 5000);
        // base 80 (0 erreurs mais hints > 0) - 20 = 60
        expect(score.points, 60);
        expect(score.hintsUsed, 2);
      });

      test('score ne descend pas sous 0', () {
        final logic = HangmanLogic('ABCDEFGHIJ');
        // Utiliser 10+ aides pour tester le clamp
        for (int i = 0; i < 10; i++) {
          logic.revealFirstLetter();
        }
        final score = logic.computeScore(durationMs: 5000);
        expect(score.points, greaterThanOrEqualTo(0));
      });
    });

    // -------------------------------------------------------------------
    // usedLetters
    // -------------------------------------------------------------------
    group('usedLetters', () {
      test('contient toutes les lettres essayées', () {
        final logic = HangmanLogic('CHAT');
        logic.guessLetter('C');
        logic.guessLetter('Z');
        expect(logic.usedLetters, containsAll(['C', 'Z']));
        expect(logic.usedLetters.length, 2);
      });
    });

    // -------------------------------------------------------------------
    // difficulté
    // -------------------------------------------------------------------
    group('difficulté', () {
      test('easy = 8 erreurs max', () {
        expect(HangmanDifficulty.easy.maxErrors, 8);
      });

      test('normal = 6 erreurs max', () {
        expect(HangmanDifficulty.normal.maxErrors, 6);
      });

      test('hard = 5 erreurs max', () {
        expect(HangmanDifficulty.hard.maxErrors, 5);
      });
    });
  });
}

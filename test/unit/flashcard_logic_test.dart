// ============================================================
// Fichier : test/unit/flashcard_logic_test.dart
// Description : Tests unitaires de FlashcardLogic et FlashcardScore.
//               Vérifie : état initial, révélation, scoring, taux.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/games/flashcard/flashcard_logic.dart';

void main() {
  // ── FlashcardLogic ────────────────────────────────────────────────────────
  group('FlashcardLogic', () {
    test('état initial : carte non révélée', () {
      final logic =
          FlashcardLogic(mot: 'CHAT', definition: 'Animal domestique');
      expect(logic.isRevealed, isFalse);
      expect(logic.mot, equals('CHAT'));
      expect(logic.definition, equals('Animal domestique'));
    });

    test('reveal() passe isRevealed à true', () {
      final logic = FlashcardLogic(mot: 'CHAT');
      logic.reveal();
      expect(logic.isRevealed, isTrue);
    });

    test('appels multiples à reveal() ne provoquent pas d\'erreur', () {
      final logic = FlashcardLogic(mot: 'CHAT');
      logic.reveal();
      logic.reveal();
      expect(logic.isRevealed, isTrue);
    });

    test('mot avec définition null est accepté', () {
      final logic = FlashcardLogic(mot: 'MOT');
      expect(logic.definition, isNull);
    });

    test('mot vide est accepté', () {
      final logic = FlashcardLogic(mot: '');
      expect(logic.mot, isEmpty);
      expect(logic.isRevealed, isFalse);
    });
  });

  // ── FlashcardScore ────────────────────────────────────────────────────────
  group('FlashcardScore', () {
    test('total = knownCount + unknownCount', () {
      const score =
          FlashcardScore(knownCount: 7, unknownCount: 3, durationMs: 0);
      expect(score.total, equals(10));
    });

    test('successRate = 100 % si tout est connu', () {
      const score =
          FlashcardScore(knownCount: 5, unknownCount: 0, durationMs: 0);
      expect(score.successRate, equals(100.0));
    });

    test('successRate = 0 % si rien de connu', () {
      const score =
          FlashcardScore(knownCount: 0, unknownCount: 5, durationMs: 0);
      expect(score.successRate, equals(0.0));
    });

    test('successRate = 70 % pour 7/10', () {
      const score =
          FlashcardScore(knownCount: 7, unknownCount: 3, durationMs: 0);
      expect(score.successRate, closeTo(70.0, 0.01));
    });

    test('successRate = 0 si total = 0 (pas de division par zéro)', () {
      const score =
          FlashcardScore(knownCount: 0, unknownCount: 0, durationMs: 0);
      expect(score.successRate, equals(0.0));
    });

    test('points = 10 par mot connu', () {
      const score =
          FlashcardScore(knownCount: 6, unknownCount: 4, durationMs: 0);
      expect(score.points, equals(60));
    });

    test('points = 0 si aucun mot connu', () {
      const score =
          FlashcardScore(knownCount: 0, unknownCount: 10, durationMs: 0);
      expect(score.points, equals(0));
    });
  });
}

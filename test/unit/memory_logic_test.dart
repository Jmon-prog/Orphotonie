// ============================================================
// Fichier : test/unit/memory_logic_test.dart
// Description : Tests unitaires de la logique Memory.
//               Vérifie : buildMemoryCards, MemoryScore, MemoryCard.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/games/memory/memory_logic.dart';

void main() {
  // Données de test
  final pairs = [
    const MemoryPairData(
      wordId: 1,
      mot: 'chat',
      definition: 'Animal domestique',
    ),
    const MemoryPairData(
      wordId: 2,
      mot: 'chien',
      definition: 'Fidèle compagnon',
    ),
    const MemoryPairData(wordId: 3, mot: 'maison', definition: 'Lieu de vie'),
  ];

  // ── buildMemoryCards ────────────────────────────────────────────────────────
  group('buildMemoryCards()', () {
    test('génère exactement 2 × nombre de paires', () {
      final cards = buildMemoryCards(pairs);
      expect(cards.length, equals(6));
    });

    test(
        'chaque paire génère une carte isWordSide=true et une isWordSide=false',
        () {
      // wordOnly: false → une carte mot + une carte définition par paire
      final cards = buildMemoryCards(pairs, wordOnly: false);
      for (final pair in pairs) {
        final wordCards = cards
            .where((c) => c.wordId == pair.wordId && c.isWordSide)
            .toList();
        final defCards = cards
            .where((c) => c.wordId == pair.wordId && !c.isWordSide)
            .toList();
        expect(
          wordCards.length,
          equals(1),
          reason: 'Mot "${pair.mot}" doit avoir 1 carte mot',
        );
        expect(
          defCards.length,
          equals(1),
          reason: 'Mot "${pair.mot}" doit avoir 1 carte définition',
        );
      }
    });

    test('les uids sont tous distincts', () {
      final cards = buildMemoryCards(pairs);
      final uids = cards.map((c) => c.uid).toSet();
      expect(uids.length, equals(cards.length));
    });

    test('carte mot contient le texte du mot', () {
      final cards = buildMemoryCards(pairs);
      final wordCard = cards.firstWhere((c) => c.wordId == 1 && c.isWordSide);
      expect(wordCard.content, equals('chat'));
    });

    test('carte définition contient la définition', () {
      // wordOnly: false → la deuxième carte contient la définition
      final cards = buildMemoryCards(pairs, wordOnly: false);
      final defCard = cards.firstWhere((c) => c.wordId == 1 && !c.isWordSide);
      expect(defCard.content, equals('Animal domestique'));
    });

    test('carte définition replie vers le mot si définition est nulle', () {
      final pairsNoDef = [
        const MemoryPairData(wordId: 10, mot: 'vide'),
      ];
      final cards = buildMemoryCards(pairsNoDef);
      // Pas de définition → les deux cartes ont isWordSide=true et contenu=mot
      expect(cards.length, equals(2));
      for (final c in cards) {
        expect(c.content, equals('vide'));
        expect(c.isWordSide, isTrue);
      }
    });

    test('cartes mélangées (seed fixe) → ordre ≠ ordre naturel au moins 1 fois',
        () {
      final natural = [
        ...pairs.map((p) => '${p.wordId}_w'),
        ...pairs.map((p) => '${p.wordId}_d'),
      ];
      bool foundDiff = false;
      for (int s = 0; s < 50; s++) {
        final cards = buildMemoryCards(pairs, seed: s);
        if (cards.map((c) => c.uid).toList() != natural) {
          foundDiff = true;
          break;
        }
      }
      expect(foundDiff, isTrue);
    });

    test('toutes les cartes initialement face cachée et non appariées', () {
      final cards = buildMemoryCards(pairs);
      for (final c in cards) {
        expect(c.isFaceUp, isFalse);
        expect(c.isMatched, isFalse);
      }
    });

    test('liste vide de paires → liste vide de cartes', () {
      final cards = buildMemoryCards([]);
      expect(cards, isEmpty);
    });
  });

  // ── MemoryCard.copyWith ──────────────────────────────────────────────────────
  group('MemoryCard.copyWith()', () {
    final card = MemoryCard(
      uid: '1_w',
      wordId: 1,
      content: 'chat',
      isWordSide: true,
    );

    test('isFaceUp peut être mis à true', () {
      final c2 = card.copyWith(isFaceUp: true);
      expect(c2.isFaceUp, isTrue);
      expect(c2.isMatched, isFalse);
    });

    test('isMatched peut être mis à true', () {
      final c2 = card.copyWith(isMatched: true);
      expect(c2.isMatched, isTrue);
      expect(c2.isFaceUp, isFalse);
    });

    test('uid, wordId, content et isWordSide sont copiés', () {
      final c2 = card.copyWith(isFaceUp: true);
      expect(c2.uid, equals(card.uid));
      expect(c2.wordId, equals(card.wordId));
      expect(c2.content, equals(card.content));
      expect(c2.isWordSide, equals(card.isWordSide));
    });
  });

  // ── MemoryScore ──────────────────────────────────────────────────────────────
  group('MemoryScore', () {
    test('accuracy = 1.0 si chaque tentative était bonne', () {
      const score = MemoryScore(pairs: 6, attempts: 6, durationMs: 0);
      expect(score.accuracy, closeTo(1.0, 0.001));
    });

    test('accuracy = 0.5 si moitié de tentatives réussies', () {
      const score = MemoryScore(pairs: 3, attempts: 6, durationMs: 0);
      expect(score.accuracy, closeTo(0.5, 0.001));
    });

    test('accuracy = 0 si aucune paire (pas de division par zéro)', () {
      const score = MemoryScore(pairs: 0, attempts: 0, durationMs: 0);
      expect(score.accuracy, equals(0.0));
    });

    test('points = 600 pour 6 paires sans erreur', () {
      const score = MemoryScore(pairs: 6, attempts: 6, durationMs: 0);
      expect(score.points, equals(600));
    });

    test('points diminuent avec les tentatives ratées', () {
      // 3 paires, 6 tentatives → 3 ratées → 300 - 3×5 = 285
      const score = MemoryScore(pairs: 3, attempts: 6, durationMs: 0);
      expect(score.points, equals(285));
    });

    test('points jamais négatifs', () {
      const score = MemoryScore(pairs: 1, attempts: 200, durationMs: 0);
      expect(score.points, greaterThanOrEqualTo(0));
    });

    test('points = 0 si aucune paire trouvée', () {
      const score = MemoryScore(pairs: 0, attempts: 10, durationMs: 0);
      expect(score.points, equals(0));
    });
  });
}

// ============================================================
// Fichier : test/unit/definition_qcm_logic_test.dart
// Description : Tests unitaires de DefinitionQcmLogic.
//               Vérifie : construction des questions, unicité des choix,
//               index correct, cas dégénérés (pas assez de distracteurs,
//               mots sans définition).
// ============================================================

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/games/definition_qcm/definition_qcm_logic.dart';
import 'package:orphotonie/core/database/app_database.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Crée un [Word] minimal pour les tests.
Word _makeWord(int id, String mot, {String? definition}) => Word(
      id: id,
      dictionaryId: 1,
      mot: mot,
      definition: definition,
      tags: '[]',
      difficulty: 1,
      createdAt: DateTime(2024),
    );

void main() {
  final logic = DefinitionQcmLogic(random: Random(0));

  // Jeu de mots avec définitions
  final words = [
    _makeWord(1, 'chat', definition: 'Animal domestique à moustaches'),
    _makeWord(2, 'chien', definition: 'Animal domestique fidèle'),
    _makeWord(3, 'maison', definition: 'Lieu où l\'on habite'),
    _makeWord(4, 'école', definition: 'Lieu d\'apprentissage'),
    _makeWord(5, 'livre', definition: 'Objet contenant des pages écrites'),
  ];

  // ── buildQuestions ─────────────────────────────────────────────────────────
  group('buildQuestions()', () {
    test('génère une question par mot de session', () {
      final questions = logic.buildQuestions(
        allWords: words,
        sessionWords: words.take(3).toList(),
      );
      expect(questions.length, equals(3));
    });

    test('chaque question a exactement 4 choix', () {
      final questions = logic.buildQuestions(
        allWords: words,
        sessionWords: words,
      );
      for (final q in questions) {
        expect(q.choices.length, equals(4));
      }
    });

    test('la bonne définition est toujours présente parmi les choix', () {
      final questions = logic.buildQuestions(
        allWords: words,
        sessionWords: words,
      );
      for (final q in questions) {
        expect(q.choices.contains(q.word.definition!), isTrue);
      }
    });

    test('correctIndex pointe bien sur la bonne définition', () {
      final questions = logic.buildQuestions(
        allWords: words,
        sessionWords: words,
      );
      for (final q in questions) {
        expect(q.choices[q.correctIndex], equals(q.word.definition!));
      }
    });

    test('les 4 choix sont distincts', () {
      final questions = logic.buildQuestions(
        allWords: words,
        sessionWords: words,
      );
      for (final q in questions) {
        expect(q.choices.toSet().length, equals(4));
      }
    });

    test('ignore les mots sans définition dans sessionWords', () {
      final withoutDef = [
        _makeWord(10, 'vide'), // pas de définition
        ...words.take(2),
      ];
      final questions = logic.buildQuestions(
        allWords: words,
        sessionWords: withoutDef,
      );
      // Seuls les 2 mots avec définition doivent générer une question
      expect(questions.length, equals(2));
    });

    test('ignore les mots sans définition dans allWords (pool de distracteurs)',
        () {
      // 1 mot cible + 3 distracteurs valides = OK. Ici seulement 2 distracteurs.
      final smallPool = [
        _makeWord(1, 'chat', definition: 'def A'),
        _makeWord(2, 'chien', definition: 'def B'),
        _makeWord(3, 'maison', definition: 'def C'),
      ];
      final questions = logic.buildQuestions(
        allWords: smallPool,
        sessionWords: smallPool.take(1).toList(),
      );
      // 1 cible + 2 distracteurs = < 3 → aucune question ne doit être générée
      // (pool 3 mots : cible + 2 distracteurs = exactement 3, donc OK avec 2 distracteurs)
      // La logique exige 3 distracteurs → ici seulement 2 disponibles → skip
      expect(questions.length, equals(0));
    });

    test('retourne liste vide si sessionWords est vide', () {
      final questions = logic.buildQuestions(
        allWords: words,
        sessionWords: [],
      );
      expect(questions, isEmpty);
    });

    test('retourne liste vide si allWords est vide', () {
      final questions = logic.buildQuestions(
        allWords: [],
        sessionWords: words.take(1).toList(),
      );
      expect(questions, isEmpty);
    });

    test('correctIndex est dans [0, 3]', () {
      final questions = logic.buildQuestions(
        allWords: words,
        sessionWords: words,
      );
      for (final q in questions) {
        expect(q.correctIndex, inInclusiveRange(0, 3));
      }
    });
  });
}

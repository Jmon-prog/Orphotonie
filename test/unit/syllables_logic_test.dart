// ============================================================
// Fichier : test/unit/syllables_logic_test.dart
// Description : Tests unitaires de SyllablesLogic.
//               Vérifie : orthographicSplit, shuffle, check,
//               scoring, cas dégénérés.
// ============================================================

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/games/syllables/syllables_logic.dart';

void main() {
  // ── orthographicSplit ──────────────────────────────────────────────────────
  group('orthographicSplit()', () {
    test('mot vide retourne [«»]', () {
      expect(SyllablesLogic.orthographicSplit(''), equals(['']));
    });

    test('monosyllabe → liste d\'un seul élément', () {
      expect(SyllablesLogic.orthographicSplit('chat'), equals(['chat']));
      expect(SyllablesLogic.orthographicSplit('mer'), equals(['mer']));
    });

    test('VCV → V-CV : "ami" → ["a","mi"]', () {
      expect(SyllablesLogic.orthographicSplit('ami'), equals(['a', 'mi']));
    });

    test('"chapeau" → ["cha","peau"]', () {
      expect(
        SyllablesLogic.orthographicSplit('chapeau'),
        equals(['cha', 'peau']),
      );
    });

    test('"ballon" → ["bal","lon"]', () {
      expect(
        SyllablesLogic.orthographicSplit('ballon'),
        equals(['bal', 'lon']),
      );
    });

    test('"princesse" → ["prin","ces","se"]', () {
      expect(
        SyllablesLogic.orthographicSplit('princesse'),
        equals(['prin', 'ces', 'se']),
      );
    });

    test('"maison" → ["mai","son"]', () {
      expect(
        SyllablesLogic.orthographicSplit('maison'),
        equals(['mai', 'son']),
      );
    });

    test('"école" → ["é","co","le"]', () {
      expect(
        SyllablesLogic.orthographicSplit('école'),
        equals(['é', 'co', 'le']),
      );
    });

    test('"boulanger" → ["bou","lan","ger"]', () {
      expect(
        SyllablesLogic.orthographicSplit('boulanger'),
        equals(['bou', 'lan', 'ger']),
      );
    });

    test('reconstruction = mot original', () {
      const words = ['chapeau', 'maison', 'boulanger', 'princesse', 'école'];
      for (final w in words) {
        final parts = SyllablesLogic.orthographicSplit(w);
        expect(
          parts.join(),
          equals(w),
          reason: '"$w" reconstruit à partir de ${parts.join(' + ')}',
        );
      }
    });

    test('groupe insép "bl" : "table" → ["ta","ble"]', () {
      expect(SyllablesLogic.orthographicSplit('table'), equals(['ta', 'ble']));
    });

    test('groupe insép "tr" : "patron" → ["pa","tron"]', () {
      expect(
        SyllablesLogic.orthographicSplit('patron'),
        equals(['pa', 'tron']),
      );
    });
  });

  // ── SyllablesLogic.shuffle ──────────────────────────────────────────────────
  group('shuffle()', () {
    test('monosyllabe retourné tel quel', () {
      final logic = SyllablesLogic('chat', ['chat']);
      expect(logic.shuffle(), equals(['chat']));
    });

    test('toutes les syllabes sont présentes après shuffle', () {
      final logic =
          SyllablesLogic('chapeau', ['cha', 'peau'], random: Random(1));
      final shuffled = logic.shuffle();
      expect(shuffled..sort(), equals(['cha', 'peau']..sort()));
    });

    test('shuffle ≠ original (avec seed reproduisant un mélange)', () {
      final syllabes = ['prin', 'ces', 'se'];
      // Essaie différents seeds jusqu\'à en trouver un qui mélange
      bool foundDiff = false;
      for (int s = 0; s < 100; s++) {
        final logic = SyllablesLogic('princesse', syllabes, random: Random(s));
        if (logic.shuffle().join() != syllabes.join()) {
          foundDiff = true;
          break;
        }
      }
      expect(foundDiff, isTrue);
    });
  });

  // ── SyllablesLogic.check ────────────────────────────────────────────────────
  group('check()', () {
    test('bonne réponse → SyllablesResult.correct', () {
      final logic = SyllablesLogic('maison', ['mai', 'son']);
      expect(logic.check(['mai', 'son']), equals(SyllablesResult.correct));
    });

    test('mauvaise réponse → SyllablesResult.incorrect', () {
      final logic = SyllablesLogic('maison', ['mai', 'son']);
      expect(logic.check(['son', 'mai']), equals(SyllablesResult.incorrect));
    });

    test('isSolved = true après bonne réponse', () {
      final logic = SyllablesLogic('maison', ['mai', 'son']);
      logic.check(['mai', 'son']);
      expect(logic.isSolved, isTrue);
    });

    test('attempts s\'incrémente à chaque check', () {
      final logic = SyllablesLogic('maison', ['mai', 'son']);
      logic.check(['son', 'mai']);
      logic.check(['son', 'mai']);
      logic.check(['mai', 'son']);
      expect(logic.attempts, equals(3));
    });
  });

  // ── SyllablesLogic.computeScore ─────────────────────────────────────────────
  group('computeScore()', () {
    test('50 pts au premier essai', () {
      final logic = SyllablesLogic('maison', ['mai', 'son']);
      logic.check(['mai', 'son']); // 1er essai réussi
      expect(logic.computeScore(), equals(50));
    });

    test('30 pts au deuxième essai', () {
      final logic = SyllablesLogic('maison', ['mai', 'son']);
      logic.check(['son', 'mai']); // raté
      logic.check(['mai', 'son']); // réussi au 2e
      expect(logic.computeScore(), equals(30));
    });

    test('10 pts à partir du 3e essai', () {
      final logic = SyllablesLogic('maison', ['mai', 'son']);
      logic.check(['son', 'mai']); // raté
      logic.check(['son', 'mai']); // raté
      logic.check(['mai', 'son']); // réussi au 3e
      expect(logic.computeScore(), equals(10));
    });
  });
}

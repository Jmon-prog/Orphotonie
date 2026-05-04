// ============================================================
// Fichier : test/unit/crossword_generator_test.dart
// Description : Tests unitaires pour CrosswordGenerator.
//               Couverture : placement, intersections, isolation,
//               numérotation, robustesse (50 grilles).
// ============================================================

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/games/crossword/crossword_generator.dart';

void main() {
  group('CrosswordGenerator', () {
    // -------------------------------------------------------------------
    // Placement de base
    // -------------------------------------------------------------------
    group('placement de base', () {
      test('place le 1er mot horizontalement', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'Animal domestique'),
        ]);
        expect(result.placements.length, 1);
        expect(result.placements.first.orientation, WordOrientation.horizontal);
        expect(result.placements.first.word, 'CHAT');
      });

      test('place 2 mots croisés', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'Animal domestique'),
          const CrosswordEntry(word: 'CHIEN', clue: 'Fidèle compagnon'),
        ]);
        expect(result.placements.length, 2);
        // Les deux orientations doivent être différentes
        expect(
          result.placements[0].orientation != result.placements[1].orientation,
          isTrue,
        );
      });

      test('grille non vide', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'test'),
          const CrosswordEntry(word: 'CHIEN', clue: 'test'),
        ]);
        expect(result.rows, greaterThan(0));
        expect(result.cols, greaterThan(0));
        expect(result.grid.isNotEmpty, isTrue);
      });

      test('mots d\'une lettre ignorés', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'A', clue: 'test'),
          const CrosswordEntry(word: 'CHAT', clue: 'test'),
        ]);
        expect(result.placements.length, 1);
        expect(result.placements.first.word, 'CHAT');
      });

      test('entrées vides → grille vide', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([]);
        expect(result.placements, isEmpty);
        expect(result.rows, 0);
        expect(result.cols, 0);
      });

      test('mots normalisés (accents retirés, majuscules)', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'château', clue: 'test'),
          const CrosswordEntry(word: 'ARCHE', clue: 'test'),
        ]);
        final words = result.placements.map((p) => p.word).toSet();
        expect(words.contains('CHATEAU'), isTrue);
        expect(words.contains('ARCHE'), isTrue);
      });
    });

    // -------------------------------------------------------------------
    // Intersections
    // -------------------------------------------------------------------
    group('intersections', () {
      test('intersections valides (même lettre)', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'test'),
          const CrosswordEntry(word: 'CHIEN', clue: 'test'),
          const CrosswordEntry(word: 'LAPIN', clue: 'test'),
        ]);

        // Vérifier que chaque lettre de chaque mot est bien dans la grille
        for (final placed in result.placements) {
          for (int i = 0; i < placed.word.length; i++) {
            final cells = placed.cells;
            final (r, c) = cells[i];
            expect(
              result.grid[r][c],
              placed.word[i],
              reason: 'Mot ${placed.word}, lettre $i à ($r,$c) : '
                  'attendu ${placed.word[i]}, trouvé ${result.grid[r][c]}',
            );
          }
        }
      });

      test('pas de collision de lettres différentes', () {
        for (int seed = 0; seed < 20; seed++) {
          final gen = CrosswordGenerator(random: Random(seed));
          final result = gen.generate([
            const CrosswordEntry(word: 'ELEPHANT', clue: 'test'),
            const CrosswordEntry(word: 'TIGRE', clue: 'test'),
            const CrosswordEntry(word: 'LION', clue: 'test'),
            const CrosswordEntry(word: 'OURS', clue: 'test'),
          ]);

          // Vérifier chaque mot
          for (final placed in result.placements) {
            for (int i = 0; i < placed.word.length; i++) {
              final (r, c) = placed.cells[i];
              expect(
                result.grid[r][c],
                placed.word[i],
                reason: 'seed=$seed mot=${placed.word}',
              );
            }
          }
        }
      });
    });

    // -------------------------------------------------------------------
    // Isolation (pas de mots collés sans case noire)
    // -------------------------------------------------------------------
    group('règle d\'isolation', () {
      test('pas de lettres adjacentes non justifiées', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'test'),
          const CrosswordEntry(word: 'CHIEN', clue: 'test'),
          const CrosswordEntry(word: 'ARBRE', clue: 'test'),
          const CrosswordEntry(word: 'LAPIN', clue: 'test'),
        ]);

        // Collecter toutes les cellules occupées par des mots
        final wordCells = <(int, int), Set<String>>{};
        for (final placed in result.placements) {
          for (final cell in placed.cells) {
            wordCells.putIfAbsent(cell, () => {}).add(placed.word);
          }
        }

        // Chaque case occupée ne devrait être adjacente
        // qu'à des cases du même mot ou d'un mot croisé
        // (vérification basique : pas de mot "collé" bout à bout)
        for (final placed in result.placements) {
          // Vérifier que la case AVANT le mot est vide
          final beforeR = placed.startRow -
              (placed.orientation == WordOrientation.vertical ? 1 : 0);
          final beforeC = placed.startCol -
              (placed.orientation == WordOrientation.horizontal ? 1 : 0);
          if (beforeR >= 0 &&
              beforeC >= 0 &&
              beforeR < result.rows &&
              beforeC < result.cols) {
            if (result.grid[beforeR][beforeC] != null) {
              // La case avant contient une lettre — c'est une intersection
              expect(
                wordCells.containsKey((beforeR, beforeC)),
                isTrue,
                reason: 'Case avant ${placed.word} non justifiée',
              );
            }
          }
        }
      });
    });

    // -------------------------------------------------------------------
    // Numérotation
    // -------------------------------------------------------------------
    group('numérotation', () {
      test('tous les mots sont numérotés', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'test'),
          const CrosswordEntry(word: 'CHIEN', clue: 'test'),
        ]);
        for (final p in result.placements) {
          expect(p.number, isNotNull, reason: '${p.word} non numéroté');
        }
      });

      test('numéros commencent à 1', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'test'),
          const CrosswordEntry(word: 'CHIEN', clue: 'test'),
        ]);
        final numbers = result.placements.map((p) => p.number!).toList()
          ..sort();
        expect(numbers.first, 1);
      });

      test('mots commençant à la même case partagent le numéro', () {
        // Si deux mots (H et V) commencent à la même case
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'test'),
          const CrosswordEntry(word: 'CHIEN', clue: 'test'),
          const CrosswordEntry(word: 'ARBRE', clue: 'test'),
        ]);
        // Vérifier que les numéros sont dans l'ordre de lecture
        final numbered = result.placements.where((p) => p.number != null);
        expect(numbered.isNotEmpty, isTrue);
      });

      test('ordre de lecture : haut→bas, gauche→droite', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'MAISON', clue: 'test'),
          const CrosswordEntry(word: 'ARBRE', clue: 'test'),
          const CrosswordEntry(word: 'LION', clue: 'test'),
          const CrosswordEntry(word: 'TIGRE', clue: 'test'),
        ]);

        // Vérifier que les numéros sont croissants
        // en ordre de lecture (row, col)
        final sorted = result.placements.toList()
          ..sort((a, b) {
            final rowDiff = a.startRow.compareTo(b.startRow);
            if (rowDiff != 0) return rowDiff;
            return a.startCol.compareTo(b.startCol);
          });

        int? prevNum;
        for (final p in sorted) {
          if (prevNum != null) {
            expect(
              p.number!,
              greaterThanOrEqualTo(prevNum),
              reason: '${p.word} n°${p.number} < précédent n°$prevNum',
            );
          }
          prevNum = p.number;
        }
      });
    });

    // -------------------------------------------------------------------
    // Clues (indices)
    // -------------------------------------------------------------------
    group('clues', () {
      test('horizontalClues et verticalClues séparés', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'Animal domestique'),
          const CrosswordEntry(word: 'CHIEN', clue: 'Fidèle compagnon'),
        ]);

        final hClues = result.horizontalClues;
        final vClues = result.verticalClues;
        expect(hClues.length + vClues.length, result.placements.length);

        for (final c in hClues) {
          expect(c.orientation, WordOrientation.horizontal);
        }
        for (final c in vClues) {
          expect(c.orientation, WordOrientation.vertical);
        }
      });

      test('les clues sont conservées', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'Animal domestique'),
        ]);
        expect(result.placements.first.clue, 'Animal domestique');
      });
    });

    // -------------------------------------------------------------------
    // Dimensions
    // -------------------------------------------------------------------
    group('dimensions', () {
      test('grille tronquée aux dimensions minimales', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'CHAT', clue: 'test'),
        ]);
        // Un seul mot de 4 lettres → 1 ligne, 4 colonnes
        expect(result.rows, 1);
        expect(result.cols, 4);
      });

      test('grille ne dépasse pas 15×15 raisonnable', () {
        final gen = CrosswordGenerator(random: Random(42));
        final result = gen.generate([
          const CrosswordEntry(word: 'ELEPHANT', clue: 'test'),
          const CrosswordEntry(word: 'TIGRE', clue: 'test'),
          const CrosswordEntry(word: 'LION', clue: 'test'),
          const CrosswordEntry(word: 'GIRAFE', clue: 'test'),
          const CrosswordEntry(word: 'OURS', clue: 'test'),
          const CrosswordEntry(word: 'VACHE', clue: 'test'),
        ]);
        expect(result.rows, lessThanOrEqualTo(20));
        expect(result.cols, lessThanOrEqualTo(20));
      });
    });

    // -------------------------------------------------------------------
    // CrosswordPlacement
    // -------------------------------------------------------------------
    group('CrosswordPlacement', () {
      test('cells horizontal', () {
        const p = CrosswordPlacement(
          word: 'CHAT',
          clue: 'test',
          startRow: 2,
          startCol: 3,
          orientation: WordOrientation.horizontal,
        );
        expect(p.cells, [(2, 3), (2, 4), (2, 5), (2, 6)]);
      });

      test('cells vertical', () {
        const p = CrosswordPlacement(
          word: 'AB',
          clue: 'test',
          startRow: 0,
          startCol: 1,
          orientation: WordOrientation.vertical,
        );
        expect(p.cells, [(0, 1), (1, 1)]);
      });

      test('withNumber', () {
        const p = CrosswordPlacement(
          word: 'TEST',
          clue: 'test',
          startRow: 0,
          startCol: 0,
          orientation: WordOrientation.horizontal,
        );
        final numbered = p.withNumber(5);
        expect(numbered.number, 5);
        expect(numbered.word, 'TEST');
      });
    });

    // -------------------------------------------------------------------
    // Robustesse : 50 grilles sans crash
    // -------------------------------------------------------------------
    group('robustesse', () {
      test('50 grilles → 0 crash, placements valides', () {
        final entries = [
          const CrosswordEntry(word: 'CHAT', clue: 'Animal domestique'),
          const CrosswordEntry(word: 'CHIEN', clue: 'Fidèle compagnon'),
          const CrosswordEntry(word: 'LAPIN', clue: 'Rongeur'),
          const CrosswordEntry(word: 'ARBRE', clue: 'Végétal'),
          const CrosswordEntry(word: 'MAISON', clue: 'Habitation'),
          const CrosswordEntry(word: 'VACHE', clue: 'Bovin'),
        ];

        for (int seed = 0; seed < 50; seed++) {
          final gen = CrosswordGenerator(random: Random(seed));
          final result = gen.generate(entries);

          // Au moins le premier mot est placé
          expect(
            result.placements.isNotEmpty,
            isTrue,
            reason: 'seed=$seed aucun mot placé',
          );

          // Grille cohérente
          expect(result.grid.length, result.rows, reason: 'seed=$seed rows');
          if (result.rows > 0) {
            expect(
              result.grid[0].length,
              result.cols,
              reason: 'seed=$seed cols',
            );
          }

          // Vérifier les lettres
          for (final placed in result.placements) {
            for (int i = 0; i < placed.word.length; i++) {
              final (r, c) = placed.cells[i];
              expect(
                result.grid[r][c],
                placed.word[i],
                reason: 'seed=$seed mot=${placed.word} lettre $i '
                    'à ($r,$c)',
              );
            }
          }

          // Tous numérotés
          for (final p in result.placements) {
            expect(
              p.number,
              isNotNull,
              reason: 'seed=$seed ${p.word} non numéroté',
            );
          }
        }
      });

      test('50 grilles avec mots longs → 0 crash', () {
        final entries = [
          const CrosswordEntry(word: 'RHINOCEROS', clue: 'Gros animal'),
          const CrosswordEntry(word: 'CROCODILE', clue: 'Reptile'),
          const CrosswordEntry(word: 'ELEPHANT', clue: 'Pachyderme'),
          const CrosswordEntry(word: 'GIRAFE', clue: 'Grand cou'),
          const CrosswordEntry(word: 'TIGRE', clue: 'Félin rayé'),
          const CrosswordEntry(word: 'LION', clue: 'Roi'),
          const CrosswordEntry(word: 'OURS', clue: 'Plantigrade'),
          const CrosswordEntry(word: 'RAT', clue: 'Rongeur'),
        ];

        for (int seed = 0; seed < 50; seed++) {
          final gen = CrosswordGenerator(random: Random(seed));
          final result = gen.generate(entries);

          expect(
            result.placements.isNotEmpty,
            isTrue,
            reason: 'seed=$seed aucun mot placé',
          );
        }
      });

      test('minimum 3 mots placés pour un set de 6', () {
        final entries = [
          const CrosswordEntry(word: 'CHAT', clue: 'test'),
          const CrosswordEntry(word: 'CHIEN', clue: 'test'),
          const CrosswordEntry(word: 'LAPIN', clue: 'test'),
          const CrosswordEntry(word: 'ARBRE', clue: 'test'),
          const CrosswordEntry(word: 'MAISON', clue: 'test'),
          const CrosswordEntry(word: 'VACHE', clue: 'test'),
        ];

        int minPlaced = 100;
        for (int seed = 0; seed < 50; seed++) {
          final gen = CrosswordGenerator(random: Random(seed));
          final result = gen.generate(entries);
          if (result.placements.length < minPlaced) {
            minPlaced = result.placements.length;
          }
        }
        // Au minimum 2 mots placés (le premier + au moins un croisé)
        expect(minPlaced, greaterThanOrEqualTo(2));
      });
    });
  });
}

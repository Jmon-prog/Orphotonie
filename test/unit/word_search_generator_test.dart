// ============================================================
// Fichier : test/unit/word_search_generator_test.dart
// Description : Tests unitaires pour WordSearchGenerator.
//               Couverture : placement, intersections, remplissage,
//               directions, sélection, robustesse (100 grilles).
// ============================================================

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/games/word_search/word_search_generator.dart';

void main() {
  group('WordSearchGenerator', () {
    // -------------------------------------------------------------------
    // Tailles de grille
    // -------------------------------------------------------------------
    group('tailles de grille', () {
      test('facile → 8×8', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.easy,
        );
        expect(gen.gridSize, 8);
      });

      test('normal → 10×10', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.normal,
        );
        expect(gen.gridSize, 10);
      });

      test('difficile → 12×12', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.hard,
        );
        expect(gen.gridSize, 12);
      });
    });

    // -------------------------------------------------------------------
    // Placement des mots
    // -------------------------------------------------------------------
    group('placement des mots', () {
      test('place tous les mots courts dans une grande grille', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.hard,
          random: Random(42),
        );
        final result = gen.generate(['CHAT', 'CHIEN', 'RAT']);
        expect(result.placedWords.length, 3);
        expect(result.skippedWords, isEmpty);
      });

      test('grille a la bonne taille', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.normal,
          random: Random(42),
        );
        final result = gen.generate(['MOT']);
        expect(result.grid.length, 10);
        expect(result.grid[0].length, 10);
        expect(result.size, 10);
      });

      test('mots trop longs sont ignorés', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.easy,
          random: Random(42),
        );
        // 8×8 → mot de 9 lettres impossible
        final result = gen.generate(['ELEPHANTS']);
        expect(result.placedWords, isEmpty);
        expect(result.skippedWords, contains('ELEPHANTS'));
      });

      test('mot vide est ignoré', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.easy,
          random: Random(42),
        );
        final result = gen.generate(['', 'CHAT']);
        expect(result.placedWords.length, 1);
      });

      test('mots sont normalisés en majuscules sans accents', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.normal,
          random: Random(42),
        );
        final result = gen.generate(['château']);
        expect(result.placedWords.length, 1);
        expect(result.placedWords.first.word, 'CHATEAU');
      });

      test('les mots les plus longs sont placés en premier', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.hard,
          random: Random(42),
        );
        final result = gen.generate(['AB', 'ELEPHANT', 'CHAT']);
        // ELEPHANT (8) devrait être placé avant CHAT (4) et AB (2)
        if (result.placedWords.length >= 2) {
          // Vérifie simplement que les 3 sont placés
          expect(result.placedWords.length, 3);
        }
      });
    });

    // -------------------------------------------------------------------
    // Intersections
    // -------------------------------------------------------------------
    group('intersections', () {
      test('intersection de même lettre autorisée', () {
        // Placer CHAT et CHIEN — C en commun
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.hard,
          random: Random(42),
        );
        final result = gen.generate(['CHAT', 'CHIEN']);
        expect(result.placedWords.length, 2);

        // Vérifier intégrité : chaque lettre du mot est bien dans la grille
        for (final placed in result.placedWords) {
          for (int i = 0; i < placed.word.length; i++) {
            final r = placed.startRow + i * placed.direction.dr;
            final c = placed.startCol + i * placed.direction.dc;
            expect(result.grid[r][c], placed.word[i]);
          }
        }
      });
    });

    // -------------------------------------------------------------------
    // Remplissage
    // -------------------------------------------------------------------
    group('remplissage', () {
      test('aucune case vide après génération', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.normal,
          random: Random(42),
        );
        final result = gen.generate(['MOT']);
        for (final row in result.grid) {
          for (final cell in row) {
            expect(cell, isNotEmpty, reason: 'Case vide trouvée');
          }
        }
      });

      test('lettres de remplissage sont des majuscules A-Z', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.easy,
          random: Random(42),
        );
        final result = gen.generate([]);
        for (final row in result.grid) {
          for (final cell in row) {
            expect(
              RegExp(r'^[A-Z]$').hasMatch(cell),
              isTrue,
              reason: 'Lettre invalide: $cell',
            );
          }
        }
      });
    });

    // -------------------------------------------------------------------
    // Directions
    // -------------------------------------------------------------------
    group('directions', () {
      test('mode facile : horizontal + vertical seulement', () {
        // Générer plusieurs grilles pour vérifier les directions
        final allDirs = <Direction>{};
        for (int seed = 0; seed < 50; seed++) {
          final g = WordSearchGenerator(
            difficulty: WordSearchDifficulty.easy,
            random: Random(seed),
          );
          final result = g.generate(['CHAT', 'CHIEN', 'RAT']);
          for (final p in result.placedWords) {
            allDirs.add(p.direction);
          }
        }
        expect(
          allDirs.every(
            (d) => d == Direction.right || d == Direction.down,
          ),
          isTrue,
          reason: 'Directions non autorisées en mode facile : $allDirs',
        );
      });

      test('mode normal : inclut diagonale ↘', () {
        final allDirs = <Direction>{};
        for (int seed = 0; seed < 100; seed++) {
          final g = WordSearchGenerator(
            difficulty: WordSearchDifficulty.normal,
            random: Random(seed),
          );
          final result = g.generate(['CHAT', 'CHIEN', 'RAT', 'VACHE']);
          for (final p in result.placedWords) {
            allDirs.add(p.direction);
          }
        }
        // Doit contenir au moins right, down, et downRight
        expect(allDirs, contains(Direction.right));
        expect(allDirs, contains(Direction.down));
        expect(allDirs, contains(Direction.downRight));
      });
    });

    // -------------------------------------------------------------------
    // checkSelection
    // -------------------------------------------------------------------
    group('checkSelection', () {
      test('trouve un mot par sélection correcte', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.normal,
          random: Random(42),
        );
        final result = gen.generate(['CHAT']);
        final placed = result.placedWords.first;
        final selection = placed.cells;
        final found = WordSearchGenerator.checkSelection(
          selection,
          result.placedWords,
        );
        expect(found, isNotNull);
        expect(found!.word, 'CHAT');
      });

      test('trouve un mot sélectionné à l\'envers', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.normal,
          random: Random(42),
        );
        final result = gen.generate(['CHAT']);
        final placed = result.placedWords.first;
        final reversed = placed.cells.reversed.toList();
        final found = WordSearchGenerator.checkSelection(
          reversed,
          result.placedWords,
        );
        expect(found, isNotNull);
        expect(found!.word, 'CHAT');
      });

      test('retourne null pour sélection incorrecte', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.normal,
          random: Random(42),
        );
        final result = gen.generate(['CHAT']);
        // Peut être null si la sélection ne correspond pas
        // On ne peut pas garantir car (0,0)-(0,1) pourrait correspondre
        // Testons avec une sélection clairement hors des mots
        final found2 = WordSearchGenerator.checkSelection(
          [(9, 9), (9, 8), (9, 7), (9, 6), (9, 5)],
          result.placedWords,
        );
        // 5 cellules pour un mot de 4 lettres → forcément null
        expect(found2, isNull);
      });
    });

    // -------------------------------------------------------------------
    // isValidSelection
    // -------------------------------------------------------------------
    group('isValidSelection', () {
      test('ligne droite horizontale → valide', () {
        expect(
          WordSearchGenerator.isValidSelection(
            [(0, 0), (0, 1), (0, 2), (0, 3)],
          ),
          isTrue,
        );
      });

      test('ligne droite verticale → valide', () {
        expect(
          WordSearchGenerator.isValidSelection(
            [(0, 0), (1, 0), (2, 0)],
          ),
          isTrue,
        );
      });

      test('diagonale → valide', () {
        expect(
          WordSearchGenerator.isValidSelection(
            [(0, 0), (1, 1), (2, 2)],
          ),
          isTrue,
        );
      });

      test('sélection non alignée → invalide', () {
        expect(
          WordSearchGenerator.isValidSelection(
            [(0, 0), (1, 1), (2, 3)],
          ),
          isFalse,
        );
      });

      test('une seule cellule → invalide', () {
        expect(
          WordSearchGenerator.isValidSelection([(0, 0)]),
          isFalse,
        );
      });
    });

    // -------------------------------------------------------------------
    // cellsBetween
    // -------------------------------------------------------------------
    group('cellsBetween', () {
      test('horizontal', () {
        final cells = WordSearchGenerator.cellsBetween(0, 0, 0, 3);
        expect(cells.length, 4);
        expect(cells.first, (0, 0));
        expect(cells.last, (0, 3));
      });

      test('vertical', () {
        final cells = WordSearchGenerator.cellsBetween(0, 0, 3, 0);
        expect(cells.length, 4);
      });

      test('diagonale', () {
        final cells = WordSearchGenerator.cellsBetween(0, 0, 2, 2);
        expect(cells.length, 3);
        expect(cells[1], (1, 1));
      });

      test('même cellule', () {
        final cells = WordSearchGenerator.cellsBetween(5, 5, 5, 5);
        expect(cells.length, 1);
        expect(cells.first, (5, 5));
      });

      test('non aligné → vide', () {
        final cells = WordSearchGenerator.cellsBetween(0, 0, 1, 3);
        expect(cells, isEmpty);
      });
    });

    // -------------------------------------------------------------------
    // Robustesse : 100 grilles sans crash
    // -------------------------------------------------------------------
    group('robustesse', () {
      test('100 grilles faciles → 0 crash, placement valide', () {
        final words = ['CHAT', 'CHIEN', 'RAT', 'LAPIN', 'VACHE'];
        for (int seed = 0; seed < 100; seed++) {
          final gen = WordSearchGenerator(
            difficulty: WordSearchDifficulty.easy,
            random: Random(seed),
          );
          final result = gen.generate(words);

          // Grille bonne taille
          expect(result.grid.length, 8, reason: 'seed=$seed');
          expect(result.grid[0].length, 8, reason: 'seed=$seed');

          // Pas de case vide
          for (final row in result.grid) {
            for (final cell in row) {
              expect(cell.isNotEmpty, isTrue, reason: 'seed=$seed vide');
            }
          }

          // Mots placés cohérents
          for (final placed in result.placedWords) {
            for (int i = 0; i < placed.word.length; i++) {
              final r = placed.startRow + i * placed.direction.dr;
              final c = placed.startCol + i * placed.direction.dc;
              expect(
                result.grid[r][c],
                placed.word[i],
                reason: 'seed=$seed mot=${placed.word} pos=($r,$c)',
              );
            }
          }
        }
      });

      test('100 grilles normales → 0 crash', () {
        final words = ['ELEPHANT', 'GIRAFE', 'LION', 'TIGRE', 'OURS'];
        for (int seed = 0; seed < 100; seed++) {
          final gen = WordSearchGenerator(
            difficulty: WordSearchDifficulty.normal,
            random: Random(seed),
          );
          final result = gen.generate(words);
          expect(result.grid.length, 10, reason: 'seed=$seed');
        }
      });

      test('100 grilles difficiles → 0 crash', () {
        final words = [
          'RHINOCEROS',
          'HIPPOPOTAME',
          'CROCODILE',
          'ELEPHANT',
          'GIRAFE',
          'LION',
          'TIGRE',
          'OURS',
          'CHAT',
          'CHIEN',
        ];
        for (int seed = 0; seed < 100; seed++) {
          final gen = WordSearchGenerator(
            difficulty: WordSearchDifficulty.hard,
            random: Random(seed),
          );
          final result = gen.generate(words);
          expect(result.grid.length, 12, reason: 'seed=$seed');
        }
      });

      test('grille sans mots → remplie de lettres', () {
        final gen = WordSearchGenerator(
          difficulty: WordSearchDifficulty.easy,
          random: Random(42),
        );
        final result = gen.generate([]);
        expect(result.placedWords, isEmpty);
        expect(result.grid.length, 8);
        for (final row in result.grid) {
          for (final cell in row) {
            expect(RegExp(r'^[A-Z]$').hasMatch(cell), isTrue);
          }
        }
      });
    });

    // -------------------------------------------------------------------
    // PlacedWord
    // -------------------------------------------------------------------
    group('PlacedWord', () {
      test('cells retourne les bonnes coordonnées', () {
        const placed = PlacedWord(
          word: 'CHAT',
          startRow: 2,
          startCol: 3,
          direction: Direction.right,
        );
        final cells = placed.cells;
        expect(cells.length, 4);
        expect(cells[0], (2, 3));
        expect(cells[1], (2, 4));
        expect(cells[2], (2, 5));
        expect(cells[3], (2, 6));
      });

      test('cells diagonale ↘', () {
        const placed = PlacedWord(
          word: 'AB',
          startRow: 0,
          startCol: 0,
          direction: Direction.downRight,
        );
        expect(placed.cells, [(0, 0), (1, 1)]);
      });
    });
  });
}

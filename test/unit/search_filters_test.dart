// ============================================================
// Fichier : test/unit/search_filters_test.dart
// Description : Tests unitaires du modèle SearchFilters.
//               Vérifie la génération SQL et la logique métier.
//               Aucun accès DB — tests purement unitaires.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/search/data/search_filters_model.dart';

void main() {
  // -------------------------------------------------------------------------
  // SQL Generation
  // -------------------------------------------------------------------------
  group('SearchFilters.buildSql()', () {
    test('filtre par défaut contient toujours islem = 1', () {
      const f = SearchFilters();
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('islem = 1'));
    });

    test('textQuery génère LIKE %query%', () {
      const f = SearchFilters(textQuery: 'chat');
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('LOWER(mot) LIKE LOWER(?)'));
      expect(args, contains('%chat%'));
    });

    test('startsWith génère LIKE prefixe%', () {
      const f = SearchFilters(startsWith: 'ch');
      final (:sql, :args) = f.buildSql();
      expect(args, contains('ch%'));
    });

    test('endsWith génère LIKE %suffixe', () {
      const f = SearchFilters(endsWith: 'tion');
      final (:sql, :args) = f.buildSql();
      expect(args, contains('%tion'));
    });

    test('exactLength génère nblettres = ?', () {
      const f = SearchFilters(exactLength: 5);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('nblettres = ?'));
      expect(args, contains(5));
    });

    test('minLength + maxLength génère plage', () {
      const f = SearchFilters(minLength: 3, maxLength: 7);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('nblettres >= ?'));
      expect(sql, contains('nblettres <= ?'));
    });

    test('exactLength prioritaire sur minLength/maxLength', () {
      const f = SearchFilters(exactLength: 5, minLength: 2, maxLength: 9);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('nblettres = ?'));
      expect(sql, isNot(contains('nblettres >= ?')));
    });

    test('cgramList génère IN (?,?,?)', () {
      const f = SearchFilters(cgramList: ['NOM', 'VER', 'ADJ']);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('cgram IN (?, ?, ?)'));
      expect(args, containsAll(['NOM', 'VER', 'ADJ']));
    });

    test('nbsyllList génère IN (?,?)', () {
      const f = SearchFilters(nbsyllList: [1, 2]);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('nbsyll IN (?, ?)'));
      expect(args, containsAll([1, 2]));
    });

    test('minPreval génère preval >= ?', () {
      const f = SearchFilters(minPreval: 70);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('preval >= ?'));
      expect(args, contains(70.0));
    });

    test('hasMorphodecomp = true génère IS NOT NULL', () {
      const f = SearchFilters(hasMorphodecomp: true);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('morphodecomp IS NOT NULL'));
    });

    test('hasMorphodecomp = false génère IS NULL', () {
      const f = SearchFilters(hasMorphodecomp: false);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('morphodecomp IS NULL'));
    });

    test('rawWheres s\'ajoute entre parenthèses', () {
      const f = SearchFilters(rawWheres: ["phono LIKE '%S%'"]);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains("(phono LIKE '%S%')"));
    });

    test('filtres combinés génèrent AND entre les clauses', () {
      const f = SearchFilters(
        cgramList: ['NOM'],
        nbsyllList: [2],
        minPreval: 70,
        startsWith: 'ch',
      );
      final (:sql, :args) = f.buildSql();
      // Toutes les clauses présentes
      expect(sql, contains('islem = 1'));
      expect(sql, contains('cgram IN'));
      expect(sql, contains('nbsyll IN'));
      expect(sql, contains('preval >= ?'));
      expect(sql, contains('LOWER(mot) LIKE LOWER(?)'));
      // AND entre chaque clause
      final ands = RegExp(r' AND ').allMatches(sql).length;
      expect(ands, greaterThanOrEqualTo(4));
    });

    test('pagination : LIMIT et OFFSET dans les args', () {
      const f = SearchFilters(pageSize: 50, page: 2);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('LIMIT ?'));
      expect(sql, contains('OFFSET ?'));
      // Les 2 derniers args sont LIMIT et OFFSET
      expect(args[args.length - 2], equals(50));
      expect(args[args.length - 1], equals(100)); // 2 * 50
    });

    test('tri alphabétique → ORDER BY mot ASC', () {
      const f = SearchFilters(sort: SearchSort.alphabetique);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('ORDER BY mot ASC'));
    });

    test('tri fréquence → ORDER BY freqortho DESC', () {
      const f = SearchFilters(sort: SearchSort.frequence);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains('freqortho DESC'));
    });
  });

  // -------------------------------------------------------------------------
  // buildCountSql
  // -------------------------------------------------------------------------
  group('buildCountSql()', () {
    test('contient COUNT(*) et pas LIMIT/OFFSET', () {
      const f = SearchFilters(textQuery: 'loup', pageSize: 100, page: 1);
      final (:sql, :args) = f.buildCountSql();
      expect(sql, contains('COUNT(*)'));
      expect(sql, isNot(contains('LIMIT')));
      // args n'ont pas les 2 derniers (LIMIT/OFFSET)
      final full = f.buildSql();
      expect(args.length, equals(full.args.length - 2));
    });
  });

  // -------------------------------------------------------------------------
  // hasActiveFilters
  // -------------------------------------------------------------------------
  group('hasActiveFilters', () {
    test('filtre vide → false', () {
      expect(const SearchFilters().hasActiveFilters, isFalse);
    });

    test('textQuery non vide → true', () {
      expect(
        const SearchFilters(textQuery: 'test').hasActiveFilters,
        isTrue,
      );
    });

    test('cgramList non vide → true', () {
      expect(
        const SearchFilters(cgramList: ['NOM']).hasActiveFilters,
        isTrue,
      );
    });

    test('minPreval non null → true', () {
      expect(
        const SearchFilters(minPreval: 50).hasActiveFilters,
        isTrue,
      );
    });
  });

  // -------------------------------------------------------------------------
  // copyWith / reset
  // -------------------------------------------------------------------------
  group('copyWith / reset', () {
    test('copyWith ne modifie que le champ ciblé', () {
      const f = SearchFilters(textQuery: 'chat', minPreval: 80);
      final f2 = f.copyWith(textQuery: 'chien');
      expect(f2.textQuery, equals('chien'));
      expect(f2.minPreval, equals(80)); // inchangé
    });

    test('reset vide tous les filtres', () {
      const f = SearchFilters(
        textQuery: 'test',
        cgramList: ['NOM'],
        nbsyllList: [2],
        minPreval: 70,
      );
      final reset = f.reset();
      expect(reset.hasActiveFilters, isFalse);
      expect(reset.cgramList, isEmpty);
      expect(reset.nbsyllList, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // activeChips
  // -------------------------------------------------------------------------
  group('activeChips', () {
    test('chips générés pour les filtres actifs', () {
      const f = SearchFilters(
        textQuery: 'loup',
        cgramList: ['NOM'],
        minPreval: 80,
      );
      final chips = f.activeChips;
      expect(chips, hasLength(greaterThanOrEqualTo(3)));
      expect(chips.any((c) => c.label.contains('loup')), isTrue);
      expect(chips.any((c) => c.label.contains('NOM')), isTrue);
      expect(chips.any((c) => c.label.contains('80')), isTrue);
    });

    test('filtre vide → aucun chip', () {
      expect(const SearchFilters().activeChips, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // QuickSearches
  // -------------------------------------------------------------------------
  group('kQuickSearches', () {
    test('9 raccourcis définis', () {
      expect(kQuickSearches, hasLength(9));
    });

    test('aucun raccourci ne contient islem (inclus par SearchFilters)', () {
      for (final qs in kQuickSearches) {
        expect(
          qs.whereClause,
          isNot(contains('islem')),
          reason: '${qs.label} ne doit pas inclure islem',
        );
      }
    });

    test('CVCV raccourci génère SQL valide via rawWheres', () {
      final qs = kQuickSearches.firstWhere((q) => q.label.contains('CVCV'));
      final f = SearchFilters(rawWheres: [qs.whereClause]);
      final (:sql, :args) = f.buildSql();
      expect(sql, contains("cvortho = 'CVCV'"));
      expect(sql, contains('islem = 1'));
    });
  });
}

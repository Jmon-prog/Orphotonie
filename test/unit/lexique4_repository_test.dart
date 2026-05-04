// ============================================================
// Fichier : test/unit/lexique4_repository_test.dart
// Description : Tests unitaires de Lexique4Repository sur une base SQLite
//               en mémoire peuplée avec quelques entrées de test.
//               Vérifie : filtres islem=1, SQL combiné, famille de mots,
//               voisins orthographiques, fetchBatch.
// ============================================================

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/core/database/lexique4_database.dart';
import 'package:orphotonie/features/search/data/lexique4_repository.dart';
import 'package:orphotonie/features/search/data/search_filters_model.dart';

// ---------------------------------------------------------------------------
// Implémentation minimale de QueryExecutorUser pour ouvrir la connexion.
// ---------------------------------------------------------------------------

class _FakeUser implements drift.QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    drift.QueryExecutor executor,
    drift.OpeningDetails details,
  ) =>
      Future.value();
}

// ---------------------------------------------------------------------------
// Helper : base SQLite en mémoire avec données de test
// ---------------------------------------------------------------------------

Future<Lexique4Database> _buildTestDb() async {
  final conn = drift.DatabaseConnection(NativeDatabase.memory());

  // Ouvre la connexion avant toute opération.
  await conn.executor.ensureOpen(_FakeUser());

  await conn.runCustom(
    '''
    CREATE TABLE IF NOT EXISTS lexique4 (
      mot TEXT, phono TEXT, phono_ipa TEXT,
      cgram TEXT, cgram_ortho TEXT,
      nbsyll INTEGER, nblettres INTEGER, nbphons INTEGER,
      syllphono TEXT, cvortho TEXT,
      freqortho REAL, cdortho REAL, preval REAL,
      freqlemme REAL, freqmot REAL, lemme TEXT,
      islem INTEGER, genre TEXT, nombre TEXT,
      morphodecomp TEXT, nbhomoph INTEGER
    )
  ''',
    [],
  );

  // (mot, phono, cgram, nbsyll, nblettres, cvortho, preval, islem, morphodecomp, nbhomoph)
  const rows = [
    ('chat', 'Sa', 'NOM', 1, 4, 'CVC', 95.0, 1, null, 0),
    ('chien', 'SjE~', 'NOM', 1, 5, 'CCVC', 97.0, 1, null, 0),
    ('cheval', 'S@val', 'NOM', 2, 6, 'CVCVC', 90.0, 1, null, 0),
    ('table', 'tabl', 'NOM', 2, 5, 'CVCCV', 85.0, 1, null, 0),
    ('manger', 'mA~Ze', 'VER', 2, 6, 'CVCCVC', 88.0, 1, '/mang/.er', 0),
    (
      'mangeable',
      'mA~Zabl',
      'ADJ',
      3,
      9,
      'CVCCVCVCV',
      45.0,
      1,
      '/mang/.able',
      0
    ),
    // islem=0 → jamais retourné
    ('chats', 'Sa', 'NOM', 1, 5, 'CVCC', 95.0, 0, null, 0),
    // nbhomoph>0
    ('verre', 'vER', 'NOM', 1, 5, 'CVCCV', 80.0, 1, null, 2),
  ];

  for (final r in rows) {
    await conn.runCustom(
      'INSERT INTO lexique4 '
      '(mot,phono,cgram,nbsyll,nblettres,cvortho,preval,islem,morphodecomp,nbhomoph) '
      'VALUES (?,?,?,?,?,?,?,?,?,?)',
      [r.$1, r.$2, r.$3, r.$4, r.$5, r.$6, r.$7, r.$8, r.$9, r.$10],
    );
  }

  return Lexique4Database.forTesting(conn);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Lexique4Database db;
  late Lexique4Repository repo;

  setUp(() async {
    db = await _buildTestDb();
    repo = Lexique4Repository(db);
  });

  tearDown(() => db.close());

  // ── islem = 1 obligatoire ─────────────────────────────────────────────────
  group('Règle islem = 1', () {
    test('search() ne retourne jamais islem = 0', () async {
      final result = await repo.search(const SearchFilters());
      for (final e in result.entries) {
        expect(e.islem, equals(1), reason: '${e.mot} a islem=${e.islem}');
      }
    });

    test('getEntry() retourne null pour un mot islem=0', () async {
      final entry = await repo.getEntry('chats');
      expect(entry, equals(null));
    });
  });

  // ── Recherche sans filtres ────────────────────────────────────────────────
  group('search() sans filtres', () {
    test('retourne tous les lemmes (islem=1)', () async {
      final result = await repo.search(const SearchFilters());
      expect(result.entries.length, equals(7));
      expect(result.totalCount, equals(7));
    });
  });

  // ── Filtres texte ─────────────────────────────────────────────────────────
  group('search() filtres texte', () {
    test('textQuery "ch" → mots contenant ch', () async {
      final result = await repo.search(const SearchFilters(textQuery: 'ch'));
      expect(result.entries.every((e) => e.mot.contains('ch')), isTrue);
      expect(result.entries, isNotEmpty);
    });

    test('startsWith "ch" → chat, chien, cheval uniquement', () async {
      final result = await repo.search(const SearchFilters(startsWith: 'ch'));
      expect(result.entries.every((e) => e.mot.startsWith('ch')), isTrue);
      expect(result.entries.length, equals(3));
    });
  });

  // ── Filtres grammaticaux ──────────────────────────────────────────────────
  group('search() filtres grammaticaux', () {
    test('cgramList NOM → uniquement NOM', () async {
      final result = await repo.search(const SearchFilters(cgramList: ['NOM']));
      expect(result.entries.every((e) => e.cgram == 'NOM'), isTrue);
    });

    test('nbsyllList [2] → bisyllabes uniquement', () async {
      final result = await repo.search(const SearchFilters(nbsyllList: [2]));
      expect(result.entries.every((e) => e.nbsyll == 2), isTrue);
    });

    test('filtres combinés NOM + 1 syllabe → chat, chien, verre', () async {
      final result = await repo.search(
        const SearchFilters(cgramList: ['NOM'], nbsyllList: [1]),
      );
      expect(result.entries.length, equals(3));
      final mots = result.entries.map((e) => e.mot).toSet();
      expect(mots, containsAll(['chat', 'chien', 'verre']));
    });

    test('hasMorphodecomp true → manger + mangeable', () async {
      final result =
          await repo.search(const SearchFilters(hasMorphodecomp: true));
      expect(result.entries.every((e) => e.morphodecomp != null), isTrue);
      expect(result.entries.length, equals(2));
    });
  });

  // ── Filtres fréquence ─────────────────────────────────────────────────────
  group('search() filtres fréquence', () {
    test('minPreval 90 → exclut les mots peu connus', () async {
      final result = await repo.search(const SearchFilters(minPreval: 90));
      expect(result.entries.every((e) => (e.preval ?? 0) >= 90), isTrue);
    });

    test('minHomophones 1 → verre uniquement', () async {
      final result = await repo.search(const SearchFilters(minHomophones: 1));
      expect(result.entries.length, equals(1));
      expect(result.entries.first.mot, equals('verre'));
    });
  });

  // ── Pagination ─────────────────────────────────────────────────────────────
  group('Pagination', () {
    test('pageSize=2 page=0 → 2 résultats, hasMore=true', () async {
      final result =
          await repo.search(const SearchFilters(pageSize: 2, page: 0));
      expect(result.entries.length, equals(2));
      expect(result.totalCount, equals(7));
      expect(result.hasMore, isTrue);
    });

    test('pageSize=100 → hasMore=false', () async {
      final result =
          await repo.search(const SearchFilters(pageSize: 100, page: 0));
      expect(result.hasMore, isFalse);
    });
  });

  // ── getEntry ───────────────────────────────────────────────────────────────
  group('getEntry()', () {
    test('retourne une entrée existante avec preval correct', () async {
      final e = await repo.getEntry('chat');
      expect(e, isNotNull);
      expect(e!.mot, equals('chat'));
      expect(e.preval, equals(95.0));
    });

    test('retourne null pour un mot inexistant', () async {
      final e = await repo.getEntry('inexistant');
      expect(e, equals(null));
    });
  });

  // ── getWordFamily ──────────────────────────────────────────────────────────
  group('getWordFamily()', () {
    test('trouve manger + mangeable via racine "mang"', () async {
      final family = await repo.getWordFamily(morphoRoot: 'mang');
      expect(family.length, equals(2));
      final mots = family.map((e) => e.mot).toList();
      expect(mots, containsAll(['manger', 'mangeable']));
    });

    test('respecte islem = 1', () async {
      final family = await repo.getWordFamily(morphoRoot: 'mang');
      expect(family.every((e) => e.islem == 1), isTrue);
    });

    test('racine inexistante → liste vide', () async {
      final family = await repo.getWordFamily(morphoRoot: 'zzz');
      expect(family, isEmpty);
    });
  });

  // ── getOrthographicNeighbors ───────────────────────────────────────────────
  group('getOrthographicNeighbors()', () {
    test('même longueur, islem=1, mot lui-même exclu', () async {
      // table (5 lettres) → voisins valides : chien(5), verre(5)
      final neighbors = await repo.getOrthographicNeighbors(mot: 'table');
      for (final e in neighbors) {
        expect(e.mot.length, equals(5));
        expect(e.mot, isNot(equals('table')));
        expect(e.islem, equals(1));
      }
    });
  });

  // ── fetchBatch ─────────────────────────────────────────────────────────────
  group('fetchBatch()', () {
    test('retourne les entrées existantes, null pour les absents', () async {
      final batch = await repo.fetchBatch(['chat', 'chien', 'zzz']);
      expect(batch['chat'], isNotNull);
      expect(batch['chien'], isNotNull);
      expect(batch['zzz'], equals(null));
    });

    test('batch vide → map vide', () async {
      final batch = await repo.fetchBatch([]);
      expect(batch, isEmpty);
    });

    test('chats (islem=0) → null dans fetchBatch', () async {
      final batch = await repo.fetchBatch(['chats']);
      expect(batch['chats'], equals(null));
    });
  });
}

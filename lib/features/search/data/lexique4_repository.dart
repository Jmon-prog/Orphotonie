// ============================================================
// Fichier : lib/features/search/data/lexique4_repository.dart
// Description : Repository de recherche dans lexique4.db.
//               La base ne contient que les mots ayant une définition
//               (version allégée, 4 973 entrées). Le filtre islem = 1
//               est supprimé — la DB est pré-filtrée.
//               Utilise Lexique4Database.rawQuery() — aucun thread principal.
// ============================================================

import '../../../core/database/lexique4_database.dart';
import 'search_filters_model.dart';

/// Résultat paginé d'une recherche.
class SearchResult {
  const SearchResult({
    required this.entries,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<LexiqueEntry> entries;

  /// Nombre total de résultats (sans pagination).
  final int totalCount;

  final int page;
  final int pageSize;

  bool get hasMore => (page + 1) * pageSize < totalCount;
}

/// Repository principal pour la recherche dans lexique4.db.
/// Dépend de [Lexique4Database] injecté par le constructeur.
class Lexique4Repository {
  const Lexique4Repository(this._db);

  final Lexique4Database _db;

  // ---------------------------------------------------------------------------
  // Recherche filtrée principale
  // ---------------------------------------------------------------------------

  /// Recherche filtrée avec pagination.
  /// [filters] : ensemble de critères combinables.
  /// [restrictToWords] : si fourni, ne retourne que les mots de cet ensemble.
  /// Retourne un [SearchResult] avec le nombre total et la page courante.
  Future<SearchResult> search(
    SearchFilters filters, {
    Set<String>? restrictToWords,
  }) async {
    final query = filters.buildSql(restrictToWords: restrictToWords);
    final countQuery = filters.buildCountSql(restrictToWords: restrictToWords);

    // Les deux requêtes en parallèle
    final results = await Future.wait([
      _db.rawQuery(query.sql, query.args),
      _db.rawQuery(countQuery.sql, countQuery.args),
    ]);

    final rows = results[0];
    final countRow = results[1];

    final entries = rows.map(LexiqueEntry.fromRow).toList();
    final total = (countRow.first['cnt'] as num?)?.toInt() ?? 0;

    return SearchResult(
      entries: entries,
      totalCount: total,
      page: filters.page,
      pageSize: filters.pageSize,
    );
  }

  // ---------------------------------------------------------------------------
  // Famille de mots (même morphodecomp root)
  // ---------------------------------------------------------------------------

  /// Retourne jusqu'à [limit] mots de la même famille morphologique.
  /// La famille est déterminée à partir d'un fragment de [morphodecomp].
  Future<List<LexiqueEntry>> getWordFamily({
    required String morphoRoot,
    int limit = 8,
  }) async {
    final rows = await _db.rawQuery(
      '''
      SELECT mot, phono, phono_ipa, cgram, cgram_ortho,
             nbsyll, nblettres, nbphons, syllphono, cvortho,
             freqortho, cdortho, preval, freqlemme, freqmot,
             lemme, islem, genre, nombre, morphodecomp, nbhomoph
      FROM lexique4
      WHERE morphodecomp LIKE ?
      ORDER BY preval DESC NULLS LAST
      LIMIT ?
      ''',
      ['%$morphoRoot%', limit],
    );
    return rows.map(LexiqueEntry.fromRow).toList();
  }

  // ---------------------------------------------------------------------------
  // Mots voisins orthographiques (même longueur, 1 lettre différente)
  // ---------------------------------------------------------------------------

  /// Retourne des mots de longueur identique pouvant servir d'exercices
  /// de discrimination visuelle. Requête déclenchée à la demande seulement.
  Future<List<LexiqueEntry>> getOrthographicNeighbors({
    required String mot,
    int limit = 10,
  }) async {
    final len = mot.length;
    final rows = await _db.rawQuery(
      '''
      SELECT mot, phono, phono_ipa, cgram, cgram_ortho,
             nbsyll, nblettres, nbphons, syllphono, cvortho,
             freqortho, cdortho, preval, freqlemme, freqmot,
             lemme, islem, genre, nombre, morphodecomp, nbhomoph
      FROM lexique4
      WHERE nblettres = ?
        AND mot != ?
      ORDER BY preval DESC NULLS LAST
      LIMIT ?
      ''',
      [len, mot, limit],
    );
    return rows.map(LexiqueEntry.fromRow).toList();
  }

  // ---------------------------------------------------------------------------
  // Fiche détaillée enrichie (entrée unique)
  // ---------------------------------------------------------------------------

  /// Récupère une entrée complète par son mot.
  Future<LexiqueEntry?> getEntry(String mot) async {
    final rows = await _db.rawQuery(
      '''
      SELECT mot, phono, phono_ipa, cgram, cgram_ortho,
             nbsyll, nblettres, nbphons, syllphono, cvortho,
             freqortho, cdortho, preval, freqlemme, freqmot,
             lemme, islem, genre, nombre, morphodecomp, nbhomoph
      FROM lexique4
      WHERE mot = ?
      LIMIT 1
      ''',
      [mot],
    );
    if (rows.isEmpty) return null;
    return LexiqueEntry.fromRow(rows.first);
  }

  // ---------------------------------------------------------------------------
  // Ajout en lot dans un dictionnaire (coordonné avec WordsDao)
  // ---------------------------------------------------------------------------

  /// Prépare les métadonnées lexicales pour une liste de mots sélectionnés.
  /// Retourne la map mot → LexiqueEntry (null si absent de lexique4).
  Future<Map<String, LexiqueEntry?>> fetchBatch(List<String> mots) async {
    if (mots.isEmpty) return {};
    final placeholders = mots.map((_) => '?').join(', ');
    final rows = await _db.rawQuery(
      '''
      SELECT mot, phono, phono_ipa, cgram, cgram_ortho,
             nbsyll, nblettres, nbphons, syllphono, cvortho,
             freqortho, cdortho, preval, freqlemme, freqmot,
             lemme, islem, genre, nombre, morphodecomp, nbhomoph
      FROM lexique4
      WHERE mot IN ($placeholders)
      ''',
      mots,
    );
    final map = <String, LexiqueEntry?>{};
    for (final m in mots) {
      map[m] = null;
    }
    for (final row in rows) {
      final entry = LexiqueEntry.fromRow(row);
      map[entry.mot] = entry;
    }
    return map;
  }
}

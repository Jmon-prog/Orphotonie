// ============================================================
// Fichier : lib/core/database/definitions_database.dart
// Description : Accès en lecture seule à definitions.db.
//               3 725 entrées avec définitions et niveaux Dubois-Buyse (1-43).
//               Sur native : copiée depuis assets au 1er lancement.
//               Sur web : chargée en mémoire depuis les assets Flutter.
// ============================================================

import 'package:drift/drift.dart';

import 'connection/database_connection.dart';

/// Représente une entrée de definitions.db.
class DefinitionEntry {
  const DefinitionEntry({
    required this.mot,
    this.definition,
    this.defCroises,
    this.defFleches,
    this.niveauDubois,
  });

  factory DefinitionEntry.fromRow(Map<String, Object?> row) {
    return DefinitionEntry(
      mot: row['mot'] as String,
      definition: row['def_complete'] as String?,
      defCroises: row['def_croises'] as String?,
      defFleches: row['def_fleches'] as String?,
      niveauDubois: (row['niveau'] as num?)?.toInt(),
    );
  }

  final String mot;
  final String? definition;
  final String? defCroises;
  final String? defFleches;
  final int? niveauDubois; // 1 à 43
}

/// Classe d'accès en lecture seule à definitions.db.
class DefinitionsDatabase {
  DefinitionsDatabase._();

  static DefinitionsDatabase? _instance;
  static DatabaseConnection? _connection;

  static Future<DefinitionsDatabase> get instance async {
    _instance ??= DefinitionsDatabase._();
    return _instance!;
  }

  Future<DatabaseConnection> _getConnection() async {
    if (_connection != null) return _connection!;
    final conn = await openReadOnlyDb('definitions.db');
    await conn.executor.ensureOpen(_DefDbUser());
    _connection = conn;
    return _connection!;
  }

  Future<List<Map<String, Object?>>> _query(
    String sql,
    List<Object?> args,
  ) async {
    final conn = await _getConnection();
    return conn.runSelect(sql, args);
  }

  // ---------------------------------------------------------------------------
  // Requêtes publiques
  // ---------------------------------------------------------------------------

  /// Récupère la définition d'un mot exact (insensible à la casse). Retourne null si absent.
  Future<DefinitionEntry?> getDefinition(String mot) async {
    final rows = await _query(
      'SELECT mot, def_complete, def_croises, def_fleches, niveau FROM definitions WHERE LOWER(mot) = LOWER(?) LIMIT 1',
      [mot.trim()],
    );
    if (rows.isEmpty) return null;
    return DefinitionEntry.fromRow(rows.first);
  }

  /// Retourne tous les mots d'un niveau Dubois-Buyse donné.
  Future<List<DefinitionEntry>> getByLevel(int niveau) async {
    final rows = await _query(
      'SELECT mot, def_complete, def_croises, def_fleches, niveau FROM definitions WHERE niveau = ? ORDER BY mot',
      [niveau],
    );
    return rows.map(DefinitionEntry.fromRow).toList();
  }

  /// Retourne les mots d'un intervalle de niveaux Dubois-Buyse.
  Future<List<DefinitionEntry>> getByLevelRange(int min, int max) async {
    final rows = await _query(
      '''
      SELECT mot, def_complete, def_croises, def_fleches, niveau FROM definitions
      WHERE niveau BETWEEN ? AND ?
      ORDER BY niveau, mot
      ''',
      [min, max],
    );
    return rows.map(DefinitionEntry.fromRow).toList();
  }

  /// Recherche des mots par préfixe (insensible à la casse).
  Future<List<DefinitionEntry>> searchByPrefix(
    String query, {
    int limit = 50,
  }) async {
    final rows = await _query(
      '''
      SELECT * FROM definitions
      WHERE LOWER(mot) LIKE LOWER(?) || '%'
      ORDER BY mot
      LIMIT ?
      ''',
      [query.toLowerCase(), limit],
    );
    return rows.map(DefinitionEntry.fromRow).toList();
  }

  /// Retourne tous les mots présents dans definitions.db.
  Future<Set<String>> getAllWords() async {
    final rows = await _query('SELECT mot FROM definitions', []);
    return rows.map((r) => r['mot'] as String).toSet();
  }

  /// Ferme la connexion proprement.
  Future<void> close() async {
    await _connection?.executor.close();
    _connection = null;
    _instance = null;
  }
}

/// Implémentation minimale de [QueryExecutorUser] pour ouvrir
/// une base read-only sans passer par GeneratedDatabase.
class _DefDbUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {
    // Pas de migration — base read-only.
  }
}

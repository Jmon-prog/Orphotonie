// ============================================================
// Fichier : lib/core/database/lexique4_database.dart
// Description : Accès en lecture seule à lexique4.db (4 973 mots avec définition).
//               Base allégée — le filtre islem = 1 n'est plus nécessaire.
//               Sur native : copiée depuis assets au 1er lancement.
//               Sur web : chargée en mémoire depuis les assets Flutter.
// ============================================================

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'connection/database_connection.dart';

// ---------------------------------------------------------------------------
// Modèle de données (colonnes de lexique4.db)
// ---------------------------------------------------------------------------

/// Représente une ligne de lexique4.db.
/// Seules les colonnes utiles à l'application sont exposées.
class LexiqueEntry {
  const LexiqueEntry({
    required this.mot,
    this.phono,
    this.phonoIpa,
    this.cgram,
    this.cgramOrtho,
    this.nbsyll,
    this.nblettres,
    this.nbphons,
    this.syllphono,
    this.cvortho,
    this.freqortho,
    this.cdortho,
    this.freqlemme,
    this.freqmot,
    this.lemme,
    required this.islem,
    this.genre,
    this.nombre,
    this.morphodecomp,
    this.nbhomoph,
    this.preval,
  });

  factory LexiqueEntry.fromRow(Map<String, Object?> row) {
    return LexiqueEntry(
      mot: row['mot'] as String,
      phono: row['phono'] as String?,
      phonoIpa: row['phono_ipa'] as String?,
      cgram: row['cgram'] as String?,
      cgramOrtho: row['cgram_ortho'] as String?,
      nbsyll: (row['nbsyll'] as num?)?.toInt(),
      nblettres: (row['nblettres'] as num?)?.toInt(),
      nbphons: (row['nbphons'] as num?)?.toInt(),
      syllphono: row['syllphono'] as String?,
      cvortho: row['cvortho'] as String?,
      freqortho: (row['freqortho'] as num?)?.toDouble(),
      cdortho: (row['cdortho'] as num?)?.toDouble(),
      freqlemme: (row['freqlemme'] as num?)?.toDouble(),
      freqmot: (row['freqmot'] as num?)?.toDouble(),
      lemme: row['lemme'] as String?,
      islem: (row['islem'] as num?)?.toInt() ?? 1,
      genre: row['genre'] as String?,
      nombre: row['nombre'] as String?,
      morphodecomp: row['morphodecomp'] as String?,
      nbhomoph: (row['nbhomoph'] as num?)?.toInt(),
      preval: (row['preval'] as num?)?.toDouble(),
    );
  }

  final String mot;
  final String? phono;
  final String? phonoIpa;
  final String? cgram;
  final String? cgramOrtho;
  final int? nbsyll;
  final int? nblettres;
  final int? nbphons;
  final String? syllphono;
  final String? cvortho;
  final double? freqortho;
  final double? cdortho; // % documents (numérique)
  final double? freqlemme;
  final double? freqmot;
  final String? lemme;
  final int islem; // Toujours 1 dans nos requêtes
  final String? genre;
  final String? nombre;
  final String? morphodecomp;
  final int? nbhomoph;
  final double? preval; // % locuteurs connaissant ce mot (Lexique 4)
}

// ---------------------------------------------------------------------------
// Accès base de données
// ---------------------------------------------------------------------------

/// Classe d'accès en lecture seule à lexique4.db.
/// La base est pré-filtrée (uniquement les mots avec définition).
class Lexique4Database {
  Lexique4Database._() : _testConnection = null;

  /// Constructeur réservé aux tests unitaires.
  /// Permet d'injecter une connexion SQLite en mémoire sans accès fichier.
  @visibleForTesting
  Lexique4Database.forTesting(DatabaseConnection conn) : _testConnection = conn;

  static Lexique4Database? _instance;
  static DatabaseConnection? _connection;

  /// Connexion injectée pour les tests (null en production).
  final DatabaseConnection? _testConnection;

  static Future<Lexique4Database> get instance async {
    _instance ??= Lexique4Database._();
    return _instance!;
  }

  /// Ouvre (ou retourne) la connexion à lexique4.db.
  /// Sur native : lit depuis le répertoire documents.
  /// Sur web : charge depuis les assets Flutter en mémoire WASM.
  Future<DatabaseConnection> _getConnection() async {
    // Connexion de test injectée via le constructeur forTesting.
    if (_testConnection != null) return _testConnection;
    if (_connection != null) return _connection!;
    final conn = await openReadOnlyDb('lexique4.db');
    await conn.executor.ensureOpen(_LexiqueDatabaseUser());
    _connection = conn;
    return _connection!;
  }

  Future<List<Map<String, Object?>>> _query(
    String sql,
    List<Object?> args,
  ) async {
    final conn = await _getConnection();
    final result = await conn.runSelect(sql, args);
    return result;
  }

  /// Exécute une requête SQL arbitraire en lecture seule.
  /// Utilisé par [Lexique4Repository] pour les filtres combinés.
  Future<List<Map<String, Object?>>> rawQuery(
    String sql,
    List<Object?> args,
  ) =>
      _query(sql, args);

  // ---------------------------------------------------------------------------
  // Requêtes publiques
  // ---------------------------------------------------------------------------

  /// Recherche des mots par préfixe orthographique.
  /// [query] : début du mot (insensible à la casse via LOWER).
  /// [limit] : nombre maximum de résultats (défaut 50).
  Future<List<LexiqueEntry>> searchByPrefix(
    String query, {
    int limit = 50,
  }) async {
    final rows = await _query(
      '''
      SELECT * FROM lexique4
      WHERE LOWER(mot) LIKE LOWER(?) || '%'
      ORDER BY freqlemme DESC
      LIMIT ?
      ''',
      ['${query.toLowerCase()}%', limit],
    );
    return rows.map(LexiqueEntry.fromRow).toList();
  }

  /// Recherche un mot exact. Retourne null si absent.
  Future<LexiqueEntry?> getByMot(String mot) async {
    final rows = await _query(
      'SELECT * FROM lexique4 WHERE mot = ? LIMIT 1',
      [mot],
    );
    if (rows.isEmpty) return null;
    return LexiqueEntry.fromRow(rows.first);
  }

  /// Retourne des mots aléatoires filtrés par nombre de syllabes.
  /// Utile pour générer des listes de mots dans les jeux.
  Future<List<LexiqueEntry>> getRandomBySyllables({
    required int nbSyllabes,
    int limit = 20,
  }) async {
    final rows = await _query(
      '''
      SELECT * FROM lexique4
      WHERE nbsyll = ?
      ORDER BY RANDOM()
      LIMIT ?
      ''',
      [nbSyllabes, limit],
    );
    return rows.map(LexiqueEntry.fromRow).toList();
  }

  /// Recherche des mots par catégorie grammaticale et fréquence minimale.
  Future<List<LexiqueEntry>> getByCategory({
    required String cgram,
    double minFreq = 0,
    int limit = 50,
  }) async {
    final rows = await _query(
      '''
      SELECT * FROM lexique4
      WHERE cgram = ?
        AND freqlemme >= ?
      ORDER BY freqlemme DESC
      LIMIT ?
      ''',
      [cgram, minFreq, limit],
    );
    return rows.map(LexiqueEntry.fromRow).toList();
  }

  /// Retourne les valeurs `phono` (SAMPA) pour un ensemble de mots.
  /// Requête groupée par lots de 900 pour respecter la limite de variables SQLite.
  Future<List<String>> getPhonoForWords(Set<String> mots) async {
    if (mots.isEmpty) return [];
    final list = mots.toList();
    final results = <String>[];
    const batchSize = 900;
    for (var i = 0; i < list.length; i += batchSize) {
      final end = (i + batchSize).clamp(0, list.length);
      final batch = list.sublist(i, end);
      final placeholders = batch.map((_) => '?').join(', ');
      final rows = await rawQuery(
        'SELECT phono FROM lexique4 '
        'WHERE mot IN ($placeholders) AND phono IS NOT NULL',
        batch,
      );
      for (final row in rows) {
        final phono = row['phono'] as String?;
        if (phono != null) results.add(phono);
      }
    }
    return results;
  }

  /// Ferme la connexion proprement (appelé à la destruction de l'app).
  Future<void> close() async {
    await _connection?.executor.close();
    _connection = null;
    _instance = null;
  }
}

/// Implémentation minimale de [QueryExecutorUser] pour ouvrir
/// une base read-only sans passer par GeneratedDatabase.
class _LexiqueDatabaseUser extends QueryExecutorUser {
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

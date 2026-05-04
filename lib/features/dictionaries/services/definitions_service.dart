// ============================================================
// Fichier : lib/features/dictionaries/services/definitions_service.dart
// Description : Service de recherche dans definitions.db (read-only).
//               Fournit la définition complète, mots-croisés, mots-fléchés
//               et le niveau Dubois-Buyse pour un mot donné.
//               100% hors ligne. Connexion adaptée native/web automatiquement.
// ============================================================

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/connection/database_connection.dart';

/// Fournit le [DefinitionsService] via Riverpod.
/// Le service est initialisé de manière lazy (à la première utilisation).
final definitionsServiceProvider = Provider<DefinitionsService>(
  (_) => DefinitionsService(),
);

/// Modèle d'une entrée du dictionnaire de définitions.
class DefinitionEntry {
  const DefinitionEntry({
    required this.mot,
    required this.niveau,
    required this.categorie,
    this.defComplete,
    this.defCroises,
    this.defFleches,
  });

  /// Le mot de référence.
  final String mot;

  /// Niveau Dubois-Buyse (1–43).
  final int niveau;

  /// Catégorie grammaticale (ex : "nom féminin").
  final String categorie;

  /// Définition pédagogique complète.
  final String? defComplete;

  /// Définition courte pour mots-croisés.
  final String? defCroises;

  /// Définition latérale pour mots-fléchés.
  final String? defFleches;
}

/// Service d'accès en lecture seule à definitions.db.
class DefinitionsService {
  DatabaseConnection? _connection;

  /// Ouvre la connexion si ce n'est pas déjà fait (lazy).
  Future<DatabaseConnection> _getConnection() async {
    if (_connection != null) return _connection!;
    final conn = await openReadOnlyDb('definitions.db');
    await conn.executor.ensureOpen(_DefinitionsDatabaseUser());
    _connection = conn;
    return _connection!;
  }

  /// Cherche un mot dans definitions.db (insensible à la casse).
  /// Retourne [DefinitionEntry] si trouvé, null sinon.
  Future<DefinitionEntry?> findDefinition(String mot) async {
    try {
      final conn = await _getConnection();
      final rows = await conn.runSelect(
        'SELECT mot, niveau, categorie, def_complete, def_croises, def_fleches '
        'FROM definitions WHERE LOWER(mot) = LOWER(?) LIMIT 1',
        [mot.trim()],
      );
      if (rows.isEmpty) return null;
      final row = rows.first;
      return DefinitionEntry(
        mot: row['mot'] as String,
        niveau: (row['niveau'] as num).toInt(),
        categorie: row['categorie'] as String? ?? '',
        defComplete: row['def_complete'] as String?,
        defCroises: row['def_croises'] as String?,
        defFleches: row['def_fleches'] as String?,
      );
    } catch (_) {
      // Base absente au 1er lancement ou erreur de lecture → null
      return null;
    }
  }

  /// Ferme la connexion (à appeler en fin de vie de l'app).
  Future<void> close() async {
    await _connection?.executor.close();
    _connection = null;
  }

  /// Retourne l'ensemble des mots présents dans definitions.db
  /// ayant au moins une définition renseignée (def_complete, def_croises ou
  /// def_fleches non null et non vide).
  Future<Set<String>> getAllWords() async {
    try {
      final conn = await _getConnection();
      final rows = await conn.runSelect(
        '''
        SELECT LOWER(mot) AS mot FROM definitions
        WHERE (def_complete  IS NOT NULL AND TRIM(def_complete)  != '')
           OR (def_croises   IS NOT NULL AND TRIM(def_croises)   != '')
           OR (def_fleches   IS NOT NULL AND TRIM(def_fleches)   != '')
        ''',
        [],
      );
      return rows.map((r) => r['mot'] as String).toSet();
    } catch (_) {
      return {};
    }
  }
}

/// Implémentation minimale de [QueryExecutorUser] pour ouvrir
/// une base read-only sans passer par GeneratedDatabase.
class _DefinitionsDatabaseUser extends QueryExecutorUser {
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

// ============================================================
// Fichier : lib/core/database/dao/dictionary_assignments_dao.dart
// Description : DAO Drift pour les assignations dictionnaire ↔ enfant.
//               Permet de lier un dictionnaire praticien à un ou plusieurs
//               enfants sans changer le propriétaire du dictionnaire.
// ============================================================

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/dictionary_assignments_table.dart';
import '../tables/dictionaries_table.dart';
import '../tables/profiles_table.dart';

part 'dictionary_assignments_dao.g.dart';

@DriftAccessor(tables: [DictionaryAssignments, Dictionaries, Profiles])
class DictionaryAssignmentsDao extends DatabaseAccessor<AppDatabase>
    with _$DictionaryAssignmentsDaoMixin {
  DictionaryAssignmentsDao(super.db);

  // --- Lecture ---

  /// Flux réactif des IDs d'enfants assignés à un dictionnaire.
  Stream<List<int>> watchAssignedChildIds(int dictionaryId) {
    return (select(dictionaryAssignments)
          ..where((a) => a.dictionaryId.equals(dictionaryId)))
        .map((a) => a.childId)
        .watch();
  }

  /// Flux réactif du nombre d'enfants assignés à un dictionnaire.
  Stream<int> watchAssignmentCount(int dictionaryId) {
    return watchAssignedChildIds(dictionaryId).map((ids) => ids.length);
  }

  /// Flux réactif des dictionnaires assignés à un enfant (lecture seule).
  Stream<List<Dictionary>> watchDictionariesForChild(int childId) {
    final query = select(dictionaries).join([
      innerJoin(
        dictionaryAssignments,
        dictionaryAssignments.dictionaryId.equalsExp(dictionaries.id),
      ),
    ])
      ..where(
        dictionaryAssignments.childId.equals(childId) &
            dictionaries.active.equals(true),
      )
      ..orderBy([OrderingTerm.asc(dictionaries.nom)]);
    return query.map((row) => row.readTable(dictionaries)).watch();
  }

  /// Retourne vrai si un enfant est déjà assigné à ce dictionnaire.
  Future<bool> isAssigned(int dictionaryId, int childId) async {
    final row = await (select(dictionaryAssignments)
          ..where(
            (a) =>
                a.dictionaryId.equals(dictionaryId) & a.childId.equals(childId),
          ))
        .getSingleOrNull();
    return row != null;
  }

  // --- Écriture ---

  /// Assigne un dictionnaire à un enfant.
  /// Ignore silencieusement si l'assignation existe déjà (UNIQUE).
  Future<void> assignDictionary(int dictionaryId, int childId) async {
    await into(dictionaryAssignments).insertOnConflictUpdate(
      DictionaryAssignmentsCompanion.insert(
        dictionaryId: dictionaryId,
        childId: childId,
      ),
    );
  }

  /// Retire l'assignation d'un dictionnaire pour un enfant.
  Future<void> unassignDictionary(int dictionaryId, int childId) async {
    await (delete(dictionaryAssignments)
          ..where(
            (a) =>
                a.dictionaryId.equals(dictionaryId) & a.childId.equals(childId),
          ))
        .go();
  }

  /// Supprime toutes les assignations d'un dictionnaire (utile avant suppression).
  Future<void> deleteAllAssignmentsForDictionary(int dictionaryId) async {
    await (delete(dictionaryAssignments)
          ..where((a) => a.dictionaryId.equals(dictionaryId)))
        .go();
  }
}

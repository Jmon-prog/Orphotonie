// ============================================================
// Fichier : lib/core/database/tables/dictionary_assignments_table.dart
// Description : Table de liaison dictionnaire ↔ enfant.
//               Un dictionnaire (propriété du praticien) peut être
//               assigné à plusieurs enfants sans changer de propriétaire.
// ============================================================

import 'package:drift/drift.dart';
import 'dictionaries_table.dart';
import 'profiles_table.dart';

/// Table de liaison : un dictionnaire assigné à un enfant.
/// Contrainte UNIQUE sur (dictionary_id, child_id) — un enfant ne peut pas
/// être assigné deux fois au même dictionnaire.
class DictionaryAssignments extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Dictionnaire assigné (propriété du praticien).
  IntColumn get dictionaryId => integer().references(Dictionaries, #id)();

  /// Enfant bénéficiaire de l'assignation.
  IntColumn get childId => integer().references(Profiles, #id)();

  /// Date d'assignation.
  DateTimeColumn get assignedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {dictionaryId, childId},
      ];
}

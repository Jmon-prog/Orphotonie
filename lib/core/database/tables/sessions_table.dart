// ============================================================
// Fichier : lib/core/database/tables/sessions_table.dart
// Description : Table Drift des sessions de jeu.
//               Une session = un type de jeu joué sur un dictionnaire.
// ============================================================

import 'package:drift/drift.dart';
import 'profiles_table.dart';
import 'dictionaries_table.dart';

/// Table des sessions de jeu.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Profil qui a joué la session.
  IntColumn get profileId => integer().references(Profiles, #id)();

  /// Dictionnaire utilisé pendant la session.
  IntColumn get dictionaryId => integer().references(Dictionaries, #id)();

  /// Type d'activité : 'memoire' | 'puzzle' | 'reconnaissance' | 'dictee' | 'associations'.
  TextColumn get activityType => text()();

  /// Horodatage de début de session.
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();

  /// Horodatage de fin (null si session interrompue).
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// Score total de la session (0-100).
  IntColumn get score => integer().withDefault(const Constant(0))();
}

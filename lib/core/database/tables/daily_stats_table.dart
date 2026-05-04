// ============================================================
// Fichier : lib/core/database/tables/daily_stats_table.dart
// Description : Table Drift des statistiques quotidiennes par profil.
//               Utilisée pour la heatmap de progression.
// ============================================================

import 'package:drift/drift.dart';
import 'profiles_table.dart';

/// Table des statistiques quotidiennes — une ligne par (profil × jour).
class DailyStats extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Profil concerné.
  IntColumn get profileId => integer().references(Profiles, #id)();

  /// Date du jour (stockée comme DateTime à minuit UTC).
  DateTimeColumn get date => dateTime()();

  /// Nombre de mots présentés dans la journée.
  IntColumn get wordsSeen => integer().withDefault(const Constant(0))();

  /// Nombre de mots réussis dans la journée.
  IntColumn get wordsSuccess => integer().withDefault(const Constant(0))();

  /// Temps de jeu total en minutes dans la journée.
  IntColumn get minutesPlayed => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, date},
      ];
}

// ============================================================
// Fichier : lib/core/database/tables/word_mastery_table.dart
// Description : Table Drift de la maîtrise de chaque mot par profil.
//               Implémente le système Leitner (boîtes 1-5) + SRS.
// ============================================================

import 'package:drift/drift.dart';
import 'profiles_table.dart';
import 'words_table.dart';

/// Table de maîtrise — une ligne par (profil × mot).
class WordMastery extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Profil concerné.
  IntColumn get profileId => integer().references(Profiles, #id)();

  /// Mot concerné.
  IntColumn get wordId => integer().references(Words, #id)();

  /// Nombre total de présentations du mot.
  IntColumn get nbSeen => integer().withDefault(const Constant(0))();

  /// Nombre de réussites totales.
  IntColumn get nbSuccess => integer().withDefault(const Constant(0))();

  /// Nombre de réussites du premier coup (sans aide).
  IntColumn get nbFirstTry => integer().withDefault(const Constant(0))();

  /// Réussites consécutives en cours.
  IntColumn get consecutiveOk => integer().withDefault(const Constant(0))();

  /// Boîte Leitner actuelle (1 = nouveau, 5 = maîtrisé).
  IntColumn get leitnerBox => integer().withDefault(const Constant(1))();

  /// Prochaine date de révision calculée par le SRS.
  DateTimeColumn get nextReview => dateTime().nullable()();

  /// Dernière date de présentation.
  DateTimeColumn get lastSeen => dateTime().nullable()();

  /// Niveau de maîtrise calculé : 0 (non vu) → 4 (maîtrisé).
  IntColumn get masteryLevel => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, wordId},
      ];
}

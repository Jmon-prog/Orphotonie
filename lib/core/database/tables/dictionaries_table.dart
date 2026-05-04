// ============================================================
// Fichier : lib/core/database/tables/dictionaries_table.dart
// Description : Table Drift des dictionnaires de mots ciblés.
//               Chaque dictionnaire appartient à un profil enfant.
// ============================================================

import 'package:drift/drift.dart';
import 'profiles_table.dart';

/// Table des dictionnaires personnalisés.
class Dictionaries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Profil propriétaire du dictionnaire (enfant ou praticien).
  IntColumn get profileId => integer().references(Profiles, #id)();

  /// Nom du dictionnaire (ex : "Sons [f] et [v]").
  TextColumn get nom => text().withLength(min: 1, max: 100)();

  /// Description libre du dictionnaire.
  TextColumn get description => text().nullable()();

  /// Couleur hexadécimale de l'étiquette (#RRGGBB).
  TextColumn get couleur => text().withDefault(const Constant('#6A5AE0'))();

  /// Icône Material (nom de l'icône en chaîne).
  TextColumn get icon => text().withDefault(const Constant('book'))();

  /// Dictionnaire actif ou archivé.
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  /// Date de création.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

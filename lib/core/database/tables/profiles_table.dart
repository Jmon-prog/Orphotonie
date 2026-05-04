// ============================================================
// Fichier : lib/core/database/tables/profiles_table.dart
// Description : Table Drift des profils utilisateurs (praticiens et enfants).
//               Chaque profil peut avoir un PIN haché (praticien uniquement).
// ============================================================

import 'package:drift/drift.dart';

/// Table des profils — praticiens et enfants dans une même table.
/// Le champ [type] discrimine ('praticien' | 'enfant').
class Profiles extends Table {
  /// Identifiant auto-incrémenté.
  IntColumn get id => integer().autoIncrement()();

  /// Prénom affiché dans l'UI.
  TextColumn get prenom => text().withLength(min: 1, max: 100)();

  /// Nom de famille (optionnel — enfant souvent identifié par prénom seul).
  TextColumn get nom => text().withLength(min: 1, max: 100).nullable()();

  /// Chemin local de l'avatar (image choisie depuis la galerie, pas de réseau).
  TextColumn get avatarPath => text().nullable()();

  /// Type de profil : 'praticien' ou 'enfant'.
  TextColumn get type => text().withDefault(const Constant('enfant'))();

  /// Id du praticien parent (null si profil praticien).
  IntColumn get parentId => integer().nullable()();

  /// Hash SHA-256 du PIN (praticien uniquement). Null = pas de PIN.
  TextColumn get pinHash => text().nullable()();

  /// Autorise le mode Découverte (sélection libre par niveau Dubois-Buyse).
  /// Activé par défaut — le praticien peut le désactiver profil par profil.
  BoolColumn get allowDiscoveryMode =>
      boolean().withDefault(const Constant(true))();

  /// Date de création du profil.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

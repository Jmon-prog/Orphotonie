// ============================================================
// Fichier : lib/core/database/tables/words_table.dart
// Description : Table Drift des mots d'un dictionnaire.
//               Stocke le mot, les définitions, les médias locaux et les tags.
//               Le champ [mot] sert de référence vers lexique4.db.
// ============================================================

import 'package:drift/drift.dart';
import 'dictionaries_table.dart';

/// Table des mots d'un dictionnaire ciblé.
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Dictionnaire auquel appartient ce mot.
  IntColumn get dictionaryId => integer().references(Dictionaries, #id)();

  /// Le mot orthographié (clé de référence vers lexique4.db).
  TextColumn get mot => text()();

  /// Définition courante (saisie manuelle ou issue de definitions.db).
  TextColumn get definition => text().nullable()();

  /// Définition en mots-croisés (courte, issue de definitions.db si disponible).
  TextColumn get defCroises => text().nullable()();

  /// Définition en mots-fléchés (issue de definitions.db si disponible).
  TextColumn get defFleches => text().nullable()();

  /// Chemin local de l'image associée (sélectionnée depuis la galerie).
  TextColumn get imagePath => text().nullable()();

  /// Chemin local de l'audio enregistré pour ce mot.
  TextColumn get audioPath => text().nullable()();

  /// Tags en JSON (ex : ["animal","maison"]). Utilisé pour filtrer en jeu.
  TextColumn get tags => text().withDefault(const Constant('[]'))();

  /// Niveau de difficulté manuel : 1 (facile) → 3 (difficile).
  IntColumn get difficulty => integer().withDefault(const Constant(1))();

  /// Date d'ajout au dictionnaire.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

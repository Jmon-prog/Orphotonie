// ============================================================
// Fichier : lib/core/database/tables/word_attempts_table.dart
// Description : Table Drift des tentatives par mot dans une session.
//               Permet l'analyse fine des erreurs.
// ============================================================

import 'package:drift/drift.dart';
import 'sessions_table.dart';
import 'words_table.dart';

/// Table des tentatives individuelles — une ligne par (session × mot).
class WordAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Session parente.
  IntColumn get sessionId => integer().references(Sessions, #id)();

  /// Mot tenté.
  IntColumn get wordId => integer().references(Words, #id)();

  /// Résultat : vrai si réussi.
  BoolColumn get success => boolean().withDefault(const Constant(false))();

  /// Réussite du premier coup (sans aide ni 2ème tentative).
  BoolColumn get firstTry => boolean().withDefault(const Constant(false))();

  /// Indice utilisé pendant la tentative.
  BoolColumn get hintUsed => boolean().withDefault(const Constant(false))();

  /// Durée de la tentative en millisecondes.
  IntColumn get durationMs => integer().withDefault(const Constant(0))();

  /// Lettres erronées en JSON (ex : ["a","e"]) pour analyse phonologique.
  TextColumn get errorLetters => text().withDefault(const Constant('[]'))();
}

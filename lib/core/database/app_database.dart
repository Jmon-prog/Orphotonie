// ============================================================
// Fichier : lib/core/database/app_database.dart
// Description : Base de donnees utilisateur (app.db) avec Drift.
//               Contient les 9 tables de donnees utilisateur.
//               Lecture/ecriture  100% hors ligne.
// ============================================================

import 'package:drift/drift.dart';

import 'connection/database_connection.dart';

import 'tables/profiles_table.dart';
import 'tables/dictionaries_table.dart';
import 'tables/dictionary_assignments_table.dart';
import 'tables/words_table.dart';
import 'tables/word_mastery_table.dart';
import 'tables/sessions_table.dart';
import 'tables/word_attempts_table.dart';
import 'tables/daily_stats_table.dart';
import 'tables/app_settings_table.dart';
import 'dao/profiles_dao.dart';
import 'dao/dictionaries_dao.dart';
import 'dao/dictionary_assignments_dao.dart';
import 'dao/words_dao.dart';
import 'dao/stats_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Dictionaries,
    DictionaryAssignments,
    Words,
    WordMastery,
    Sessions,
    WordAttempts,
    DailyStats,
    AppSettings,
  ],
  daos: [
    ProfilesDao,
    DictionariesDao,
    DictionaryAssignmentsDao,
    WordsDao,
    StatsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur pour les tests unitaires — base en mémoire, jamais de fichier.
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Migration v1 -> v2 : ajout colonne onboarding_done
          if (from < 2) {
            await m.addColumn(appSettings, appSettings.onboardingDone);
          }
          // Migration v2 -> v3 : ajout colonnes TTS (tts_rate, tts_volume)
          if (from < 3) {
            await m.addColumn(appSettings, appSettings.ttsRate);
            await m.addColumn(appSettings, appSettings.ttsVolume);
          }
          // Migration v3 -> v4 : ajout thème enfant
          if (from < 4) {
            await m.addColumn(appSettings, appSettings.childThemeName);
          }
          // Migration v4 -> v5 : ajout parentId dans Profiles
          if (from < 5) {
            await m.addColumn(profiles, profiles.parentId);
          }
          // Migration v5 -> v6 : introduction de dictionary_assignments.
          // Les dictionnaires appartenant à un enfant (profileId = enfant) sont
          // migrés : le profileId passe au praticien parent, et une ligne
          // d'assignation est créée dans la nouvelle table.
          if (from < 6) {
            await m.createTable(dictionaryAssignments);
            // Créer les assignations pour les dictionnaires enfant existants
            await customStatement('''
              INSERT OR IGNORE INTO dictionary_assignments (dictionary_id, child_id, assigned_at)
              SELECT d.id, d.profile_id, d.created_at
              FROM dictionaries d
              JOIN profiles p ON p.id = d.profile_id
              WHERE p.type = 'enfant'
            ''');
            // Réattribuer ces dictionnaires au praticien parent
            await customStatement('''
              UPDATE dictionaries
              SET profile_id = (
                SELECT p.parent_id
                FROM profiles p
                WHERE p.id = dictionaries.profile_id
                  AND p.type = 'enfant'
                  AND p.parent_id IS NOT NULL
              )
              WHERE profile_id IN (
                SELECT id FROM profiles WHERE type = 'enfant'
              )
            ''');
          }
          // Migration v6 -> v7 : ajout colonnes d'accessibilité
          if (from < 7) {
            await m.addColumn(appSettings, appSettings.dyslexicFont);
            await m.addColumn(appSettings, appSettings.ttsRate);
            await m.addColumn(appSettings, appSettings.ttsVolume);
            await m.addColumn(appSettings, appSettings.childThemeName);
            await m.addColumn(appSettings, appSettings.highContrast);
            await m.addColumn(appSettings, appSettings.colorBlindMode);
            await m.addColumn(appSettings, appSettings.reduceAnimations);
            await m.addColumn(appSettings, appSettings.largeTargets);
            await m.addColumn(appSettings, appSettings.hapticFeedback);
            await m.addColumn(appSettings, appSettings.textSpacing);
            await m.addColumn(appSettings, appSettings.showCaptions);
          }
          // Migration v7 -> v8 : ajout allowDiscoveryMode dans Profiles
          if (from < 8) {
            await customStatement(
              'ALTER TABLE profiles ADD COLUMN allow_discovery_mode INTEGER NOT NULL DEFAULT 1',
            );
          }
          // Migration v8 -> v9 : ajout archivedAt dans Profiles
          if (from < 9) {
            await m.addColumn(profiles, profiles.archivedAt);
          }
        },
        beforeOpen: (details) async {
          // Active les foreign keys SQLite (désactivées par défaut)
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Ouvre la connexion SQLite vers app.db.
/// Native : fichier dans le répertoire documents.
/// Web : persistance via IndexedDB (WASM).
LazyDatabase _openConnection() {
  return openAppDb();
}

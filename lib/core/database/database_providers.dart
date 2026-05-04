// ============================================================
// Fichier : lib/core/database/database_providers.dart
// Description : Providers Riverpod pour les 3 bases de données.
//               keepAlive = true — les instances vivent toute la durée de l'app.
//               100% hors ligne.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'lexique4_database.dart';
import 'definitions_database.dart';

// ---------------------------------------------------------------------------
// app.db — base utilisateur (lecture/écriture)
// ---------------------------------------------------------------------------

/// Provider singleton de la base utilisateur Drift (app.db).
/// Fermée automatiquement si le provider est détruit (dispose).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// DAOs exposés comme providers pour injection dans les features
final profilesDaoProvider = Provider(
  (ref) => ref.watch(appDatabaseProvider).profilesDao,
);
final dictionariesDaoProvider = Provider(
  (ref) => ref.watch(appDatabaseProvider).dictionariesDao,
);
final dictionaryAssignmentsDaoProvider = Provider(
  (ref) => ref.watch(appDatabaseProvider).dictionaryAssignmentsDao,
);
final wordsDaoProvider = Provider(
  (ref) => ref.watch(appDatabaseProvider).wordsDao,
);
final statsDaoProvider = Provider(
  (ref) => ref.watch(appDatabaseProvider).statsDao,
);

// ---------------------------------------------------------------------------
// Stream réactif des mots déjà présents dans un dictionnaire (Set<String>)
// Utilisé dans la recherche pour afficher le retour visuel "déjà ajouté".
// ---------------------------------------------------------------------------

/// Retourne en temps réel l'ensemble des orthographes déjà dans le dictionnaire [id].
final wordsInDictionaryProvider =
    StreamProvider.family<Set<String>, int>((ref, id) {
  return ref.watch(wordsDaoProvider).watchWordsForDictionary(id).map(
        (list) => list.map((w) => w.mot).toSet(),
      );
});

// ---------------------------------------------------------------------------
// lexique4.db — lecture seule
// ---------------------------------------------------------------------------

/// Provider asynchrone de Lexique 4 (189 863 mots, read-only).
final lexique4Provider = FutureProvider<Lexique4Database>((ref) async {
  final db = await Lexique4Database.instance;
  ref.onDispose(db.close);
  return db;
});

// ---------------------------------------------------------------------------
// definitions.db — lecture seule
// ---------------------------------------------------------------------------

/// Provider asynchrone des définitions Dubois-Buyse (3 726 entrées, read-only).
final definitionsProvider = FutureProvider<DefinitionsDatabase>((ref) async {
  final db = await DefinitionsDatabase.instance;
  ref.onDispose(db.close);
  return db;
});

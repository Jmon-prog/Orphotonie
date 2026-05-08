// ============================================================
// Fichier : lib/core/database/dao/words_dao.dart
// Description : DAO Drift pour les mots d'un dictionnaire.
//               CRUD + sélection SRS (Leitner) pour les sessions de jeu.
// ============================================================

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/words_table.dart';
import '../tables/word_mastery_table.dart';

part 'words_dao.g.dart';

@DriftAccessor(tables: [Words, WordMastery])
class WordsDao extends DatabaseAccessor<AppDatabase> with _$WordsDaoMixin {
  WordsDao(super.db);

  // --- Lecture ---

  /// Flux réactif de tous les mots d'un dictionnaire.
  Stream<List<Word>> watchWordsForDictionary(int dictionaryId) => (select(words)
        ..where((w) => w.dictionaryId.equals(dictionaryId))
        ..orderBy([(w) => OrderingTerm.asc(w.mot)]))
      .watch();

  /// Récupère un mot par identifiant.
  Future<Word?> getWordById(int id) =>
      (select(words)..where((w) => w.id.equals(id))).getSingleOrNull();

  /// Récupère un mot par orthographe dans un dictionnaire.
  Future<Word?> getWordByMot(int dictionaryId, String mot) => (select(words)
        ..where(
          (w) => w.dictionaryId.equals(dictionaryId) & w.mot.equals(mot),
        ))
      .getSingleOrNull();

  // --- Sélection SRS (Leitner) pour une session de jeu ---

  /// Sélectionne [limit] mots prioritaires selon le SRS.
  /// Ordre : révision en retard → boîte 1 (nouveaux) → aléatoire.
  Future<List<Word>> selectWordsForSession({
    required int dictionaryId,
    required int profileId,
    required int limit,
  }) async {
    // Requête SQL brute pour le tri SRS multi-critères
    final result = await customSelect(
      '''
      SELECT w.*
      FROM words w
      LEFT JOIN word_mastery wm
             ON wm.word_id = w.id
            AND wm.profile_id = ?
      WHERE w.dictionary_id = ?
      ORDER BY
        CASE WHEN wm.next_review <= datetime('now') THEN 0 ELSE 1 END,
        CASE WHEN COALESCE(wm.leitner_box, 1) = 1 THEN 0 ELSE 1 END,
        RANDOM()
      LIMIT ?
      ''',
      variables: [
        Variable.withInt(profileId),
        Variable.withInt(dictionaryId),
        Variable.withInt(limit),
      ],
      readsFrom: {words, wordMastery},
    ).get();

    return Future.wait(result.map((row) => words.mapFromRow(row)));
  }

  // --- Écriture ---

  /// Insère un nouveau mot. Retourne son identifiant généré.
  Future<int> insertWord(WordsCompanion entry) => into(words).insert(entry);

  /// Met à jour un mot existant.
  Future<bool> updateWord(WordsCompanion entry) => update(words).replace(entry);

  /// Supprime un mot par identifiant.
  Future<int> deleteWord(int id) =>
      (delete(words)..where((w) => w.id.equals(id))).go();

  // --- Maîtrise (SRS) ---

  /// Récupère la maîtrise d'un mot pour un profil. Null si jamais vu.
  Future<WordMasteryData?> getMastery(int wordId, int profileId) =>
      (select(wordMastery)
            ..where(
              (wm) => wm.wordId.equals(wordId) & wm.profileId.equals(profileId),
            ))
          .getSingleOrNull();

  /// Insère ou met à jour la maîtrise d'un mot (upsert).
  Future<void> upsertMastery(WordMasteryCompanion entry) async {
    await into(wordMastery).insertOnConflictUpdate(entry);
  }

  /// Réinitialise la progression Leitner d'un profil :
  /// supprime toutes les entrées WordMastery pour remettre les mots en boîte 1.
  Future<int> resetProgressionForProfile(int profileId) =>
      (delete(wordMastery)..where((wm) => wm.profileId.equals(profileId))).go();
}

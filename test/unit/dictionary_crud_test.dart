// ============================================================
// Fichier : test/unit/dictionary_crud_test.dart
// Description : Tests unitaires du CRUD dictionnaires et mots (app.db).
//               Base en mémoire Drift — aucun accès disque, aucun réseau.
// ============================================================

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/core/database/app_database.dart';

AppDatabase _inMemoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;

  setUp(() => db = _inMemoryDb());
  tearDown(() => db.close());

  // -------------------------------------------------------------------------
  // Helper : crée un profil praticien et retourne son id
  // -------------------------------------------------------------------------
  Future<int> createPraticien() => db.profilesDao.insertProfile(
        const ProfilesCompanion(
          prenom: Value('Sophie'),
          type: Value('praticien'),
        ),
      );

  // -------------------------------------------------------------------------
  // DictionariesDao
  // -------------------------------------------------------------------------
  group('DictionariesDao', () {
    test('crée un dictionnaire et le retrouve', () async {
      final pid = await createPraticien();
      final id = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(pid),
          nom: const Value('Sons [f]'),
        ),
      );
      expect(id, isPositive);

      final dic = await db.dictionariesDao.getDictionaryById(id);
      expect(dic, isNotNull);
      expect(dic!.nom, equals('Sons [f]'));
      expect(dic.profileId, equals(pid));
      expect(dic.active, isTrue);
    });

    test('watchDictionariesForProfile — stream réactif', () async {
      final pid = await createPraticien();

      // Flux initialement vide
      final stream = db.dictionariesDao.watchDictionariesForProfile(pid);
      expect(await stream.first, isEmpty);

      // Insertion → stream se met à jour
      await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(pid),
          nom: const Value('Animaux'),
        ),
      );
      final list = await stream.first;
      expect(list, hasLength(1));
      expect(list.first.nom, equals('Animaux'));
    });

    test('met à jour un dictionnaire', () async {
      final pid = await createPraticien();
      final id = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(pid),
          nom: const Value('Initial'),
        ),
      );
      final dic = await db.dictionariesDao.getDictionaryById(id);
      await db.dictionariesDao.updateDictionary(
        DictionariesCompanion(
          id: Value(dic!.id),
          profileId: Value(pid),
          nom: const Value('Modifié'),
          couleur: const Value('#FF5733'),
        ),
      );
      final updated = await db.dictionariesDao.getDictionaryById(id);
      expect(updated!.nom, equals('Modifié'));
      expect(updated.couleur, equals('#FF5733'));
    });

    test('archive un dictionnaire (active = false)', () async {
      final pid = await createPraticien();
      final id = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(pid),
          nom: const Value('À archiver'),
        ),
      );
      await db.dictionariesDao.archiveDictionary(id);

      // watchDictionariesForProfile ne retourne PAS les dictionnaires archivés
      final stream = db.dictionariesDao.watchDictionariesForProfile(pid);
      expect(await stream.first, isEmpty);

      // Mais getDictionaryById le retrouve quand même
      final dic = await db.dictionariesDao.getDictionaryById(id);
      expect(dic!.active, isFalse);
    });

    test('supprime un dictionnaire', () async {
      final pid = await createPraticien();
      final id = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(pid),
          nom: const Value('À supprimer'),
        ),
      );
      await db.dictionariesDao.deleteDictionary(id);
      final dic = await db.dictionariesDao.getDictionaryById(id);
      expect(dic, isNull);
    });

    test('watchDictionary émet null après suppression', () async {
      final pid = await createPraticien();
      final id = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(pid),
          nom: const Value('Test'),
        ),
      );

      final stream = db.dictionariesDao.watchDictionary(id);
      // Présent d'abord
      expect((await stream.first)?.id, equals(id));

      // Suppression
      await db.dictionariesDao.deleteDictionary(id);
      expect(await stream.first, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // WordsDao
  // -------------------------------------------------------------------------
  group('WordsDao', () {
    late int dicId;
    late int profId;

    setUp(() async {
      profId = await createPraticien();
      dicId = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(profId),
          nom: const Value('Test Dict'),
        ),
      );
    });

    test('insère un mot et le retrouve', () async {
      final id = await db.wordsDao.insertWord(
        WordsCompanion(
          dictionaryId: Value(dicId),
          mot: const Value('papillon'),
          definition: const Value('Un insecte aux ailes colorées'),
          difficulty: const Value(2),
        ),
      );
      expect(id, isPositive);

      final word = await db.wordsDao.getWordById(id);
      expect(word, isNotNull);
      expect(word!.mot, equals('papillon'));
      expect(word.difficulty, equals(2));
    });

    test('watchWordsForDictionary — stream réactif', () async {
      final stream = db.wordsDao.watchWordsForDictionary(dicId);
      expect(await stream.first, isEmpty);

      await db.wordsDao.insertWord(
        WordsCompanion(
          dictionaryId: Value(dicId),
          mot: const Value('chat'),
        ),
      );
      final words = await stream.first;
      expect(words, hasLength(1));
      expect(words.first.mot, equals('chat'));
    });

    test('met à jour un mot', () async {
      final id = await db.wordsDao.insertWord(
        WordsCompanion(
          dictionaryId: Value(dicId),
          mot: const Value('chien'),
        ),
      );
      await db.wordsDao.updateWord(
        WordsCompanion(
          id: Value(id),
          dictionaryId: Value(dicId),
          mot: const Value('chien'),
          definition: const Value('Animal domestique fidèle'),
          difficulty: const Value(1),
        ),
      );
      final updated = await db.wordsDao.getWordById(id);
      expect(updated!.definition, equals('Animal domestique fidèle'));
    });

    test('supprime un mot', () async {
      final id = await db.wordsDao.insertWord(
        WordsCompanion(
          dictionaryId: Value(dicId),
          mot: const Value('vache'),
        ),
      );
      await db.wordsDao.deleteWord(id);
      expect(await db.wordsDao.getWordById(id), isNull);
    });

    test('getWordByMot retourne null si absent', () async {
      final result = await db.wordsDao.getWordByMot(dicId, 'inexistant');
      expect(result, isNull);
    });

    test('insertion de plusieurs mots — stream retourne tous les mots',
        () async {
      const mots = ['zèbre', 'âne', 'mouton'];
      for (final m in mots) {
        await db.wordsDao.insertWord(
          WordsCompanion(dictionaryId: Value(dicId), mot: Value(m)),
        );
      }

      final words = await db.wordsDao.watchWordsForDictionary(dicId).first;
      // Tous les mots sont présents (l'ordre dépend de la collation SQLite)
      expect(words, hasLength(3));
      expect(words.map((w) => w.mot).toSet(), containsAll(mots));
    });
  });
}

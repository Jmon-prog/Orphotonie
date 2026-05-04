// ============================================================
// Fichier : test/unit/database_test.dart
// Description : Tests unitaires du schéma Drift (app.db).
//               Utilise une base en mémoire pour éviter tout accès disque.
//               100% hors ligne — aucun réseau, aucune dépendance externe.
// ============================================================

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:orphotonie/core/database/app_database.dart';

/// Crée une base en mémoire pour les tests (jamais de fichier disque).
AppDatabase _inMemoryDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = _inMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  // -------------------------------------------------------------------------
  // Profils
  // -------------------------------------------------------------------------
  group('ProfilesDao', () {
    test('insère et retrouve un profil praticien', () async {
      final id = await db.profilesDao.insertProfile(
        const ProfilesCompanion(
          prenom: Value('Marie'),
          nom: Value('Dupont'),
          type: Value('praticien'),
        ),
      );
      expect(id, isPositive);

      final profile = await db.profilesDao.getProfileById(id);
      expect(profile, isNotNull);
      expect(profile!.prenom, equals('Marie'));
      expect(profile.type, equals('praticien'));
    });

    test('met à jour le hash PIN d\'un profil', () async {
      final id = await db.profilesDao.insertProfile(
        const ProfilesCompanion(
          prenom: Value('Jean'),
          type: Value('praticien'),
        ),
      );

      await db.profilesDao.setPinHash(id, 'abc123hash');
      final hash = await db.profilesDao.getPinHash(id);
      expect(hash, equals('abc123hash'));
    });

    test('supprime un profil', () async {
      final id = await db.profilesDao.insertProfile(
        const ProfilesCompanion(prenom: Value('Test')),
      );
      final deleted = await db.profilesDao.deleteProfile(id);
      expect(deleted, equals(1));

      final profile = await db.profilesDao.getProfileById(id);
      expect(profile, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Dictionnaires
  // -------------------------------------------------------------------------
  group('DictionariesDao', () {
    late int profileId;

    setUp(() async {
      profileId = await db.profilesDao.insertProfile(
        const ProfilesCompanion(prenom: Value('Enfant Test')),
      );
    });

    test('insère et retrouve un dictionnaire', () async {
      final id = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(profileId),
          nom: const Value('Sons [f] et [v]'),
        ),
      );
      expect(id, isPositive);

      final dict = await db.dictionariesDao.getDictionaryById(id);
      expect(dict, isNotNull);
      expect(dict!.nom, equals('Sons [f] et [v]'));
      expect(dict.active, isTrue);
    });

    test('archive un dictionnaire', () async {
      final id = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(profileId),
          nom: const Value('À archiver'),
        ),
      );
      await db.dictionariesDao.archiveDictionary(id);

      final dict = await db.dictionariesDao.getDictionaryById(id);
      expect(dict!.active, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Mots
  // -------------------------------------------------------------------------
  group('WordsDao', () {
    late int profileId;
    late int dictId;

    setUp(() async {
      profileId = await db.profilesDao.insertProfile(
        const ProfilesCompanion(prenom: Value('Enfant Jeu')),
      );
      dictId = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(profileId),
          nom: const Value('Dictionnaire Jeu'),
        ),
      );
    });

    test('insère et retrouve un mot par orthographe', () async {
      await db.wordsDao.insertWord(
        WordsCompanion(
          dictionaryId: Value(dictId),
          mot: const Value('ballon'),
          definition:
              const Value('Objet gonflé et rond utilisé dans les jeux.'),
          difficulty: const Value(1),
        ),
      );

      final word = await db.wordsDao.getWordByMot(dictId, 'ballon');
      expect(word, isNotNull);
      expect(word!.mot, equals('ballon'));
      expect(word.difficulty, equals(1));
    });

    test('retourne les mots d\'un dictionnaire', () async {
      for (final m in ['chat', 'chien', 'cheval']) {
        await db.wordsDao.insertWord(
          WordsCompanion(
            dictionaryId: Value(dictId),
            mot: Value(m),
          ),
        );
      }
      final words = await db.wordsDao.watchWordsForDictionary(dictId).first;
      expect(words.length, equals(3));
    });

    test('sélectionne des mots pour session SRS', () async {
      for (final m in ['soleil', 'lune', 'etoile', 'nuage']) {
        await db.wordsDao.insertWord(
          WordsCompanion(
            dictionaryId: Value(dictId),
            mot: Value(m),
          ),
        );
      }
      final selected = await db.wordsDao.selectWordsForSession(
        dictionaryId: dictId,
        profileId: profileId,
        limit: 3,
      );
      expect(selected.length, equals(3));
    });
  });
}

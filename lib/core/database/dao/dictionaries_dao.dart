// ============================================================
// Fichier : lib/core/database/dao/dictionaries_dao.dart
// Description : DAO Drift pour les dictionnaires de mots ciblés.
//               CRUD complet + Streams réactifs.
// ============================================================

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/dictionaries_table.dart';

part 'dictionaries_dao.g.dart';

@DriftAccessor(tables: [Dictionaries])
class DictionariesDao extends DatabaseAccessor<AppDatabase>
    with _$DictionariesDaoMixin {
  DictionariesDao(super.db);

  // --- Lecture ---

  /// Flux réactif des dictionnaires appartenant au praticien (profileId = praticienId).
  /// Les dictionnaires praticien restent toujours visibles, indépendamment
  /// des assignations aux enfants.
  Stream<List<Dictionary>> watchDictionariesForPractitioner(int praticienId) =>
      (select(dictionaries)
            ..where(
              (d) => d.profileId.equals(praticienId) & d.active.equals(true),
            )
            ..orderBy([(d) => OrderingTerm.asc(d.nom)]))
          .watch();

  /// Flux réactif de tous les dictionnaires d'un praticien et de ses enfants.
  /// @deprecated Utiliser [watchDictionariesForPractitioner] — conservé pour
  /// compatibilité avec les anciens écrans pendant la migration.
  Stream<List<Dictionary>> watchDictionariesForPractitionerAndChildren(
    int praticienId,
    List<int> childIds,
  ) {
    final ids = [praticienId, ...childIds];
    return (select(dictionaries)
          ..where((d) => d.active.equals(true) & d.profileId.isIn(ids))
          ..orderBy([(d) => OrderingTerm.asc(d.nom)]))
        .watch();
  }

  /// Flux réactif de tous les dictionnaires actifs d'un profil.
  Stream<List<Dictionary>> watchDictionariesForProfile(int profileId) =>
      (select(dictionaries)
            ..where(
              (d) => d.profileId.equals(profileId) & d.active.equals(true),
            )
            ..orderBy([(d) => OrderingTerm.asc(d.nom)]))
          .watch();

  /// Flux réactif d'un dictionnaire par son identifiant.
  Stream<Dictionary?> watchDictionary(int id) =>
      (select(dictionaries)..where((d) => d.id.equals(id))).watchSingleOrNull();

  /// Récupère un dictionnaire par identifiant (lecture unique).
  Future<Dictionary?> getDictionaryById(int id) =>
      (select(dictionaries)..where((d) => d.id.equals(id))).getSingleOrNull();

  // --- Écriture ---

  /// Insère un nouveau dictionnaire. Retourne son identifiant généré.
  Future<int> insertDictionary(DictionariesCompanion entry) =>
      into(dictionaries).insert(entry);

  /// Met à jour un dictionnaire existant.
  Future<bool> updateDictionary(DictionariesCompanion entry) =>
      update(dictionaries).replace(entry);

  /// Archive un dictionnaire (active = false) sans le supprimer.
  Future<void> archiveDictionary(int id) async {
    await (update(dictionaries)..where((d) => d.id.equals(id))).write(
      const DictionariesCompanion(active: Value(false)),
    );
  }

  /// Supprime définitivement un dictionnaire.
  Future<int> deleteDictionary(int id) =>
      (delete(dictionaries)..where((d) => d.id.equals(id))).go();
}

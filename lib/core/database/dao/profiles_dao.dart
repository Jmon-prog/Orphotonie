// ============================================================
// Fichier : lib/core/database/dao/profiles_dao.dart
// Description : DAO Drift pour les profils utilisateurs.
//               CRUD complet + authentification PIN locale.
// ============================================================

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/profiles_table.dart';

part 'profiles_dao.g.dart';

@DriftAccessor(tables: [Profiles])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin {
  ProfilesDao(super.db);

  /// Récupère tous les enfants d'un praticien donné (par parentId).
  Future<List<Profile>> getChildrenOfPractitioner(int praticienId) {
    return (select(profiles)..where((p) => p.parentId.equals(praticienId)))
        .get();
  }

  // --- Lecture ---

  /// Flux réactif de tous les profils, triés par prénom.
  Stream<List<Profile>> watchAllProfiles() =>
      (select(profiles)..orderBy([(p) => OrderingTerm.asc(p.prenom)])).watch();

  /// Flux réactif des profils actifs (non archivés) d'un type donné.
  Stream<List<Profile>> watchProfilesByType(String type) => (select(profiles)
        ..where(
          (p) => p.type.equals(type) & p.archivedAt.isNull(),
        )
        ..orderBy([(p) => OrderingTerm.asc(p.prenom)]))
      .watch();

  /// Flux réactif des enfants actifs (non archivés) d'un praticien.
  Stream<List<Profile>> watchActiveChildrenOfPractitioner(int praticienId) =>
      (select(profiles)
            ..where(
              (p) => p.parentId.equals(praticienId) & p.archivedAt.isNull(),
            )
            ..orderBy([(p) => OrderingTerm.asc(p.prenom)]))
          .watch();

  /// Flux réactif des enfants archivés d'un praticien.
  Stream<List<Profile>> watchArchivedChildrenOfPractitioner(int praticienId) =>
      (select(profiles)
            ..where(
              (p) => p.parentId.equals(praticienId) & p.archivedAt.isNotNull(),
            )
            ..orderBy([(p) => OrderingTerm.asc(p.prenom)]))
          .watch();

  /// Récupère un profil par son identifiant. Null si absent.
  Future<Profile?> getProfileById(int id) =>
      (select(profiles)..where((p) => p.id.equals(id))).getSingleOrNull();

  // --- Écriture ---

  /// Insère un nouveau profil. Retourne son identifiant généré.
  Future<int> insertProfile(ProfilesCompanion entry) =>
      into(profiles).insert(entry);

  /// Met à jour un profil existant.
  Future<bool> updateProfile(ProfilesCompanion entry) =>
      update(profiles).replace(entry);

  /// Supprime un profil par son identifiant.
  Future<int> deleteProfile(int id) =>
      (delete(profiles)..where((p) => p.id.equals(id))).go();

  /// Archive un profil enfant (le masque de l'écran de connexion).
  Future<void> archiveProfile(int id) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(archivedAt: Value(DateTime.now())),
    );
  }

  /// Restaure un profil archivé (redevient visible à la connexion).
  Future<void> unarchiveProfile(int id) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      const ProfilesCompanion(archivedAt: Value(null)),
    );
  }

  // --- Authentification PIN ---

  /// Retourne le hash PIN d'un profil praticien (null = pas de PIN configuré).
  Future<String?> getPinHash(int profileId) async {
    final profile = await getProfileById(profileId);
    return profile?.pinHash;
  }

  /// Définit ou efface le PIN haché d'un profil praticien.
  Future<void> setPinHash(int profileId, String? hash) async {
    await (update(profiles)..where((p) => p.id.equals(profileId))).write(
      ProfilesCompanion(pinHash: Value(hash)),
    );
  }
}

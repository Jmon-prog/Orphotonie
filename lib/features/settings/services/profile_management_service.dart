// ============================================================
// Fichier : lib/features/settings/services/profile_management_service.dart
// Description : Service de gestion du cycle de vie des profils.
//               Archive, restauration, réinitialisation Leitner,
//               suppression (avec cascade manuelle) et reset d'usine.
//               Toutes les opérations destructives s'exécutent en
//               transaction pour garantir la cohérence de app.db.
//               100 % hors ligne — aucun accès réseau.
// ============================================================

import '../../../core/database/app_database.dart';

/// Service de gestion des profils et des données utilisateur.
class ProfileManagementService {
  ProfileManagementService(this._db);
  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // Archive / Restauration
  // ---------------------------------------------------------------------------

  /// Archive un profil enfant : le masque de l'écran de connexion
  /// sans supprimer aucune donnée.
  Future<void> archiveProfile(int profileId) async {
    try {
      await _db.profilesDao.archiveProfile(profileId);
    } catch (e) {
      throw Exception('Impossible d\'archiver le profil : $e');
    }
  }

  /// Restaure un profil archivé : le remet visible à la connexion.
  Future<void> unarchiveProfile(int profileId) async {
    try {
      await _db.profilesDao.unarchiveProfile(profileId);
    } catch (e) {
      throw Exception('Impossible de restaurer le profil : $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Réinitialisation Leitner
  // ---------------------------------------------------------------------------

  /// Remet tous les mots d'un profil en boîte 1 (supprime les entrées
  /// WordMastery). Les dictionnaires et les mots eux-mêmes sont conservés.
  Future<int> resetProgression(int profileId) async {
    try {
      return await _db.wordsDao.resetProgressionForProfile(profileId);
    } catch (e) {
      throw Exception('Impossible de réinitialiser la progression : $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Suppression d'un profil (cascade manuelle)
  // ---------------------------------------------------------------------------

  /// Supprime un profil et **toutes** ses données associées :
  /// WordMastery, Sessions, WordAttempts, DailyStats, DictionaryAssignments.
  ///
  /// Les dictionnaires eux-mêmes (propriété du praticien) sont conservés.
  Future<void> deleteProfile(int profileId) async {
    try {
      await _db.transaction(() async {
        // 1. Récupérer les IDs de sessions du profil
        final sessionRows = await (_db.select(_db.sessions)
              ..where((s) => s.profileId.equals(profileId)))
            .get();
        final sessionIds = sessionRows.map((s) => s.id).toList();

        // 2. Supprimer les tentatives liées à ces sessions
        if (sessionIds.isNotEmpty) {
          await (_db.delete(_db.wordAttempts)
                ..where((wa) => wa.sessionId.isIn(sessionIds)))
              .go();
        }

        // 3. Supprimer les sessions
        await (_db.delete(_db.sessions)
              ..where((s) => s.profileId.equals(profileId)))
            .go();

        // 4. Supprimer la maîtrise des mots
        await (_db.delete(_db.wordMastery)
              ..where((wm) => wm.profileId.equals(profileId)))
            .go();

        // 5. Supprimer les statistiques quotidiennes
        await (_db.delete(_db.dailyStats)
              ..where((ds) => ds.profileId.equals(profileId)))
            .go();

        // 6. Supprimer les assignations de dictionnaires (enfant uniquement)
        await (_db.delete(_db.dictionaryAssignments)
              ..where((da) => da.childId.equals(profileId)))
            .go();

        // 7. Supprimer le profil lui-même
        await _db.profilesDao.deleteProfile(profileId);
      });
    } catch (e) {
      throw Exception('Impossible de supprimer le profil : $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Suppression de tous les enfants d'un praticien
  // ---------------------------------------------------------------------------

  /// Supprime tous les profils enfants (actifs et archivés) d'un praticien,
  /// ainsi que toutes leurs données. Les dictionnaires du praticien sont
  /// conservés.
  Future<int> deleteAllChildProfiles(int praticienId) async {
    try {
      final children =
          await _db.profilesDao.getChildrenOfPractitioner(praticienId);
      for (final child in children) {
        await deleteProfile(child.id);
      }
      return children.length;
    } catch (e) {
      throw Exception('Impossible de supprimer les profils enfants : $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Réinitialisation complète (factory reset)
  // ---------------------------------------------------------------------------

  /// Supprime **toutes** les données utilisateur de app.db :
  /// profils, dictionnaires, mots, sessions, stats et paramètres.
  ///
  /// ⚠️ Irréversible — doit être précédé d'une double confirmation UI.
  Future<void> factoryReset() async {
    try {
      await _db.transaction(() async {
        await _db.customStatement('DELETE FROM word_attempts');
        await _db.customStatement('DELETE FROM sessions');
        await _db.customStatement('DELETE FROM word_mastery');
        await _db.customStatement('DELETE FROM daily_stats');
        await _db.customStatement('DELETE FROM dictionary_assignments');
        await _db.customStatement('DELETE FROM words');
        await _db.customStatement('DELETE FROM dictionaries');
        await _db.customStatement('DELETE FROM profiles');
        await _db.customStatement('DELETE FROM app_settings');
      });
    } catch (e) {
      throw Exception('Réinitialisation impossible : $e');
    }
  }
}

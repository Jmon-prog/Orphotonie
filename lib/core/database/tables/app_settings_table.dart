// ============================================================
// Fichier : lib/core/database/tables/app_settings_table.dart
// Description : Table Drift des paramètres applicatifs par profil.
//               Stocke les préférences UI, TTS et de session.
// ============================================================

import 'package:drift/drift.dart';
import 'profiles_table.dart';

/// Table des paramètres — une ligne par profil.
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Profil concerné (clé unique : un seul réglage par profil).
  IntColumn get profileId => integer().references(Profiles, #id).unique()();

  /// Nom du thème : 'clair' | 'sombre' | 'systeme'.
  TextColumn get themeName => text().withDefault(const Constant('systeme'))();

  /// Thème visuel enfant : 'espace' | 'foret' | 'ocean' | 'fantasy'.
  TextColumn get childThemeName =>
      text().withDefault(const Constant('ocean'))();

  /// Taille de police relative : 1.0 = normale.
  RealColumn get fontSize => real().withDefault(const Constant(1.0))();

  /// Synthèse vocale activée.
  BoolColumn get ttsEnabled => boolean().withDefault(const Constant(true))();

  /// Vitesse TTS (0.5 = lent, 1.0 = normal). Défaut 0.8 pour les enfants.
  RealColumn get ttsRate => real().withDefault(const Constant(0.8))();

  /// Volume TTS (0.0–1.0).
  RealColumn get ttsVolume => real().withDefault(const Constant(1.0))();

  /// Sons de feedback activés.
  BoolColumn get soundEnabled => boolean().withDefault(const Constant(true))();

  /// Durée maximale d'une session de jeu en minutes (0 = illimitée).
  IntColumn get sessionDurationLimitMin =>
      integer().withDefault(const Constant(0))();

  /// L'utilisateur a terminé l'onboarding.
  BoolColumn get onboardingDone =>
      boolean().withDefault(const Constant(false))();

  // ---- Accessibilité ----

  /// Police adaptée dyslexie (OpenDyslexic) activée.
  BoolColumn get dyslexicFont => boolean().withDefault(const Constant(false))();

  /// Mode contraste élevé activé.
  BoolColumn get highContrast => boolean().withDefault(const Constant(false))();

  /// Mode daltonisme : 'none' | 'deuteranopia' | 'protanopia' | 'tritanopia'.
  TextColumn get colorBlindMode => text().withDefault(const Constant('none'))();

  /// Réduire les animations (surclasse MediaQuery.disableAnimations).
  BoolColumn get reduceAnimations =>
      boolean().withDefault(const Constant(false))();

  /// Taille des cibles tactiles : 'normal' | 'large' | 'xlarge'.
  TextColumn get largeTargets => text().withDefault(const Constant('normal'))();

  /// Retour haptique activé.
  BoolColumn get hapticFeedback =>
      boolean().withDefault(const Constant(true))();

  /// Espacement texte dyslexie activé (letter-spacing + word-spacing accrus).
  BoolColumn get textSpacing => boolean().withDefault(const Constant(false))();

  /// Afficher les sous-titres audio (pour les mots lus par TTS).
  BoolColumn get showCaptions => boolean().withDefault(const Constant(false))();
}

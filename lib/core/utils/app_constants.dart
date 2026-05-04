// ============================================================
// Fichier : lib/core/utils/app_constants.dart
// Description : Constantes globales de l'application Orphotonie.
//               Versions, noms de bases, clés de préférences, etc.
// ============================================================

/// Constantes globales partagées par toutes les features.
abstract class AppConstants {
  // --- Versions ---
  static const String appVersion = '0.1.0';

  // --- Bases de données ---
  static const String dbLexique = 'lexique4.db';
  static const String dbDefinitions = 'definitions.db';
  static const String dbApp = 'app.db';

  // --- Limites UI ---
  static const int searchMaxResults = 100;
  static const int dictionnaireMaxMots = 200;

  // --- Jeux ---
  static const List<String> typesJeux = [
    'memoire',
    'puzzle',
    'reconnaissance',
    'dictee',
    'associations',
  ];

  // --- Niveaux Dubois-Buyse ---
  static const int duboisMin = 1;
  static const int duboisMax = 43;

  // --- Format export ---
  static const String extensionExport = '.orpho';
}

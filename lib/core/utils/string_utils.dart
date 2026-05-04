// ============================================================
// Fichier : lib/core/utils/string_utils.dart
// Description : Utilitaires de traitement de chaînes.
//               Normalisation des diacritiques pour la comparaison
//               dans les jeux orthographiques (pendu, mots croisés,
//               mot lacunaire).
// ============================================================

/// Mapping diacritique → lettre de base (majuscules et minuscules).
const Map<String, String> _diacriticMap = {
  // Minuscules
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'î': 'i', 'ï': 'i', 'í': 'i', 'ì': 'i',
  'ô': 'o', 'ö': 'o', 'ó': 'o', 'ò': 'o', 'õ': 'o',
  'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
  'ÿ': 'y', 'ç': 'c', 'ñ': 'n', 'œ': 'oe', 'æ': 'ae',
  // Majuscules
  'À': 'A', 'Â': 'A', 'Ä': 'A', 'Á': 'A', 'Ã': 'A',
  'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
  'Î': 'I', 'Ï': 'I', 'Í': 'I', 'Ì': 'I',
  'Ô': 'O', 'Ö': 'O', 'Ó': 'O', 'Ò': 'O', 'Õ': 'O',
  'Ù': 'U', 'Û': 'U', 'Ü': 'U', 'Ú': 'U',
  'Ÿ': 'Y', 'Ç': 'C', 'Ñ': 'N', 'Œ': 'OE', 'Æ': 'AE',
};

/// Supprime les diacritiques d'une chaîne.
///
/// Exemple : `stripAccents('FRONTIÈRE')` → `'FRONTIERE'`
/// Exemple : `stripAccents('È')` → `'E'`
String stripAccents(String s) =>
    s.split('').map((c) => _diacriticMap[c] ?? c).join();

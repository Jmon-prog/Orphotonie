// ============================================================
// Fichier : lib/features/auth/services/pin_service.dart
// Description : Service d'authentification PIN local + question secrète.
//               Hash SHA-256 + salt aléatoire — aucun réseau.
//               Hashes stockés dans flutter_secure_storage,
//               jamais dans la base de données Drift.
//               La question secrète permet la réinitialisation du PIN
//               sans accès réseau, dans les règles de l'art :
//               · Réponse normalisée avant hachage (trim + minuscules)
//               · Même schéma salt+hash que le PIN
//               · Texte de la question stocké en clair (non sensible)
// ============================================================

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ---------------------------------------------------------------------------
// Clés de stockage
// ---------------------------------------------------------------------------

/// Hash SHA-256 du PIN.
const _kPinHashKey = 'orphotonie_pin_hash';

/// Salt du PIN.
const _kPinSaltKey = 'orphotonie_pin_salt';

/// Texte de la question secrète (non sensible — stockage en clair).
const _kSecretQuestionKey = 'orphotonie_secret_question';

/// Hash SHA-256 de la réponse secrète.
const _kSecretAnswerHashKey = 'orphotonie_secret_answer_hash';

/// Salt de la réponse secrète.
const _kSecretAnswerSaltKey = 'orphotonie_secret_answer_salt';

// ---------------------------------------------------------------------------
// Questions prédéfinies (évite les réponses trop courtes ou triviales)
// ---------------------------------------------------------------------------

/// Liste des questions secrètes proposées au praticien.
/// Utiliser une liste fermée réduit le risque de questions faibles.
const kSecretQuestions = [
  'Quel est le prénom de votre mère ?',
  'Dans quelle ville êtes-vous né(e) ?',
  'Quel est le nom de votre premier animal de compagnie ?',
  'Quel est votre plat préféré ?',
  "Quel est le prénom de votre meilleur(e) ami(e) d'enfance ?",
];

/// Service de gestion du PIN praticien et de la question secrète.
/// Toutes les opérations sont 100% locales.
class PinService {
  PinService(this._storage);

  final FlutterSecureStorage _storage;

  // ---------------------------------------------------------------------------
  // Utilitaires internes
  // ---------------------------------------------------------------------------

  /// Génère un salt aléatoire de 32 octets encodé en base64.
  static String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// Hash SHA-256 d'une valeur avec son salt.
  static String _hash(String value, String salt) {
    final input = utf8.encode('$salt:$value');
    return sha256.convert(input).toString();
  }

  /// Normalise une réponse secrète avant hachage :
  /// supprime les espaces superflus et met en minuscules.
  static String _normalizeAnswer(String answer) => answer.trim().toLowerCase();

  // ---------------------------------------------------------------------------
  // API PIN
  // ---------------------------------------------------------------------------

  /// Retourne true si un PIN praticien est déjà configuré.
  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _kPinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  /// Définit le PIN praticien (hash + salt stockés dans secure storage).
  /// Écrase silencieusement tout PIN existant.
  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hash(pin, salt);
    await _storage.write(key: _kPinSaltKey, value: salt);
    await _storage.write(key: _kPinHashKey, value: hash);
  }

  /// Vérifie un PIN entré par l'utilisateur.
  /// Retourne true si le hash correspond.
  Future<bool> verifyPin(String pin) async {
    final hash = await _storage.read(key: _kPinHashKey);
    final salt = await _storage.read(key: _kPinSaltKey);
    if (hash == null || salt == null) return false;
    return _hash(pin, salt) == hash;
  }

  /// Supprime le PIN (réinitialisation du praticien).
  Future<void> clearPin() async {
    await _storage.delete(key: _kPinHashKey);
    await _storage.delete(key: _kPinSaltKey);
  }

  // ---------------------------------------------------------------------------
  // API Question secrète
  // ---------------------------------------------------------------------------

  /// Retourne true si une question secrète a été configurée.
  Future<bool> hasSecretQuestion() async {
    final q = await _storage.read(key: _kSecretQuestionKey);
    return q != null && q.isNotEmpty;
  }

  /// Retourne le texte de la question secrète en clair, ou null.
  Future<String?> getSecretQuestion() =>
      _storage.read(key: _kSecretQuestionKey);

  /// Enregistre la question et hache la réponse.
  /// La réponse est normalisée (trim + minuscules) avant hachage.
  Future<void> setSecretQuestion(String question, String answer) async {
    final normalized = _normalizeAnswer(answer);
    final salt = _generateSalt();
    final hash = _hash(normalized, salt);
    await _storage.write(key: _kSecretQuestionKey, value: question);
    await _storage.write(key: _kSecretAnswerSaltKey, value: salt);
    await _storage.write(key: _kSecretAnswerHashKey, value: hash);
  }

  /// Vérifie la réponse secrète saisie par l'utilisateur.
  /// La réponse est normalisée avant comparaison (insensible à la casse).
  Future<bool> verifySecretAnswer(String answer) async {
    final hash = await _storage.read(key: _kSecretAnswerHashKey);
    final salt = await _storage.read(key: _kSecretAnswerSaltKey);
    if (hash == null || salt == null) return false;
    return _hash(_normalizeAnswer(answer), salt) == hash;
  }

  /// Supprime la question secrète et son hash (lors d'une réinitialisation totale).
  Future<void> clearSecretQuestion() async {
    await _storage.delete(key: _kSecretQuestionKey);
    await _storage.delete(key: _kSecretAnswerHashKey);
    await _storage.delete(key: _kSecretAnswerSaltKey);
  }
}

// ---------------------------------------------------------------------------
// Provider Riverpod
// ---------------------------------------------------------------------------

/// Provider de FlutterSecureStorage (singleton).
final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

/// Provider du PinService.
final pinServiceProvider = Provider<PinService>(
  (ref) => PinService(ref.watch(_secureStorageProvider)),
);

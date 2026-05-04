// ============================================================
// Fichier : lib/features/decouverte/decouverte_providers.dart
// Description : Providers Riverpod pour le mode Découverte.
//               Gère : chargement des mots, exploration mot par mot,
//               création/suppression du dictionnaire temporaire,
//               suivi du parcours d'activités.
//               100 % hors ligne.
// ============================================================

import 'dart:math';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import '../../core/database/definitions_database.dart';
import '../../core/database/app_database.dart';
import 'decouverte_session.dart';

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class DecouverteNotifier extends StateNotifier<DecouverteSessionState> {
  DecouverteNotifier(this._ref) : super(DecouverteSessionState.empty);

  final Ref _ref;

  // ---------------------------------------------------------------------------
  // Étape 1 : Configurer et charger les mots
  // ---------------------------------------------------------------------------

  /// Lance une nouvelle session : tire [config.wordCount] mots au hasard
  /// dans la plage de niveaux [config.levelMin]–[config.levelMax].
  Future<void> startSession(DecouverteConfig config) async {
    state = DecouverteSessionState.empty.copyWith(
      config: config,
      isLoading: true,
    );

    try {
      final db = await DefinitionsDatabase.instance;
      final pool = await db.getByLevelRange(config.levelMin, config.levelMax);

      if (pool.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Aucun mot trouvé pour ces niveaux. Élargis la plage !',
        );
        return;
      }

      // Tirage aléatoire sans remise
      final rng = Random();
      final shuffled = List<DefinitionEntry>.from(pool)..shuffle(rng);
      final picked = shuffled.take(config.wordCount).toList();

      state = state.copyWith(
        isLoading: false,
        words: picked.map((e) => DecouverteWordState(entry: e)).toList(),
        currentWordIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des mots : $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Étape 2 : Présentation mot par mot
  // ---------------------------------------------------------------------------

  /// Marque le mot courant avec un statut et avance au suivant.
  void judgeCurrentWord(WordExplorationStatus status) {
    final idx = state.currentWordIndex;
    if (idx >= state.words.length) return;

    final updated = List<DecouverteWordState>.from(state.words);
    updated[idx] = updated[idx].copyWith(status: status);

    state = state.copyWith(
      words: updated,
      currentWordIndex: idx + 1,
    );
  }

  /// Revient au mot précédent (annulation).
  void previousWord() {
    if (state.currentWordIndex <= 0) return;
    state = state.copyWith(
      currentWordIndex: state.currentWordIndex - 1,
    );
  }

  // ---------------------------------------------------------------------------
  // Étape 3 : Construire le parcours
  // ---------------------------------------------------------------------------

  /// Crée le dictionnaire temporaire en base et y insère les mots à travailler.
  /// Si l'enfant a tout marqué "Je connais", on prend tous les mots.
  Future<void> buildParcours(int childProfileId) async {
    final wordsToUse = state.wordsToLearn.isNotEmpty
        ? state.wordsToLearn
        : state.words; // tous si tout "Je connais"

    if (wordsToUse.isEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      final db = _ref.read(appDatabaseProvider);

      // Crée le dictionnaire temporaire (appartient au profil enfant —
      // invisible dans les écrans praticien et dans la liste enfant normale)
      final dicId = await db.dictionariesDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(childProfileId),
          nom: const Value('__decouverte__'),
          description: const Value('Session Découverte temporaire'),
          couleur: const Value('#5AE0C0'),
          icon: const Value('explore'),
        ),
      );

      // Insère les mots
      final wordsDao = db.wordsDao;
      for (final w in wordsToUse) {
        await wordsDao.insertWord(
          WordsCompanion(
            dictionaryId: Value(dicId),
            mot: Value(w.entry.mot),
            definition: Value(w.entry.definition),
            defCroises: Value(w.entry.defCroises),
            defFleches: Value(w.entry.defFleches),
          ),
        );
      }

      state = state.copyWith(
        tempDicId: dicId,
        isLoading: false,
        // Sélectionner toutes les activités par défaut
        chosenActivityRoutes: kDecouverteActivities.map((a) => a.route).toSet(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la préparation du parcours : $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Gestion du parcours
  // ---------------------------------------------------------------------------

  /// Active ou désactive une activité dans le parcours.
  void toggleActivity(String route) {
    final chosen = Set<String>.from(state.chosenActivityRoutes);
    if (chosen.contains(route)) {
      chosen.remove(route);
    } else {
      chosen.add(route);
    }
    state = state.copyWith(chosenActivityRoutes: chosen);
  }

  /// Marque une activité comme terminée.
  void markActivityDone(String route) {
    final done = Set<String>.from(state.doneActivityRoutes)..add(route);
    state = state.copyWith(doneActivityRoutes: done);
  }

  // ---------------------------------------------------------------------------
  // Fin de session
  // ---------------------------------------------------------------------------

  /// Supprime le dictionnaire temporaire et réinitialise la session.
  Future<void> endSession() async {
    final dicId = state.tempDicId;
    if (dicId != null) {
      try {
        await _ref
            .read(appDatabaseProvider)
            .dictionariesDao
            .deleteDictionary(dicId);
      } catch (_) {
        // Nettoyage best-effort — pas bloquant
      }
    }
    state = DecouverteSessionState.empty;
  }

  /// Réinitialise la session sans supprimer le dictionnaire temporaire.
  /// Utiliser après sauvegarde du dictionnaire.
  void resetSession() {
    state = DecouverteSessionState.empty;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provider global de la session Découverte.
/// Une seule session à la fois (un seul enfant connecté).
final decouverteProvider =
    StateNotifierProvider<DecouverteNotifier, DecouverteSessionState>(
  (ref) => DecouverteNotifier(ref),
);

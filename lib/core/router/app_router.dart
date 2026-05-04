// ============================================================
// Fichier : lib/core/router/app_router.dart
// Description : Configuration de la navigation avec go_router.
//               Routes déclaratives pour toutes les features.
//               100% hors ligne — aucune redirection réseau.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/notifiers/auth_notifier.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/profile_selection_screen.dart';
import '../../features/auth/screens/create_profile_screen.dart';
import '../../features/auth/screens/create_practitioner_screen.dart';
import '../../features/auth/screens/pin_entry_screen.dart';
import '../../features/auth/screens/secret_question_screen.dart';
import '../../features/auth/screens/reset_pin_screen.dart';
import '../../features/dictionaries/screens/dictionary_list_screen.dart';
import '../../features/dictionaries/screens/add_edit_dictionary_screen.dart';
import '../../features/dictionaries/screens/word_list_screen.dart';
import '../../features/dictionaries/screens/exercise_sheet_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/games/anagram/anagram_game_screen.dart';
import '../../features/games/hangman/hangman_game_screen.dart';
import '../../features/games/hangman/hangman_logic.dart';
import '../../features/games/fill_blank/fill_blank_game_screen.dart';
import '../../features/games/fill_blank/fill_blank_logic.dart';
import '../../features/games/word_search/word_search_game_screen.dart';
import '../../features/games/word_search/word_search_generator.dart';
import '../../features/games/crossword/crossword_game_screen.dart';
import '../../features/games/flashcard/flashcard_game_screen.dart';
import '../../features/games/definition_qcm/definition_qcm_game_screen.dart';
import '../../features/games/syllables/syllables_game_screen.dart';
import '../../features/games/memory/memory_game_screen.dart';
import '../../features/decouverte/screens/decouverte_config_screen.dart';
import '../../features/decouverte/screens/decouverte_presentation_screen.dart';
import '../../features/decouverte/screens/decouverte_parcours_screen.dart';
import '../../features/sharing/screens/share_dictionary_screen.dart';
import '../../features/sharing/screens/import_screen.dart';
import '../../features/sharing/screens/stats_report_screen.dart';
import '../../core/sharing/stats_share_encoder.dart';
import '../../features/enfant/enfant_home_screen.dart';
import '../../features/home/praticien_accueil_screen.dart';
import '../../features/games/praticien_jeux_screen.dart';
import '../../features/stats/praticien_stats_screen.dart';
import '../../features/help/presentation/aide_screen.dart';
import '../../features/settings/presentation/parametres_screen.dart';
import '../layout/adaptive_scaffold.dart';

// ---------------------------------------------------------------------------
// Noms de routes (constantes pour éviter les typos)
// ---------------------------------------------------------------------------
abstract class AppRoutes {
  static const home = '/';
  static const profiles = '/profiles';
  static const newChild = '/profiles/new-child';
  static const newPractitioner = '/profiles/new-practitioner';
  static const pin = '/pin';
  static const childHome = '/home/child';

  /// Conservé pour compatibilité ascendante — redirige vers [praticienDictionnaires].
  static const practitionerHome = '/home/practitioner';
  static const forgotPin = '/forgot-pin';
  static const resetPin = '/reset-pin';

  // Espace praticien — shell adaptatif (Jalon 18)
  static const praticienAccueil = '/praticien/accueil';
  static const praticienDictionnaires = '/praticien/dictionnaires';
  static const praticienJeux = '/praticien/jeux';
  static const praticienStats = '/praticien/stats';

  // Dictionnaires (Jalon 4) — paths sous le shell praticien
  static const dictionnaires = '/praticien/dictionnaires';
  static const newDictionary = '/praticien/dictionnaires/new';
  static const editDictionary = '/praticien/dictionnaires/:id/edit';
  static const wordList = '/praticien/dictionnaires/:id/mots';
  static const newWord = '/praticien/dictionnaires/:id/mots/new';
  static const editWord = '/praticien/dictionnaires/:id/mots/:wordId/edit';
  static const exerciseSheet = '/praticien/dictionnaires/:id/fiches';

  // Routes hors shell (jalons 5+)
  static const dictionnaire = '/dictionnaire';
  static const recherche = '/recherche';
  static const jeux = '/jeux';
  static const anagramme = '/anagramme';
  static const pendu = '/pendu';
  static const motLacunaire = '/mot-lacunaire';
  static const motsCaches = '/mots-caches';
  static const motsCroises = '/mots-croises';
  static const flashcard = '/flashcard';
  static const definitionQcm = '/definition-qcm';
  static const roueSyllabes = '/roue-syllabes';
  static const memory = '/memory';

  // Mode Découverte (Jalon+)
  static const decouverteConfig = '/decouverte/config';
  static const decouvertePresentation = '/decouverte/presentation';
  static const decouverceParcours = '/decouverte/parcours';

  static const aide = '/aide';
  static const parametres = '/parametres';

  // Partage (Jalon 15)
  static const share = '/partage';
  static const importDic = '/import';

  /// Rapport de statistiques reçu par URL (lecture seule).
  static const statsRapport = '/stats-rapport';
}

// ---------------------------------------------------------------------------
// Provider du router (Riverpod)
// ---------------------------------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  // Écoute l'état d'authentification pour les redirections
  final authListenable = ValueNotifier<AuthState>(const Unauthenticated());
  ref.listen<AuthState>(authNotifierProvider, (_, next) {
    authListenable.value = next;
  });

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    refreshListenable: authListenable,

    // Redirection globale selon l'état d'auth
    redirect: (context, state) {
      final auth = authListenable.value;
      final location = state.matchedLocation;

      // Routes publiques — toujours accessibles
      const publicRoutes = [
        AppRoutes.home,
        AppRoutes.profiles,
        AppRoutes.newChild,
        AppRoutes.newPractitioner,
        AppRoutes.pin,
        AppRoutes.forgotPin,
        AppRoutes.resetPin,
      ];
      if (publicRoutes.contains(location)) return null;

      // Non authentifié → sélection de profil
      if (auth is Unauthenticated) return AppRoutes.profiles;

      // Compatibilité ascendante : ancienne route praticien → nouveau shell
      if (location == AppRoutes.practitionerHome) {
        return AppRoutes.praticienDictionnaires;
      }

      // Tout état authentifié → autoriser
      return null;
    },

    routes: [
      // Écran de démarrage (splash)
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const SplashScreen(),
      ),

      // Sélection de profil
      GoRoute(
        path: AppRoutes.profiles,
        builder: (context, state) => const ProfileSelectionScreen(),
        routes: [
          GoRoute(
            path: 'new-child',
            builder: (context, state) => const CreateProfileScreen(),
          ),
          GoRoute(
            path: 'new-practitioner',
            builder: (context, state) => const CreatePractitionerScreen(),
          ),
        ],
      ),

      // Saisie du PIN
      GoRoute(
        path: AppRoutes.pin,
        builder: (context, state) => const PinEntryScreen(),
      ),

      // Récupération du PIN — question secrète
      GoRoute(
        path: AppRoutes.forgotPin,
        builder: (context, state) => const SecretQuestionScreen(),
      ),

      // Réinitialisation du PIN
      GoRoute(
        path: AppRoutes.resetPin,
        builder: (context, state) => const ResetPinScreen(),
      ),

      // Espace enfant
      GoRoute(
        path: AppRoutes.childHome,
        builder: (context, state) => const EnfantHomeScreen(),
      ),

      // Compatibilité ascendante : ancienne route praticien → nouveau shell
      GoRoute(
        path: AppRoutes.practitionerHome,
        redirect: (context, state) => AppRoutes.praticienDictionnaires,
      ),

      // Compatibilité ascendante : ancienne route /dictionnaires → shell
      GoRoute(
        path: '/dictionnaires',
        redirect: (context, state) => AppRoutes.praticienDictionnaires,
      ),

      // ── Shell adaptatif — Espace praticien (Jalon 18) ──────────────────
      // NavigationBar (compact) / NavigationRail (medium) / Drawer (expanded+)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => OrphoAdaptiveScaffold(
          navigationShell: navigationShell,
        ),
        branches: [
          // Branche 0 : Accueil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.praticienAccueil,
                builder: (context, state) => const PraticienAccueilScreen(),
              ),
            ],
          ),

          // Branche 1 : Dictionnaires + listes de mots
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.praticienDictionnaires,
                builder: (context, state) => const DictionaryListScreen(),
                routes: [
                  // Création d'un nouveau dictionnaire
                  GoRoute(
                    path: 'new',
                    builder: (context, state) {
                      final auth = ref.read(authNotifierProvider);
                      final profileId =
                          auth is PractitionerAuth ? auth.profile.id : 0;
                      return AddEditDictionaryScreen(profileId: profileId);
                    },
                  ),
                  // Édition d'un dictionnaire existant
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final auth = ref.read(authNotifierProvider);
                      final profileId =
                          auth is PractitionerAuth ? auth.profile.id : 0;
                      return AddEditDictionaryScreen(profileId: profileId);
                    },
                  ),
                  GoRoute(
                    path: ':id/mots',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final name =
                          state.uri.queryParameters['nom'] ?? 'Dictionnaire';
                      return WordListScreen(
                        dictionaryId: id,
                        dictionaryName: name,
                      );
                    },
                  ),
                  GoRoute(
                    path: ':id/fiches',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final name =
                          state.uri.queryParameters['nom'] ?? 'Dictionnaire';
                      return ExerciseSheetScreen(
                        dictionaryId: id,
                        dictionaryName: name,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branche 2 : Jeux
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.praticienJeux,
                builder: (context, state) => const PraticienJeuxScreen(),
              ),
            ],
          ),

          // Branche 3 : Progression / Statistiques
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.praticienStats,
                builder: (context, state) => const PraticienStatsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Routes futures
      GoRoute(
        path: AppRoutes.recherche,
        builder: (context, state) {
          final dicId = state.uri.queryParameters['dicId'] != null
              ? int.tryParse(state.uri.queryParameters['dicId']!)
              : null;
          final dicName = state.uri.queryParameters['dicName'];
          return SearchScreen(
            dictionaryId: dicId,
            dictionaryName: dicName,
          );
        },
      ),
      // Jeu Anagramme (Jalon 6)
      GoRoute(
        path: AppRoutes.anagramme,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          final dicName = state.uri.queryParameters['dicName'];
          return AnagramGameScreen(
            dictionaryId: dicId,
            profileId: profileId,
            dictionaryName: dicName,
          );
        },
      ),
      // Jeu Pendu (Jalon 7)
      GoRoute(
        path: AppRoutes.pendu,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          final dicName = state.uri.queryParameters['dicName'];
          final diffStr = state.uri.queryParameters['difficulty'] ?? 'normal';
          final difficulty = HangmanDifficulty.values.firstWhere(
            (d) => d.name == diffStr,
            orElse: () => HangmanDifficulty.normal,
          );
          return HangmanGameScreen(
            dictionaryId: dicId,
            profileId: profileId,
            dictionaryName: dicName,
            difficulty: difficulty,
          );
        },
      ),
      // Jeu Mot Lacunaire (Jalon 8)
      GoRoute(
        path: AppRoutes.motLacunaire,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          final dicName = state.uri.queryParameters['dicName'];
          final modeStr = state.uri.queryParameters['mode'] ?? 'freeInput';
          final mode = FillBlankMode.values.firstWhere(
            (m) => m.name == modeStr,
            orElse: () => FillBlankMode.freeInput,
          );
          return FillBlankGameScreen(
            dictionaryId: dicId,
            profileId: profileId,
            dictionaryName: dicName,
            mode: mode,
          );
        },
      ),
      // Jeu Mots Cachés (Jalon 9)
      GoRoute(
        path: AppRoutes.motsCaches,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          final dicName = state.uri.queryParameters['dicName'];
          final diffStr = state.uri.queryParameters['difficulty'] ?? 'normal';
          final difficulty = WordSearchDifficulty.values.firstWhere(
            (d) => d.name == diffStr,
            orElse: () => WordSearchDifficulty.normal,
          );
          return WordSearchGameScreen(
            dictionaryId: dicId,
            profileId: profileId,
            dictionaryName: dicName,
            difficulty: difficulty,
          );
        },
      ),
      // Jeu Mots Croisés (Jalon 10)
      GoRoute(
        path: AppRoutes.motsCroises,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          final dicName = state.uri.queryParameters['dicName'];
          return CrosswordGameScreen(
            dictionaryId: dicId,
            profileId: profileId,
            dictionaryName: dicName,
          );
        },
      ),
      // Partage de dictionnaire (Jalon 15)
      GoRoute(
        path: AppRoutes.share,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          return ShareDictionaryScreen(dictionaryId: dicId);
        },
      ),
      GoRoute(
        path: AppRoutes.importDic,
        builder: (context, state) {
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          // Paramètre 'd' reçu depuis un deep link orphotonie://import?d=ORPH-...
          final initialCode = state.uri.queryParameters['d'];
          return ImportScreen(profileId: profileId, initialCode: initialCode);
        },
      ),
      // Jeu Flashcard Leitner
      GoRoute(
        path: AppRoutes.flashcard,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          final dicName = state.uri.queryParameters['dicName'];
          return FlashcardGameScreen(
            dictionaryId: dicId,
            profileId: profileId,
            dictionaryName: dicName,
          );
        },
      ),
      // Jeu QCM Définition
      GoRoute(
        path: AppRoutes.definitionQcm,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          final dicName = state.uri.queryParameters['dicName'];
          return DefinitionQcmGameScreen(
            dictionaryId: dicId,
            profileId: profileId,
            dictionaryName: dicName,
          );
        },
      ),
      // Jeu Roue des Syllabes
      GoRoute(
        path: AppRoutes.roueSyllabes,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          final dicName = state.uri.queryParameters['dicName'];
          return SyllablesGameScreen(
            dictionaryId: dicId,
            profileId: profileId,
            dictionaryName: dicName,
          );
        },
      ),
      // Jeu Memory
      GoRoute(
        path: AppRoutes.memory,
        builder: (context, state) {
          final dicId = int.parse(
            state.uri.queryParameters['dicId'] ?? '0',
          );
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          final dicName = state.uri.queryParameters['dicName'];
          return MemoryGameScreen(
            dictionaryId: dicId,
            profileId: profileId,
            dictionaryName: dicName,
          );
        },
      ),
      // Mode Découverte — Configuration
      GoRoute(
        path: AppRoutes.decouverteConfig,
        builder: (context, state) {
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          return DecouverteConfigScreen(profileId: profileId);
        },
      ),
      // Mode Découverte — Présentation mot par mot
      GoRoute(
        path: AppRoutes.decouvertePresentation,
        builder: (context, state) {
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          return DecouvertePresentationScreen(profileId: profileId);
        },
      ),
      // Mode Découverte — Parcours d'activités
      GoRoute(
        path: AppRoutes.decouverceParcours,
        builder: (context, state) {
          final profileId = int.parse(
            state.uri.queryParameters['profileId'] ?? '0',
          );
          return DecouverteParcourstScreen(profileId: profileId);
        },
      ),
      GoRoute(
        path: AppRoutes.aide,
        builder: (context, state) => const AideScreen(),
      ),
      GoRoute(
        path: AppRoutes.parametres,
        builder: (context, state) => const ParametresScreen(),
      ),
      // Rapport de statistiques partagé par URL orphotonie://stats?d=ORPH-STAT-...
      GoRoute(
        path: AppRoutes.statsRapport,
        builder: (context, state) {
          final code = state.uri.queryParameters['d'] ?? '';
          StatsSnapshot? snapshot;
          if (code.isNotEmpty) {
            try {
              snapshot = StatsShareEncoder().decodeSnapshot(code);
            } catch (_) {}
          }
          if (snapshot == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Rapport')),
              body: const Center(child: Text('Lien invalide ou corrompu.')),
            );
          }
          return StatsReportScreen(snapshot: snapshot);
        },
      ),
    ],
  );
});

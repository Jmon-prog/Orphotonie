// ============================================================
// Fichier : lib/features/decouverte/decouverte_session.dart
// Description : Modèles de données pour le mode Découverte.
//               Session 100 % en mémoire — pas de persistance directe.
//               Les mots sélectionnés sont temporairement écrits en
//               base uniquement le temps du parcours d'activités.
// ============================================================

import '../../core/database/definitions_database.dart';

// ---------------------------------------------------------------------------
// Configuration de la session
// ---------------------------------------------------------------------------

/// Paramètres choisis par l'enfant avant de démarrer une session Découverte.
class DecouverteConfig {
  const DecouverteConfig({
    required this.levelMin,
    required this.levelMax,
    required this.wordCount,
  });

  /// Niveau Dubois-Buyse minimum (1–43).
  final int levelMin;

  /// Niveau Dubois-Buyse maximum (1–43).
  final int levelMax;

  /// Nombre de mots à tirer (5, 10 ou 15).
  final int wordCount;
}

// ---------------------------------------------------------------------------
// État d'un mot pendant la présentation
// ---------------------------------------------------------------------------

/// Statut d'exploration d'un mot lors de la présentation.
enum WordExplorationStatus {
  /// L'enfant n'a pas encore jugé ce mot.
  unknown,

  /// L'enfant connaît ce mot.
  known,

  /// L'enfant veut travailler ce mot.
  toLearn,
}

/// Un mot de la session avec son statut d'exploration.
class DecouverteWordState {
  const DecouverteWordState({
    required this.entry,
    this.status = WordExplorationStatus.unknown,
  });

  final DefinitionEntry entry;
  final WordExplorationStatus status;

  DecouverteWordState copyWith({WordExplorationStatus? status}) {
    return DecouverteWordState(
      entry: entry,
      status: status ?? this.status,
    );
  }
}

// ---------------------------------------------------------------------------
// Activités disponibles dans le parcours
// ---------------------------------------------------------------------------

/// Une activité proposée dans le parcours Découverte.
class DecouverteActivity {
  const DecouverteActivity({
    required this.route,
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });

  /// Route go_router (ex: AppRoutes.flashcard).
  final String route;
  final String label;
  final String icon; // nom symbolique pour l'icône
  final int color; // valeur ARGB
  final String description;
}

/// Liste des activités disponibles dans le parcours, dans l'ordre suggéré.
/// Du plus simple (reconnaissance) au plus complexe (production).
const kDecouverteActivities = [
  DecouverteActivity(
    route: '/flashcard',
    label: 'Flashcard',
    icon: 'flashcard',
    color: 0xFF5A7AE0,
    description: 'Découvre les mots et leurs définitions',
  ),
  DecouverteActivity(
    route: '/definition-qcm',
    label: 'QCM Définition',
    icon: 'qcm',
    color: 0xFFB05AE0,
    description: 'Associe chaque mot à sa définition',
  ),
  DecouverteActivity(
    route: '/memory',
    label: 'Memory',
    icon: 'memory',
    color: 0xFF5AE0C0,
    description: 'Retrouve les paires mot-définition',
  ),
  DecouverteActivity(
    route: '/anagramme',
    label: 'Anagramme',
    icon: 'anagramme',
    color: 0xFF6A5AE0,
    description: 'Remets les lettres dans le bon ordre',
  ),
  DecouverteActivity(
    route: '/pendu',
    label: 'Pendu',
    icon: 'pendu',
    color: 0xFFE05A5A,
    description: 'Retrouve le mot lettre par lettre',
  ),
  DecouverteActivity(
    route: '/roue-syllabes',
    label: 'Syllabes',
    icon: 'syllabes',
    color: 0xFF5ABDE0,
    description: 'Remets les syllabes dans le bon ordre',
  ),
];

// ---------------------------------------------------------------------------
// État global de la session
// ---------------------------------------------------------------------------

/// État complet d'une session Découverte.
class DecouverteSessionState {
  const DecouverteSessionState({
    this.config,
    this.words = const [],
    this.currentWordIndex = 0,
    this.isLoading = false,
    this.error,
    this.tempDicId,
    this.chosenActivityRoutes = const {},
    this.doneActivityRoutes = const {},
  });

  /// Configuration choisie par l'enfant (null = pas encore configuré).
  final DecouverteConfig? config;

  /// Mots tirés depuis definitions.db avec leur statut.
  final List<DecouverteWordState> words;

  /// Index du mot affiché dans l'écran de présentation.
  final int currentWordIndex;

  /// Chargement en cours (requête DB).
  final bool isLoading;

  /// Message d'erreur, null si tout va bien.
  final String? error;

  /// Identifiant du dictionnaire temporaire créé en base pour les jeux.
  /// Null tant que le parcours n'a pas été lancé.
  final int? tempDicId;

  /// Routes des activités choisies par l'enfant pour le parcours.
  final Set<String> chosenActivityRoutes;

  /// Routes des activités déjà terminées.
  final Set<String> doneActivityRoutes;

  // ---------------------------------------------------------------------------
  // Dérivés
  // ---------------------------------------------------------------------------

  /// Mots que l'enfant veut travailler (statut toLearn).
  List<DecouverteWordState> get wordsToLearn =>
      words.where((w) => w.status == WordExplorationStatus.toLearn).toList();

  /// Tous les mots ont été jugés (connu ou à apprendre).
  bool get allWordsJudged =>
      words.isNotEmpty &&
      words.every((w) => w.status != WordExplorationStatus.unknown);

  /// La présentation est terminée (index dépasse la liste).
  bool get presentationComplete => currentWordIndex >= words.length;

  /// Nombre d'activités choisies terminées.
  int get doneCount => doneActivityRoutes.length;

  /// Nombre d'activités choisies.
  int get totalChosen => chosenActivityRoutes.length;

  /// Progression dans le parcours (0.0 à 1.0).
  double get progressRatio => totalChosen == 0 ? 0.0 : doneCount / totalChosen;

  /// Le parcours est entièrement terminé.
  bool get parcoursComplete => totalChosen > 0 && doneCount >= totalChosen;

  DecouverteSessionState copyWith({
    DecouverteConfig? config,
    List<DecouverteWordState>? words,
    int? currentWordIndex,
    bool? isLoading,
    String? error,
    int? tempDicId,
    Set<String>? chosenActivityRoutes,
    Set<String>? doneActivityRoutes,
  }) {
    return DecouverteSessionState(
      config: config ?? this.config,
      words: words ?? this.words,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tempDicId: tempDicId ?? this.tempDicId,
      chosenActivityRoutes: chosenActivityRoutes ?? this.chosenActivityRoutes,
      doneActivityRoutes: doneActivityRoutes ?? this.doneActivityRoutes,
    );
  }

  /// Réinitialise complètement la session.
  static const empty = DecouverteSessionState();
}

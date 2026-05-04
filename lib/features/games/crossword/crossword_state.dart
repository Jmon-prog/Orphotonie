// ============================================================
// Fichier : lib/features/games/crossword/crossword_state.dart
// Description : État du jeu de mots croisés.
//               Grille, saisie utilisateur, sélection, progression.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/foundation.dart';
import 'crossword_generator.dart';

/// État d'une cellule de la grille (saisie utilisateur).
enum CellState {
  /// Pas encore remplie.
  empty,

  /// Lettre saisie (non validée).
  filled,

  /// Lettre correcte (validée).
  correct,

  /// Lettre révélée par un indice.
  revealed,
}

/// Sélection active dans la grille.
@immutable
class CrosswordSelection {
  const CrosswordSelection({
    required this.placementIndex,
    required this.cellIndex,
  });

  /// Index du mot sélectionné dans la liste des placements.
  final int placementIndex;

  /// Index de la lettre active dans ce mot.
  final int cellIndex;

  CrosswordSelection copyWith({int? placementIndex, int? cellIndex}) {
    return CrosswordSelection(
      placementIndex: placementIndex ?? this.placementIndex,
      cellIndex: cellIndex ?? this.cellIndex,
    );
  }
}

/// État complet du jeu de mots croisés.
@immutable
class CrosswordGameState {
  const CrosswordGameState({
    this.gridData,
    this.userInput = const {},
    this.cellStates = const {},
    this.completedWords = const {},
    this.selection,
    this.totalScore = 0,
    this.hintsUsed = 0,
    this.isLoading = false,
    this.isFinished = false,
    this.error,
    this.sessionId,
    this.startTimeMs,
    this.elapsedSeconds = 0,
    this.dictionaryId,
    this.profileId,
  });

  /// Données de la grille générée.
  final CrosswordGrid? gridData;

  /// Saisie utilisateur : (row, col) → lettre.
  final Map<(int, int), String> userInput;

  /// État de chaque cellule : (row, col) → CellState.
  final Map<(int, int), CellState> cellStates;

  /// Indices des mots complétés correctement.
  final Set<int> completedWords;

  /// Sélection active.
  final CrosswordSelection? selection;

  /// Score total.
  final int totalScore;

  /// Nombre d'indices utilisés.
  final int hintsUsed;

  /// Chargement en cours.
  final bool isLoading;

  /// Partie terminée.
  final bool isFinished;

  /// Message d'erreur.
  final String? error;

  /// ID de session.
  final int? sessionId;

  /// Timestamp de début.
  final int? startTimeMs;

  /// Temps écoulé (secondes).
  final int elapsedSeconds;

  /// ID dictionnaire.
  final int? dictionaryId;

  /// ID profil.
  final int? profileId;

  // -----------------------------------------------------------------------
  // Getters calculés
  // -----------------------------------------------------------------------

  /// Nombre de mots à trouver.
  int get totalWords => gridData?.placements.length ?? 0;

  /// Nombre de mots trouvés.
  int get foundWords => completedWords.length;

  /// Progression.
  String get progressLabel => '$foundWords / $totalWords';

  /// Tous les mots trouvés ?
  bool get allFound =>
      gridData != null && completedWords.length == gridData!.placements.length;

  /// Mot actuellement sélectionné.
  CrosswordPlacement? get selectedPlacement {
    if (selection == null || gridData == null) return null;
    if (selection!.placementIndex < 0 ||
        selection!.placementIndex >= gridData!.placements.length) return null;
    return gridData!.placements[selection!.placementIndex];
  }

  /// Label timer.
  String get timerLabel {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // -----------------------------------------------------------------------
  // copyWith
  // -----------------------------------------------------------------------

  CrosswordGameState copyWith({
    CrosswordGrid? gridData,
    Map<(int, int), String>? userInput,
    Map<(int, int), CellState>? cellStates,
    Set<int>? completedWords,
    CrosswordSelection? Function()? selection,
    int? totalScore,
    int? hintsUsed,
    bool? isLoading,
    bool? isFinished,
    String? Function()? error,
    int? Function()? sessionId,
    int? startTimeMs,
    int? elapsedSeconds,
    int? dictionaryId,
    int? profileId,
  }) {
    return CrosswordGameState(
      gridData: gridData ?? this.gridData,
      userInput: userInput ?? this.userInput,
      cellStates: cellStates ?? this.cellStates,
      completedWords: completedWords ?? this.completedWords,
      selection: selection != null ? selection() : this.selection,
      totalScore: totalScore ?? this.totalScore,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      isLoading: isLoading ?? this.isLoading,
      isFinished: isFinished ?? this.isFinished,
      error: error != null ? error() : this.error,
      sessionId: sessionId != null ? sessionId() : this.sessionId,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      profileId: profileId ?? this.profileId,
    );
  }
}

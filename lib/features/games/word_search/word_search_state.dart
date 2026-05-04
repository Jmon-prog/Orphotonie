// ============================================================
// Fichier : lib/features/games/word_search/word_search_state.dart
// Description : État du jeu Mots Cachés.
//               Grille, mots trouvés, sélection en cours,
//               chronomètre, score.
// ============================================================

import 'package:flutter/material.dart';
import 'word_search_generator.dart';

/// Couleurs attribuées aux mots trouvés.
const _foundWordColors = [
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.amber,
  Colors.cyan,
  Colors.red,
];

/// État complet d'une partie de Mots Cachés.
class WordSearchGameState {
  const WordSearchGameState({
    this.gridData,
    this.foundWords = const {},
    this.foundWordColors = const {},
    this.currentSelection = const [],
    this.isSelecting = false,
    this.totalScore = 0,
    this.isLoading = true,
    this.isFinished = false,
    this.error,
    this.sessionId,
    this.startTimeMs,
    this.elapsedSeconds = 0,
    this.dictionaryId,
    this.profileId,
    this.difficulty = WordSearchDifficulty.normal,
  });

  /// Données de la grille générée.
  final WordSearchGrid? gridData;

  /// Mots trouvés (clé = mot).
  final Set<String> foundWords;

  /// Couleur attribuée à chaque mot trouvé.
  final Map<String, Color> foundWordColors;

  /// Cellules sélectionnées en cours (pendant le glissement).
  final List<(int, int)> currentSelection;

  /// En train de sélectionner ?
  final bool isSelecting;

  /// Score cumulé.
  final int totalScore;

  /// Chargement.
  final bool isLoading;

  /// Partie terminée.
  final bool isFinished;

  /// Erreur.
  final String? error;

  /// ID session app.db.
  final int? sessionId;

  /// Timestamp début de partie.
  final int? startTimeMs;

  /// Secondes écoulées.
  final int elapsedSeconds;

  /// Dictionnaire et profil.
  final int? dictionaryId;
  final int? profileId;

  /// Difficulté.
  final WordSearchDifficulty difficulty;

  /// Grille de lettres.
  List<List<String>> get grid => gridData?.grid ?? [];

  /// Taille de la grille.
  int get gridSize => gridData?.size ?? 0;

  /// Mots à trouver.
  List<String> get wordsToFind =>
      gridData?.placedWords.map((p) => p.word).toList() ?? [];

  /// Nombre de mots trouvés / total.
  String get progressLabel =>
      '${foundWords.length}/${gridData?.placedWords.length ?? 0} mots';

  /// Tous les mots trouvés ?
  bool get allFound =>
      gridData != null &&
      foundWords.length >= gridData!.placedWords.length;

  /// Cellules qui font partie de mots trouvés (pour surbrillance).
  Map<(int, int), Color> get highlightedCells {
    final map = <(int, int), Color>{};
    if (gridData == null) return map;
    for (final placed in gridData!.placedWords) {
      if (foundWords.contains(placed.word)) {
        final color = foundWordColors[placed.word] ?? Colors.grey;
        for (final cell in placed.cells) {
          map[cell] = color;
        }
      }
    }
    return map;
  }

  /// Chronomètre formaté.
  String get timerLabel {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Prochaine couleur à attribuer.
  Color get _nextColor =>
      _foundWordColors[foundWords.length % _foundWordColors.length];

  /// Copie avec modifications.
  WordSearchGameState copyWith({
    WordSearchGrid? gridData,
    Set<String>? foundWords,
    Map<String, Color>? foundWordColors,
    List<(int, int)>? currentSelection,
    bool? isSelecting,
    int? totalScore,
    bool? isLoading,
    bool? isFinished,
    String? error,
    int? sessionId,
    int? startTimeMs,
    int? elapsedSeconds,
    int? dictionaryId,
    int? profileId,
    WordSearchDifficulty? difficulty,
  }) {
    return WordSearchGameState(
      gridData: gridData ?? this.gridData,
      foundWords: foundWords ?? this.foundWords,
      foundWordColors: foundWordColors ?? this.foundWordColors,
      currentSelection: currentSelection ?? this.currentSelection,
      isSelecting: isSelecting ?? this.isSelecting,
      totalScore: totalScore ?? this.totalScore,
      isLoading: isLoading ?? this.isLoading,
      isFinished: isFinished ?? this.isFinished,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      profileId: profileId ?? this.profileId,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  /// Ajoute un mot trouvé avec sa couleur.
  WordSearchGameState withFoundWord(String word) {
    final newFound = Set<String>.from(foundWords)..add(word);
    final newColors = Map<String, Color>.from(foundWordColors)
      ..[word] = _nextColor;
    return copyWith(
      foundWords: newFound,
      foundWordColors: newColors,
    );
  }
}

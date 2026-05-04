// ============================================================
// Fichier : lib/features/games/hangman/hangman_game_screen.dart
// Description : Écran principal du jeu Pendu.
//               Mascotte ballon (8 états), clavier A-Z,
//               emplacements du mot, aides, scoring.
//               Responsive mobile/tablette/desktop.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_providers.dart';
import 'hangman_logic.dart';
import 'hangman_providers.dart';
import 'widgets/hangman_mascot.dart';
import 'widgets/word_display.dart';
import 'widgets/letter_keyboard.dart';
import 'widgets/used_letters.dart';

/// Écran du jeu Pendu.
///
/// Paramètres requis :
/// - [dictionaryId] : dictionnaire source des mots
/// - [profileId] : profil enfant en cours
/// - [dictionaryName] : nom affiché dans l'AppBar
/// - [difficulty] : niveau de difficulté
class HangmanGameScreen extends ConsumerStatefulWidget {
  const HangmanGameScreen({
    super.key,
    required this.dictionaryId,
    required this.profileId,
    this.dictionaryName,
    this.difficulty = HangmanDifficulty.normal,
  });

  final int dictionaryId;
  final int profileId;
  final String? dictionaryName;
  final HangmanDifficulty difficulty;

  @override
  ConsumerState<HangmanGameScreen> createState() => _HangmanGameScreenState();
}

class _HangmanGameScreenState extends ConsumerState<HangmanGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hangmanGameProvider.notifier).startGame(
            dictionaryId: widget.dictionaryId,
            profileId: widget.profileId,
            difficulty: widget.difficulty,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hangmanGameProvider);
    final notifier = ref.read(hangmanGameProvider.notifier);

    // Sons de feedback
    ref.listen<HangmanGameState>(hangmanGameProvider, (prev, next) {
      if (next.isWordOver && !(prev?.isWordOver ?? false)) {
        if (next.isWon) {
          ref.read(audioFeedbackServiceProvider).playSuccess();
          // Lire le mot trouvé
          final tts = ref.read(ttsServiceProvider);
          if (tts.isAvailable && next.currentWord != null) {
            tts.speakWord(next.currentWord!.mot);
          }
        } else {
          ref.read(audioFeedbackServiceProvider).playError();
        }
      }
      if (next.isFinished && !(prev?.isFinished ?? false)) {
        ref.read(audioFeedbackServiceProvider).playLevelComplete();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName ?? 'Pendu'),
        actions: [
          // Bouton TTS
          Builder(
            builder: (context) {
              final tts = ref.watch(ttsServiceProvider);
              return IconButton(
                onPressed: tts.isAvailable && state.currentWord != null
                    ? () => tts.speakWord(state.currentWord!.mot)
                    : null,
                icon: const Icon(Icons.volume_up),
                tooltip:
                    tts.isAvailable ? 'Écouter le mot' : 'TTS non disponible',
              );
            },
          ),
          // Score
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                '⭐ ${state.totalScore} pts',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          // Menu aide
          if (!state.isFinished && !state.isLoading && !state.isWordOver)
            PopupMenuButton<int>(
              icon: const Icon(Icons.lightbulb_outline),
              tooltip: 'Aide',
              onSelected: (value) {
                switch (value) {
                  case 1:
                    notifier.useHintFirst();
                  case 2:
                    notifier.useHintRandom();
                  case 3:
                    notifier.useHintDefinition();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 1,
                  child: Text('Révéler la 1ʳᵉ lettre (-20 pts)'),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text('Révéler une lettre aléatoire (-15 pts)'),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Text('Afficher la définition (-10 pts)'),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HangmanGameState state,
    HangmanNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isFinished) {
      return _buildFinishScreen(context, state);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final mascotSize = isWide ? 200.0 : 150.0;
        final tileSize = isWide ? 48.0 : 40.0;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Progression
                  Text(
                    state.progressLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),

                  const SizedBox(height: 8),

                  // Erreurs
                  Text(
                    'Erreurs : ${state.errorsCount} / ${state.maxErrors}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: state.errorsCount > state.maxErrors ~/ 2
                              ? Colors.red
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),

                  const SizedBox(height: 12),

                  // Mascotte
                  HangmanMascot(
                    state: state.mascotState,
                    size: mascotSize,
                  ),

                  const SizedBox(height: 16),

                  // Mot à deviner
                  WordDisplay(
                    revealedWord: state.revealedWord,
                    tileSize: tileSize,
                    isGameOver: state.isWordOver,
                    fullWord: state.currentWord?.mot,
                  ),

                  const SizedBox(height: 12),

                  // Définition (aide 3)
                  if (state.showDefinition &&
                      state.currentWord?.definition != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.currentWord!.definition!,
                                style: TextStyle(color: Colors.blue.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Lettres essayées
                  UsedLetters(
                    correctLetters: state.logic?.correctLetters ?? {},
                    incorrectLetters: state.incorrectLetters,
                  ),

                  const SizedBox(height: 16),

                  // Résultat mot terminé
                  if (state.isWordOver) ...[
                    _buildWordResult(context, state),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => notifier.nextWord(),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Mot suivant'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(200, 48),
                        backgroundColor:
                            state.isWon ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Clavier A-Z
                  if (!state.isWordOver)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: LetterKeyboard(
                        usedLetters: state.usedLetters,
                        correctLetters: state.logic?.correctLetters ?? {},
                        onLetterTap: (letter) => notifier.guessLetter(letter),
                        enabled: !state.isWordOver,
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordResult(BuildContext context, HangmanGameState state) {
    if (state.isWon) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 8),
          Text(
            'Bravo ! Mot trouvé !',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cancel, color: Colors.red, size: 48),
        const SizedBox(height: 8),
        Text(
          'Le mot était : ${state.currentWord?.mot.toUpperCase() ?? ""}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildFinishScreen(BuildContext context, HangmanGameState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalWords = state.words.length;
    final avgScore = totalWords > 0 ? state.totalScore ~/ totalWords : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: avgScore >= 80
                  ? Colors.amber
                  : avgScore >= 50
                      ? Colors.orange
                      : colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Bravo !',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score total : ${state.totalScore} pts',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '$totalWords mots · Moyenne $avgScore pts/mot',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                ref.read(hangmanGameProvider.notifier).startGame(
                      dictionaryId: widget.dictionaryId,
                      profileId: widget.profileId,
                      difficulty: widget.difficulty,
                    );
              },
              icon: const Icon(Icons.replay),
              label: const Text('Rejouer'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

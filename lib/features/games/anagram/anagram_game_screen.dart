// ============================================================
// Fichier : lib/features/games/anagram/anagram_game_screen.dart
// Description : Écran principal du jeu Anagramme.
//               Lettres mélangées (haut) → emplacements réponse (bas).
//               Drag-and-drop + tap. Animation confettis au succès.
//               Responsive mobile/tablette/desktop.
//               100 % hors-ligne.
// ============================================================

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_providers.dart';
import 'anagram_providers.dart';
import 'widgets/letter_tile.dart';
import 'widgets/answer_slots.dart';
import 'widgets/score_display.dart';

/// Écran du jeu Anagramme.
///
/// Paramètres requis :
/// - [dictionaryId] : dictionnaire source des mots
/// - [profileId] : profil enfant en cours
/// - [dictionaryName] : nom affiché dans l'AppBar
class AnagramGameScreen extends ConsumerStatefulWidget {
  const AnagramGameScreen({
    super.key,
    required this.dictionaryId,
    required this.profileId,
    this.dictionaryName,
  });

  final int dictionaryId;
  final int profileId;
  final String? dictionaryName;

  @override
  ConsumerState<AnagramGameScreen> createState() => _AnagramGameScreenState();
}

class _AnagramGameScreenState extends ConsumerState<AnagramGameScreen>
    with TickerProviderStateMixin {
  // Confettis
  final List<_ConfettiParticle> _confetti = [];
  late AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Rebuilder quand l'animation se termine pour retirer l'overlay
    _confettiCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() {});
      }
    });

    // Lancer la partie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(anagramGameProvider.notifier).startGame(
            dictionaryId: widget.dictionaryId,
            profileId: widget.profileId,
          );
    });
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _triggerConfetti() {
    final random = Random();
    _confetti.clear();
    for (int i = 0; i < 30; i++) {
      _confetti.add(
        _ConfettiParticle(
          x: random.nextDouble(),
          speed: 0.3 + random.nextDouble() * 0.7,
          color: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
            Colors.orange,
          ][random.nextInt(6)],
        ),
      );
    }
    _confettiCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(anagramGameProvider);
    final notifier = ref.read(anagramGameProvider.notifier);

    // Déclenche les confettis + sons selon le résultat
    ref.listen<AnagramGameState>(anagramGameProvider, (prev, next) {
      if (next.isCorrect == true && prev?.isCorrect != true) {
        _triggerConfetti();
        ref.read(audioFeedbackServiceProvider).playSuccess();
        // Lire le mot trouvé
        final tts = ref.read(ttsServiceProvider);
        if (tts.isAvailable && next.currentWord != null) {
          tts.speakWord(next.currentWord!.mot);
        }
      } else if (next.isCorrect == false && prev?.isCorrect != false) {
        ref.read(audioFeedbackServiceProvider).playError();
      }
      if (next.isFinished && !(prev?.isFinished ?? false)) {
        ref.read(audioFeedbackServiceProvider).playLevelComplete();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName ?? 'Anagramme'),
        actions: [
          // Bouton TTS — lit le mot courant
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
          // Bouton aide
          if (!state.isFinished && !state.isLoading)
            IconButton(
              onPressed: () => notifier.useHint(),
              icon: const Icon(Icons.lightbulb_outline),
              tooltip: 'Révéler une lettre (-10 pts)',
            ),
        ],
      ),
      body: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AnagramGameState state,
    AnagramNotifier notifier,
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
        // Taille adaptative des tuiles
        final word = state.currentWord;
        final letterCount = word?.mot.length ?? 5;
        final maxTileSize = constraints.maxWidth < 400 ? 44.0 : 56.0;
        final tileSize = ((constraints.maxWidth - 48) / letterCount - 8)
            .clamp(36.0, maxTileSize);

        return Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Score + progression
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ScoreDisplay(
                      totalScore: state.totalScore,
                      progressLabel: state.progressLabel,
                      hintsUsed: state.hintsUsed,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Image du mot (si disponible)
                  if (word?.imagePath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(word!.imagePath!),
                          height: constraints.maxHeight * 0.2,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Consigne
                  Text(
                    'Remets les lettres dans le bon ordre !',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Lettres mélangées (zone du haut)
                  Semantics(
                    label: 'Lettres mélangées',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        state.shuffledLetters.length,
                        (i) => LetterTile(
                          letter: state.shuffledLetters[i],
                          index: i,
                          isEmpty: state.shuffledLetters[i] == null,
                          size: tileSize,
                          onTap: state.shuffledLetters[i] != null
                              ? () => notifier.placeLetter(i)
                              : null,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Divider visuel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Divider(
                      color:
                          Theme.of(context).colorScheme.outline.withAlpha(40),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Zone de réponse (emplacements)
                  AnswerSlots(
                    slots: state.answerSlots,
                    revealedPositions:
                        state.logic?.revealedPositions ?? const {},
                    onSlotTap: (i) => notifier.removeLetter(i),
                    onLetterDropped: (sourceIndex) =>
                        notifier.placeLetter(sourceIndex),
                    tileSize: tileSize,
                    isCorrect: state.isCorrect,
                  ),

                  const Spacer(flex: 2),

                  // Boutons d'action
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: _buildActionButtons(context, state, notifier),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Confettis — IgnorePointer empêche l'overlay de bloquer les taps
            if (_confettiCtrl.isAnimating)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiCtrl,
                  builder: (context, _) => CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _ConfettiPainter(
                      _confetti,
                      _confettiCtrl.value,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AnagramGameState state,
    AnagramNotifier notifier,
  ) {
    if (state.isCorrect == true) {
      // Mot trouvé → bouton "Mot suivant"
      return FilledButton.icon(
        onPressed: () => notifier.nextWord(),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Mot suivant'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: Colors.green,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Feedback erreur
        if (state.isCorrect == false)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Ce n\'est pas le bon ordre. Réessaye !',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade700,
                  ),
            ),
          ),

        // Valider
        FilledButton.icon(
          onPressed:
              state.isAnswerComplete ? () => notifier.validateAnswer() : null,
          icon: const Icon(Icons.check),
          label: const Text('Valider'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishScreen(BuildContext context, AnagramGameState state) {
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
                ref.read(anagramGameProvider.notifier).startGame(
                      dictionaryId: widget.dictionaryId,
                      profileId: widget.profileId,
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

// ---------------------------------------------------------------------------
// Confettis
// ---------------------------------------------------------------------------

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.color,
  });

  final double x;
  final double speed;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.progress);

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withAlpha((255 * (1 - progress)).toInt());
      final x = p.x * size.width;
      final y = progress * size.height * p.speed;
      canvas.drawCircle(
        Offset(x, y),
        4 + progress * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

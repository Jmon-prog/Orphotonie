// ============================================================
// Fichier : lib/features/games/flashcard/flashcard_game_screen.dart
// Description : Écran du jeu Flashcard Leitner.
//               Carte recto (mot) → tap pour révéler le verso (définition).
//               L'enfant juge : "Je savais" / "Je ne savais pas".
//               Responsive mobile/tablette/desktop. Accessible.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'flashcard_providers.dart';

/// Écran du jeu Flashcard Leitner.
///
/// Paramètres requis :
/// - [dictionaryId] : dictionnaire source des mots
/// - [profileId]    : profil enfant en cours
/// - [dictionaryName] : nom affiché dans l'AppBar
class FlashcardGameScreen extends ConsumerStatefulWidget {
  const FlashcardGameScreen({
    super.key,
    required this.dictionaryId,
    required this.profileId,
    this.dictionaryName,
  });

  final int dictionaryId;
  final int profileId;
  final String? dictionaryName;

  @override
  ConsumerState<FlashcardGameScreen> createState() =>
      _FlashcardGameScreenState();
}

class _FlashcardGameScreenState extends ConsumerState<FlashcardGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(flashcardGameProvider.notifier).startGame(
            dictionaryId: widget.dictionaryId,
            profileId: widget.profileId,
          );
    });
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    ref.read(flashcardGameProvider.notifier).reveal();
    _flipCtrl.forward(from: 0);
  }

  Future<void> _answer(bool known) async {
    _flipCtrl.reset();
    await ref.read(flashcardGameProvider.notifier).answer(known);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashcardGameProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName ?? 'Flashcards'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                state.isLoading || state.words.isEmpty
                    ? ''
                    : state.progressLabel,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : state.isFinished
                  ? _buildResults(context, state)
                  : _buildGame(context, state),
    );
  }

  Widget _buildGame(BuildContext context, FlashcardGameState state) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final cardWidth = (isWide ? 500.0 : constraints.maxWidth - 48).clamp(
          200.0,
          500.0,
        );
        final cardHeight = cardWidth * 0.65;

        return Column(
          children: [
            // Barre de progression
            LinearProgressIndicator(
              value: state.words.isEmpty
                  ? 0
                  : state.currentIndex / state.words.length,
              minHeight: 4,
            ),
            const SizedBox(height: 8),
            // Compteurs connu / inconnu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CountBadge(
                    icon: Icons.check_circle_outline,
                    count: state.knownCount,
                    color: Colors.green,
                    label: 'sus',
                  ),
                  _CountBadge(
                    icon: Icons.cancel_outlined,
                    count: state.unknownCount,
                    color: Colors.red,
                    label: 'non sus',
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Carte
            Center(
              child: Semantics(
                button: !state.isRevealed,
                label: state.isRevealed
                    ? 'Carte retournée. ${state.currentWord?.mot ?? ""}'
                    : 'Carte à retourner. Appuyez pour révéler.',
                child: GestureDetector(
                  onTap: state.isRevealed ? null : _flip,
                  child: AnimatedBuilder(
                    animation: _flipAnim,
                    builder: (context, child) {
                      final angle = _flipAnim.value * 3.14159;
                      final showFront = _flipAnim.value < 0.5;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: showFront
                              ? _CardFace(
                                  mot: state.currentWord?.mot ?? '',
                                  isFront: true,
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                )
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateY(3.14159),
                                  child: _CardFace(
                                    mot: state.currentWord?.mot ?? '',
                                    definition: state.logic?.definition,
                                    isFront: false,
                                    cardWidth: cardWidth,
                                    cardHeight: cardHeight,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Indication tap si pas encore révélé
            if (!state.isRevealed)
              Text(
                'Appuyez sur la carte pour voir la définition',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            // Boutons de réponse (visibles après révélation)
            if (state.isRevealed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'Je ne savais pas',
                        child: OutlinedButton.icon(
                          onPressed: () => _answer(false),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text(
                            'Je ne savais pas',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'Je savais',
                        child: ElevatedButton.icon(
                          onPressed: () => _answer(true),
                          icon: const Icon(Icons.check),
                          label: const Text('Je savais'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
          ],
        );
      },
    );
  }

  Widget _buildResults(BuildContext context, FlashcardGameState state) {
    final theme = Theme.of(context);
    final total = state.knownCount + state.unknownCount;
    final rate = total > 0 ? (state.knownCount / total * 100).round() : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              rate >= 70 ? Icons.emoji_events : Icons.sentiment_satisfied_alt,
              size: 72,
              color: rate >= 70 ? Colors.amber : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Session terminée !',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _ResultRow(label: 'Mots sus', value: '${state.knownCount}'),
            _ResultRow(
              label: 'Mots à retravailler',
              value: '${state.unknownCount}',
            ),
            _ResultRow(label: 'Taux de réussite', value: '$rate %'),
            _ResultRow(
              label: 'Points',
              value: '${state.totalScore}',
            ),
            const SizedBox(height: 32),
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
}

// ---------------------------------------------------------------------------
// Widgets internes
// ---------------------------------------------------------------------------

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.mot,
    required this.isFront,
    required this.cardWidth,
    required this.cardHeight,
    this.definition,
  });

  final String mot;
  final String? definition;
  final bool isFront;
  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isFront ? theme.colorScheme.primary : theme.colorScheme.secondary,
          width: 2,
        ),
      ),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isFront
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.secondaryContainer.withOpacity(0.3),
        ),
        child: isFront
            ? Center(
                child: Text(
                  mot,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mot,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      definition?.isNotEmpty == true
                          ? definition!
                          : '(pas de définition)',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.icon,
    required this.count,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final int count;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Fichier : lib/features/games/memory/memory_game_screen.dart
// Description : Écran du jeu Memory (Jeu des paires).
//               Plateau de cartes à retourner pour trouver les
//               paires mot ↔ définition. Animation de retournement.
//               Responsive mobile/tablette/desktop. Accessible.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'memory_providers.dart';
import 'memory_logic.dart';

/// Écran du jeu Memory.
///
/// Paramètres requis :
/// - [dictionaryId]   : dictionnaire source des mots
/// - [profileId]      : profil enfant en cours
/// - [dictionaryName] : nom affiché dans l'AppBar
class MemoryGameScreen extends ConsumerStatefulWidget {
  const MemoryGameScreen({
    super.key,
    required this.dictionaryId,
    required this.profileId,
    this.dictionaryName,
  });

  final int dictionaryId;
  final int profileId;
  final String? dictionaryName;

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryGameProvider.notifier).startGame(
            dictionaryId: widget.dictionaryId,
            profileId: widget.profileId,
          );
    });
  }

  /// Retourne une carte et déclenche le retournement automatique si mauvaise paire.
  void _onCardTap(String uid) {
    final notifier = ref.read(memoryGameProvider.notifier);
    final flipped = notifier.selectCard(uid);
    if (!flipped) return;

    // Si une deuxième carte vient d'être sélectionnée et que c'est une mauvaise paire,
    // déclencher le retournement automatique après 900 ms.
    final state = ref.read(memoryGameProvider);
    if (state.isChecking) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          ref.read(memoryGameProvider.notifier).resolveSelection();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoryGameProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName ?? 'Memory'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                state.isLoading
                    ? ''
                    : '${state.matchedCount} / ${state.totalPairs}',
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildError(context, state.error!)
              : state.isFinished
                  ? _buildResults(context, state)
                  : _buildGame(context, state),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
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

  Widget _buildGame(BuildContext context, MemoryGameState state) {
    return Column(
      children: [
        // Barre de progression
        LinearProgressIndicator(
          value: state.progress,
          minHeight: 4,
        ),
        // Tentatives
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                label: '${state.matchedCount} paires trouvées',
                child: _StatBadge(
                  icon: Icons.check_circle_outline,
                  value: '${state.matchedCount}',
                  label: 'paires',
                  color: Colors.green,
                ),
              ),
              Semantics(
                label: '${state.attempts} tentatives',
                child: _StatBadge(
                  icon: Icons.touch_app_outlined,
                  value: '${state.attempts}',
                  label: 'tentatives',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Semantics(
                label: '${state.score} points',
                child: _StatBadge(
                  icon: Icons.star_outline,
                  value: '${state.score}',
                  label: 'points',
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        // Plateau de cartes
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700
                  ? 5
                  : (constraints.maxWidth > 450 ? 4 : 3);
              return GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: state.cards.length,
                itemBuilder: (context, index) {
                  final card = state.cards[index];
                  return _MemoryCardWidget(
                    card: card,
                    onTap: () => _onCardTap(card.uid),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context, MemoryGameState state) {
    final theme = Theme.of(context);
    final perfect = state.attempts == state.totalPairs;
    final accuracy = state.attempts > 0
        ? (state.matchedCount / state.attempts * 100).round()
        : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              perfect ? Icons.emoji_events : Icons.sentiment_satisfied_alt,
              size: 72,
              color: perfect ? Colors.amber : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              perfect ? 'Parfait !' : 'Bravo !',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu as trouvé toutes les paires !',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 28),
            _ResultRow(
              label: 'Paires trouvées',
              value: '${state.matchedCount}',
            ),
            _ResultRow(label: 'Tentatives', value: '${state.attempts}'),
            _ResultRow(label: 'Précision', value: '$accuracy %'),
            _ResultRow(label: 'Score', value: '${state.score} pts'),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(memoryGameProvider.notifier).restart(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Rejouer'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carte individuelle avec animation de retournement
// ---------------------------------------------------------------------------

class _MemoryCardWidget extends StatefulWidget {
  const _MemoryCardWidget({
    required this.card,
    required this.onTap,
  });

  final MemoryCard card;
  final VoidCallback onTap;

  @override
  State<_MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<_MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _showFront = widget.card.isFaceUp;
    if (_showFront) _ctrl.value = 1;
  }

  @override
  void didUpdateWidget(_MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nowFaceUp = widget.card.isFaceUp;
    if (nowFaceUp != oldWidget.card.isFaceUp) {
      if (nowFaceUp) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWordSide = widget.card.isWordSide;
    final isMatched = widget.card.isMatched;

    // Couleurs
    final frontColor = isMatched
        ? Colors.green.shade100
        : isWordSide
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.secondaryContainer;
    final frontTextColor = isMatched
        ? Colors.green.shade900
        : isWordSide
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSecondaryContainer;

    return Semantics(
      button: !widget.card.isFaceUp && !widget.card.isMatched,
      label: widget.card.isFaceUp
          ? 'Carte retournée : ${widget.card.content}'
          : 'Carte cachée. Appuyez pour retourner.',
      child: GestureDetector(
        onTap: widget.card.isMatched ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) {
            final angle = _anim.value * 3.14159;
            final showFace = _anim.value >= 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: showFace
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _CardFace(
                        content: widget.card.content,
                        backgroundColor: frontColor,
                        textColor: frontTextColor,
                        isWordSide: isWordSide,
                        isMatched: isMatched,
                      ),
                    )
                  : _CardBack(),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Face avant et face arrière
// ---------------------------------------------------------------------------

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.content,
    required this.backgroundColor,
    required this.textColor,
    required this.isWordSide,
    required this.isMatched,
  });

  final String content;
  final Color backgroundColor;
  final Color textColor;
  final bool isWordSide;
  final bool isMatched;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched
              ? Colors.green
              : isWordSide
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : theme.colorScheme.secondary.withValues(alpha: 0.4),
          width: isMatched ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isWordSide) ...[
            Icon(
              isMatched ? Icons.check_circle : Icons.abc_rounded,
              size: 18,
              color: textColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            content,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: isWordSide ? FontWeight.bold : FontWeight.normal,
              fontSize: isWordSide ? 14 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.question_mark_rounded,
          size: 28,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets utilitaires
// ---------------------------------------------------------------------------

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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

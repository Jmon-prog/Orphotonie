// ============================================================
// Fichier : lib/features/games/anagram/widgets/answer_slots.dart
// Description : Zone de réponse du jeu Anagramme.
//               Emplacements où l'enfant place les lettres (tap ou drop).
//               Supporte le drag-and-drop + tap pour retirer.
// ============================================================

import 'package:flutter/material.dart';
import 'letter_tile.dart';

/// Zone de réponse avec [slotCount] emplacements.
///
/// Accepte les lettres par DragTarget ou par tap (via [onSlotTap]).
class AnswerSlots extends StatelessWidget {
  const AnswerSlots({
    super.key,
    required this.slots,
    required this.revealedPositions,
    this.onSlotTap,
    this.onLetterDropped,
    this.tileSize = 52,
    this.isCorrect,
  });

  /// Contenu actuel de chaque emplacement (null = vide).
  final List<String?> slots;

  /// Positions révélées par l'aide (non modifiables).
  final Set<int> revealedPositions;

  /// Callback quand un slot est tappé (pour retirer la lettre).
  final void Function(int index)? onSlotTap;

  /// Callback quand une lettre est déposée par drag sur un slot.
  final void Function(int sourceIndex)? onLetterDropped;

  /// Taille des tuiles.
  final double tileSize;

  /// Résultat de la validation (null = pas encore, true = correct, false = incorrect).
  final bool? isCorrect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Zone de réponse',
      child: _AnimatedContainer(
        isCorrect: isCorrect,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(slots.length, (i) {
            final isRevealed = revealedPositions.contains(i);

            if (slots[i] != null) {
              return LetterTile(
                letter: slots[i],
                index: i,
                isRevealed: isRevealed,
                isDraggable: false,
                size: tileSize,
                onTap: isRevealed ? null : () => onSlotTap?.call(i),
              );
            }

            // Slot vide = DragTarget
            return DragTarget<int>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) {
                onLetterDropped?.call(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                return LetterTile(
                  letter: null,
                  index: i,
                  isEmpty: true,
                  size: tileSize,
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

/// Conteneur animé qui tremble sur erreur.
class _AnimatedContainer extends StatefulWidget {
  const _AnimatedContainer({
    required this.isCorrect,
    required this.child,
  });

  final bool? isCorrect;
  final Widget child;

  @override
  State<_AnimatedContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<_AnimatedContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCorrect == false && oldWidget.isCorrect != false) {
      _shakeCtrl.forward(from: 0).then((_) => _shakeCtrl.reverse());
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeCtrl.isAnimating
                ? _shakeAnim.value *
                    ((_shakeCtrl.value * 10).toInt().isEven ? 1 : -1)
                : 0,
            0,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

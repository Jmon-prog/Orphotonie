// ============================================================
// Fichier : lib/features/games/fill_blank/widgets/letter_pool_mode.dart
// Description : Mode pool de lettres du jeu Mot Lacunaire.
//               Drag-and-drop des lettres vers les lacunes.
//               Fonctionne sur mobile et desktop.
//               Responsive, accessible.
// ============================================================

import 'package:flutter/material.dart';

/// Mode pool de lettres : glisser-déposer des lettres disponibles
/// vers les emplacements vides.
class LetterPoolMode extends StatelessWidget {
  const LetterPoolMode({
    super.key,
    required this.pool,
    required this.blankIndices,
    required this.placements,
    required this.onLetterPlaced,
    required this.onLetterRemoved,
    this.isCorrect,
    this.tileSize = 52,
  });

  /// Lettres disponibles dans le pool.
  final List<String> pool;

  /// Indices des lacunes dans le mot.
  final List<int> blankIndices;

  /// Lettres placées : blankIndex → poolIndex.
  final Map<int, int> placements;

  /// Callback quand une lettre est placée.
  final void Function(int poolIndex, int blankIndex) onLetterPlaced;

  /// Callback quand une lettre est retirée d'une lacune.
  final void Function(int blankIndex) onLetterRemoved;

  /// Résultat de la validation.
  final bool? isCorrect;

  /// Taille de chaque tuile.
  final double tileSize;

  /// Indices du pool déjà placés.
  Set<int> get _usedPoolIndices => placements.values.toSet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = isCorrect == true;

    return Semantics(
      label: 'Pool de lettres : glissez les lettres vers les lacunes',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zones de dépôt (lacunes)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: blankIndices.map((blankIdx) {
              final poolIdx = placements[blankIdx];
              final hasLetter = poolIdx != null;
              final letter = hasLetter ? pool[poolIdx] : null;

              return DragTarget<int>(
                onWillAcceptWithDetails: (details) =>
                    !disabled && !placements.containsKey(blankIdx),
                onAcceptWithDetails: (details) {
                  onLetterPlaced(details.data, blankIdx);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovering = candidateData.isNotEmpty;

                  return GestureDetector(
                    onTap: hasLetter && !disabled
                        ? () => onLetterRemoved(blankIdx)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: tileSize,
                      height: tileSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isHovering
                            ? theme.colorScheme.primaryContainer
                            : hasLetter
                                ? theme.colorScheme.secondaryContainer
                                : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isHovering
                              ? theme.colorScheme.primary
                              : hasLetter
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.outline,
                          width: isHovering ? 3 : 2,
                        ),
                      ),
                      child: Text(
                        letter ?? '_',
                        style: TextStyle(
                          fontSize: tileSize * 0.45,
                          fontWeight: FontWeight.bold,
                          color: hasLetter
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Lettres disponibles (draggable)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(pool.length, (i) {
              final isUsed = _usedPoolIndices.contains(i);

              if (isUsed || disabled) {
                // Lettre déjà placée — afficher en grisé
                return Opacity(
                  opacity: isUsed ? 0.3 : 1.0,
                  child: Container(
                    width: tileSize,
                    height: tileSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pool[i],
                      style: TextStyle(
                        fontSize: tileSize * 0.45,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return Draggable<int>(
                data: i,
                feedback: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: tileSize,
                    height: tileSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pool[i],
                      style: TextStyle(
                        fontSize: tileSize * 0.45,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Container(
                    width: tileSize,
                    height: tileSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pool[i],
                      style: TextStyle(
                        fontSize: tileSize * 0.45,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                child: Semantics(
                  label: 'Lettre ${pool[i]}',
                  hint: 'Glissez vers une lacune',
                  child: GestureDetector(
                    onTap: () {
                      // Tap : placer dans la première lacune libre
                      final firstFree = blankIndices.firstWhere(
                        (idx) => !placements.containsKey(idx),
                        orElse: () => -1,
                      );
                      if (firstFree != -1) {
                        onLetterPlaced(i, firstFree);
                      }
                    },
                    child: Container(
                      width: tileSize,
                      height: tileSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.tertiary,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        pool[i],
                        style: TextStyle(
                          fontSize: tileSize * 0.45,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

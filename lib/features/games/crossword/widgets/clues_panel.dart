// ============================================================
// Fichier : lib/features/games/crossword/widgets/clues_panel.dart
// Description : Panneau des indices (Horizontaux / Verticaux).
//               Affiche les définitions numérotées,
//               barre les mots trouvés.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../crossword_generator.dart';

/// Paire (index dans placements, placement).
class IndexedClue {
  const IndexedClue(this.placementIndex, this.placement);
  final int placementIndex;
  final CrosswordPlacement placement;
}

/// Panneau affichant les indices horizontaux et verticaux.
class CluesPanel extends StatelessWidget {
  const CluesPanel({
    super.key,
    required this.horizontalClues,
    required this.verticalClues,
    required this.completedIndices,
    this.selectedIndex,
    required this.onClueTap,
  });

  /// Indices horizontaux avec index original.
  final List<IndexedClue> horizontalClues;

  /// Indices verticaux avec index original.
  final List<IndexedClue> verticalClues;

  /// Indices des mots complétés (index dans placements).
  final Set<int> completedIndices;

  /// Index du mot sélectionné (dans placements).
  final int? selectedIndex;

  /// Callback au tap sur un indice.
  final void Function(int placementIndex) onClueTap;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_forward, size: 16),
                    const SizedBox(width: 4),
                    Text('Horizontal (${horizontalClues.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_downward, size: 16),
                    const SizedBox(width: 4),
                    Text('Vertical (${verticalClues.length})'),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildClueList(context, horizontalClues),
                _buildClueList(context, verticalClues),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClueList(
    BuildContext context,
    List<IndexedClue> clues,
  ) {
    if (clues.isEmpty) {
      return const Center(
        child: Text('Aucun indice', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: clues.length,
      itemBuilder: (context, index) {
        final ic = clues[index];
        final clue = ic.placement;
        final pi = ic.placementIndex;
        final isCompleted = completedIndices.contains(pi);
        final isSelected = selectedIndex == pi;

        return Semantics(
          label: '${clue.number}. ${clue.clue}'
              '${isCompleted ? ', trouvé' : ''}',
          child: ListTile(
            dense: true,
            selected: isSelected,
            selectedTileColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              child: Text(
                '${clue.number ?? '?'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              clue.clue,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
                fontSize: 14,
              ),
            ),
            trailing: isCompleted
                ? const Icon(Icons.check, color: Colors.green, size: 18)
                : null,
            onTap: () => onClueTap(pi),
          ),
        );
      },
    );
  }
}

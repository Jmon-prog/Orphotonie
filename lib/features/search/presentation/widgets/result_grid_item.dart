// ============================================================
// Fichier : lib/features/search/presentation/widgets/result_grid_item.dart
// Description : Tuile compacte (~90×70dp) pour la vue grille.
//               Tap court → sélection · Tap long → fiche détaillée.
//               Checkbox, mot, catégorie · syllabes, barre fréquence.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/database/lexique4_database.dart';
import 'search_widgets_shared.dart';

/// Tuile de la vue grille.
class ResultGridItem extends StatelessWidget {
  const ResultGridItem({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    this.isAlreadyAdded = false,
  });

  final LexiqueEntry entry;
  final bool isSelected;
  final bool isAlreadyAdded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final catColor = cgramColor(entry.cgram);

    return Semantics(
      label: '${entry.mot}, ${entry.cgram ?? ''}, sélectionné : $isSelected',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isAlreadyAdded
                ? Colors.green.withAlpha(22)
                : isSelected
                    ? colorScheme.primaryContainer.withAlpha(60)
                    : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAlreadyAdded
                  ? Colors.green.shade400
                  : isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
              width: isAlreadyAdded || isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              // Checkbox en haut à gauche
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Coche verte si sélectionné ou déjà ajouté
              if (isAlreadyAdded || isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Tooltip(
                    message: isAlreadyAdded
                        ? 'Déjà dans le dictionnaire'
                        : 'Sélectionné',
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                  ),
                ),

              // Contenu principal centré
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mot
                    Text(
                      entry.mot.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // Catégorie · syllabes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.cgram ?? '?',
                            style: TextStyle(
                              color: catColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.nbsyll ?? '-'}s',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Barre de fréquence
                    FrequencyBar(entry.preval),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

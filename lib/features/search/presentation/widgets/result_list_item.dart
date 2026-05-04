// ============================================================
// Fichier : lib/features/search/presentation/widgets/result_list_item.dart
// Description : Ligne optimisée pour ListView.builder (hauteur fixe ~60dp).
//               Checkbox · Mot · Badge catégorie+genre · Syllabation ·
//               Badges compacts · Barre fréquence · ➕
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/database/lexique4_database.dart';
import 'search_widgets_shared.dart';

/// Item de la vue liste — hauteur fixe 60dp.
class ResultListItem extends StatelessWidget {
  const ResultListItem({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onAdd,
    required this.onToggleSelect,
    this.isAlreadyAdded = false,
  });

  final LexiqueEntry entry;
  final bool isSelected;
  final bool isAlreadyAdded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onAdd;
  final VoidCallback onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final catColor = cgramColor(entry.cgram);

    // Construire le label catégorie : NOM m s
    final cgramLabel = [
      entry.cgram ?? '?',
      if (entry.genre == 'm') 'm',
      if (entry.genre == 'f') 'f',
      if (entry.nombre == 's') 's',
      if (entry.nombre == 'p') 'p',
    ].join(' ');

    // Syllabation avec séparateur · pour l'affichage
    final syllDisplay = entry.syllphono?.replaceAll('-', '·') ?? entry.mot;

    return Semantics(
      label:
          '${entry.mot}, ${entry.cgram ?? ''}, ${entry.nbsyll ?? ''} syllabes',
      button: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          height: 60,
          color: isAlreadyAdded
              ? Colors.green.withAlpha(18)
              : isSelected
                  ? colorScheme.primaryContainer.withAlpha(40)
                  : null,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 32,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggleSelect(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),

              // Mot + syllabation
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.mot.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      syllDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Badge catégorie (pilule colorée : NOM m s)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: catColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: catColor.withAlpha(80)),
                ),
                child: Text(
                  cgramLabel,
                  style: TextStyle(
                    color: catColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Badges compacts : 3s · 7L
              Text(
                '${entry.nbsyll ?? '-'}s · ${entry.nblettres ?? '-'}L',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),

              // Barre de fréquence
              FrequencyBar(entry.preval),
              const SizedBox(width: 4),

              // Bouton ➕ ou ✓
              isAlreadyAdded
                  ? Tooltip(
                      message: 'Déjà dans le dictionnaire',
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 22,
                      ),
                    )
                  : isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 22,
                        )
                      : IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 22),
                          onPressed: onAdd,
                          tooltip: 'Ajouter au dictionnaire',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

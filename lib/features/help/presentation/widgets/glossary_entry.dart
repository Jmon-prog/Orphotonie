// ============================================================
// Fichier : lib/features/help/presentation/widgets/glossary_entry.dart
// Description : Card expansible pour une entrée de glossaire.
//               Accessible. 100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../../data/help_content.dart';

/// Card expansible affichant une entrée de glossaire.
class GlossaryEntryCard extends StatelessWidget {
  const GlossaryEntryCard({
    super.key,
    required this.entry,
    this.initiallyExpanded = false,
  });

  final GlossaryEntry entry;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Terme : ${entry.term}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ExpansionTile(
          key: PageStorageKey<String>(entry.key),
          initiallyExpanded: initiallyExpanded,
          leading: Icon(
            Icons.help_outline,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            entry.term,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            entry.shortExplanation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.detailedExplanation,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (entry.example != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.example!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

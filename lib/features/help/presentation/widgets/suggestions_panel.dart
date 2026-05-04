// ============================================================
// Fichier : lib/features/help/presentation/widgets/suggestions_panel.dart
// Description : Panneau expansible de suggestions contextuelles —
//               affiche les 3 mots les plus prévalents + explication
//               des filtres actifs en langage naturel. 100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../../data/help_content.dart';
import '../../../search/data/search_filters_model.dart';

/// Données d'un mot suggéré.
class SuggestedWord {
  const SuggestedWord({
    required this.mot,
    required this.preval,
    this.cgram,
  });

  final String mot;
  final double preval;
  final String? cgram;
}

/// Panneau de suggestions contextuelles.
///
/// S'affiche sous les filtres de recherche pour donner un aperçu
/// des mots correspondants et une explication en langage naturel.
class SuggestionsPanel extends StatelessWidget {
  const SuggestionsPanel({
    super.key,
    required this.filters,
    required this.topWords,
    required this.totalCount,
  });

  /// Filtres actuellement actifs.
  final SearchFilters filters;

  /// Top 3 mots par prévalence.
  final List<SuggestedWord> topWords;

  /// Nombre total de résultats.
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final explanation = explainFilters(filters);

    return Semantics(
      label: 'Panneau de suggestions',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(
            Icons.lightbulb_outline,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            '$totalCount mot${totalCount > 1 ? 's' : ''} trouvé${totalCount > 1 ? 's' : ''}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Explication des filtres en langage naturel
                  Text(
                    explanation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  // Top mots
                  if (topWords.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Mots les plus connus :',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: topWords.map((w) {
                        return Chip(
                          avatar: CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              '${w.preval.toInt()}',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          label: Text(w.mot),
                        );
                      }).toList(),
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

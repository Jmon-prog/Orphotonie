// ============================================================
// Fichier : lib/features/search/presentation/widgets/quick_searches.dart
// Description : Boutons de raccourcis prédéfinis pour les praticiens.
//               Défilement horizontal. Plusieurs raccourcis peuvent être
//               actifs simultanément — combinés par AND dans la requête.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/search_filters_model.dart';
import '../../search_providers.dart';

/// Bande horizontale de raccourcis de recherche multi-sélectionnables.
class QuickSearchesBar extends ConsumerWidget {
  const QuickSearchesBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final rawWheres = ref.watch(searchNotifierProvider).filters.rawWheres;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: kQuickSearches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final qs = kQuickSearches[i];
          final isActive = rawWheres.contains(qs.whereClause);
          return Semantics(
            label: isActive
                ? 'Raccourci actif : ${qs.label}. Appuyer pour désactiver.'
                : 'Raccourci : ${qs.label}. Appuyer pour activer.',
            button: true,
            selected: isActive,
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isActive) ...[
                    Icon(
                      Icons.check,
                      size: 14,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    qs.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              selected: isActive,
              checkmarkColor: colorScheme.onPrimaryContainer,
              showCheckmark: false,
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primaryContainer,
              side: isActive
                  ? BorderSide(color: colorScheme.primary, width: 1.5)
                  : BorderSide(color: colorScheme.outlineVariant),
              onSelected: (_) => ref
                  .read(searchNotifierProvider.notifier)
                  .applyQuickSearch(qs),
            ),
          );
        },
      ),
    );
  }
}

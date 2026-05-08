// ============================================================
// Fichier : lib/features/help/presentation/pedagogical_guide_screen.dart
// Description : Écran des guides pédagogiques — 5 guides avec
//               conseils + bouton « Appliquer ces filtres ».
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar.dart';
import '../data/help_content.dart';
import '../../search/presentation/search_screen.dart';

/// Écran affichant les guides pédagogiques pré-remplis.
class PedagogicalGuideScreen extends StatelessWidget {
  const PedagogicalGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThemedAppBar(
        title: 'Guides pédagogiques',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: kPedagogicalGuides.length,
        itemBuilder: (context, index) {
          final guide = kPedagogicalGuides[index];
          return _GuideCard(guide: guide);
        },
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide});
  final PedagogicalGuide guide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        leading: Icon(
          Icons.school,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          guide.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          guide.description,
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
                // Conseils
                ...guide.tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Bouton appliquer filtres
                Semantics(
                  button: true,
                  label: 'Appliquer les filtres du guide ${guide.title}',
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _applyFilters(context),
                      icon: const Icon(Icons.filter_alt),
                      label: const Text('Appliquer ces filtres'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Navigue vers l'écran de recherche avec les filtres pré-remplis.
  void _applyFilters(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          initialFilters: guide.suggestedFilters,
        ),
      ),
    );
  }
}

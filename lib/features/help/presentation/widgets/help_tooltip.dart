// ============================================================
// Fichier : lib/features/help/presentation/widgets/help_tooltip.dart
// Description : Widget ℹ️ réutilisable — tap court : tooltip,
//               tap long : ouvre le glossaire sur le terme.
//               Accessible. 100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../glossary_screen.dart';

/// Icône ℹ️ avec tooltip et lien vers le glossaire.
///
/// ```dart
/// HelpTooltip(
///   term: 'Prévalence',
///   shortExplanation: 'Combien de Français connaissent ce mot.',
///   glossaryKey: 'preval',
/// )
/// ```
class HelpTooltip extends StatelessWidget {
  const HelpTooltip({
    super.key,
    required this.term,
    required this.shortExplanation,
    this.glossaryKey,
    this.iconSize = 18,
  });

  /// Nom du terme affiché dans le tooltip.
  final String term;

  /// Explication courte (2 phrases max).
  final String shortExplanation;

  /// Clé du glossaire pour le tap long (null = pas de lien).
  final String? glossaryKey;

  /// Taille de l'icône.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Aide : $term',
      hint: 'Appuyer pour voir l\'explication, appui long pour le glossaire',
      child: GestureDetector(
        onTap: () => _showTooltipOverlay(context),
        onLongPress: glossaryKey != null ? () => _openGlossary(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.info_outline,
            size: iconSize,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  /// Affiche un tooltip flottant au tap court.
  void _showTooltipOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => entry.remove(),
        behavior: HitTestBehavior.opaque,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shortExplanation,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (glossaryKey != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Appui long pour en savoir plus',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Fermer automatiquement après 4 secondes
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }

  /// Ouvre le glossaire sur l'entrée correspondante.
  void _openGlossary(BuildContext context) {
    if (glossaryKey == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GlossaryScreen(initialKey: glossaryKey),
      ),
    );
  }
}

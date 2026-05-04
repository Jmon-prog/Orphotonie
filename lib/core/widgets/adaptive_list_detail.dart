// ============================================================
// Fichier : lib/core/widgets/adaptive_list_detail.dart
//
// Pattern Master-Detail adaptatif.
// - Compact / medium : vue liste seule (navigation vers le détail)
// - Expanded+        : liste et détail côte à côte (pas de navigation)
//
// Conforme aux "Canonical Layouts" de Material Design 3.
// ============================================================

import 'package:flutter/material.dart';
import '../layout/breakpoints.dart';

/// Widget implémentant le pattern Master-Detail adaptatif.
///
/// En mode compact/medium, seule la liste est affichée. Quand
/// l'utilisateur sélectionne un élément, [onItemSelected] est
/// appelé pour naviguer vers la vue détail (via go_router).
///
/// En mode expanded+, la liste et le détail sont affichés côte
/// à côte. [detailWidget] doit être fourni dans ce cas.
///
/// Usage :
/// ```dart
/// AdaptiveListDetail(
///   listWidget: WordListView(words: words, onSelected: onSelected),
///   detailWidget: selectedWord != null
///       ? WordDetailView(word: selectedWord)
///       : const _NoSelectionPlaceholder(),
///   hasSelection: selectedWord != null,
/// )
/// ```
class AdaptiveListDetail extends StatelessWidget {
  const AdaptiveListDetail({
    required this.listWidget,
    required this.detailWidget,
    this.hasSelection = false,
    this.listFlex = 1,
    this.detailFlex = 2,
    super.key,
  });

  /// Widget de la colonne liste (maître).
  final Widget listWidget;

  /// Widget de la colonne détail.
  /// Affiché uniquement en mode expanded+.
  final Widget detailWidget;

  /// Indique si un élément est sélectionné dans la liste.
  final bool hasSelection;

  /// Proportion relative de la colonne liste.
  final int listFlex;

  /// Proportion relative de la colonne détail.
  final int detailFlex;

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.useDrawer(context)) {
      // Mode expanded+ : affichage côte à côte
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(flex: listFlex, child: listWidget),
          const VerticalDivider(width: 1, thickness: 1),
          Flexible(
            flex: detailFlex,
            child: hasSelection
                ? detailWidget
                : const _NoSelectionPlaceholder(),
          ),
        ],
      );
    }

    // Mode compact/medium : liste seule
    return listWidget;
  }
}

/// Placeholder affiché dans la colonne détail quand rien n'est sélectionné.
class _NoSelectionPlaceholder extends StatelessWidget {
  const _NoSelectionPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez un élément\npour voir les détails',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

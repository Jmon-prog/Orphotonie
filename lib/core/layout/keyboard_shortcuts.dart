// ============================================================
// Fichier : lib/core/layout/keyboard_shortcuts.dart
//
// Raccourcis clavier globaux actifs sur toutes les plateformes
// desktop (Windows, macOS, Linux).
// Wrap l'arbre de widgets avec [OrphoKeyboardShortcuts] pour
// activer les raccourcis dans une page donnée.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Intents (actions déclenchées par les raccourcis)
// ---------------------------------------------------------------------------

/// Ctrl+N — Créer un nouveau dictionnaire.
class CreateDictionaryIntent extends Intent {
  const CreateDictionaryIntent();
}

/// Ctrl+P — Imprimer un exercice.
class PrintExerciseIntent extends Intent {
  const PrintExerciseIntent();
}

/// Ctrl+F — Ouvrir la recherche dans le Lexique 3.
class SearchIntent extends Intent {
  const SearchIntent();
}

/// Échap — Fermer un panneau ou un dialogue.
class DismissIntent extends Intent {
  const DismissIntent();
}

/// Ctrl+Z — Annuler (dessin / historique).
class UndoIntent extends Intent {
  const UndoIntent();
}

// ---------------------------------------------------------------------------
// Carte de raccourcis globaux
// ---------------------------------------------------------------------------

/// Raccourcis clavier globaux de l'application.
/// Activer uniquement sur les plateformes desktop.
final kGlobalShortcuts = <ShortcutActivator, Intent>{
  // Ctrl+N : nouveau dictionnaire
  const SingleActivator(LogicalKeyboardKey.keyN, control: true):
      const CreateDictionaryIntent(),

  // Ctrl+P : imprimer
  const SingleActivator(LogicalKeyboardKey.keyP, control: true):
      const PrintExerciseIntent(),

  // Ctrl+F : recherche Lexique 3
  const SingleActivator(LogicalKeyboardKey.keyF, control: true):
      const SearchIntent(),

  // Échap : fermer panneau/dialogue
  const SingleActivator(LogicalKeyboardKey.escape):
      const DismissIntent(),

  // Ctrl+Z : annuler (dessin)
  const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
      const UndoIntent(),
};

// ---------------------------------------------------------------------------
// Widget wrapper
// ---------------------------------------------------------------------------

/// Enveloppe un sous-arbre avec les raccourcis clavier globaux.
///
/// Fournir [actions] pour brancher les handlers sur les intents.
/// Exemple :
/// ```dart
/// OrphoKeyboardShortcuts(
///   actions: {
///     SearchIntent: CallbackAction<SearchIntent>(
///       onInvoke: (_) => _openSearch(),
///     ),
///   },
///   child: myWidget,
/// )
/// ```
class OrphoKeyboardShortcuts extends StatelessWidget {
  const OrphoKeyboardShortcuts({
    required this.child,
    this.actions = const {},
    super.key,
  });

  final Widget child;

  /// Actions à brancher sur les intents des raccourcis.
  final Map<Type, Action<Intent>> actions;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: kGlobalShortcuts,
      child: Actions(
        actions: actions,
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

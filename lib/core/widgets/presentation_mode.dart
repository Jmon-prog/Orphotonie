// ============================================================
// Fichier : lib/core/widgets/presentation_mode.dart
//
// Mode Présentation pour les grands écrans (ExtraLarge ≥ 1600 dp).
// Projectable sur tableau blanc interactif en cabinet.
//
// Affiche le mot courant en très grand avec image centrée et
// boutons d'action pour l'orthophoniste.
// ============================================================

import 'package:flutter/material.dart';
import '../layout/breakpoints.dart';

/// Données d'un mot en mode présentation.
class PresentationWord {
  const PresentationWord({
    required this.mot,
    this.phonetique,
    this.imagePath,
    this.note,
  });

  final String mot;
  final String? phonetique;
  final String? imagePath;
  final String? note;
}

/// Mode Présentation — pour tableau blanc interactif (ExtraLarge).
///
/// Affiche le mot courant en grand format avec boutons de contrôle.
/// Activable depuis l'interface praticien en mode ExtraLarge.
///
/// Usage :
/// ```dart
/// if (Breakpoints.of(context) == ScreenSize.extraLarge)
///   PresentationModeWidget(
///     word: currentWord,
///     onNext: _nextWord,
///     onSpeak: _speakWord,
///   )
/// ```
class PresentationModeWidget extends StatelessWidget {
  const PresentationModeWidget({
    required this.word,
    this.onNext,
    this.onPrevious,
    this.onSpeak,
    this.onAddToGame,
    super.key,
  });

  final PresentationWord word;

  /// Passer au mot suivant.
  final VoidCallback? onNext;

  /// Revenir au mot précédent.
  final VoidCallback? onPrevious;

  /// Lire le mot à voix haute (TTS).
  final VoidCallback? onSpeak;

  /// Ajouter le mot à l'activité en cours.
  final VoidCallback? onAddToGame;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Mode Présentation'),
        actions: [
          Semantics(
            label: 'Quitter le mode présentation',
            child: TextButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Quitter'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      body: MaxWidthPresentationContent(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image du mot (grande)
            if (word.imagePath != null && word.imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  word.imagePath!,
                  width: 320,
                  height: 320,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(context),
                ),
              )
            else
              _imagePlaceholder(context),

            const SizedBox(height: 40),

            // Mot en très grand (64 sp)
            Semantics(
              label: 'Mot : ${word.mot}',
              child: Text(
                word.mot,
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Phonétique
            if (word.phonetique != null) ...[
              const SizedBox(height: 12),
              Text(
                word.phonetique!,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],

            // Note
            if (word.note != null && word.note!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                word.note!,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 48),

            // Boutons d'action géants
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                if (onPrevious != null)
                  Semantics(
                    label: 'Mot précédent',
                    child: FilledButton.tonal(
                      onPressed: onPrevious,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 28),
                          SizedBox(width: 8),
                          Text('Précédent', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                if (onSpeak != null)
                  Semantics(
                    label: 'Lire à voix haute',
                    child: FilledButton(
                      onPressed: onSpeak,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up, size: 28),
                          SizedBox(width: 8),
                          Text('Écouter', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                if (onNext != null)
                  Semantics(
                    label: 'Mot suivant',
                    child: FilledButton.tonal(
                      onPressed: onNext,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Suivant', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 28),
                        ],
                      ),
                    ),
                  ),
                if (onAddToGame != null)
                  Semantics(
                    label: 'Ajouter au jeu',
                    child: OutlinedButton(
                      onPressed: onAddToGame,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Ajouter au jeu',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 100,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

/// Conteneur interne du mode présentation avec contrainte max-width.
class MaxWidthPresentationContent extends StatelessWidget {
  const MaxWidthPresentationContent({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: child,
        ),
      ),
    );
  }
}

/// Bouton flottant pour activer le mode présentation (ExtraLarge seulement).
class PresentationModeFab extends StatelessWidget {
  const PresentationModeFab({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.of(context) != ScreenSize.extraLarge) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Activer le mode présentation tableau blanc',
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: const Icon(Icons.present_to_all),
        label: const Text('Présentation'),
      ),
    );
  }
}

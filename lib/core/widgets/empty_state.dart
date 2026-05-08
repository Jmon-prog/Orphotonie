// ============================================================
// Fichier : lib/core/widgets/empty_state.dart
// Description : Widget d'état vide réutilisable.
//               Affiche une icône, un titre, une description,
//               et un bouton d'action optionnel.
//               Responsive (adapte la taille selon le breakpoint).
// ============================================================

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Widget d'état vide — utilisé quand une liste ne contient aucun élément.
///
/// Exemple d'utilisation :
/// ```dart
/// EmptyState(
///   icon: Icons.folder_open_rounded,
///   title: 'Aucun dictionnaire',
///   description: 'Créez votre premier dictionnaire pour commencer.',
///   actionLabel: 'Créer',
///   onAction: () => ...,
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.compact = false,
  });

  /// Icône Material à afficher (utiliser les variantes _rounded).
  final IconData icon;

  /// Titre court de l'état vide.
  final String title;

  /// Description facultative (conseils, explication).
  final String? description;

  /// Libellé du bouton d'action (null = pas de bouton).
  final String? actionLabel;

  /// Callback du bouton d'action.
  final VoidCallback? onAction;

  /// Couleur de l'icône (par défaut : primary avec opacité).
  final Color? iconColor;

  /// Mode compact pour les panneaux latéraux ou les espaces réduits.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary.withOpacity(0.35);
    final iconSize = compact ? 56.0 : 80.0;
    final titleStyle =
        compact ? theme.textTheme.titleMedium : theme.textTheme.titleLarge;

    return Semantics(
      label: title,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.l : AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône dans un cercle tonal
              Container(
                width: iconSize + AppSpacing.xl,
                height: iconSize + AppSpacing.xl,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: color,
                ),
              ),
              SizedBox(height: compact ? AppSpacing.m : AppSpacing.l),

              // Titre
              Text(
                title,
                style: titleStyle?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              // Description
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Bouton d'action
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: compact ? AppSpacing.m : AppSpacing.xl),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Variante encore plus compacte pour les panneaux inline (ex : liste vide
/// dans un onglet qui n'est pas le focus principal de l'écran).
///
/// N'affiche pas de bouton d'action — utilisez [EmptyState] pour cela.
class EmptyStateInline extends StatelessWidget {
  const EmptyStateInline({
    super.key,
    required this.icon,
    required this.title,
  });

  /// Icône Material à afficher (utiliser les variantes _rounded).
  final IconData icon;

  /// Texte court décrivant l'absence de contenu.
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

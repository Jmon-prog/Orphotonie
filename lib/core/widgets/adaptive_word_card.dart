// ============================================================
// Fichier : lib/core/widgets/adaptive_word_card.dart
//
// Carte de mot adaptative avec 3 variantes selon la taille d'écran :
//   - Compact  : ListTile horizontal simple
//   - Medium   : Card avec image miniature
//   - Expanded : Card riche avec détails orthophoniques
//
// Pattern à appliquer à tous les widgets complexes de l'app.
// ============================================================

import 'package:flutter/material.dart';
import '../layout/breakpoints.dart';
import '../database/app_database.dart';

/// Carte de mot adaptative.
///
/// Affiche un mot de dictionnaire dans un format adapté à la
/// taille d'écran courante.
class AdaptiveWordCard extends StatelessWidget {
  const AdaptiveWordCard({
    required this.word,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Word word;

  /// Callback appelé lors d'un tap sur la carte.
  final VoidCallback? onTap;

  /// Callback pour l'action d'édition.
  final VoidCallback? onEdit;

  /// Callback pour l'action de suppression.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return switch (Breakpoints.of(context)) {
      ScreenSize.compact => _WordCardCompact(
          word: word,
          onTap: onTap,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ScreenSize.medium => _WordCardMedium(
          word: word,
          onTap: onTap,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      _ => _WordCardExpanded(
          word: word,
          onTap: onTap,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Compact — ListTile horizontal simple
// ---------------------------------------------------------------------------

class _WordCardCompact extends StatelessWidget {
  const _WordCardCompact({
    required this.word,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Word word;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mot : ${word.mot}',
      button: onTap != null,
      child: ListTile(
        title: Text(
          word.mot,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: word.definition != null
            ? Text(
                word.definition!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              )
            : null,
        trailing: onEdit != null || onDelete != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Modifier',
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Theme.of(context).colorScheme.error,
                      tooltip: 'Supprimer',
                      onPressed: onDelete,
                    ),
                ],
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Medium — Card avec image miniature
// ---------------------------------------------------------------------------

class _WordCardMedium extends StatelessWidget {
  const _WordCardMedium({
    required this.word,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Word word;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Mot : ${word.mot}',
      button: onTap != null,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Miniature image ou placeholder
                _WordImage(
                  imagePath: word.imagePath,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(word.mot, style: textTheme.titleSmall),
                      if (word.definition != null)
                        Text(
                          word.definition!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.outline),
                        ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Modifier',
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    tooltip: 'Supprimer',
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expanded — Card riche avec détails orthophoniques
// ---------------------------------------------------------------------------

class _WordCardExpanded extends StatelessWidget {
  const _WordCardExpanded({
    required this.word,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Word word;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Mot : ${word.mot}',
      button: onTap != null,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image plus grande
                _WordImage(imagePath: word.imagePath, size: 72),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(word.mot, style: textTheme.titleMedium),
                      if (word.definition != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          word.definition!,
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.outline),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Modifier',
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        tooltip: 'Supprimer',
                        onPressed: onDelete,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composant interne — miniature d'image
// ---------------------------------------------------------------------------

class _WordImage extends StatelessWidget {
  const _WordImage({required this.size, this.imagePath});

  final String? imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_outlined,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

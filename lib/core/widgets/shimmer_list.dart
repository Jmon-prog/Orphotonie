// ============================================================
// Fichier : lib/core/widgets/shimmer_list.dart
// Description : Widgets skeleton loading basés sur le package shimmer.
//               Remplacent les CircularProgressIndicator dans les listes
//               pour un feedback visuel plus élégant et moins anxiogène.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_spacing.dart';

// ---------------------------------------------------------------------------
// Widget de base Shimmer
// ---------------------------------------------------------------------------

/// Conteneur shimmer — applique l'effet sur n'importe quel child.
///
/// Les couleurs s'adaptent automatiquement au mode sombre.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  /// Widget sur lequel appliquer l'effet de brillance animée.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFE8E7F0),
      highlightColor:
          isDark ? const Color(0xFF3D3D52) : const Color(0xFFF5F4FF),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Bloc rectangulaire générique
// ---------------------------------------------------------------------------

/// Rectangle shimmer — brique de base pour composer des skeletons.
///
/// Sans [width], s'étire pour occuper toute la largeur disponible.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.m,
  });

  /// Largeur fixe en dp (null = étirement maximal via [double.infinity]).
  final double? width;

  /// Hauteur du bloc skeleton (défaut : 16 dp).
  final double height;

  /// Rayon des coins arrondis (défaut : [AppRadius.m] = 12 dp).
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ligne de liste skeleton (avatar + texte)
// ---------------------------------------------------------------------------

/// Skeleton d'un ListTile : cercle avatar + deux lignes de texte.
class _ShimmerListTile extends StatelessWidget {
  const _ShimmerListTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          // Avatar
          const ShimmerBox(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: AppSpacing.m),
          // Lignes de texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: MediaQuery.sizeOf(context).width * 0.45),
                const SizedBox(height: AppSpacing.xs),
                const ShimmerBox(height: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Liste de N skeletons ListTile avec effet shimmer global.
///
/// À utiliser dans un [Stack] ou directement dans le body d'un [Scaffold]
/// le temps que les données asynchrones arrivent.
///
/// Utilisation :
/// ```dart
/// if (isLoading) const ShimmerListView(itemCount: 5)
/// ```
class ShimmerListView extends StatelessWidget {
  const ShimmerListView({super.key, this.itemCount = 6});

  /// Nombre de lignes skeleton à afficher (défaut : 6).
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
        itemBuilder: (_, __) => const _ShimmerListTile(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grille de cards skeleton
// ---------------------------------------------------------------------------

/// Card skeleton — pour les grilles de dictionnaires, mots, jeux.
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 20, width: MediaQuery.sizeOf(context).width * 0.3),
          const SizedBox(height: AppSpacing.xs),
          const ShimmerBox(height: 13),
          const SizedBox(height: AppSpacing.xxs),
          ShimmerBox(height: 13, width: MediaQuery.sizeOf(context).width * 0.2),
        ],
      ),
    );
  }
}

/// Grille de N cards skeletons avec effet shimmer global.
///
/// Utilisé pour les grilles de dictionnaires, de jeux, de mots.
class ShimmerGridView extends StatelessWidget {
  const ShimmerGridView({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  /// Nombre de cartes skeleton à afficher (défaut : 6).
  final int itemCount;

  /// Nombre de colonnes dans la grille (défaut : 2).
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.m),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.m,
          mainAxisSpacing: AppSpacing.m,
          childAspectRatio: 1.6,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => const _ShimmerCard(),
      ),
    );
  }
}

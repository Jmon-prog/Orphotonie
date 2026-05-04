// ============================================================
// Fichier : lib/core/widgets/adaptive_grid.dart
//
// Calcul adaptatif de la taille des cellules d'une grille de jeu.
// La grille est toujours carrée et tient sur l'écran sans scroll.
//
// Règle : si la taille calculée descend sous [minCellSize] (28 dp),
// la grille doit être réduite au format inférieur disponible.
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../layout/breakpoints.dart';

/// Calcule la taille optimale d'une cellule de grille carrée.
///
/// La cellule est dimensionnée pour que la grille tienne dans
/// l'espace disponible sans dépasser [maxCellSize].
///
/// Paramètres :
/// - [availableWidth]  : largeur disponible pour la grille (dp)
/// - [availableHeight] : hauteur disponible pour la grille (dp)
/// - [gridSize]        : nombre de colonnes = nombre de lignes
/// - [minCellSize]     : taille minimale (accessibilité, défaut 28 dp)
/// - [maxCellSize]     : taille maximale (ergonomie, défaut 56 dp)
///
/// Retourne la taille de la cellule ou null si trop petite.
double? computeCellSize({
  required double availableWidth,
  required double availableHeight,
  required int gridSize,
  double minCellSize = 28,
  double maxCellSize = 56,
}) {
  final byWidth = (availableWidth / gridSize).clamp(0.0, maxCellSize);
  final byHeight = (availableHeight / gridSize).clamp(0.0, maxCellSize);
  final cellSize = min(byWidth, byHeight);
  if (cellSize < minCellSize) return null; // grille trop petite
  return cellSize;
}

/// Sélectionne la taille de grille optimale parmi les tailles disponibles.
///
/// Réduit automatiquement la taille de la grille si les cellules
/// deviendraient trop petites (< 28 dp).
///
/// Retourne la taille de grille la plus grande possible, ou la
/// première valeur de [availableSizes] par défaut.
int selectOptimalGridSize({
  required double availableWidth,
  required double availableHeight,
  required List<int> availableSizes,
  double minCellSize = 28,
}) {
  // Trier décroissant pour essayer les plus grandes en premier
  final sorted = List<int>.from(availableSizes)..sort((a, b) => b.compareTo(a));

  for (final size in sorted) {
    final cell = computeCellSize(
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      gridSize: size,
      minCellSize: minCellSize,
    );
    if (cell != null) return size;
  }

  // Fallback : retourner la plus petite taille disponible
  return sorted.last;
}

/// Grille adaptative auto-dimensionnée.
///
/// Utilise [LayoutBuilder] pour calculer la taille des cellules
/// selon l'espace disponible. La grille est toujours carrée.
///
/// Usage :
/// ```dart
/// AdaptiveGrid(
///   gridSize: 8,
///   cellBuilder: (context, row, col, cellSize) => GridCell(row: row, col: col),
/// )
/// ```
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    required this.gridSize,
    required this.cellBuilder,
    this.minCellSize = 28,
    this.maxCellSize = 56,
    this.padding = const EdgeInsets.all(8),
    super.key,
  });

  /// Nombre de colonnes = nombre de lignes.
  final int gridSize;

  /// Constructeur de chaque cellule.
  /// [cellSize] est la taille calculée de la cellule.
  final Widget Function(BuildContext context, int row, int col, double cellSize)
      cellBuilder;

  /// Taille minimale d'une cellule en dp (accessibilité).
  final double minCellSize;

  /// Taille maximale d'une cellule en dp.
  final double maxCellSize;

  /// Padding autour de la grille.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - padding.horizontal;
        final availableHeight = constraints.maxHeight - padding.vertical;

        final cellSize = computeCellSize(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          gridSize: gridSize,
          minCellSize: minCellSize,
          maxCellSize: maxCellSize,
        );

        // Si les cellules sont trop petites, afficher un message d'erreur
        if (cellSize == null) {
          return const Center(
            child: Text(
              'Écran trop petit pour cette grille.',
              textAlign: TextAlign.center,
            ),
          );
        }

        final totalSize = cellSize * gridSize;

        return Center(
          child: Padding(
            padding: padding,
            child: SizedBox(
              width: totalSize,
              height: totalSize,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(gridSize, (row) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(gridSize, (col) {
                      return SizedBox(
                        width: cellSize,
                        height: cellSize,
                        child: cellBuilder(context, row, col, cellSize),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Calcule la taille de grille recommandée selon le breakpoint.
///
/// Retourne le [gridSize] maximal autorisé pour la taille d'écran donnée.
int maxGridSizeForScreenSize(ScreenSize screenSize) {
  return switch (screenSize) {
    ScreenSize.compact    => 8,   // Téléphone : grille max 8×8
    ScreenSize.medium     => 12,  // Tablette portrait : grille max 12×12
    ScreenSize.expanded   => 15,  // Tablette paysage : grille max 15×15
    ScreenSize.large      => 15,  // Desktop : grille max 15×15
    ScreenSize.extraLarge => 15,  // Grand écran : grille max 15×15
  };
}

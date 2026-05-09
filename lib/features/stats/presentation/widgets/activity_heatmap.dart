// ============================================================
// Fichier : lib/features/stats/presentation/widgets/activity_heatmap.dart
// Description : Grille heatmap 12 mois d'activité (CustomPainter).
//               Jours vides = gris, actifs = vert gradué.
//               Responsive. Accessible.
// ============================================================

import 'package:flutter/material.dart';
import '../../data/stats_repository.dart';

/// Heatmap d'activité sur 12 mois, style GitHub.
class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({
    super.key,
    required this.data,
    this.cellSize = 14,
    this.cellSpacing = 3,
  });

  /// Données quotidiennes (12 mois max).
  final List<DailyActivity> data;

  /// Taille d'une cellule en pixels.
  final double cellSize;

  /// Espacement entre cellules.
  final double cellSpacing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Calendrier d\'activité sur 12 mois',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final adjustedCellSize = constraints.maxWidth < 400 ? 10.0 : cellSize;
          final adjustedSpacing =
              constraints.maxWidth < 400 ? 2.0 : cellSpacing;

          return CustomPaint(
            size: Size(
              constraints.maxWidth,
              7 * (adjustedCellSize + adjustedSpacing) + adjustedSpacing,
            ),
            painter: _HeatmapPainter(
              data: data,
              cellSize: adjustedCellSize,
              cellSpacing: adjustedSpacing,
              emptyColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              activeColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.data,
    required this.cellSize,
    required this.cellSpacing,
    required this.emptyColor,
    required this.activeColor,
  });

  final List<DailyActivity> data;
  final double cellSize;
  final double cellSpacing;
  final Color emptyColor;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Construire un map date → intensité
    final intensityMap = <String, double>{};
    for (final day in data) {
      final key = _dateKey(day.date);
      intensityMap[key] = day.intensity;
    }

    // Calculer la plage de dates (52 semaines = 364 jours)
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 363));

    // Trouver le premier jour de la semaine de début
    final startWeekday = startDate.weekday; // 1=lundi, 7=dimanche
    final adjustedStart = startDate.subtract(
      Duration(days: startWeekday - 1),
    );

    final step = cellSize + cellSpacing;
    int col = 0;

    var currentDate = adjustedStart;
    while (!currentDate.isAfter(today)) {
      final row = (currentDate.weekday - 1) % 7; // 0=lundi, 6=dimanche
      final key = _dateKey(currentDate);
      final intensity = intensityMap[key] ?? 0;

      final rect = Rect.fromLTWH(
        col * step,
        row * step,
        cellSize,
        cellSize,
      );

      final paint = Paint()
        ..color = intensity > 0
            ? Color.lerp(
                activeColor.withValues(alpha: 0.15),
                activeColor,
                intensity,
              )!
            : emptyColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.2)),
        paint,
      );

      currentDate = currentDate.add(const Duration(days: 1));
      // Nouvelle colonne chaque lundi
      if (currentDate.weekday == 1) col++;
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

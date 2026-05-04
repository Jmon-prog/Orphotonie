// ============================================================
// Fichier : lib/features/search/presentation/widgets/search_widgets_shared.dart
// Description : Widgets partagés entre result_list_item et result_grid_item.
// ============================================================

import 'package:flutter/material.dart';

/// Couleur du badge selon la catégorie grammaticale.
Color cgramColor(String? cgram) => switch (cgram) {
      'NOM' => const Color(0xFF1565C0),
      'VER' => const Color(0xFF2E7D32),
      'ADJ' => const Color(0xFFE65100),
      'ADV' => const Color(0xFF6A1B9A),
      'AUX' => const Color(0xFF00838F),
      'PRE' => const Color(0xFF546E7A),
      'CON' => const Color(0xFF4E342E),
      'ONO' => const Color(0xFFAD1457),
      'PRO' => const Color(0xFF283593),
      _ => const Color(0xFF616161),
    };

/// Barre de fréquence (4 blocs) selon la prévalence.
class FrequencyBar extends StatelessWidget {
  const FrequencyBar(this.preval, {super.key});
  final double? preval;

  @override
  Widget build(BuildContext context) {
    final v = preval ?? 0;
    final filled = v >= 90
        ? 4
        : v >= 70
            ? 3
            : v >= 50
                ? 2
                : v > 0
                    ? 1
                    : 0;
    final color = v >= 90
        ? Colors.green
        : v >= 70
            ? Colors.lightGreen
            : v >= 50
                ? Colors.orange
                : Colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (i) => Container(
          width: 7,
          height: 12,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: i < filled ? color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

/// Libellé de prévalence.
String prevalLabel(double? preval) {
  if (preval == null) return 'Données indisponibles';
  if (preval >= 90) return 'Universel';
  if (preval >= 70) return 'Très connu';
  if (preval >= 50) return 'Assez connu';
  return 'Peu connu';
}

/// Couleur de la jauge de prévalence.
Color prevalColor(double? preval) {
  if (preval == null) return Colors.grey;
  if (preval >= 90) return Colors.green;
  if (preval >= 70) return Colors.lightGreen;
  if (preval >= 50) return Colors.orange;
  return Colors.red;
}

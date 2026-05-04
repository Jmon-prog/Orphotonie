// ============================================================
// Fichier : lib/features/games/crossword/widgets/number_badge.dart
// Description : Badge numéroté affiché en haut à gauche
//               des cases de début de mot.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';

/// Badge affichant le numéro d'un mot dans la grille.
class NumberBadge extends StatelessWidget {
  const NumberBadge({
    super.key,
    required this.number,
    this.size = 14,
  });

  /// Numéro à afficher.
  final int number;

  /// Taille de la police.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 1,
      left: 2,
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

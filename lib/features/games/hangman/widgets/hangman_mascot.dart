// ============================================================
// Fichier : lib/features/games/hangman/widgets/hangman_mascot.dart
// Description : Mascotte du jeu Pendu — ballon qui se dégonfle.
//               8 états progressifs dessinés en CustomPainter.
//               Friendly, adapté aux enfants (pas de pendaison).
//               100 % hors-ligne, aucun asset réseau.
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';

/// Mascotte ballon avec 8 états de dégonflage.
///
/// [state] va de 0 (ballon intact) à 8 (ballon éclaté).
/// Animation fluide entre les états via [AnimatedSwitcher].
class HangmanMascot extends StatelessWidget {
  const HangmanMascot({
    super.key,
    required this.state,
    this.size = 200,
  });

  /// État courant de la mascotte (0 = intact, 8 = éclaté).
  final int state;

  /// Taille du widget (carré).
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: state == 0
          ? 'Ballon intact'
          : state >= 8
              ? 'Ballon éclaté'
              : 'Ballon dégonflé, état $state sur 8',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        child: CustomPaint(
          painter: _BalloonPainter(
            state: state,
            balloonColor: _colorForState(state),
          ),
        ),
      ),
    );
  }

  Color _colorForState(int state) {
    if (state <= 2) return Colors.green.shade400;
    if (state <= 4) return Colors.orange.shade400;
    if (state <= 6) return Colors.red.shade400;
    return Colors.red.shade700;
  }
}

class _BalloonPainter extends CustomPainter {
  _BalloonPainter({
    required this.state,
    required this.balloonColor,
  });

  final int state;
  final Color balloonColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (state >= 8) {
      _drawBurst(canvas, size);
      return;
    }

    final cx = size.width / 2;
    final cy = size.height * 0.4;

    // Rayon du ballon (rétrécit avec les erreurs)
    final maxRadius = size.width * 0.35;
    final shrinkFactor = 1.0 - (state / 8.0) * 0.6;
    final radius = maxRadius * shrinkFactor;

    // Déformation : le ballon devient de plus en plus ovale / tordu
    final deformX = 1.0 - (state / 8.0) * 0.3;
    final deformY = 1.0 + (state / 8.0) * 0.15;

    // Peinture du ballon
    final balloonPaint = Paint()
      ..color = balloonColor.withAlpha(230)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(deformX, deformY);

    // Corps du ballon
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2,
        height: radius * 2.2,
      ),
      balloonPaint,
    );

    // Reflet
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(80)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-radius * 0.25, -radius * 0.35),
        width: radius * 0.5,
        height: radius * 0.7,
      ),
      highlightPaint,
    );

    canvas.restore();

    // Nœud du ballon
    final knotY = cy + radius * deformY * 1.1;
    final knotPaint = Paint()
      ..color = balloonColor
      ..style = PaintingStyle.fill;
    final knotPath = Path()
      ..moveTo(cx - 5, knotY)
      ..lineTo(cx + 5, knotY)
      ..lineTo(cx, knotY + 10)
      ..close();
    canvas.drawPath(knotPath, knotPaint);

    // Ficelle
    final stringPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final stringPath = Path()
      ..moveTo(cx, knotY + 10)
      ..cubicTo(
        cx - 10,
        knotY + 40,
        cx + 10,
        knotY + 60,
        cx,
        size.height * 0.9,
      );
    canvas.drawPath(stringPath, stringPaint);

    // Visage du ballon (yeux + bouche)
    _drawFace(canvas, cx, cy, radius * shrinkFactor);

    // Pansements / fissures selon l'état
    if (state >= 3) {
      _drawCracks(canvas, cx, cy, radius * shrinkFactor);
    }

    // Gouttes d'air qui s'échappent (états 5+)
    if (state >= 5) {
      _drawAirDrops(canvas, cx, cy, radius);
    }
  }

  void _drawFace(Canvas canvas, double cx, double cy, double radius) {
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Yeux
    final eyeY = cy - radius * 0.15;
    final eyeSpacing = radius * 0.3;
    canvas.drawCircle(Offset(cx - eyeSpacing, eyeY), 4, eyePaint);
    canvas.drawCircle(Offset(cx + eyeSpacing, eyeY), 4, eyePaint);

    // Bouche (souriante → triste selon état)
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final mouthY = cy + radius * 0.15;
    final mouthWidth = radius * 0.35;

    if (state <= 2) {
      // Sourire
      final smilePath = Path()
        ..moveTo(cx - mouthWidth, mouthY)
        ..quadraticBezierTo(cx, mouthY + 12, cx + mouthWidth, mouthY);
      canvas.drawPath(smilePath, mouthPaint);
    } else if (state <= 5) {
      // Neutre
      canvas.drawLine(
        Offset(cx - mouthWidth, mouthY + 4),
        Offset(cx + mouthWidth, mouthY + 4),
        mouthPaint,
      );
    } else {
      // Triste
      final sadPath = Path()
        ..moveTo(cx - mouthWidth, mouthY + 10)
        ..quadraticBezierTo(cx, mouthY - 4, cx + mouthWidth, mouthY + 10);
      canvas.drawPath(sadPath, mouthPaint);
    }

    // Yeux inquiets (états 6+)
    if (state >= 6) {
      final browPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      // Sourcils inquiets
      canvas.drawLine(
        Offset(cx - eyeSpacing - 6, eyeY - 10),
        Offset(cx - eyeSpacing + 6, eyeY - 6),
        browPaint,
      );
      canvas.drawLine(
        Offset(cx + eyeSpacing + 6, eyeY - 10),
        Offset(cx + eyeSpacing - 6, eyeY - 6),
        browPaint,
      );
    }
  }

  void _drawCracks(Canvas canvas, double cx, double cy, double radius) {
    final crackPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Fissure 1
    final crack1 = Path()
      ..moveTo(cx + radius * 0.4, cy - radius * 0.3)
      ..lineTo(cx + radius * 0.5, cy - radius * 0.1)
      ..lineTo(cx + radius * 0.35, cy + radius * 0.1);
    canvas.drawPath(crack1, crackPaint);

    if (state >= 5) {
      // Fissure 2
      final crack2 = Path()
        ..moveTo(cx - radius * 0.3, cy + radius * 0.2)
        ..lineTo(cx - radius * 0.45, cy + radius * 0.4)
        ..lineTo(cx - radius * 0.25, cy + radius * 0.5);
      canvas.drawPath(crack2, crackPaint);
    }
  }

  void _drawAirDrops(Canvas canvas, double cx, double cy, double radius) {
    final dropPaint = Paint()
      ..color = Colors.grey.shade300.withAlpha(120)
      ..style = PaintingStyle.fill;

    // Petites bulles d'air
    canvas.drawCircle(
      Offset(cx + radius * 0.6, cy - radius * 0.5),
      4,
      dropPaint,
    );
    canvas.drawCircle(
      Offset(cx + radius * 0.75, cy - radius * 0.7),
      3,
      dropPaint,
    );
    if (state >= 7) {
      canvas.drawCircle(
        Offset(cx + radius * 0.5, cy - radius * 0.8),
        5,
        dropPaint,
      );
    }
  }

  void _drawBurst(Canvas canvas, Size size) {
    // État 8 : ballon éclaté — éclats qui volent
    final cx = size.width / 2;
    final cy = size.height * 0.4;
    final random = Random(42); // Seed fixe pour reproductibilité

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi;
      final dist = 20.0 + random.nextDouble() * 40;
      final fragmentPaint = Paint()
        ..color = Colors.red.shade400.withAlpha(180)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              cx + cos(angle) * dist,
              cy + sin(angle) * dist,
            ),
            width: 8 + random.nextDouble() * 8,
            height: 4 + random.nextDouble() * 6,
          ),
          const Radius.circular(2),
        ),
        fragmentPaint,
      );
    }

    // Ficelle tombée
    final stringPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final stringPath = Path()
      ..moveTo(cx, cy + 30)
      ..cubicTo(
        cx - 15,
        cy + 50,
        cx + 10,
        cy + 70,
        cx - 5,
        size.height * 0.9,
      );
    canvas.drawPath(stringPath, stringPaint);

    // Texte "POP!"
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'POP!',
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter oldDelegate) =>
      oldDelegate.state != state;
}

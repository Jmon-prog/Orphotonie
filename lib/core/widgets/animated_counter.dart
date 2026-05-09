// ============================================================
// Fichier : lib/core/widgets/animated_counter.dart
// Description : Compteur animé pour les statistiques (scores, streaks…).
//               Utilise AnimatedSwitcher avec une transition verticale
//               pour donner vie aux chiffres qui changent.
//               Respecte reduceAnimations via MediaQuery.
// ============================================================

import 'package:flutter/material.dart';

/// Compteur numérique animé.
///
/// Anime le changement de valeur par un glissement vertical (chiffre
/// entrant par le bas, sortant par le haut). Désactivé si l'utilisateur
/// a activé "Réduire les animations" dans les paramètres.
///
/// Utilisation :
/// ```dart
/// AnimatedCounter(
///   value: stats.totalWords,
///   style: theme.textTheme.headlineMedium,
/// )
/// ```
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix,
    this.suffix,
    this.duration = const Duration(milliseconds: 400),
  });

  /// Valeur numérique à afficher et à animer lors de chaque changement.
  final int value;

  /// Style typographique (null = hérite du style du parent).
  final TextStyle? style;

  /// Texte affiché avant la valeur (ex : '€ ').
  final String? prefix;

  /// Texte affiché après la valeur (ex : ' pts').
  final String? suffix;

  /// Durée de la transition entre deux valeurs (défaut : 400 ms).
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final text = '${prefix ?? ''}$value${suffix ?? ''}';

    if (reduceMotion) {
      return Text(text, style: style);
    }

    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        text,
        key: ValueKey(value),
        style: style,
      ),
    );
  }
}

/// Badge de score animé — pour les jeux (points gagnés).
///
/// Affiche brièvement une valeur "+N" qui apparaît puis disparaît.
class ScoreBadge extends StatefulWidget {
  const ScoreBadge({
    super.key,
    required this.points,
    this.color,
    this.onComplete,
  });

  /// Nombre de points gagnés à afficher (formaté « +N »).
  final int points;

  /// Couleur de fond du badge (défaut : couleur secondaire du thème).
  final Color? color;

  /// Appelé à la fin de l'animation de disparition, par ex. pour retirer
  /// le widget de l'arbre.
  final VoidCallback? onComplete;

  @override
  State<ScoreBadge> createState() => _ScoreBadgeState();
}

class _ScoreBadgeState extends State<ScoreBadge>
    with SingleTickerProviderStateMixin {
  /// Contrôleur principal de l'animation (entrée → pause → sortie).
  late final AnimationController _ctrl;

  /// Interpolation d'opacité : 0 → 1 (entrée) → 1 (pause) → 0 (sortie).
  late final Animation<double> _opacity;

  /// Interpolation de déplacement vertical : 0 → -1,2 (monte vers le haut).
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    // Séquence en 3 phases pondérées : entrée rapide (20%) → plateau (50%) → sortie douce (30%)
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.2),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.secondary;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '+${widget.points}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

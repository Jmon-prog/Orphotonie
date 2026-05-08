// ============================================================
// Fichier : lib/core/widgets/profile_avatar.dart
// Description : Avatar de profil avec tag Hero pour la transition
//               animée entre l'écran de sélection et l'écran principal.
//               Affiche l'image locale ou une initiale colorée.
//               Respecte reduceAnimations via MediaQuery.
// ============================================================

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';

/// Clé Hero partagée entre l'écran de sélection et le header de session.
///
/// Retourne un tag unique par profil pour éviter les collisions Hero.
String profileHeroTag(int profileId) => 'profile_avatar_$profileId';

/// Avatar de profil avec Hero pour les transitions de navigation.
///
/// - Si [avatarPath] est fourni et le fichier existe → image
/// - Sinon → cercle coloré avec l'initiale du prénom
///
/// Le tag Hero est automatiquement désactivé si :
/// - l'utilisateur a activé "Réduire les animations",
/// - [useHero] est `false` (ex : grille de sélection sans destination Hero),
/// - l'application tourne sur Flutter Web (Hero peut causer un rendu blanc
///   pendant la mesure initiale de la route sur le web).
///
/// Utilisation (écran de sélection) :
/// ```dart
/// ProfileAvatar(
///   profileId: profile.id,
///   prenom: profile.prenom,
///   avatarPath: profile.avatarPath,
///   radius: 32,
/// )
/// ```
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profileId,
    required this.prenom,
    this.avatarPath,
    this.radius = 28,
    this.backgroundColor,
    this.foregroundColor,
    this.useHero = true,
  });

  /// Identifiant unique du profil (sert de clé Hero).
  final int profileId;

  /// Prénom du profil — utilisé pour l'initiale et la couleur déterministe.
  final String prenom;

  /// Chemin absolu vers l'image locale (null = initiale colorée).
  final String? avatarPath;

  /// Rayon du cercle en dp (défaut : 28).
  final double radius;

  /// Couleur de fond de l'avatar (null = couleur déterministe basée sur le prénom).
  final Color? backgroundColor;

  /// Couleur du texte de l'initiale (null = calculée selon la luminance du fond).
  final Color? foregroundColor;

  /// Active ou désactive le tag Hero (défaut : `true`).
  ///
  /// Mettre à `false` sur les écrans dont la destination ne possède pas
  /// de [ProfileAvatar] correspondant, ou pour éviter les artefacts web.
  final bool useHero;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final avatar = _buildAvatar(context);

    // Hero désactivé : réduction des animations, useHero=false, ou plateforme web
    // (sur web, le Hero peut placer le contenu dans l'Overlay pendant la mesure
    // initiale de la route, laissant un espace vide dans la carte).
    if (reduceMotion || !useHero || kIsWeb) return avatar;

    return Hero(
      tag: profileHeroTag(profileId),
      // Fait fondre l'avatar source pendant la transition de page.
      flightShuttleBuilder: (_, animation, __, fromCtx, toCtx) {
        return FadeTransition(opacity: animation, child: toCtx.widget);
      },
      child: avatar,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);

    // Image locale — non disponible sur Flutter Web (pas de système de fichiers)
    if (!kIsWeb &&
        avatarPath != null &&
        avatarPath!.isNotEmpty &&
        File(avatarPath!).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(avatarPath!)),
      );
    }

    // Initiale colorée
    final initial =
        prenom.isNotEmpty ? prenom.substring(0, 1).toUpperCase() : '?';
    final bg =
        backgroundColor ?? _colorFromName(prenom, theme.colorScheme.primary);
    final fg = foregroundColor ??
        (bg.computeLuminance() > 0.4 ? Colors.black87 : Colors.white);

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  /// Génère une couleur déterministe à partir du prénom (palette AppColors).
  static Color _colorFromName(String name, Color fallback) {
    if (name.isEmpty) return fallback;
    const palette = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      Color(0xFF7986CB), // Indigo (thème Espace)
      Color(0xFF2E7D32), // Vert (thème Forêt)
      Color(0xFF01579B), // Bleu (thème Océan)
      Color(0xFF6A1B9A), // Violet (thème Fantasy)
    ];
    final index = name.codeUnitAt(0) % palette.length;
    return palette[index];
  }
}

/// Badge d'état sur l'avatar (ex : praticien = étoile, enfant = pas de badge).
class ProfileAvatarWithBadge extends StatelessWidget {
  const ProfileAvatarWithBadge({
    super.key,
    required this.avatar,
    this.badge,
    this.badgeOffset = const Offset(0.7, 0.7),
  });

  /// Avatar de base sur lequel superposer le badge.
  final ProfileAvatar avatar;

  /// Widget superposé en bas à droite (null = pas de badge).
  final Widget? badge;

  /// Position relative du badge dans le Stack (défaut : bas-droite).
  final Offset badgeOffset;

  @override
  Widget build(BuildContext context) {
    if (badge == null) return avatar;
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: badge!,
          ),
        ),
      ],
    );
  }
}

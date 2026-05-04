// ============================================================
// Fichier : lib/features/enfant/enfant_home_screen.dart
// Description : Écran d'accueil de l'espace enfant.
//               Affiche les dictionnaires du profil et permet de
//               lancer une activité (jeu) depuis un sélecteur.
//               Responsive mobile/tablette/desktop. 100 % hors ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_providers.dart';
import '../../core/router/app_router.dart';
import '../auth/notifiers/auth_notifier.dart';

// ---------------------------------------------------------------------------
// Définition des 5 jeux disponibles
// ---------------------------------------------------------------------------

/// Représente un jeu disponible dans l'espace enfant.
class _GameEntry {
  const _GameEntry({
    required this.route,
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });

  /// Route go_router de lancement du jeu.
  final String route;

  /// Nom affiché.
  final String label;

  /// Icône Material.
  final IconData icon;

  /// Couleur de la carte du jeu.
  final Color color;

  /// Courte description pour l'enfant.
  final String description;
}

/// Liste statique des 8 jeux disponibles.
const _kGames = [
  _GameEntry(
    route: AppRoutes.anagramme,
    label: 'Anagramme',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFF6A5AE0),
    description: 'Remets les lettres dans le bon ordre !',
  ),
  _GameEntry(
    route: AppRoutes.pendu,
    label: 'Pendu',
    icon: Icons.text_fields_rounded,
    color: Color(0xFFE05A5A),
    description: 'Trouve le mot lettre par lettre.',
  ),
  _GameEntry(
    route: AppRoutes.motLacunaire,
    label: 'Mot Lacunaire',
    icon: Icons.edit_note_rounded,
    color: Color(0xFF5AAdE0),
    description: 'Complète les lettres manquantes.',
  ),
  _GameEntry(
    route: AppRoutes.motsCaches,
    label: 'Mots Cachés',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF5AE09A),
    description: 'Retrouve les mots dans la grille.',
  ),
  _GameEntry(
    route: AppRoutes.motsCroises,
    label: 'Mots Croisés',
    icon: Icons.grid_on_rounded,
    color: Color(0xFFE0AD5A),
    description: 'Remplis la grille de mots croisés.',
  ),
  _GameEntry(
    route: AppRoutes.flashcard,
    label: 'Flashcard',
    icon: Icons.style_rounded,
    color: Color(0xFF5A7AE0),
    description: 'Mémorise les mots avec des cartes.',
  ),
  _GameEntry(
    route: AppRoutes.definitionQcm,
    label: 'QCM Définition',
    icon: Icons.quiz_rounded,
    color: Color(0xFFB05AE0),
    description: 'Trouve la bonne définition !',
  ),
  _GameEntry(
    route: AppRoutes.roueSyllabes,
    label: 'Syllabes',
    icon: Icons.record_voice_over_rounded,
    color: Color(0xFF5ABDE0),
    description: 'Remets les syllabes dans l\'ordre.',
  ),
  _GameEntry(
    route: AppRoutes.memory,
    label: 'Memory',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF5AE0C0),
    description: 'Retrouve les paires mot-définition !',
  ),
];

// ---------------------------------------------------------------------------
// Résolution du nom d'icône Material stocké en base de données
// ---------------------------------------------------------------------------

/// Résout le nom d'icône Material stocké comme chaîne dans [Dictionaries.icon].
/// Retourne [Icons.book] en cas de nom inconnu.
IconData _resolveIcon(String? name) {
  switch (name) {
    case 'book':
      return Icons.book_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'school':
      return Icons.school_rounded;
    case 'pets':
      return Icons.pets_rounded;
    case 'nature':
      return Icons.park_rounded;
    case 'home':
      return Icons.home_rounded;
    case 'favorite':
      return Icons.favorite_rounded;
    case 'sports':
      return Icons.sports_rounded;
    case 'music_note':
      return Icons.music_note_rounded;
    case 'palette':
      return Icons.palette_rounded;
    case 'directions_car':
      return Icons.directions_car_rounded;
    case 'restaurant':
      return Icons.restaurant_rounded;
    default:
      return Icons.book_rounded;
  }
}

/// Convertit une couleur hexadécimale (#RRGGBB ou RRGGBB) en [Color].
Color _hexColor(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFF6A5AE0);
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

// ---------------------------------------------------------------------------
// Écran principal
// ---------------------------------------------------------------------------

/// Écran d'accueil de l'espace enfant.
///
/// Affiche la liste des dictionnaires du profil enfant connecté.
/// Chaque carte de dictionnaire permet de lancer un jeu via
/// [_GamePickerSheet].
class EnfantHomeScreen extends ConsumerWidget {
  const EnfantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(currentChildProvider);
    if (child == null) {
      // Sécurité : ne devrait pas arriver si le routeur est correct.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Flux des dictionnaires assignés à cet enfant via la table de liaison
    final dicsStream = ref
        .watch(dictionaryAssignmentsDaoProvider)
        .watchDictionariesForChild(child.id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _ChildGreeting(child: child),
        actions: [
          Semantics(
            label: 'Quitter l\'espace enfant',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Quitter',
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                context.go(AppRoutes.profiles);
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Dictionary>>(
        stream: dicsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger les listes : ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final dics = snapshot.data ?? [];

          // Bannière Découverte + grille des dictionnaires
          return CustomScrollView(
            slivers: [
              // ── Bannière Mode Découverte ──────────────────────────────────
              if (child.allowDiscoveryMode)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: _DiscoveryBanner(profileId: child.id),
                  ),
                ),

              // ── Message liste vide ────────────────────────────────────────
              if (dics.isEmpty)
                SliverFillRemaining(
                  child: _EmptyDictionaryState(prenom: child.prenom),
                )
              else
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.crossAxisExtent < 480
                        ? 1
                        : constraints.crossAxisExtent < 800
                            ? 2
                            : 3;
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: crossAxisCount == 1 ? 2.8 : 1.6,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _DictionaryCard(
                            dictionary: dics[i],
                            profileId: child.id,
                          ),
                          childCount: dics.length,
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// En-tête de salutation
// ---------------------------------------------------------------------------

/// Salutation dans l'AppBar : avatar emoji + prénom de l'enfant.
class _ChildGreeting extends StatelessWidget {
  const _ChildGreeting({required this.child});

  final Profile child;

  @override
  Widget build(BuildContext context) {
    final avatar = child.avatarPath;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (avatar != null && avatar.isNotEmpty)
          Text(avatar, style: const TextStyle(fontSize: 22))
        else
          const Icon(Icons.child_care_rounded),
        const SizedBox(width: 8),
        Text(
          'Bonjour ${child.prenom} !',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// État vide
// ---------------------------------------------------------------------------

/// Affiché quand l'enfant n'a aucun dictionnaire actif.
class _EmptyDictionaryState extends StatelessWidget {
  const _EmptyDictionaryState({required this.prenom});

  final String prenom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 72,
              color: theme.colorScheme.primary.withAlpha(140),
            ),
            const SizedBox(height: 20),
            Text(
              'Pas encore de liste, $prenom !',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Demande à ton orthophoniste ou à tes parents\n'
              'de créer une liste de mots pour toi.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carte de dictionnaire
// ---------------------------------------------------------------------------

/// Carte cliquable représentant un dictionnaire.
/// Affiche : nom, icône, couleur du dictionnaire et nombre de mots.
/// Un tap ouvre le sélecteur de jeu [_GamePickerSheet].
class _DictionaryCard extends ConsumerWidget {
  const _DictionaryCard({
    required this.dictionary,
    required this.profileId,
  });

  final Dictionary dictionary;
  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dicColor = _hexColor(dictionary.couleur);
    final dicIcon = _resolveIcon(dictionary.icon);

    return Semantics(
      label: 'Dictionnaire ${dictionary.nom}. Appuie pour choisir un jeu.',
      button: true,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: dicColor.withAlpha(100),
            width: 1.5,
          ),
        ),
        color: dicColor.withAlpha(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showGamePicker(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icône colorée
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: dicColor.withAlpha(45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(dicIcon, color: dicColor, size: 28),
                ),
                const SizedBox(width: 14),

                // Nom + nombre de mots
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dictionary.nom,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _WordCountLabel(dictionaryId: dictionary.id),
                    ],
                  ),
                ),

                // Bouton jouer + menu
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: dicColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _showGamePicker(context, ref),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Jouer'),
                ),
                const SizedBox(width: 4),
                // Menu contextuel (supprimer)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  tooltip: 'Options',
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 20,),
                          SizedBox(width: 10),
                          Text('Supprimer cette liste',
                              style: TextStyle(color: Colors.red),),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, ref);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Dialog de confirmation avant suppression.
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette liste ?'),
        content: Text(
          'La liste "${dictionary.nom}" sera définitivement supprimée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(appDatabaseProvider)
            .dictionaryAssignmentsDao
            .unassignDictionary(dictionary.id, profileId);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de supprimer cette liste.')),
        );
      }
    }
  }

  /// Ouvre le sélecteur de jeu en bas de l'écran.
  void _showGamePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _GamePickerSheet(
        dictionary: dictionary,
        profileId: profileId,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compteur de mots réactif
// ---------------------------------------------------------------------------

/// Affiche le nombre de mots d'un dictionnaire de façon réactive (Stream).
class _WordCountLabel extends ConsumerWidget {
  const _WordCountLabel({required this.dictionaryId});

  final int dictionaryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream =
        ref.watch(wordsDaoProvider).watchWordsForDictionary(dictionaryId);

    return StreamBuilder<List<Word>>(
      stream: stream,
      builder: (context, snap) {
        final count = snap.data?.length;
        final label = count == null
            ? '…'
            : count == 0
                ? 'Aucun mot'
                : count == 1
                    ? '1 mot'
                    : '$count mots';

        return Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
              ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sélecteur de jeu (ModalBottomSheet)
// ---------------------------------------------------------------------------

/// Feuille modale listant les 5 jeux disponibles.
/// Permet à l'enfant de choisir le jeu qu'il souhaite jouer.
class _GamePickerSheet extends StatelessWidget {
  const _GamePickerSheet({
    required this.dictionary,
    required this.profileId,
  });

  final Dictionary dictionary;
  final int profileId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poignée
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Titre de la liste
            Text(
              dictionary.nom,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Choisir un jeu',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
            const SizedBox(height: 18),

            // Grille des jeux
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 400 ? 2 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.05,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _kGames.length,
                  itemBuilder: (context, i) => _GameCard(
                    game: _kGames[i],
                    onTap: () => _launchGame(context, _kGames[i]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Ferme la feuille et navigue vers le jeu sélectionné.
  void _launchGame(BuildContext context, _GameEntry game) {
    Navigator.of(context).pop();

    // Construction de l'URL avec les paramètres requis par chaque jeu.
    final uri = Uri(
      path: game.route,
      queryParameters: {
        'dicId': dictionary.id.toString(),
        'profileId': profileId.toString(),
        'dicName': dictionary.nom,
      },
    );
    context.push(uri.toString());
  }
}

// ---------------------------------------------------------------------------
// Carte de jeu
// ---------------------------------------------------------------------------

/// Carte d'un jeu dans le sélecteur.
class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onTap});

  final _GameEntry game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${game.label}. ${game.description}',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: game.color.withAlpha(28),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: game.color.withAlpha(90), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: game.color.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(game.icon, color: game.color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  game.label,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
// Bannière Mode Découverte
// ---------------------------------------------------------------------------

/// Carte interactive permettant d'accéder au mode Découverte.
/// Visible uniquement si [allowDiscoveryMode] est activé sur le profil enfant.
class _DiscoveryBanner extends StatelessWidget {
  const _DiscoveryBanner({required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = Color(0xFF5AE0C0);

    return Semantics(
      label: 'Mode Découverte. Explore de nouveaux mots par niveau scolaire.',
      button: true,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: color, width: 2),
        ),
        color: color.withAlpha(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go(
            '${AppRoutes.decouverteConfig}?profileId=$profileId',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icône
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withAlpha(50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),

                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode Découverte',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A8B74),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Explore de nouveaux mots par niveau scolaire',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                // Chevron
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

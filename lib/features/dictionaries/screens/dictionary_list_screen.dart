// ============================================================
// Fichier : lib/features/dictionaries/screens/dictionary_list_screen.dart
// Description : Écran principal praticien — liste des dictionnaires.
//               Stream réactif Drift, swipe pour supprimer, long press pour éditer.
//               Responsive mobile / tablette / desktop.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/notifiers/auth_notifier.dart';
import 'add_edit_dictionary_screen.dart';
import 'assign_dictionary_screen.dart';

// ---------------------------------------------------------------------------
// Palette de couleurs (dupliquée depuis add_edit pour éviter le couplage)
// ---------------------------------------------------------------------------
Color _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

const _kIcons = <String, IconData>{
  'book': Icons.book,
  'star': Icons.star,
  'pets': Icons.pets,
  'school': Icons.school,
  'music_note': Icons.music_note,
  'favorite': Icons.favorite,
  'emoji_nature': Icons.emoji_nature,
  'sports_soccer': Icons.sports_soccer,
  'home': Icons.home,
  'directions_car': Icons.directions_car,
};

// ---------------------------------------------------------------------------
// Écran
// ---------------------------------------------------------------------------

/// Liste des dictionnaires du praticien connecté.
class DictionaryListScreen extends ConsumerWidget {
  const DictionaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final profile = switch (authState) {
      PractitionerAuth(profile: final p) => p,
      _ => null,
    };

    if (profile == null) {
      // Ne devrait pas arriver (router protège cette route)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Flux des dictionnaires appartenant au praticien (jamais affecté par les assignations)
    final dicsStream = ref
        .watch(dictionariesDaoProvider)
        .watchDictionariesForPractitioner(profile.id);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mes Dictionnaires'),
            Text(
              '${profile.prenom} ${profile.nom ?? ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Paramètres',
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Paramètres',
              onPressed: () => context.go(AppRoutes.parametres),
            ),
          ),
          Semantics(
            label: 'Se déconnecter',
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Déconnexion',
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
              child: Text('Erreur : [${snapshot.error}'),
            );
          }
          final dics = snapshot.data ?? [];

          if (dics.isEmpty) {
            return _EmptyState(profileId: profile.id);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Vue grille sur tablette/desktop, liste sur mobile
              if (constraints.maxWidth > 700) {
                return _GridView(dics: dics, profileId: profile.id);
              }
              return _ListView(dics: dics, profileId: profile.id);
            },
          );
        },
      ),
      floatingActionButton: Semantics(
        label: 'Créer un nouveau dictionnaire',
        child: FloatingActionButton.extended(
          onPressed: () => context.go(AppRoutes.newDictionary),
          icon: const Icon(Icons.add),
          label: const Text('Nouveau'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vues — liste et grille
// ---------------------------------------------------------------------------

class _ListView extends ConsumerWidget {
  const _ListView({required this.dics, required this.profileId});
  final List<Dictionary> dics;
  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: dics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final dic = dics[i];
        return _DictionaryTile(dic: dic, profileId: profileId);
      },
    );
  }
}

class _GridView extends ConsumerWidget {
  const _GridView({required this.dics, required this.profileId});
  final List<Dictionary> dics;
  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: dics.length,
      itemBuilder: (context, i) => _DictionaryCard(
        dic: dics[i],
        profileId: profileId,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tuile liste
// ---------------------------------------------------------------------------

class _DictionaryTile extends ConsumerWidget {
  const _DictionaryTile({required this.dic, required this.profileId});
  final Dictionary dic;
  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _hexToColor(dic.couleur);
    return Dismissible(
      key: Key('dic_${dic.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _delete(context, ref),
      child: Semantics(
        label: 'Dictionnaire ${dic.nom}. Glisser pour supprimer.',
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.go(
              '${AppRoutes.dictionnaires}/${dic.id}/mots?nom=${Uri.encodeComponent(dic.nom)}',
            ),
            onLongPress: () => _openEdit(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icône colorée
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _kIcons[dic.icon] ?? Icons.book,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Texte
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dic.nom,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (dic.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            dic.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Actions
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_outlined),
                    tooltip: 'Assigner à un enfant',
                    onPressed: () => _openAssign(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Modifier',
                    onPressed: () => _openEdit(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAssign(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AssignDictionaryScreen(dictionary: dic),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openEdit(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AddEditDictionaryScreen(profileId: profileId, dictionary: dic),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(dictionariesDaoProvider).deleteDictionary(dic.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le dictionnaire ?'),
        content: Text(
          'Le dictionnaire « ${dic.nom} » et tous ses mots seront supprimés définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carte grille
// ---------------------------------------------------------------------------

class _DictionaryCard extends ConsumerWidget {
  const _DictionaryCard({required this.dic, required this.profileId});
  final Dictionary dic;
  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _hexToColor(dic.couleur);
    return Semantics(
      label: 'Dictionnaire ${dic.nom}',
      child: GestureDetector(
        onTap: () => context.go(
          '${AppRoutes.dictionnaires}/${dic.id}/mots?nom=${Uri.encodeComponent(dic.nom)}',
        ),
        onLongPress: () => Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                AddEditDictionaryScreen(profileId: profileId, dictionary: dic),
            fullscreenDialog: true,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withAlpha(204)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(77),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _kIcons[dic.icon] ?? Icons.book,
                    color: Colors.white,
                    size: 28,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => AssignDictionaryScreen(dictionary: dic),
                        fullscreenDialog: true,
                      ),
                    ),
                    child: const Tooltip(
                      message: 'Assigner à un enfant',
                      child: Icon(
                        Icons.person_add_alt_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => AddEditDictionaryScreen(
                          profileId: profileId,
                          dictionary: dic,
                        ),
                        fullscreenDialog: true,
                      ),
                    ),
                    child:
                        const Icon(Icons.edit, color: Colors.white70, size: 18),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                dic.nom,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (dic.description != null)
                Text(
                  dic.description!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// État vide
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.profileId});
  final int profileId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withAlpha(102),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun dictionnaire',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre premier dictionnaire pour commencer à\najouter des mots pour l\'enfant.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Créer un dictionnaire'),
              onPressed: () => Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => AddEditDictionaryScreen(profileId: profileId),
                  fullscreenDialog: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

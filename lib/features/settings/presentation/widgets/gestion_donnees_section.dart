// ============================================================
// Fichier : lib/features/settings/presentation/widgets/gestion_donnees_section.dart
// Description : Section "Gestion des profils" dans l'écran Paramètres.
//               Visible uniquement pour les praticiens.
//               Propose 3 niveaux d'actions :
//                 Niveau 1 — Actions par profil enfant (archive, reset, suppr.)
//                 Niveau 2 — Supprimer tous les profils enfants
//                 Niveau 3 — Réinitialisation complète (PIN + confirmation)
//               100 % hors ligne, responsive, accessible (Semantics).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_providers.dart';
import '../../../../features/auth/notifiers/auth_notifier.dart';
import '../../../../features/auth/services/pin_service.dart';

// ---------------------------------------------------------------------------
// Section principale
// ---------------------------------------------------------------------------

/// Section "Gestion des profils" pour l'écran Paramètres.
/// Visible uniquement quand [isPractitioner] est vrai.
class GestionDonneesSection extends ConsumerStatefulWidget {
  const GestionDonneesSection({super.key, required this.praticienId});

  final int praticienId;

  @override
  ConsumerState<GestionDonneesSection> createState() =>
      _GestionDonneesSectionState();
}

class _GestionDonneesSectionState extends ConsumerState<GestionDonneesSection> {
  bool _showArchived = false;

  // ---------------------------------------------------------------------------
  // Helpers de confirmation
  // ---------------------------------------------------------------------------

  /// Affiche une boîte de confirmation simple.
  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: confirmColor != null
                ? FilledButton.styleFrom(backgroundColor: confirmColor)
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Affiche une boîte de confirmation avec vérification du PIN praticien.
  Future<bool> _confirmWithPin(
    BuildContext context, {
    required int praticienId,
    required String title,
    required String content,
    required String confirmLabel,
  }) async {
    final pinController = TextEditingController();
    String? errorText;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'Code PIN praticien',
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
                onChanged: (_) {
                  if (errorText != null) {
                    setDialogState(() => errorText = null);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () async {
                final pinService = ref.read(pinServiceProvider);
                final hasPin = await pinService.hasPin();
                if (!hasPin ||
                    await pinService.verifyPin(
                      pinController.text.trim(),
                    )) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } else {
                  setDialogState(() => errorText = 'PIN incorrect');
                }
              },
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
    pinController.dispose();
    return result ?? false;
  }

  /// Affiche la boîte de confirmation avec saisie du mot RÉINITIALISER
  /// et vérification PIN — utilisée pour le factory reset.
  Future<bool> _confirmFactoryReset(
    BuildContext context, {
    required int praticienId,
  }) async {
    final wordController = TextEditingController();
    final pinController = TextEditingController();
    String? wordError;
    String? pinError;
    const confirmWord = 'RÉINITIALISER';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Réinitialisation complète'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Action irréversible',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cette action supprime définitivement :\n'
                      '• Tous les profils praticien et enfants\n'
                      '• Tous les dictionnaires et leurs mots\n'
                      '• Toutes les progressions et statistiques\n'
                      '• Tous les paramètres\n\n'
                      'Il n\'est pas possible d\'annuler cette opération.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tapez $confirmWord pour confirmer :',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: wordController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: confirmWord,
                  errorText: wordError,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (wordError != null) {
                    setDialogState(() => wordError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Code PIN praticien :',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  errorText: pinError,
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
                onChanged: (_) {
                  if (pinError != null) {
                    setDialogState(() => pinError = null);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade800,
              ),
              onPressed: () async {
                bool valid = true;

                // Vérifier le mot de confirmation
                if (wordController.text.trim() != confirmWord) {
                  setDialogState(
                    () => wordError = 'Tapez exactement : $confirmWord',
                  );
                  valid = false;
                }

                // Vérifier le PIN
                if (valid) {
                  final pinService = ref.read(pinServiceProvider);
                  if (await pinService.hasPin() &&
                      !await pinService.verifyPin(
                        pinController.text.trim(),
                      )) {
                    setDialogState(() => pinError = 'PIN incorrect');
                    valid = false;
                  }
                }

                if (valid && ctx.mounted) Navigator.of(ctx).pop(true);
              },
              child: const Text('Tout supprimer'),
            ),
          ],
        ),
      ),
    );
    wordController.dispose();
    pinController.dispose();
    return result ?? false;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _archiveProfile(Profile child) async {
    final ok = await _confirm(
      context,
      title: 'Archiver ${child.prenom} ?',
      content: '${child.prenom} n\'apparaîtra plus dans l\'écran de connexion. '
          'Toutes ses données (progression, dictionnaires) sont conservées. '
          'Vous pourrez restaurer ce profil à tout moment.',
      confirmLabel: 'Archiver',
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(profileManagementServiceProvider).archiveProfile(child.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${child.prenom} a été archivé.'),
            action: SnackBarAction(
              label: 'Annuler',
              onPressed: () => ref
                  .read(profileManagementServiceProvider)
                  .unarchiveProfile(child.id),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _unarchiveProfile(Profile child) async {
    try {
      await ref
          .read(profileManagementServiceProvider)
          .unarchiveProfile(child.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${child.prenom} a été restauré.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _resetProgression(Profile child) async {
    final ok = await _confirm(
      context,
      title: 'Réinitialiser la progression ?',
      content:
          'Tous les mots de ${child.prenom} seront remis en boîte 1 (Leitner). '
          'Les dictionnaires et les mots sont conservés. '
          'Cette action est utile en début d\'année scolaire.',
      confirmLabel: 'Réinitialiser',
      confirmColor: Colors.orange.shade700,
    );
    if (!ok || !mounted) return;
    try {
      final count = await ref
          .read(profileManagementServiceProvider)
          .resetProgression(child.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$count mot${count > 1 ? "s" : ""} réinitialisé${count > 1 ? "s" : ""} '
              'pour ${child.prenom}.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteProfile(Profile child) async {
    final ok = await _confirmWithPin(
      context,
      praticienId: widget.praticienId,
      title: 'Supprimer ${child.prenom} ?',
      content: 'Cette action supprime définitivement le profil et toutes ses '
          'données : progression, sessions, statistiques. '
          'Les dictionnaires du praticien sont conservés.\n\n'
          'Confirmez avec votre PIN.',
      confirmLabel: 'Supprimer',
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(profileManagementServiceProvider).deleteProfile(child.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil de ${child.prenom} supprimé.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteAllChildren() async {
    final ok = await _confirmWithPin(
      context,
      praticienId: widget.praticienId,
      title: 'Supprimer tous les profils enfants ?',
      content: 'Cette action supprime définitivement tous les profils enfants '
          '(actifs et archivés) et toutes leurs données. '
          'Vos dictionnaires sont conservés.\n\n'
          'Confirmez avec votre PIN.',
      confirmLabel: 'Tout supprimer',
    );
    if (!ok || !mounted) return;
    try {
      final count = await ref
          .read(profileManagementServiceProvider)
          .deleteAllChildProfiles(widget.praticienId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$count profil${count > 1 ? "s" : ""} supprimé${count > 1 ? "s" : ""}.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _factoryReset() async {
    final ok = await _confirmFactoryReset(
      context,
      praticienId: widget.praticienId,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(profileManagementServiceProvider).factoryReset();
      // Déconnecter et revenir à l'accueil
      if (mounted) {
        ref.read(authNotifierProvider.notifier).logout();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final activeChildren = ref.watch(
      _activeChildrenProvider(widget.praticienId),
    );
    final archivedChildren = ref.watch(
      _archivedChildrenProvider(widget.praticienId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------
        // Profils enfants actifs
        // ---------------------------------------------------------------
        const _SectionLabel(title: 'Gestion des profils'),
        const SizedBox(height: 8),
        Card(
          child: activeChildren.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erreur : $e'),
            ),
            data: (children) => children.isEmpty
                ? const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Aucun profil enfant'),
                    subtitle: Text(
                      'Créez des profils enfants depuis l\'accueil.',
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < children.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _ChildProfileTile(
                          child: children[i],
                          onArchive: () => _archiveProfile(children[i]),
                          onReset: () => _resetProgression(children[i]),
                          onDelete: () => _deleteProfile(children[i]),
                        ),
                      ],
                    ],
                  ),
          ),
        ),

        // ---------------------------------------------------------------
        // Profils archivés (section repliable)
        // ---------------------------------------------------------------
        archivedChildren.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (archived) {
            if (archived.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _showArchived = !_showArchived),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          _showArchived ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Profils archivés (${archived.length})',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showArchived)
                  Card(
                    child: Column(
                      children: [
                        for (int i = 0; i < archived.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          _ArchivedProfileTile(
                            child: archived[i],
                            onRestore: () => _unarchiveProfile(archived[i]),
                            onDelete: () => _deleteProfile(archived[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // ---------------------------------------------------------------
        // Zone de danger
        // ---------------------------------------------------------------
        const _SectionLabel(title: 'Zone de danger', isWarning: true),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade200),
          ),
          child: Column(
            children: [
              // Supprimer tous les enfants
              Semantics(
                button: true,
                label: 'Supprimer tous les profils enfants',
                child: ListTile(
                  leading: Icon(
                    Icons.group_remove,
                    color: Colors.orange.shade700,
                  ),
                  title: const Text('Supprimer tous les profils enfants'),
                  subtitle: const Text(
                    'Conserve vos dictionnaires — irréversible',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _deleteAllChildren,
                ),
              ),
              const Divider(height: 1),
              // Réinitialisation complète
              Semantics(
                button: true,
                label: 'Réinitialisation complète de l\'application',
                child: ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: Colors.red.shade700,
                  ),
                  title: const Text('Réinitialisation complète'),
                  subtitle: const Text(
                    'Supprime toutes les données — irréversible',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _factoryReset,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tuile profil enfant actif
// ---------------------------------------------------------------------------

class _ChildProfileTile extends StatelessWidget {
  const _ChildProfileTile({
    required this.child,
    required this.onArchive,
    required this.onReset,
    required this.onDelete,
  });

  final Profile child;
  final VoidCallback onArchive;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          child.prenom.substring(0, 1).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(child.prenom),
      subtitle: child.nom != null ? Text(child.nom!) : null,
      trailing: PopupMenuButton<_ChildAction>(
        tooltip: 'Actions pour ${child.prenom}',
        onSelected: (action) {
          switch (action) {
            case _ChildAction.archive:
              onArchive();
            case _ChildAction.reset:
              onReset();
            case _ChildAction.delete:
              onDelete();
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: _ChildAction.archive,
            child: ListTile(
              leading: Icon(Icons.archive_outlined),
              title: Text('Archiver'),
              subtitle: Text('Masque sans supprimer'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: _ChildAction.reset,
            child: ListTile(
              leading: Icon(Icons.restart_alt, color: Colors.orange),
              title: Text('Réinitialiser la progression'),
              subtitle: Text('Remet en boîte 1 Leitner'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: _ChildAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: Text('Irréversible'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tuile profil enfant archivé
// ---------------------------------------------------------------------------

class _ArchivedProfileTile extends StatelessWidget {
  const _ArchivedProfileTile({
    required this.child,
    required this.onRestore,
    required this.onDelete,
  });

  final Profile child;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text(
          child.prenom.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        child.prenom,
        style: TextStyle(color: Colors.grey.shade600),
      ),
      subtitle: Text(
        child.archivedAt != null
            ? 'Archivé le ${_formatDate(child.archivedAt!)}'
            : 'Archivé',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: PopupMenuButton<_ArchivedAction>(
        tooltip: 'Actions pour ${child.prenom}',
        onSelected: (action) {
          switch (action) {
            case _ArchivedAction.restore:
              onRestore();
            case _ArchivedAction.delete:
              onDelete();
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: _ArchivedAction.restore,
            child: ListTile(
              leading: Icon(Icons.unarchive_outlined),
              title: Text('Restaurer'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: _ArchivedAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Supprimer', style: TextStyle(color: Colors.red)),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

// ---------------------------------------------------------------------------
// Label de section interne
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.isWarning = false});

  final String title;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isWarning
                  ? Colors.red.shade700
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Enums d'actions
// ---------------------------------------------------------------------------

enum _ChildAction { archive, reset, delete }

enum _ArchivedAction { restore, delete }

// ---------------------------------------------------------------------------
// Providers locaux (StreamProvider.family)
// ---------------------------------------------------------------------------

final _activeChildrenProvider =
    StreamProvider.autoDispose.family<List<Profile>, int>((ref, praticienId) {
  return ref
      .watch(profilesDaoProvider)
      .watchActiveChildrenOfPractitioner(praticienId);
});

final _archivedChildrenProvider =
    StreamProvider.autoDispose.family<List<Profile>, int>((ref, praticienId) {
  return ref
      .watch(profilesDaoProvider)
      .watchArchivedChildrenOfPractitioner(praticienId);
});

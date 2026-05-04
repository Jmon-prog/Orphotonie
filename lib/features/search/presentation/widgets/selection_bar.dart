// ============================================================
// Fichier : lib/features/search/presentation/widgets/selection_bar.dart
// Description : Barre flottante apparaissant quand ≥1 mot est sélectionné.
//               Animation slide-up · Bouton "Ajouter X mots au dictionnaire"
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../search_providers.dart';

/// Barre d'action flottante ancrée en bas de l'écran.
/// Reçoit le [dictionaryId] cible (null = aucun dictionnaire sélectionné).
class SelectionBar extends ConsumerWidget {
  const SelectionBar({
    super.key,
    this.dictionaryId,
    this.dictionaryName,
    this.onAddToDictionary,
  });

  final int? dictionaryId;
  final String? dictionaryName;

  /// Callback déclenché quand l'utilisateur confirme l'ajout.
  /// Reçoit la liste des mots sélectionnés.
  final void Function(List<String> mots)? onAddToDictionary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchNotifierProvider);
    final count = state.selected.length;
    final visible = count > 0;

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !visible,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Voir la sélection
                TextButton.icon(
                  icon: const Icon(Icons.list),
                  label: Text('Voir ($count)'),
                  onPressed: visible ? () => _showSelectionSheet(context, ref) : null,
                ),
                const Spacer(),
                // Ajouter au dictionnaire
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(
                    dictionaryName != null
                        ? 'Ajouter $count → "${dictionaryName!}"'
                        : 'Ajouter $count mots',
                  ),
                  onPressed: visible
                      ? () {
                          final mots = state.selected.toList();
                          onAddToDictionary?.call(mots);
                          ref
                              .read(searchNotifierProvider.notifier)
                              .clearSelection();
                        }
                      : null,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Feuille récapitulative
  // ---------------------------------------------------------------------------

  void _showSelectionSheet(BuildContext context, WidgetRef ref) {
    final selected = ref.read(searchNotifierProvider).selected.toList()..sort();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SelectionSheet(
        mots: selected,
        dictionaryName: dictionaryName,
        onRemove: (mot) =>
            ref.read(searchNotifierProvider.notifier).toggleSelection(mot),
        onConfirm: () {
          final current = ref.read(searchNotifierProvider).selected.toList();
          onAddToDictionary?.call(current);
          ref.read(searchNotifierProvider.notifier).clearSelection();
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feuille récapitulative
// ---------------------------------------------------------------------------

class _SelectionSheet extends StatelessWidget {
  const _SelectionSheet({
    required this.mots,
    required this.dictionaryName,
    required this.onRemove,
    required this.onConfirm,
  });

  final List<String> mots;
  final String? dictionaryName;
  final void Function(String mot) onRemove;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          // Poignée
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // En-tête
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${mots.length} mots à ajouter',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (dictionaryName != null) ...[
                  const Text(' → '),
                  Text(
                    '"$dictionaryName"',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          // Liste
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: mots.length,
              itemBuilder: (_, i) {
                final mot = mots[i];
                return ListTile(
                  leading: const Icon(Icons.check, color: Colors.green),
                  title: Text(mot),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => onRemove(mot),
                    tooltip: 'Retirer',
                  ),
                );
              },
            ),
          ),
          // Bouton confirmer
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: Text('Confirmer l\'ajout de ${mots.length} mots'),
                onPressed: mots.isNotEmpty ? onConfirm : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

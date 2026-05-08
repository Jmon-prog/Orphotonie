// ============================================================
// Fichier : lib/features/help/presentation/glossary_screen.dart
// Description : Écran glossaire — liste des 10 termes linguistiques
//               avec barre de recherche. 100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar.dart';
import '../data/help_content.dart';
import 'widgets/glossary_entry.dart';

/// Écran affichant le glossaire complet des termes linguistiques.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key, this.initialKey});

  /// Si fourni, l'entrée correspondante sera ouverte automatiquement.
  final String? initialKey;

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _searchQuery = '';

  List<GlossaryEntry> get _filteredEntries {
    if (_searchQuery.isEmpty) return kGlossaryEntries;
    final q = _searchQuery.toLowerCase();
    return kGlossaryEntries.where((e) {
      return e.term.toLowerCase().contains(q) ||
          e.shortExplanation.toLowerCase().contains(q) ||
          e.detailedExplanation.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries;

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Glossaire',
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              label: 'Rechercher un terme dans le glossaire',
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un terme…',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
          // Liste
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'Aucun terme trouvé.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: entries.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return GlossaryEntryCard(
                        entry: entry,
                        initiallyExpanded: entry.key == widget.initialKey,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

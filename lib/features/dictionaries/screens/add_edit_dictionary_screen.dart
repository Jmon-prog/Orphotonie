// ============================================================
// Fichier : lib/features/dictionaries/screens/add_edit_dictionary_screen.dart
// Description : Ã‰cran de crÃ©ation et d'Ã©dition d'un dictionnaire.
//               Saisie du nom, description, couleur d'Ã©tiquette et icÃ´ne.
//               Utilise Drift (DictionariesDao) via Riverpod.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/router/app_router.dart';

// ---------------------------------------------------------------------------
// Constantes
// ---------------------------------------------------------------------------

/// Palette de couleurs disponibles pour l'Ã©tiquette du dictionnaire.
const _kColors = [
  '#6A5AE0', // violet (dÃ©faut)
  '#2196F3', // bleu
  '#4CAF50', // vert
  '#FF9800', // orange
  '#E91E63', // rose
  '#009688', // teal
  '#795548', // brun
  '#607D8B', // gris bleu
];

/// IcÃ´nes Material disponibles pour le dictionnaire.
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
// Ã‰cran
// ---------------------------------------------------------------------------

/// Ã‰cran de crÃ©ation / Ã©dition d'un dictionnaire.
/// [dictionary] est null pour une crÃ©ation, non null pour une Ã©dition.
class AddEditDictionaryScreen extends ConsumerStatefulWidget {
  const AddEditDictionaryScreen({
    super.key,
    required this.profileId,
    this.dictionary,
  });

  /// Identifiant du profil propriÃ©taire du dictionnaire.
  final int profileId;

  /// Dictionnaire existant (Ã©dition) ou null (crÃ©ation).
  final Dictionary? dictionary;

  @override
  ConsumerState<AddEditDictionaryScreen> createState() =>
      _AddEditDictionaryScreenState();
}

class _AddEditDictionaryScreenState
    extends ConsumerState<AddEditDictionaryScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomCtrl;
  late final TextEditingController _descCtrl;
  late final FocusNode _nomFocusNode;
  late String _couleur;
  late String _icon;
  bool _saving = false;

  bool get _isEdit => widget.dictionary != null;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.dictionary?.nom ?? '');
    _descCtrl =
        TextEditingController(text: widget.dictionary?.description ?? '');
    _nomFocusNode = FocusNode();
    _couleur = widget.dictionary?.couleur ?? '#6A5AE0';
    _icon = widget.dictionary?.icon ?? 'book';
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descCtrl.dispose();
    _nomFocusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sauvegarde
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final dao = ref.read(dictionariesDaoProvider);
      if (_isEdit) {
        await dao.updateDictionary(
          DictionariesCompanion(
            id: Value(widget.dictionary!.id),
            profileId: Value(widget.profileId),
            nom: Value(_nomCtrl.text.trim()),
            description: Value(
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            ),
            couleur: Value(_couleur),
            icon: Value(_icon),
          ),
        );
      } else {
        final newId = await dao.insertDictionary(
          DictionariesCompanion(
            profileId: Value(widget.profileId),
            nom: Value(_nomCtrl.text.trim()),
            description: Value(
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            ),
            couleur: Value(_couleur),
            icon: Value(_icon),
          ),
        );
        if (mounted) {
          // Naviguer directement vers la liste des mots du nouveau dictionnaire
          final nom = Uri.encodeComponent(_nomCtrl.text.trim());
          Navigator.of(context).pop(true);
          context.go('${AppRoutes.dictionnaires}/$newId/mots?nom=$nom');
          return;
        }
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // RÃ©cupÃ¨re la liste des enfants (profils)
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isEdit ? 'Modifier le dictionnaire' : 'Nouveau dictionnaire'),
        actions: [
          Semantics(
            label: 'Enregistrer le dictionnaire',
            child: IconButton(
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? constraints.maxWidth * 0.15 : 20,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prévisualisation — ValueListenableBuilder pour éviter
                  // de reconstruire le formulaire à chaque frappe
                  Center(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _nomCtrl,
                      builder: (context, value, _) => _DictionaryPreview(
                        couleur: _couleur,
                        iconName: _icon,
                        nom: value.text.isEmpty
                            ? 'Mon dictionnaire'
                            : value.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Nom
                  TextFormField(
                    controller: _nomCtrl,
                    focusNode: _nomFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nom du dictionnaire *',
                      hintText: 'Ex. : Sons [f] et [v]',
                      prefixIcon: Icon(Icons.book_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Le nom est obligatoire';
                      }
                      if (v.trim().length > 100) {
                        return 'Maximum 100 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnel)',
                      hintText: 'Ex. : Session printemps 2026',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Couleur
                  Text('Couleur', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: _kColors.map((hex) {
                      final color = _hexToColor(hex);
                      final selected = _couleur == hex;
                      return Semantics(
                        label: 'Couleur $hex',
                        selected: selected,
                        child: GestureDetector(
                          onTap: () => setState(() => _couleur = hex),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: color.withAlpha(153),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Icône
                  Text('Icône', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _kIcons.entries.map((entry) {
                      final selected = _icon == entry.key;
                      final color = _hexToColor(_couleur);
                      return Semantics(
                        label: 'Icône ${entry.key}',
                        selected: selected,
                        child: GestureDetector(
                          onTap: () => setState(() => _icon = entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: selected ? color : color.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                              border: selected
                                  ? Border.all(color: color, width: 2)
                                  : null,
                            ),
                            child: Icon(
                              entry.value,
                              color: selected ? Colors.white : color,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),

                  // Bouton sauvegarde
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(
                        _isEdit ? 'Enregistrer' : 'Créer le dictionnaire',
                      ),
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliaires
// ---------------------------------------------------------------------------

/// Prévisualisation de la carte dictionnaire.
class _DictionaryPreview extends StatelessWidget {
  const _DictionaryPreview({
    required this.couleur,
    required this.iconName,
    required this.nom,
  });

  final String couleur;
  final String iconName;
  final String nom;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(couleur);
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(179)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(102),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _kIcons[iconName] ?? Icons.book,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            nom,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Convertit un code hex (#RRGGBB) en [Color].
Color _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

// ============================================================
// Fichier : lib/features/dictionaries/screens/add_edit_word_screen.dart
// Description : Écran d'ajout / modification d'un mot dans un dictionnaire.
//               Mot, définitions (auto-remplies depuis definitions.db),
//               image (galerie/appareil photo), audio (enregistrement),
//               tags libres et niveau de difficulté 1–3.
// ============================================================

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../services/definitions_service.dart';
import '../services/media_service.dart';

// ---------------------------------------------------------------------------
// Écran
// ---------------------------------------------------------------------------

/// Écran de création / édition d'un mot.
/// [dictionaryId] est obligatoire. [word] est null pour une création.
class AddEditWordScreen extends ConsumerStatefulWidget {
  const AddEditWordScreen({
    super.key,
    required this.dictionaryId,
    this.word,
  });

  final int dictionaryId;
  final Word? word;

  @override
  ConsumerState<AddEditWordScreen> createState() => _AddEditWordScreenState();
}

class _AddEditWordScreenState extends ConsumerState<AddEditWordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs texte
  late final TextEditingController _motCtrl;
  late final TextEditingController _defCtrl;
  late final TextEditingController _defCroisesCtrl;
  late final TextEditingController _defFlechesCtrl;
  late final TextEditingController _tagCtrl;

  // Médias
  String? _imagePath; // chemin relatif
  String? _audioPath; // chemin relatif

  // Tags (liste mutable)
  late List<String> _tags;

  // Difficulté 1–3
  int _difficulty = 1;

  // États
  bool _saving = false;
  bool _recording = false;
  bool _loadingDef = false;

  bool get _isEdit => widget.word != null;

  @override
  void initState() {
    super.initState();
    final w = widget.word;
    _motCtrl = TextEditingController(text: w?.mot ?? '');
    _defCtrl = TextEditingController(text: w?.definition ?? '');
    _defCroisesCtrl = TextEditingController(text: w?.defCroises ?? '');
    _defFlechesCtrl = TextEditingController(text: w?.defFleches ?? '');
    _tagCtrl = TextEditingController();
    _imagePath = w?.imagePath;
    _audioPath = w?.audioPath;
    _difficulty = w?.difficulty ?? 1;
    try {
      _tags = List<String>.from(
        (w?.tags != null && w!.tags.isNotEmpty && w.tags != '[]')
            ? _parseTags(w.tags)
            : [],
      );
    } catch (_) {
      _tags = [];
    }
  }

  @override
  void dispose() {
    _motCtrl.dispose();
    _defCtrl.dispose();
    _defCroisesCtrl.dispose();
    _defFlechesCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auto-remplissage définition depuis definitions.db
  // ---------------------------------------------------------------------------

  Future<void> _lookupDefinition() async {
    final mot = _motCtrl.text.trim();
    if (mot.isEmpty) return;
    setState(() => _loadingDef = true);
    try {
      final entry =
          await ref.read(definitionsServiceProvider).findDefinition(mot);
      if (entry != null && mounted) {
        setState(() {
          if (_defCtrl.text.isEmpty && entry.defComplete != null) {
            _defCtrl.text = entry.defComplete!;
          }
          if (_defCroisesCtrl.text.isEmpty && entry.defCroises != null) {
            _defCroisesCtrl.text = entry.defCroises!;
          }
          if (_defFlechesCtrl.text.isEmpty && entry.defFleches != null) {
            _defFlechesCtrl.text = entry.defFleches!;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Définition pré-remplie depuis la bibliothèque ✓'),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune définition trouvée pour ce mot.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingDef = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Image
  // ---------------------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final media = ref.read(mediaServiceProvider);
      final path = source == ImageSource.gallery
          ? await media.pickImageFromGallery()
          : await media.pickImageFromCamera();
      if (path != null && mounted) {
        setState(() => _imagePath = path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    if (_imagePath == null) return;
    await ref.read(mediaServiceProvider).deleteImage(_imagePath!);
    setState(() => _imagePath = null);
  }

  // ---------------------------------------------------------------------------
  // Audio
  // ---------------------------------------------------------------------------

  Future<void> _toggleRecording() async {
    final media = ref.read(mediaServiceProvider);
    if (_recording) {
      // Arrêt
      try {
        final path = await media.stopRecording();
        if (path != null && mounted) {
          setState(() {
            _audioPath = path;
            _recording = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red),
          );
          setState(() => _recording = false);
        }
      }
    } else {
      // Démarrage
      try {
        await media.startRecording();
        if (mounted) setState(() => _recording = true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;
    try {
      await ref.read(mediaServiceProvider).playAudio(_audioPath!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeAudio() async {
    if (_audioPath == null) return;
    await ref.read(mediaServiceProvider).deleteAudio(_audioPath!);
    setState(() => _audioPath = null);
  }

  // ---------------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------------

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagCtrl.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  // ---------------------------------------------------------------------------
  // Sauvegarde
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final dao = ref.read(wordsDaoProvider);
      final tagsJson = '[${_tags.map((t) => '"$t"').join(',')}]';
      if (_isEdit) {
        // En modification, vérifier le doublon seulement si le mot a changé
        final motSaisi = _motCtrl.text.trim();
        if (motSaisi != widget.word!.mot) {
          final existing =
              await dao.getWordByMot(widget.dictionaryId, motSaisi);
          if (existing != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('« $motSaisi » existe déjà dans ce dictionnaire.'),
              ),
            );
            setState(() => _saving = false);
            return;
          }
        }
        await dao.updateWord(
          WordsCompanion(
            id: Value(widget.word!.id),
            dictionaryId: Value(widget.dictionaryId),
            mot: Value(_motCtrl.text.trim()),
            definition: Value(
              _defCtrl.text.trim().isEmpty ? null : _defCtrl.text.trim(),
            ),
            defCroises: Value(
              _defCroisesCtrl.text.trim().isEmpty
                  ? null
                  : _defCroisesCtrl.text.trim(),
            ),
            defFleches: Value(
              _defFlechesCtrl.text.trim().isEmpty
                  ? null
                  : _defFlechesCtrl.text.trim(),
            ),
            imagePath: Value(_imagePath),
            audioPath: Value(_audioPath),
            tags: Value(tagsJson),
            difficulty: Value(_difficulty),
          ),
        );
      } else {
        // Vérification doublon avant création
        final motSaisi = _motCtrl.text.trim();
        final existing = await dao.getWordByMot(widget.dictionaryId, motSaisi);
        if (existing != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('« $motSaisi » existe déjà dans ce dictionnaire.'),
              ),
            );
            setState(() => _saving = false);
          }
          return;
        }
        await dao.insertWord(
          WordsCompanion(
            dictionaryId: Value(widget.dictionaryId),
            mot: Value(_motCtrl.text.trim()),
            definition: Value(
              _defCtrl.text.trim().isEmpty ? null : _defCtrl.text.trim(),
            ),
            defCroises: Value(
              _defCroisesCtrl.text.trim().isEmpty
                  ? null
                  : _defCroisesCtrl.text.trim(),
            ),
            defFleches: Value(
              _defFlechesCtrl.text.trim().isEmpty
                  ? null
                  : _defFlechesCtrl.text.trim(),
            ),
            imagePath: Value(_imagePath),
            audioPath: Value(_audioPath),
            tags: Value(tagsJson),
            difficulty: Value(_difficulty),
          ),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier le mot' : 'Ajouter un mot'),
        actions: [
          Semantics(
            label: 'Enregistrer le mot',
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
            final isWide = constraints.maxWidth > 700;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
                vertical: 20,
              ),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _leftColumn(theme)),
                        const SizedBox(width: 24),
                        Expanded(child: _rightColumn(theme)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _leftColumn(theme),
                        const SizedBox(height: 16),
                        _rightColumn(theme),
                        const SizedBox(height: 40),
                        _saveButton(),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _leftColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Mot ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                controller: _motCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Mot *',
                  hintText: 'Ex. : PAPILLON',
                  prefixIcon: Icon(Icons.text_fields),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Le mot est obligatoire';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: 'Rechercher la définition dans la bibliothèque',
              child: IconButton.filled(
                icon: _loadingDef
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                tooltip: 'Auto-remplir la définition',
                onPressed: _loadingDef ? null : _lookupDefinition,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Définition complète ---
        TextFormField(
          controller: _defCtrl,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Définition complète (optionnel)',
            hintText: 'Ex. : Un papillon est un insecte aux ailes colorées…',
            alignLabelWithHint: true,
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 64),
              child: Icon(Icons.description_outlined),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // --- Définitions courtes ---
        TextFormField(
          controller: _defCroisesCtrl,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Définition mots croisés (optionnel)',
            hintText: 'Ex. : Insecte aux ailes colorées',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _defFlechesCtrl,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Définition mots fléchés (optionnel)',
            hintText: 'Ex. : Insecte pollinisateur',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 20),

        // --- Difficulté ---
        Text('Niveau de difficulté', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _DifficultySelector(
          value: _difficulty,
          onChanged: (v) => setState(() => _difficulty = v),
        ),
      ],
    );
  }

  Widget _rightColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Image ---
        Text('Image', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _ImageSection(
          imagePath: _imagePath,
          onPickGallery: () => _pickImage(ImageSource.gallery),
          onPickCamera: () => _pickImage(ImageSource.camera),
          onRemove: _removeImage,
        ),
        const SizedBox(height: 20),

        // --- Audio ---
        Text('Prononciation', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _AudioSection(
          audioPath: _audioPath,
          isRecording: _recording,
          onToggleRecord: _toggleRecording,
          onPlay: _playAudio,
          onRemove: _removeAudio,
        ),
        const SizedBox(height: 20),

        // --- Tags ---
        Text('Étiquettes', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Ex. : animal, ferme…',
                  isDense: true,
                ),
                onFieldSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter l\'étiquette',
              onPressed: _addTag,
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: _tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: const Icon(Icons.check),
        label: Text(_isEdit ? 'Enregistrer' : 'Ajouter le mot'),
        onPressed: _saving ? null : _save,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Parse le JSON de tags (simple implémentation sans dépendance externe).
List<String> _parseTags(String json) {
  final clean = json.trim().replaceAll('[', '').replaceAll(']', '');
  if (clean.isEmpty) return [];
  return clean
      .split(',')
      .map((s) => s.trim().replaceAll('"', ''))
      .where((s) => s.isNotEmpty)
      .toList();
}

// ---------------------------------------------------------------------------
// Widgets auxiliaires
// ---------------------------------------------------------------------------

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final level = i + 1;
        final selected = level <= value;
        return Semantics(
          label: 'Difficulté $level sur 3',
          selected: value == level,
          child: GestureDetector(
            onTap: () => onChanged(level),
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                selected ? Icons.star : Icons.star_border,
                color: selected
                    ? const Color(0xFFFFB300)
                    : Theme.of(context).colorScheme.outline,
                size: 32,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ImageSection extends ConsumerWidget {
  const _ImageSection({
    required this.imagePath,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onRemove,
  });

  final String? imagePath;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagePath != null)
          Stack(
            children: [
              FutureBuilder<String>(
                future: ref
                    .read(mediaServiceProvider)
                    .absoluteImagePath(imagePath!),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(snap.data!),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
              Positioned(
                top: 6,
                right: 6,
                child: IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                  onPressed: onRemove,
                ),
              ),
            ],
          )
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galerie'),
                onPressed: onPickGallery,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Photo'),
                onPressed: onPickCamera,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AudioSection extends StatelessWidget {
  const _AudioSection({
    required this.audioPath,
    required this.isRecording,
    required this.onToggleRecord,
    required this.onPlay,
    required this.onRemove,
  });

  final String? audioPath;
  final bool isRecording;
  final VoidCallback onToggleRecord;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bouton enregistrement
        Semantics(
          label: isRecording
              ? 'Arrêter l\'enregistrement'
              : 'Démarrer l\'enregistrement',
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: isRecording ? Colors.red : null,
            ),
            icon: Icon(isRecording ? Icons.stop : Icons.mic),
            label: Text(isRecording ? 'Arrêter' : 'Enregistrer'),
            onPressed: onToggleRecord,
          ),
        ),
        if (audioPath != null) ...[
          const SizedBox(width: 8),
          // Lecture
          Semantics(
            label: 'Écouter l\'enregistrement',
            child: IconButton.outlined(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Écouter',
              onPressed: onPlay,
            ),
          ),
          const SizedBox(width: 4),
          // Supprimer
          Semantics(
            label: 'Supprimer l\'enregistrement',
            child: IconButton.outlined(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer l\'audio',
              onPressed: onRemove,
            ),
          ),
        ] else if (!isRecording)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Aucun enregistrement',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

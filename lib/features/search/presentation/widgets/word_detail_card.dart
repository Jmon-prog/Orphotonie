// ============================================================
// Fichier : lib/features/search/presentation/widgets/word_detail_card.dart
// Description : Fiche détaillée d'un mot (bottom sheet mobile / dialog desktop).
//               Blocs : en-tête, connaissance, phonologie, morphologie,
//               famille de mots, ambiguïté, bouton ajouter.
// ============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/lexique4_database.dart';
import '../../../../core/audio/audio_providers.dart';
import '../../search_providers.dart';
import 'search_widgets_shared.dart';

// ---------------------------------------------------------------------------
// Point d'entrée : ouvre la fiche en bottom sheet ou dialog
// ---------------------------------------------------------------------------

/// Ouvre la fiche d'un mot en bottom sheet (mobile) ou dialog (desktop).
///
/// [word] : si fourni, affiche en bas les données praticien (image, étiquettes,
/// définition personnalisée, boutons Modifier / Supprimer).
void showWordDetail(
  BuildContext context, {
  required LexiqueEntry entry,
  int? dictionaryId,
  void Function(LexiqueEntry)? onAdd,
  // Données praticien (optionnelles — depuis la liste de mots)
  Word? word,
  List<String>? tags,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  final isDesktop = MediaQuery.sizeOf(context).width > 900;

  if (isDesktop) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 580,
          child: _WordDetailContent(
            entry: entry,
            onAdd: onAdd,
            word: word,
            tags: tags,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => _WordDetailContent(
          entry: entry,
          scrollController: controller,
          onAdd: onAdd,
          word: word,
          tags: tags,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contenu de la fiche
// ---------------------------------------------------------------------------

class _WordDetailContent extends ConsumerWidget {
  const _WordDetailContent({
    required this.entry,
    this.scrollController,
    this.onAdd,
    this.word,
    this.tags,
    this.onEdit,
    this.onDelete,
  });

  final LexiqueEntry entry;
  final ScrollController? scrollController;
  final void Function(LexiqueEntry)? onAdd;
  // Données praticien (optionnelles)
  final Word? word;
  final List<String>? tags;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Poignée (mobile)
        if (scrollController != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        // Contenu scrollable
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              // ── En-tête ─────────────────────────────────────────────────
              _HeaderBlock(entry: entry, onAdd: onAdd),
              const SizedBox(height: 16),

              // ── Connaissance ─────────────────────────────────────────────
              _KnowledgeBlock(entry: entry),
              const SizedBox(height: 12),

              // ── Définitions (depuis definitions.db) ──────────────────────
              _DefinitionsBlock(mot: entry.mot),
              const SizedBox(height: 12),

              // ── Phonologie ───────────────────────────────────────────────
              _PhonologyBlock(entry: entry),
              const SizedBox(height: 12),

              // ── Morphologie ──────────────────────────────────────────────
              if (entry.morphodecomp != null) ...[
                _MorphologyBlock(morphodecomp: entry.morphodecomp!),
                const SizedBox(height: 12),
              ],

              // ── Famille de mots ──────────────────────────────────────────
              if (entry.morphodecomp != null) ...[
                _WordFamilyBlock(
                  morphoRoot: _extractRoot(entry.morphodecomp!),
                  currentMot: entry.mot,
                  onTap: (e) => showWordDetail(
                    context,
                    entry: e,
                    onAdd: onAdd,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Ambiguïté ────────────────────────────────────────────────
              if (_isAmbiguous(entry)) ...[
                _AmbiguityBlock(cgramOrtho: entry.cgramOrtho!),
                const SizedBox(height: 12),
              ],

              // ── Bouton TTS ────────────────────────────────────────────────
              OutlinedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text('Écouter'),
                onPressed: () async {
                  try {
                    await ref.read(ttsServiceProvider).speakPhonetic(
                          word: entry.mot,
                          phonoIpa: entry.phonoIpa,
                        );
                  } catch (_) {}
                },
              ),
              const SizedBox(height: 8),

              // ── Section praticien (données app.db — visible uniquement
              //    depuis la liste de mots) ─────────────────────────────────
              if (word != null) ..._buildPraticienSection(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Sections spécifiques au suivi praticien (image, définition, étiquettes,
  /// boutons Modifier / Supprimer). Affichées seulement quand [word] est fourni.
  List<Widget> _buildPraticienSection(BuildContext context) {
    final theme = Theme.of(context);
    final w = word!;
    final hasPractoDef =
        w.definition != null && w.definition!.trim().isNotEmpty;
    final hasTags = tags != null && tags!.isNotEmpty;
    final hasImage = w.imagePath != null;
    final hasActions = onEdit != null || onDelete != null;

    if (!hasPractoDef && !hasTags && !hasImage && !hasActions) return [];

    return [
      const Divider(height: 32),

      // Image associée au mot (plein-largeur, rognée)
      if (hasImage) ..._buildImage(w.imagePath!),

      // Définition saisie manuellement par le praticien
      if (hasPractoDef) ...[
        _InfoCard(
          icon: Icons.subject,
          title: 'Note du praticien',
          children: [
            Text(w.definition!, style: const TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
      ],

      // Étiquettes thérapeutiques
      if (hasTags) ...[
        _InfoCard(
          icon: Icons.sell_outlined,
          title: 'Étiquettes',
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags!
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],

      // Boutons d'action
      if (hasActions)
        Row(
          children: [
            if (onEdit != null)
              Expanded(
                child: FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier'),
                ),
              ),
            if (onEdit != null && onDelete != null) const SizedBox(width: 12),
            if (onDelete != null)
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Supprimer'),
                ),
              ),
          ],
        ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildImage(String path) {
    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
      const SizedBox(height: 12),
    ];
  }

  bool _isAmbiguous(LexiqueEntry e) =>
      e.cgramOrtho != null && e.cgramOrtho!.contains(',');

  String _extractRoot(String morphodecomp) {
    // Ex: "_dé/compos(er).able" → "compos"
    final match = RegExp(r'/([^.()\[\]]+)').firstMatch(morphodecomp);
    if (match != null) return match.group(1)!;
    // Fallback : prend les lettres alphabétiques
    return morphodecomp.replaceAll(RegExp(r'[^a-zA-ZÀ-ÿ]'), '').substring(
          0,
          morphodecomp.length.clamp(0, 6),
        );
  }
}

// ---------------------------------------------------------------------------
// Blocs
// ---------------------------------------------------------------------------

/// En-tête : mot en grand · syllabation colorée · badges · bouton ➕
class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({required this.entry, this.onAdd});
  final LexiqueEntry entry;
  final void Function(LexiqueEntry)? onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final syllables = entry.syllphono?.split('-') ?? [entry.mot];

    // Couleurs WCAG AA : fond soutenu + texte blanc en dark, fond pastel + texte foncé en light
    final altColors = isDark
        ? [
            const Color(0xFF1565C0), // bleu foncé
            const Color(0xFF2E7D32), // vert foncé
            const Color(0xFF6A1B9A), // violet foncé
            const Color(0xFFE65100), // orange foncé
          ]
        : [
            const Color(0xFFBBDEFB), // bleu pastel
            const Color(0xFFC8E6C9), // vert pastel
            const Color(0xFFE1BEE7), // violet pastel
            const Color(0xFFFFE0B2), // orange pastel
          ];
    // Texte toujours contrasté ≥ 4.5:1
    final syllTextColor = isDark ? Colors.white : const Color(0xFF212121);

    return Column(
      children: [
        // Mot
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                entry.mot.toUpperCase(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            if (onAdd != null)
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                onPressed: () {
                  onAdd!(entry);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
        // Catégorie + genre
        Text(
          [
            entry.cgram,
            if (entry.genre == 'm') 'masculin',
            if (entry.genre == 'f') 'féminin',
          ].whereType<String>().join(' '),
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        // Syllabation colorée
        Wrap(
          spacing: 4,
          children: syllables.asMap().entries.map((e) {
            final color = altColors[e.key % altColors.length];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: syllTextColor,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Badges chiffres
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatBadge(
              label: '${entry.nbsyll ?? '-'}',
              sub: 'syllabes',
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _StatBadge(
              label: '${entry.nblettres ?? '-'}',
              sub: 'lettres',
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _StatBadge(
              label: '${entry.nbphons ?? '-'}',
              sub: 'phonèmes',
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.sub,
    required this.color,
  });
  final String label;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // En dark mode : fond plus opaque pour que le texte reste lisible
    final bgAlpha = isDark ? 50 : 25;
    final borderAlpha = isDark ? 150 : 80;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(bgAlpha),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(borderAlpha)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            sub,
            style: TextStyle(fontSize: 10, color: color.withAlpha(200)),
          ),
        ],
      ),
    );
  }
}

/// Bloc Connaissance : 3 jauges (preval, cdortho, freqortho)
class _KnowledgeBlock extends StatelessWidget {
  const _KnowledgeBlock({required this.entry});
  final LexiqueEntry entry;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.bar_chart,
      title: 'Connaissance & Usage',
      children: [
        _GaugeRow(
          label: 'Prévalence',
          value: entry.preval != null ? entry.preval! / 100 : null,
          text: entry.preval != null
              ? '${entry.preval!.toStringAsFixed(0)}%'
              : 'N/D',
          subtitle: prevalLabel(entry.preval),
          color: prevalColor(entry.preval),
        ),
        const SizedBox(height: 8),
        _GaugeRow(
          label: 'Diversité contextuelle',
          value:
              entry.cdortho != null ? (entry.cdortho! / 100).clamp(0, 1) : null,
          text: entry.cdortho != null
              ? '${entry.cdortho!.toStringAsFixed(1)}%'
              : 'N/D',
          subtitle: 'Présent dans X% des documents',
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        _GaugeRow(
          label: 'Fréquence orale',
          value: entry.freqortho != null
              ? (entry.freqortho! / 1000).clamp(0, 1)
              : null,
          text: entry.freqortho != null
              ? '${entry.freqortho!.toStringAsFixed(1)}/M'
              : 'N/D',
          subtitle: 'Occurrences par million de mots',
          color: Colors.teal,
        ),
      ],
    );
  }
}

class _GaugeRow extends StatelessWidget {
  const _GaugeRow({
    required this.label,
    required this.value,
    required this.text,
    required this.subtitle,
    required this.color,
  });
  final String label;
  final double? value; // 0..1
  final String text;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Bloc Phonologie : IPA · C/V · homophones
class _PhonologyBlock extends StatelessWidget {
  const _PhonologyBlock({required this.entry});
  final LexiqueEntry entry;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.record_voice_over,
      title: 'Phonologie',
      children: [
        if (entry.phonoIpa != null)
          _InfoRow(
            label: 'IPA',
            value: '/${entry.phonoIpa!}/',
            valueBold: true,
          ),
        if (entry.phono != null)
          _InfoRow(label: 'Lexique codes', value: entry.phono!),
        if (entry.cvortho != null)
          _InfoRow(label: 'Structure C/V', value: entry.cvortho!),
        _InfoRow(
          label: 'Homophones',
          value: entry.nbhomoph == null || entry.nbhomoph == 0
              ? 'aucun'
              : '${entry.nbhomoph}',
        ),
      ],
    );
  }
}

/// Bloc Morphologie : décomposition colorée
class _MorphologyBlock extends StatelessWidget {
  const _MorphologyBlock({required this.morphodecomp});
  final String morphodecomp;

  @override
  Widget build(BuildContext context) {
    final parts = _parseMorpho(morphodecomp);

    return _InfoCard(
      icon: Icons.extension,
      title: 'Morphologie',
      trailing: const Tooltip(
        message: 'La décomposition morphologique aide à comprendre la famille '
            'de mots et à travailler la conscience morphologique.',
        child: Icon(Icons.info_outline, size: 16),
      ),
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: parts.map((p) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: p.color.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.color.withAlpha(120)),
              ),
              child: Column(
                children: [
                  Text(
                    p.text,
                    style: TextStyle(
                      color: p.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    p.role,
                    style: TextStyle(fontSize: 9, color: p.color),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<_MorphoPart> _parseMorpho(String s) {
    // _xxx → préfixe · /xxx → racine · .xxx → suffixe
    final parts = <_MorphoPart>[];
    final prefixes = RegExp(r'_([^/.\[\]()]+)').allMatches(s);
    for (final m in prefixes) {
      parts.add(_MorphoPart(m.group(1)!, 'préfixe', Colors.blue.shade600));
    }
    final roots = RegExp(r'/([^.\[\]()]+)').allMatches(s);
    for (final m in roots) {
      parts.add(_MorphoPart(m.group(1)!, 'racine', Colors.green.shade600));
    }
    final suffixes = RegExp(r'\.([^_/\[\]()]+)').allMatches(s);
    for (final m in suffixes) {
      parts.add(_MorphoPart(m.group(1)!, 'suffixe', Colors.purple.shade600));
    }
    if (parts.isEmpty) {
      parts.add(_MorphoPart(s, 'morphème', Colors.grey.shade600));
    }
    return parts;
  }
}

class _MorphoPart {
  const _MorphoPart(this.text, this.role, this.color);
  final String text;
  final String role;
  final Color color;
}

/// Bloc Famille de mots
class _WordFamilyBlock extends ConsumerWidget {
  const _WordFamilyBlock({
    required this.morphoRoot,
    required this.currentMot,
    required this.onTap,
  });
  final String morphoRoot;
  final String currentMot;
  final void Function(LexiqueEntry) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(wordFamilyProvider(morphoRoot));

    return _InfoCard(
      icon: Icons.people,
      title: 'Famille de mots',
      children: [
        familyAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
          data: (family) {
            final others =
                family.where((e) => e.mot != currentMot).take(8).toList();
            if (others.isEmpty) {
              return const Text('Aucun mot de la même famille trouvé.');
            }
            return Wrap(
              spacing: 8,
              runSpacing: 4,
              children: others
                  .map(
                    (e) => ActionChip(
                      label: Text(e.mot),
                      onPressed: () => onTap(e),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Bloc Ambiguïté grammaticale
class _AmbiguityBlock extends StatelessWidget {
  const _AmbiguityBlock({required this.cgramOrtho});
  final String cgramOrtho;

  @override
  Widget build(BuildContext context) {
    final cats = cgramOrtho
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return _InfoCard(
      icon: Icons.warning_amber,
      iconColor: Colors.orange,
      title: 'Mot ambigu',
      children: [
        const Text('Ce mot peut être :'),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: cats
              .map(
                (c) => Chip(
                  label: Text(c),
                  backgroundColor: cgramColor(c).withAlpha(25),
                  labelStyle: TextStyle(color: cgramColor(c)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets utilitaires internes
// ---------------------------------------------------------------------------

/// Bloc Définitions + Niveau Dubois-Buyse (données definitions.db)
class _DefinitionsBlock extends ConsumerWidget {
  const _DefinitionsBlock({required this.mot});
  final String mot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defAsync = ref.watch(definitionProvider(mot));

    return defAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (def) {
        if (def == null) return const SizedBox.shrink();
        return Column(
          children: [
            // Définition complète
            if (def.defComplete != null && def.defComplete!.isNotEmpty)
              _InfoCard(
                icon: Icons.menu_book,
                title: 'Définition',
                children: [
                  Text(def.defComplete!, style: const TextStyle(fontSize: 13)),
                ],
              ),
            // Mots croisés & fléchés côte à côte
            if ((def.defCroises != null && def.defCroises!.isNotEmpty) ||
                (def.defFleches != null && def.defFleches!.isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (def.defCroises != null && def.defCroises!.isNotEmpty)
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.grid_on,
                          title: 'Mots croisés',
                          children: [
                            Text(
                              def.defCroises!,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (def.defCroises != null &&
                        def.defCroises!.isNotEmpty &&
                        def.defFleches != null &&
                        def.defFleches!.isNotEmpty)
                      const SizedBox(width: 8),
                    if (def.defFleches != null && def.defFleches!.isNotEmpty)
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.arrow_forward,
                          title: 'Mots fléchés',
                          children: [
                            Text(
                              def.defFleches!,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            // Niveau de lecture Dubois-Buyse
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _InfoCard(
                icon: Icons.school,
                title: 'Niveau de lecture',
                children: [
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final filled = _niveauToStars(def.niveau) > i;
                        return Icon(
                          filled ? Icons.circle : Icons.circle_outlined,
                          size: 14,
                          color: filled ? Colors.orange : Colors.grey.shade400,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        _niveauLabel(def.niveau),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(Dubois-Buyse ~${def.niveau})',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  int _niveauToStars(int niveau) {
    if (niveau <= 8) return 1; // CP
    if (niveau <= 15) return 2; // CE1-CE2
    if (niveau <= 23) return 3; // CM1-CM2
    if (niveau <= 31) return 4; // 6e-5e
    return 5; // 4e+
  }

  String _niveauLabel(int niveau) {
    if (niveau <= 5) return 'CP';
    if (niveau <= 8) return 'CE1';
    if (niveau <= 11) return 'CE2';
    if (niveau <= 15) return 'CM1';
    if (niveau <= 19) return 'CM2';
    if (niveau <= 23) return '6e';
    if (niveau <= 27) return '5e-4e';
    if (niveau <= 31) return '3e';
    return 'Lycée+';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
    this.iconColor,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });
  final String label;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

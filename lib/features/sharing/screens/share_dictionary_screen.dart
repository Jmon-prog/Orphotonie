// ============================================================
// Fichier : lib/features/sharing/screens/share_dictionary_screen.dart
// Description : Écran de choix de méthode de partage d'un dictionnaire.
//               QR Code (≤ 30 mots), fichier .orpho ou code texte.
//               100% hors ligne — aucun accès réseau.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/sharing/share_encoder.dart';
import '../../../core/sharing/sharing_providers.dart';
import 'qr_share_screen.dart';

/// Écran de partage d'un dictionnaire.
///
/// Propose 3 méthodes : QR Code, fichier .orpho et code texte.
class ShareDictionaryScreen extends ConsumerStatefulWidget {
  const ShareDictionaryScreen({
    super.key,
    required this.dictionaryId,
  });

  /// Identifiant du dictionnaire à partager.
  final int dictionaryId;

  @override
  ConsumerState<ShareDictionaryScreen> createState() =>
      _ShareDictionaryScreenState();
}

class _ShareDictionaryScreenState extends ConsumerState<ShareDictionaryScreen> {
  bool _includeDefinitions = true;
  bool _includeMedia = false;
  bool _includeAudio = false;
  bool _exporting = false;

  Dictionary? _dictionary;
  List<Word> _words = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dicDao = ref.read(dictionariesDaoProvider);
      final wordDao = ref.read(wordsDaoProvider);
      final dic = await dicDao.getDictionaryById(widget.dictionaryId);
      final wordsStream = wordDao.watchWordsForDictionary(widget.dictionaryId);
      final words = await wordsStream.first;
      if (mounted) {
        setState(() {
          _dictionary = dic;
          _words = words;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool get _canUseQr =>
      ref.read(shareEncoderProvider).canUseQrCode(_words.length);

  // ---------------------------------------------------------------------------
  // Export fichier .orpho
  // ---------------------------------------------------------------------------

  Future<void> _exportFile() async {
    if (_dictionary == null) return;
    setState(() => _exporting = true);
    try {
      final encoder = ref.read(shareEncoderProvider);
      final docsDir = await getApplicationDocumentsDirectory();
      final outputDir = '${docsDir.path}/orphotonie/exports';

      final wordMaps = _words
          .map(
            (w) => <String, dynamic>{
              'mot': w.mot,
              'definition': w.definition,
              'imagePath': w.imagePath,
              'audioPath': w.audioPath,
            },
          )
          .toList();

      final file = await encoder.exportToFile(
        name: _dictionary!.nom,
        couleur: _dictionary!.couleur,
        words: wordMaps,
        outputDir: outputDir,
        includeDefinitions: _includeDefinitions,
        includeMedia: _includeMedia,
      );

      if (mounted) {
        // Partage via la sheet système
        await Share.shareXFiles([XFile(file.path)]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ---------------------------------------------------------------------------
  // QR Code
  // ---------------------------------------------------------------------------

  void _openQrShare() {
    if (_dictionary == null) return;
    final encoder = ref.read(shareEncoderProvider);
    final code = encoder.generateQrCode(
      name: _dictionary!.nom,
      wordList: _words.map((w) => w.mot).toList(),
    );

    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le dictionnaire est trop volumineux pour un QR Code.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrShareScreen(
          dictionaryName: _dictionary!.nom,
          orphCode: code,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Code texte (copier)
  // ---------------------------------------------------------------------------

  void _copyTextCode() {
    if (_dictionary == null) return;
    final encoder = ref.read(shareEncoderProvider);
    final code = encoder.generateQrCode(
      name: _dictionary!.nom,
      wordList: _words.map((w) => w.mot).toList(),
    );

    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Le dictionnaire est trop volumineux pour un code texte.'),
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copié dans le presse-papiers ✓')),
    );
  }

  // ---------------------------------------------------------------------------
  // Lien URL (deep link orphotonie://)
  // ---------------------------------------------------------------------------

  /// Génère et copie un lien URL `orphotonie://import?d=ORPH-...`.
  ///
  /// Fonctionne sans limite de mots. Sur mobile, tapper le lien ouvre
  /// directement l'écran d'import. Sur desktop/PWA, coller dans l'app.
  void _copyShareUrl() {
    if (_dictionary == null) return;
    try {
      final encoder = ref.read(shareEncoderProvider);
      final result = encoder.generateUrlCode(
        name: _dictionary!.nom,
        wordList: _words.map((w) => w.mot).toList(),
        includeDefinitions: _includeDefinitions,
        wordsWithDefs: _includeDefinitions
            ? _words
                .map(
                  (w) => <String, dynamic>{
                    'mot': w.mot,
                    'definition': w.definition,
                  },
                )
                .toList()
            : null,
      );

      Clipboard.setData(ClipboardData(text: result.url));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lien copié dans le presse-papiers ✓'),
          action: SnackBarAction(
            label: 'Voir',
            onPressed: () => _showUrlDialog(result.url),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du lien : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Affiche le lien URL dans une boîte de dialogue avec QR Code.
  void _showUrlDialog(String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lien de partage'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR du lien URL
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 220,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
              const SizedBox(height: 16),
              // URL lisible
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scannez le QR Code ou copiez ce lien\n'
                'et envoyez-le par SMS ou messagerie.',
                style: Theme.of(ctx).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lien copié ✓')),
              );
            },
            child: const Text('Copier'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Partager')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_dictionary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Partager')),
        body: const Center(child: Text('Dictionnaire introuvable.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Partager « ${_dictionary!.nom} »')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(_dictionary!.nom),
                    subtitle: Text('${_words.length} mot(s)'),
                  ),
                ),
                const SizedBox(height: 24),

                // Méthodes de partage
                Text(
                  'Choisir la méthode :',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: isWide ? null : double.infinity,
                      child: _qrButton(theme),
                    ),
                    SizedBox(
                      width: isWide ? null : double.infinity,
                      child: _fileButton(theme),
                    ),
                    SizedBox(
                      width: isWide ? null : double.infinity,
                      child: _textButton(theme),
                    ),
                    SizedBox(
                      width: isWide ? null : double.infinity,
                      child: _urlButton(theme),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Options d'export (pour fichier .orpho)
                Text(
                  'Options du fichier .orpho :',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Inclure les définitions',
                  child: CheckboxListTile(
                    title: const Text('Inclure les définitions'),
                    value: _includeDefinitions,
                    onChanged: (v) =>
                        setState(() => _includeDefinitions = v ?? true),
                  ),
                ),
                Semantics(
                  label: 'Inclure les images',
                  child: CheckboxListTile(
                    title: const Text('Inclure les images'),
                    value: _includeMedia,
                    onChanged: (v) =>
                        setState(() => _includeMedia = v ?? false),
                  ),
                ),
                Semantics(
                  label: 'Inclure les audios',
                  child: CheckboxListTile(
                    title:
                        const Text('Inclure les audios (fichier plus lourd)'),
                    value: _includeAudio,
                    onChanged: (v) =>
                        setState(() => _includeAudio = v ?? false),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _qrButton(ThemeData theme) {
    final enabled = _canUseQr;
    return Semantics(
      label: 'Partager par QR Code',
      child: Card(
        color: enabled ? null : theme.disabledColor.withAlpha(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? _openQrShare : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 40,
                  color:
                      enabled ? theme.colorScheme.primary : theme.disabledColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'QR Code',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: enabled ? null : theme.disabledColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enabled ? '≤ $kQrMaxWords mots' : '> $kQrMaxWords mots',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: enabled ? null : theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fileButton(ThemeData theme) {
    return Semantics(
      label: 'Partager par fichier .orpho',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _exporting ? null : _exportFile,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _exporting
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(),
                      )
                    : Icon(
                        Icons.file_present,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                const SizedBox(height: 8),
                Text('Fichier .orpho', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text('Tous les mots', style: theme.textTheme.bodySmall),
                Text('✓ Images incluses', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textButton(ThemeData theme) {
    final enabled = _canUseQr;
    return Semantics(
      label: 'Copier le code texte',
      child: Card(
        color: enabled ? null : theme.disabledColor.withAlpha(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? _copyTextCode : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.content_copy,
                  size: 40,
                  color:
                      enabled ? theme.colorScheme.primary : theme.disabledColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Code texte',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: enabled ? null : theme.disabledColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '≤ $kQrMaxWords mots',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: enabled ? null : theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _urlButton(ThemeData theme) {
    return Semantics(
      label: 'Copier le lien URL de partage',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _copyShareUrl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.link,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text('Lien URL', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Tous les mots',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'SMS / messagerie',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

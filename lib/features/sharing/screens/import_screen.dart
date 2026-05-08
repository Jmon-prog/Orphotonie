// ============================================================
// Fichier : lib/features/sharing/screens/import_screen.dart
// Description : Écran d'import de dictionnaire partagé.
//               Import par QR Code (caméra), fichier .orpho ou code ORPH-.
//               Prévisualisation avant validation. 100% hors ligne.
// ============================================================

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/sharing/share_decoder.dart';
import '../../../core/sharing/share_encoder.dart';
import '../../../core/sharing/sharing_providers.dart';
import '../../../core/widgets/app_bar.dart';

/// Écran d'import de dictionnaire depuis QR Code, fichier ou code texte.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({
    super.key,
    required this.profileId,

    /// Code ORPH- ou URL orphotonie:// pré-rempli (depuis un deep link).
    this.initialCode,
  });

  /// Profil dans lequel importer le dictionnaire.
  final int profileId;

  /// Code ou URL reçu par deep link — déclenche l'import automatiquement.
  final String? initialCode;

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _codeCtrl = TextEditingController();
  SharedDictionaryData? _preview;
  bool _importing = false;
  bool _scanning = false;
  String? _scanError;

  // Contrôleur du scanner — créé à la demande, libéré au dispose
  MobileScannerController? _scannerCtrl;

  /// Sur web, la caméra n'est disponible qu'en HTTPS (ou localhost).
  bool get _webCameraAvailable =>
      !kIsWeb ||
      Uri.base.scheme == 'https' ||
      Uri.base.host == 'localhost' ||
      Uri.base.host == '127.0.0.1';

  @override
  void initState() {
    super.initState();
    // Si un code ou une URL a été passé par deep link, on l'importe directement
    if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final decoder = ref.read(shareDecoderProvider);
        final normalized = decoder.normalizeInput(widget.initialCode!);
        _codeCtrl.text = normalized;
        _decodeOrphCode(normalized);
      });
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _scannerCtrl?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Import par fichier .orpho
  // ---------------------------------------------------------------------------

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      if (!filePath.endsWith('.orpho')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner un fichier .orpho'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final decoder = ref.read(shareDecoderProvider);
      final docsDir = await getApplicationDocumentsDirectory();
      final mediaDir = '${docsDir.path}/orphotonie/media';

      final data = await decoder.importFromFile(
        File(filePath),
        mediaOutputDir: mediaDir,
      );

      if (mounted) setState(() => _preview = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Scanner QR
  // ---------------------------------------------------------------------------

  void _startScan() {
    // Sur web HTTP (hors localhost), getUserMedia est bloqué par le navigateur
    if (!_webCameraAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Caméra indisponible : l\'application doit être servie en HTTPS '
            'pour accéder à la caméra depuis un navigateur.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }
    _scannerCtrl?.dispose();
    _scannerCtrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
    );
    setState(() {
      _scanning = true;
      _scanError = null;
    });
  }

  void _stopScan() {
    _scannerCtrl?.dispose();
    _scannerCtrl = null;
    setState(() {
      _scanning = false;
      _scanError = null;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_scanning) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final decoder = ref.read(shareDecoderProvider);
      final normalized = decoder.normalizeInput(raw);
      if (normalized.startsWith(kOrphPrefix)) {
        // QR code valide — arrêt du scanner + décodage
        _stopScan();
        _decodeOrphCode(normalized);
        return;
      }
    }
    // QR code détecté mais pas un code ORPH-
    if (mounted) {
      setState(
        () => _scanError =
            'QR Code non reconnu — ce n\'est pas un dictionnaire Orphotonie.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Import par code texte
  // ---------------------------------------------------------------------------

  void _pasteCode() {
    final raw = _codeCtrl.text.trim();
    if (raw.isEmpty) return;
    final decoder = ref.read(shareDecoderProvider);
    final code = decoder.normalizeInput(raw);
    _decodeOrphCode(code);
  }

  void _decodeOrphCode(String code) {
    try {
      final decoder = ref.read(shareDecoderProvider);
      final data = decoder.importFromCode(code);
      setState(() => _preview = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code invalide : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Confirmation et import dans app.db
  // ---------------------------------------------------------------------------

  Future<void> _confirmImport() async {
    if (_preview == null) return;
    setState(() => _importing = true);
    try {
      final dicDao = ref.read(dictionariesDaoProvider);
      final wordDao = ref.read(wordsDaoProvider);

      // Crée le dictionnaire
      final dicId = await dicDao.insertDictionary(
        DictionariesCompanion(
          profileId: Value(widget.profileId),
          nom: Value(_preview!.nom),
          couleur: Value(_preview!.couleur),
          description: Value(
            'Importé le ${DateTime.now().toString().substring(0, 10)}',
          ),
        ),
      );

      // Insère tous les mots
      for (final word in _preview!.words) {
        await wordDao.insertWord(
          WordsCompanion(
            dictionaryId: Value(dicId),
            mot: Value(word.mot),
            definition: Value(word.definition),
            imagePath: Value(word.localImagePath),
            audioPath: Value(word.localAudioPath),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '« ${_preview!.nom} » importé avec '
              '${_preview!.words.length} mot(s) ✓',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'import : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Importer un dictionnaire',
        leading: _scanning
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Arrêter le scan',
                onPressed: _stopScan,
              )
            : null,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (_scanning) {
            return _buildScanner(constraints);
          }

          if (_preview != null) {
            return _buildPreview(theme, isWide);
          }

          return _buildMethodChooser(theme, isWide);
        },
      ),
    );
  }

  Widget _buildScanner(BoxConstraints constraints) {
    return Stack(
      children: [
        // Vue caméra
        MobileScanner(
          controller: _scannerCtrl,
          onDetect: _onDetect,
          errorBuilder: (context, error, child) {
            // Affichage d'erreur caméra inline
            String msg;
            switch (error.errorCode) {
              case MobileScannerErrorCode.permissionDenied:
                msg =
                    'Accès à la caméra refusé.\nAutorisez la caméra dans les paramètres.';
              case MobileScannerErrorCode.unsupported:
                msg = 'Caméra non disponible sur cet appareil.';
              default:
                msg =
                    'Erreur caméra : ${error.errorDetails?.message ?? error.errorCode.name}';
            }
            return _ScanErrorView(message: msg, onBack: _stopScan);
          },
        ),

        // Viseur centré
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // Message d'erreur de décodage (code non reconnu)
        if (_scanError != null)
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade800.withAlpha(230),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _scanError!,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _scanError = null),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Instruction + bouton annuler
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              const Text(
                'Pointez la caméra vers le QR Code du dictionnaire',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 10),
              FilledButton.tonal(
                onPressed: _stopScan,
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodChooser(ThemeData theme, bool isWide) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 16,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avertissement web contextuel (HTTP vs HTTPS)
          if (kIsWeb)
            Card(
              color: _webCameraAvailable
                  ? theme.colorScheme.secondaryContainer
                  : theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _webCameraAvailable
                          ? Icons.check_circle_outline
                          : Icons.no_photography_outlined,
                      color: _webCameraAvailable
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _webCameraAvailable
                            ? 'HTTPS détecté — la caméra est disponible. '
                                'Le navigateur demandera l\'autorisation au premier scan.'
                            : 'Caméra indisponible (HTTP). '
                                'L\'application doit être servie en HTTPS pour accéder à la caméra. '
                                'Utilisez le code texte ORPH- à la place.',
                        style: TextStyle(
                          color: _webCameraAvailable
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onErrorContainer,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (kIsWeb) const SizedBox(height: 12),

          // Scanner QR
          Semantics(
            label: 'Scanner un QR Code avec la caméra',
            child: Card(
              child: ListTile(
                leading: Icon(
                  Icons.qr_code_scanner,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Scanner un QR Code'),
                subtitle: const Text('Utilisez la caméra'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _startScan,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Fichier .orpho (pas sur web)
          if (!kIsWeb)
            Semantics(
              label: 'Importer un fichier .orpho',
              child: Card(
                child: ListTile(
                  leading: Icon(
                    Icons.file_open,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Importer un fichier .orpho'),
                  subtitle: const Text('Depuis le stockage'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickFile,
                ),
              ),
            ),
          if (!kIsWeb) const SizedBox(height: 24),
          if (kIsWeb) const SizedBox(height: 12),

          // Code texte
          Text('Ou coller un code ORPH- :', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _codeCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'ORPH-...',
              border: const OutlineInputBorder(),
              suffixIcon: Semantics(
                label: 'Importer le code collé',
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _pasteCode,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'Importer le code texte',
            child: FilledButton.icon(
              icon: const Icon(Icons.paste),
              label: const Text('Importer le code'),
              onPressed: _pasteCode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(ThemeData theme, bool isWide) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 16,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _hexToColor(_preview!.couleur),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.book, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _preview!.nom,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_preview!.words.length} mot(s)',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (_preview!.exportDate != null)
                          Text(
                            'Exporté le ${_preview!.exportDate}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Liste des mots
          Text('Mots à importer :', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _preview!.words.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final word = _preview!.words[index];
                return ListTile(
                  dense: true,
                  leading: Text(
                    '${index + 1}',
                    style: theme.textTheme.bodySmall,
                  ),
                  title: Text(word.mot),
                  subtitle: word.definition != null
                      ? Text(
                          word.definition!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (word.localImagePath != null)
                        const Icon(Icons.image, size: 16),
                      if (word.localAudioPath != null)
                        const Icon(Icons.audiotrack, size: 16),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Boutons
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Annuler l\'import',
                  child: OutlinedButton(
                    onPressed: () => setState(() => _preview = null),
                    child: const Text('Annuler'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  label: 'Confirmer l\'import du dictionnaire',
                  child: FilledButton.icon(
                    icon: _importing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: const Text('Importer'),
                    onPressed: _importing ? null : _confirmImport,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget d'erreur caméra inline
// ---------------------------------------------------------------------------

class _ScanErrorView extends StatelessWidget {
  const _ScanErrorView({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onBack,
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convertit un code hex (#RRGGBB) en [Color].
Color _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

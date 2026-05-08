// ============================================================
// Fichier : lib/features/sharing/screens/qr_share_screen.dart
// Description : Écran d'affichage du QR Code généré localement.
//               Utilise qr_flutter — aucun service réseau.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/widgets/app_bar.dart';

/// Écran d'affichage du QR Code d'un dictionnaire.
///
/// Le QR Code encode un code ORPH- (JSON minimal compressé).
class QrShareScreen extends StatelessWidget {
  const QrShareScreen({
    super.key,
    required this.dictionaryName,
    required this.orphCode,
  });

  /// Nom du dictionnaire (titre de l'écran).
  final String dictionaryName;

  /// Code ORPH- complet à encoder dans le QR.
  final String orphCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: ThemedAppBar(
        title: 'QR Code — $dictionaryName',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final qrSize =
              constraints.maxWidth > 500 ? 350.0 : constraints.maxWidth * 0.7;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: Column(
                children: [
                  // QR Code
                  Semantics(
                    label: 'QR Code du dictionnaire $dictionaryName. '
                        'Scanner avec un autre appareil pour importer.',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: orphCode,
                        version: QrVersions.auto,
                        size: qrSize,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Instructions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Comment scanner ?',
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '1. Ouvrez Orphotonie sur l\'autre appareil\n'
                            '2. Allez dans « Importer un dictionnaire »\n'
                            '3. Appuyez sur « Scanner un QR Code »\n'
                            '4. Visez ce QR Code avec la caméra',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Taille du code
                  Text(
                    '${orphCode.length} caractères',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Bouton copier
                  Semantics(
                    label: 'Copier le code texte dans le presse-papiers',
                    child: FilledButton.icon(
                      icon: const Icon(Icons.content_copy),
                      label: const Text('Copier le code texte'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: orphCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Code copié dans le presse-papiers ✓'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

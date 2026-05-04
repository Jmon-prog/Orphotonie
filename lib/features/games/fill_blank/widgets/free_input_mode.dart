// ============================================================
// Fichier : lib/features/games/fill_blank/widgets/free_input_mode.dart
// Description : Mode frappe libre du jeu Mot Lacunaire.
//               Champ de saisie dans chaque lacune.
//               Responsive, accessible.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mode frappe libre : un TextField pour chaque lacune.
class FreeInputMode extends StatefulWidget {
  const FreeInputMode({
    super.key,
    required this.blankIndices,
    required this.onLetterChanged,
    this.isCorrect,
    this.tileSize = 52,
  });

  /// Indices des lacunes dans le mot.
  final List<int> blankIndices;

  /// Callback quand une lettre est saisie/modifiée.
  final void Function(int blankIndex, String letter) onLetterChanged;

  /// Résultat de la validation.
  final bool? isCorrect;

  /// Taille de chaque champ.
  final double tileSize;

  @override
  State<FreeInputMode> createState() => _FreeInputModeState();
}

class _FreeInputModeState extends State<FreeInputMode> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.blankIndices.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.blankIndices.length,
      (_) => FocusNode(),
    );

    // Focus sur la première lacune
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FreeInputMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si les lacunes changent (nouveau mot), recréer
    if (oldWidget.blankIndices.length != widget.blankIndices.length) {
      for (final c in _controllers) {
        c.dispose();
      }
      for (final f in _focusNodes) {
        f.dispose();
      }
      _controllers.clear();
      _focusNodes.clear();
      _controllers.addAll(
        List.generate(
          widget.blankIndices.length,
          (_) => TextEditingController(),
        ),
      );
      _focusNodes.addAll(
        List.generate(
          widget.blankIndices.length,
          (_) => FocusNode(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = widget.isCorrect == true;

    return Semantics(
      label: 'Saisie des lettres manquantes',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(widget.blankIndices.length, (i) {
          return SizedBox(
            width: widget.tileSize,
            height: widget.tileSize,
            child: Semantics(
              label: 'Lettre ${i + 1} sur ${widget.blankIndices.length}',
              textField: true,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                enabled: !disabled,
                maxLength: 1,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZÀ-ÿ]'),
                  ),
                ],
                style: TextStyle(
                  fontSize: widget.tileSize * 0.45,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: const UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                ),
                onChanged: (value) {
                  widget.onLetterChanged(widget.blankIndices[i], value);
                  // Passe au champ suivant automatiquement
                  if (value.isNotEmpty && i < _focusNodes.length - 1) {
                    _focusNodes[i + 1].requestFocus();
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================
// Fichier : lib/features/auth/screens/pin_entry_screen.dart
// Description : Écran de saisie du PIN praticien.
//               Clavier numérique custom (pas le clavier système).
//               3 tentatives max → verrouillage 60 secondes.
//               Animation de tremblement si PIN incorrect.
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/auth_notifier.dart';
import '../../../core/router/app_router.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen>
    with SingleTickerProviderStateMixin {
  static const _pinLength = 6;
  static const _pinMin = 4;

  final List<String> _digits = [];
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // --- Logique PIN ---

  void _addDigit(String d) {
    if (_digits.length >= _pinLength || _isLoading) return;
    setState(() {
      _digits.add(d);
      _errorMessage = null;
    });
    // Soumission automatique à longueur minimale atteinte
    if (_digits.length >= _pinMin) _trySubmit();
  }

  void _removeDigit() {
    if (_digits.isEmpty || _isLoading) return;
    setState(() => _digits.removeLast());
  }

  Future<void> _trySubmit() async {
    final pin = _digits.join();
    setState(() => _isLoading = true);

    final success =
        await ref.read(authNotifierProvider.notifier).submitPin(pin);

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.praticienDictionnaires);
    } else {
      // Erreur : tremblement + message
      _shakeController.forward(from: 0);
      setState(() {
        _digits.clear();
        _isLoading = false;
        _errorMessage = 'PIN incorrect';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Gestion du verrouillage
    if (authState is PinLocked) {
      return _LockedScreen(secondsLeft: authState.secondsLeft);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accès Praticien'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.profiles)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🔒 Entrez votre PIN',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),

                // Indicateurs de saisie ● ● ● ○
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pinLength, (i) {
                      final filled = i < _digits.length;
                      return Semantics(
                        label: filled ? 'Chiffre saisi' : 'Chiffre manquant',
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Message d'erreur
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Clavier numérique custom
                _NumericKeypad(
                  onDigit: _addDigit,
                  onDelete: _removeDigit,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 24),

                // Lien "Mot de passe oublié ?"
                Semantics(
                  button: true,
                  label: 'Mot de passe oublié',
                  child: TextButton.icon(
                    onPressed: () {
                      // Informe le notifier et navigue vers la question secrète
                      final authState = ref.read(authNotifierProvider);
                      if (authState is AwaitingPin) {
                        ref
                            .read(authNotifierProvider.notifier)
                            .requestSecretAnswer(authState.profile);
                      }
                      context.go(AppRoutes.forgotPin);
                    },
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: const Text('Mot de passe oublié ?'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Écran de verrouillage (60 s)
// ---------------------------------------------------------------------------

class _LockedScreen extends StatelessWidget {
  const _LockedScreen({required this.secondsLeft});
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: 24),
            Text(
              'Trop de tentatives',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Réessayez dans ${secondsLeft}s',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Clavier numérique custom
// ---------------------------------------------------------------------------

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onDigit,
    required this.onDelete,
    required this.enabled,
  });

  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 88, height: 72);
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Semantics(
                label: key == '⌫' ? 'Effacer' : 'Chiffre $key',
                button: true,
                child: SizedBox(
                  width: 80,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: enabled
                        ? () {
                            if (key == '⌫') {
                              onDelete();
                            } else {
                              onDigit(key);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: key == '⌫'
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: key == '⌫'
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      key,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

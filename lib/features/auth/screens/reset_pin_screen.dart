// ============================================================
// Fichier : lib/features/auth/screens/reset_pin_screen.dart
// Description : Réinitialisation du PIN après validation de la question
//               secrète. Nouveau PIN (4–6 chiffres) + confirmation.
//               Met à jour le hash dans flutter_secure_storage via PinService.
//               Retourne ensuite à l'écran de saisie PIN.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/auth_notifier.dart';
import '../services/pin_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_bar.dart';

class ResetPinScreen extends ConsumerStatefulWidget {
  const ResetPinScreen({super.key});

  @override
  ConsumerState<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends ConsumerState<ResetPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _pinConfirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Remplace le PIN existant par le nouveau
      await ref.read(pinServiceProvider).setPin(_pinController.text.trim());

      if (!mounted) return;

      // Notifie l'AuthNotifier que le reset est terminé
      final authState = ref.read(authNotifierProvider);
      if (authState is PinResetAllowed) {
        ref
            .read(authNotifierProvider.notifier)
            .completePinReset(authState.profile);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN mis à jour avec succès !')),
      );
      context.go(AppRoutes.pin);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sécurité : si l'état n'est plus PinResetAllowed, rediriger
    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next is! PinResetAllowed && next is! Unauthenticated && mounted) {
        context.go(AppRoutes.pin);
      }
    });

    return Scaffold(
      appBar: const ThemedAppBar(
        title: 'Nouveau PIN',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_reset, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Définir un nouveau PIN',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez un nouveau PIN de 4 à 6 chiffres.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Nouveau PIN
                  Semantics(
                    label: 'Nouveau PIN',
                    child: TextFormField(
                      controller: _pinController,
                      decoration: InputDecoration(
                        labelText: 'Nouveau PIN (4 à 6 chiffres)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePin
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePin = !_obscurePin),
                          tooltip: _obscurePin ? 'Afficher' : 'Masquer',
                        ),
                      ),
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Veuillez entrer un nouveau PIN';
                        }
                        if (v.length < 4) return 'Minimum 4 chiffres';
                        if (!RegExp(r'^\d+$').hasMatch(v)) {
                          return 'Chiffres uniquement';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Confirmation PIN
                  Semantics(
                    label: 'Confirmation du nouveau PIN',
                    child: TextFormField(
                      controller: _pinConfirmController,
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le PIN',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (v) {
                        if (v != _pinController.text) {
                          return 'Les PIN ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      label: 'Enregistrer le nouveau PIN',
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Enregistrer le nouveau PIN'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

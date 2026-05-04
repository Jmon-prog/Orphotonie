// ============================================================
// Fichier : lib/features/auth/screens/secret_question_screen.dart
// Description : Récupération du PIN oublié via la question secrète.
//               Affiche la question enregistrée par le praticien.
//               Champ de réponse texte (insensible à la casse).
//               3 mauvaises réponses → verrouillage 60 secondes.
//               Sur réponse correcte → écran de réinitialisation du PIN.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/auth_notifier.dart';
import '../services/pin_service.dart';
import '../../../core/router/app_router.dart';

class SecretQuestionScreen extends ConsumerStatefulWidget {
  const SecretQuestionScreen({super.key});

  @override
  ConsumerState<SecretQuestionScreen> createState() =>
      _SecretQuestionScreenState();
}

class _SecretQuestionScreenState extends ConsumerState<SecretQuestionScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _questionText;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Charge le texte de la question depuis le secure storage.
  Future<void> _loadQuestion() async {
    final q = await ref.read(pinServiceProvider).getSecretQuestion();
    if (mounted) setState(() => _questionText = q);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final ok = await ref
        .read(authNotifierProvider.notifier)
        .submitSecretAnswer(_controller.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      // Réponse correcte → réinitialisation du PIN
      context.go(AppRoutes.resetPin);
    } else {
      final authState = ref.read(authNotifierProvider);
      if (authState is PinLocked) {
        // Le notifier a déclenché le verrouillage — retour à l'écran PIN
        if (mounted) context.go(AppRoutes.pin);
      } else {
        _controller.clear();
        setState(() => _errorMessage = 'Réponse incorrecte. Réessayez.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Surveille le verrouillage pour rediriger automatiquement
    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next is PinLocked && mounted) {
        context.go(AppRoutes.pin);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Récupération du PIN'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.pin)),
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
                  // Icône + titre
                  const Icon(Icons.help_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Question secrète',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Répondez correctement pour réinitialiser votre PIN.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Affichage de la question
                  if (_questionText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _questionText!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    // Question non configurée
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .errorContainer
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aucune question secrète configurée. '
                              'Contactez l\'administrateur de l\'appareil.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Champ de réponse
                  Semantics(
                    label: 'Réponse à la question secrète',
                    child: TextFormField(
                      controller: _controller,
                      enabled: _questionText != null && !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'Votre réponse',
                        hintText: 'La casse n\'a pas d\'importance',
                        prefixIcon: const Icon(Icons.key_outlined),
                        errorText: _errorMessage,
                      ),
                      textCapitalization: TextCapitalization.none,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Veuillez entrer une réponse';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La réponse est insensible aux majuscules et aux espaces.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.55),
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Bouton valider
                  SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      label: 'Valider la réponse',
                      child: ElevatedButton(
                        onPressed: (_questionText == null || _isLoading)
                            ? null
                            : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Valider'),
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

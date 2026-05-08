// ============================================================
// Fichier : lib/features/auth/screens/create_profile_screen.dart
// Description : Création d'un profil enfant.
//               Saisie prénom + sélection avatar emoji + choix thème.
//               Responsive. Données stockées dans app.db via ProfilesDao.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_bar.dart';

/// Avatars emoji disponibles pour les enfants.
const _avatars = [
  '🦁',
  '🐘',
  '🦊',
  '🐧',
  '🦋',
  '🐢',
  '🐬',
  '🦄',
  '🐼',
  '🐸',
  '🦖',
  '🐙',
];

/// Thèmes disponibles pour l'interface de jeu.
const _themes = {
  'espace': '🚀 Espace',
  'foret': '🌳 Forêt',
  'ocean': '🌊 Océan',
  'fantasy': '🐉 Fantasy',
};

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  String _selectedAvatar = _avatars.first;
  String _selectedTheme = 'espace';
  bool _isLoading = false;

  @override
  void dispose() {
    _prenomController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final dao = ref.read(profilesDaoProvider);
      await dao.insertProfile(
        ProfilesCompanion(
          prenom: Value(_prenomController.text.trim()),
          type: const Value('enfant'),
          // L'avatar et le thème sont stockés dans les notes (JSON futur)
          avatarPath: Value(_selectedAvatar),
        ),
      );
      if (!mounted) return;
      context.go(AppRoutes.profiles);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la création : $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThemedAppBar(
        title: 'Nouveau profil enfant',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Champ prénom
                      TextFormField(
                        controller: _prenomController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Veuillez entrer un prénom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Sélection avatar
                      Text(
                        'Choisir un avatar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _avatars.length,
                        itemBuilder: (context, i) {
                          final avatar = _avatars[i];
                          final selected = avatar == _selectedAvatar;
                          return Semantics(
                            label: 'Avatar $avatar',
                            selected: selected,
                            button: true,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAvatar = avatar),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: selected
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    avatar,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Sélection thème
                      Text(
                        'Choisir un thème',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: _themes.entries.map((entry) {
                          final selected = entry.key == _selectedTheme;
                          return Semantics(
                            label: 'Thème ${entry.value}',
                            selected: selected,
                            button: true,
                            child: ChoiceChip(
                              label: Text(entry.value),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _selectedTheme = entry.key),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 48),

                      // Bouton valider
                      SizedBox(
                        width: double.infinity,
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
                              : const Text('Créer le profil'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

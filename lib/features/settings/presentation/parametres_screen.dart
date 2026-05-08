// ============================================================
// Fichier : lib/features/settings/presentation/parametres_screen.dart
// Description : Écran Paramètres complet — apparence, texte, accessibilité
//               visuelle, accessibilité motrice, animations, audio, jeux,
//               aide et à propos. Persisté via AppThemeNotifier dans app.db.
//               100 % hors-ligne, responsive (mobile/tablette/desktop).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/child_themes.dart';
import '../../../core/theme/theme_providers.dart';
import '../../../core/widgets/app_bar.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../../auth/services/pin_service.dart';
import '../../help/presentation/glossary_screen.dart';
import '../../help/presentation/onboarding_screen.dart';
import 'widgets/gestion_donnees_section.dart';

/// Écran des paramètres de l'application.
class ParametresScreen extends ConsumerWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(appThemeProvider);
    final themeNotifier = ref.read(appThemeProvider.notifier);
    final auth = ref.watch(authNotifierProvider);
    final profileId = switch (auth) {
      PractitionerAuth(profile: final p) => p.id,
      ChildSelected(profile: final p) => p.id,
      _ => 0,
    };
    final isPractitioner = auth is PractitionerAuth;

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Paramètres',
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.praticienAccueil);
            }
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================================
                    // APPARENCE
                    // =========================================================
                    const _SectionHeader(title: 'Apparence'),
                    const SizedBox(height: 8),

                    // Mode clair / sombre
                    Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Thème de l\'interface',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'Thème système',
                            child: RadioListTile<ThemeMode>(
                              title: const Text('Système'),
                              subtitle: const Text('Suit le mode de l\'OS'),
                              secondary: const Icon(Icons.brightness_auto),
                              value: ThemeMode.system,
                              groupValue: themeState.themeMode,
                              onChanged: (v) => themeNotifier.setThemeMode(v!),
                            ),
                          ),
                          Semantics(
                            label: 'Thème clair',
                            child: RadioListTile<ThemeMode>(
                              title: const Text('Clair'),
                              secondary: const Icon(Icons.light_mode),
                              value: ThemeMode.light,
                              groupValue: themeState.themeMode,
                              onChanged: (v) => themeNotifier.setThemeMode(v!),
                            ),
                          ),
                          Semantics(
                            label: 'Thème sombre',
                            child: RadioListTile<ThemeMode>(
                              title: const Text('Sombre'),
                              secondary: const Icon(Icons.dark_mode),
                              value: ThemeMode.dark,
                              groupValue: themeState.themeMode,
                              onChanged: (v) => themeNotifier.setThemeMode(v!),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Thème enfant
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thème enfant',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Appliqué dans l\'espace enfant',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: childThemes.values.map((theme) {
                                final isSelected =
                                    themeState.childThemeKey == theme.key;
                                return Semantics(
                                  label: 'Thème ${theme.label}',
                                  selected: isSelected,
                                  button: true,
                                  child: GestureDetector(
                                    onTap: () =>
                                        themeNotifier.setChildTheme(theme.key),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: theme.background,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.primary
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: theme.primary
                                                      .withOpacity(0.4),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: theme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _themeIcon(theme.key),
                                              size: 18,
                                              color: theme.onPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            theme.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: theme.onBackground,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // TEXTE
                    // =========================================================
                    const _SectionHeader(title: 'Texte'),
                    const SizedBox(height: 8),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Taille du texte
                            Text(
                              'Taille du texte',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.text_decrease, size: 18),
                                Expanded(
                                  child: Semantics(
                                    label:
                                        'Taille du texte : ${(themeState.fontSize * 100).round()} %',
                                    onIncrease: () => themeNotifier
                                        .setFontSize(themeState.fontSize + 0.1),
                                    onDecrease: () => themeNotifier
                                        .setFontSize(themeState.fontSize - 0.1),
                                    child: Slider(
                                      value: themeState.fontSize,
                                      min: 0.8,
                                      max: 2.0,
                                      divisions: 12,
                                      label:
                                          '${(themeState.fontSize * 100).round()} %',
                                      onChanged: (v) =>
                                          themeNotifier.setFontSize(v),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.text_increase, size: 22),
                              ],
                            ),
                            Center(
                              child: Text(
                                'Exemple de texte',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontSize: 16 * themeState.fontSize,
                                    ),
                              ),
                            ),
                            const Divider(height: 24),

                            // Police dyslexique
                            Semantics(
                              label:
                                  'Police dyslexique OpenDyslexic. ${themeState.dyslexicFont ? "Activée" : "Désactivée"}',
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                secondary: const Icon(Icons.font_download),
                                title: const Text('Police dyslexique'),
                                subtitle: const Text(
                                  'OpenDyslexic — facilite la lecture',
                                ),
                                value: themeState.dyslexicFont,
                                onChanged: (v) =>
                                    themeNotifier.setDyslexicFont(v),
                              ),
                            ),
                            const Divider(height: 8),

                            // Espacement texte
                            Semantics(
                              label:
                                  'Espacement texte dyslexie. ${themeState.textSpacing ? "Activé" : "Désactivé"}',
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                secondary:
                                    const Icon(Icons.format_line_spacing),
                                title: const Text('Espacement texte'),
                                subtitle: const Text(
                                  'Espacement accru entre lettres et mots',
                                ),
                                value: themeState.textSpacing,
                                onChanged: (v) =>
                                    themeNotifier.setTextSpacing(v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // ACCESSIBILITÉ VISUELLE
                    // =========================================================
                    const _SectionHeader(title: 'Accessibilité visuelle'),
                    const SizedBox(height: 8),

                    Card(
                      child: Column(
                        children: [
                          // Contraste élevé
                          Semantics(
                            label:
                                'Mode contraste élevé. ${themeState.highContrast ? "Activé" : "Désactivé"}',
                            child: SwitchListTile(
                              secondary: const Icon(Icons.contrast),
                              title: const Text('Contraste élevé'),
                              subtitle: const Text(
                                'Fond blanc, texte noir — WCAG AAA',
                              ),
                              value: themeState.highContrast,
                              onChanged: (v) =>
                                  themeNotifier.setHighContrast(v),
                            ),
                          ),
                          const Divider(height: 1),

                          // Mode daltonisme
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  const Icon(Icons.palette_outlined, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Mode daltonisme'),
                                        Text(
                                          'Filtre de couleur appliqué globalement',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                            child: Semantics(
                              label:
                                  'Mode daltonisme sélectionné : ${_colorBlindLabel(themeState.colorBlindMode)}',
                              child: SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'none',
                                    label: Text('Aucun'),
                                    tooltip: 'Aucun filtre',
                                  ),
                                  ButtonSegment(
                                    value: 'deuteranopia',
                                    label: Text('Deutér.'),
                                    tooltip: 'Deutéranopie (rouge/vert)',
                                  ),
                                  ButtonSegment(
                                    value: 'protanopia',
                                    label: Text('Protan.'),
                                    tooltip: 'Protanopie (insensibilité rouge)',
                                  ),
                                  ButtonSegment(
                                    value: 'tritanopia',
                                    label: Text('Tritan.'),
                                    tooltip: 'Tritanopie (bleu/jaune)',
                                  ),
                                ],
                                selected: {themeState.colorBlindMode},
                                onSelectionChanged: (s) =>
                                    themeNotifier.setColorBlindMode(s.first),
                                style: ButtonStyle(
                                  textStyle: WidgetStateProperty.all(
                                    const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // ACCESSIBILITÉ MOTRICE
                    // =========================================================
                    const _SectionHeader(title: 'Accessibilité motrice'),
                    const SizedBox(height: 8),

                    Card(
                      child: Column(
                        children: [
                          // Taille des cibles
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app_outlined,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Taille des cibles tactiles',
                                        ),
                                        Text(
                                          'Normal = 48 dp · Grand = 64 dp · Très grand = 72 dp',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                            child: Semantics(
                              label:
                                  'Taille des cibles : ${_targetsLabel(themeState.largeTargets)}',
                              child: SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'normal',
                                    label: Text('Normal'),
                                  ),
                                  ButtonSegment(
                                    value: 'large',
                                    label: Text('Grand'),
                                  ),
                                  ButtonSegment(
                                    value: 'xlarge',
                                    label: Text('Très grand'),
                                  ),
                                ],
                                selected: {themeState.largeTargets},
                                onSelectionChanged: (s) =>
                                    themeNotifier.setLargeTargets(s.first),
                              ),
                            ),
                          ),
                          const Divider(height: 1),

                          // Retour haptique
                          Semantics(
                            label:
                                'Retour haptique. ${themeState.hapticFeedback ? "Activé" : "Désactivé"}',
                            child: SwitchListTile(
                              secondary: const Icon(Icons.vibration),
                              title: const Text('Retour haptique'),
                              subtitle:
                                  const Text('Vibration lors des interactions'),
                              value: themeState.hapticFeedback,
                              onChanged: (v) =>
                                  themeNotifier.setHapticFeedback(v),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // ANIMATIONS
                    // =========================================================
                    const _SectionHeader(title: 'Animations'),
                    const SizedBox(height: 8),

                    Card(
                      child: Semantics(
                        label:
                            'Réduire les animations. ${themeState.reduceAnimations ? "Activé" : "Désactivé"}',
                        child: SwitchListTile(
                          secondary: const Icon(Icons.animation),
                          title: const Text('Réduire les animations'),
                          subtitle: const Text(
                            'Transitions instantanées — recommandé en cas d\'épilepsie photosensible',
                          ),
                          value: themeState.reduceAnimations,
                          onChanged: (v) =>
                              themeNotifier.setReduceAnimations(v),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // AUDIO & SYNTHÈSE VOCALE
                    // =========================================================
                    const _SectionHeader(title: 'Audio et synthèse vocale'),
                    const SizedBox(height: 8),

                    Card(
                      child: Column(
                        children: [
                          // TTS activé
                          Semantics(
                            label:
                                'Synthèse vocale. ${themeState.ttsEnabled ? "Activée" : "Désactivée"}',
                            child: SwitchListTile(
                              secondary: const Icon(Icons.record_voice_over),
                              title: const Text('Synthèse vocale'),
                              subtitle: const Text(
                                'Lecture audio des mots et instructions',
                              ),
                              value: themeState.ttsEnabled,
                              onChanged: (v) => themeNotifier.setTtsEnabled(v),
                            ),
                          ),

                          if (themeState.ttsEnabled) ...[
                            const Divider(height: 1),

                            // Vitesse TTS
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.speed, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Vitesse de lecture',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        themeState.ttsRate <= 0.6
                                            ? 'Lent'
                                            : themeState.ttsRate >= 0.9
                                                ? 'Normal'
                                                : 'Moyen',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  Semantics(
                                    label:
                                        'Vitesse TTS : ${(themeState.ttsRate * 100).round()} %',
                                    onIncrease: () => themeNotifier
                                        .setTtsRate(themeState.ttsRate + 0.1),
                                    onDecrease: () => themeNotifier
                                        .setTtsRate(themeState.ttsRate - 0.1),
                                    child: Slider(
                                      value: themeState.ttsRate,
                                      min: 0.5,
                                      max: 1.0,
                                      divisions: 5,
                                      label:
                                          '${(themeState.ttsRate * 100).round()} %',
                                      onChanged: (v) =>
                                          themeNotifier.setTtsRate(v),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),

                            // Volume TTS
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.volume_up, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Volume de lecture',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${(themeState.ttsVolume * 100).round()} %',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  Semantics(
                                    label:
                                        'Volume TTS : ${(themeState.ttsVolume * 100).round()} %',
                                    onIncrease: () =>
                                        themeNotifier.setTtsVolume(
                                      themeState.ttsVolume + 0.1,
                                    ),
                                    onDecrease: () =>
                                        themeNotifier.setTtsVolume(
                                      themeState.ttsVolume - 0.1,
                                    ),
                                    child: Slider(
                                      value: themeState.ttsVolume,
                                      min: 0.0,
                                      max: 1.0,
                                      divisions: 10,
                                      label:
                                          '${(themeState.ttsVolume * 100).round()} %',
                                      onChanged: (v) =>
                                          themeNotifier.setTtsVolume(v),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            const Divider(height: 1),

                            // Sous-titres
                            Semantics(
                              label:
                                  'Afficher les sous-titres audio. ${themeState.showCaptions ? "Activé" : "Désactivé"}',
                              child: SwitchListTile(
                                secondary: const Icon(Icons.closed_caption),
                                title: const Text('Sous-titres audio'),
                                subtitle:
                                    const Text('Affiche le mot lu à l\'écran'),
                                value: themeState.showCaptions,
                                onChanged: (v) =>
                                    themeNotifier.setShowCaptions(v),
                              ),
                            ),
                          ],

                          const Divider(height: 1),

                          // Sons de feedback
                          Semantics(
                            label:
                                'Sons de feedback. ${themeState.soundEnabled ? "Activés" : "Désactivés"}',
                            child: SwitchListTile(
                              secondary: const Icon(Icons.music_note),
                              title: const Text('Sons de feedback'),
                              subtitle: const Text(
                                'Sons lors des bonnes/mauvaises réponses',
                              ),
                              value: themeState.soundEnabled,
                              onChanged: (v) =>
                                  themeNotifier.setSoundEnabled(v),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // JEUX
                    // =========================================================
                    const _SectionHeader(title: 'Jeux'),
                    const SizedBox(height: 8),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Durée max. d\'une session'),
                                      Text(
                                        themeState.sessionDurationLimitMin == 0
                                            ? 'Illimitée'
                                            : '${themeState.sessionDurationLimitMin} min',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Semantics(
                              label:
                                  'Durée maximale de session : ${themeState.sessionDurationLimitMin == 0 ? "Illimitée" : "${themeState.sessionDurationLimitMin} minutes"}',
                              onIncrease: () =>
                                  themeNotifier.setSessionDuration(
                                themeState.sessionDurationLimitMin == 0
                                    ? 10
                                    : themeState.sessionDurationLimitMin + 10,
                              ),
                              onDecrease: () =>
                                  themeNotifier.setSessionDuration(
                                (themeState.sessionDurationLimitMin - 10)
                                    .clamp(0, 120),
                              ),
                              child: Slider(
                                value: themeState.sessionDurationLimitMin
                                    .toDouble(),
                                min: 0,
                                max: 60,
                                divisions: 6,
                                label: themeState.sessionDurationLimitMin == 0
                                    ? 'Illimitée'
                                    : '${themeState.sessionDurationLimitMin} min',
                                onChanged: (v) =>
                                    themeNotifier.setSessionDuration(v.round()),
                              ),
                            ),
                            Text(
                              'La session s\'arrête automatiquement au bout du temps imparti (0 = illimitée).',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // SÉCURITÉ (espace gestionnaire uniquement)
                    // =========================================================
                    if (isPractitioner) ...[
                      const _SectionHeader(title: 'Sécurité'),
                      const SizedBox(height: 8),
                      const _PinManagementCard(),
                      const SizedBox(height: 24),
                    ],

                    // =========================================================
                    // AIDE
                    // =========================================================
                    const _SectionHeader(title: 'Aide'),
                    const SizedBox(height: 8),

                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.menu_book_outlined),
                            title: const Text('Glossaire des termes'),
                            subtitle: const Text(
                              'Fréquence, phonologie, Dubois-Buyse…',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GlossaryScreen(),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          if (profileId > 0) ...[
                            ListTile(
                              leading: const Icon(Icons.play_circle_outline),
                              title: const Text('Revoir le tutoriel'),
                              subtitle:
                                  const Text('Présentation de l\'application'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OnboardingScreen(
                                    isPractitioner: isPractitioner,
                                    profileId: profileId,
                                    onComplete: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                          ],
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text('Aide complète'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.go(AppRoutes.aide),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // GESTION DES PROFILS (praticien uniquement)
                    // =========================================================
                    if (isPractitioner) ...[
                      GestionDonneesSection(praticienId: profileId),
                      const SizedBox(height: 24),
                    ],

                    // =========================================================
                    // À PROPOS
                    // =========================================================
                    const _SectionHeader(title: 'À propos'),
                    const SizedBox(height: 8),

                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('Version'),
                            trailing: Text(
                              '0.1.0',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                          const Divider(height: 1),
                          const ListTile(
                            leading: Icon(Icons.privacy_tip_outlined),
                            title: Text('Données'),
                            subtitle: Text(
                              '100 % locales — aucun envoi réseau',
                            ),
                          ),
                          const Divider(height: 1),
                          const ListTile(
                            leading: Icon(Icons.accessible),
                            title: Text('Accessibilité'),
                            subtitle: Text(
                              'WCAG 2.1 AA — TalkBack, VoiceOver, Narrator compatibles',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _themeIcon(String key) {
    switch (key) {
      case 'espace':
        return Icons.rocket_launch;
      case 'foret':
        return Icons.forest;
      case 'ocean':
        return Icons.waves;
      case 'fantasy':
        return Icons.auto_awesome;
      default:
        return Icons.palette;
    }
  }

  String _colorBlindLabel(String mode) {
    switch (mode) {
      case 'deuteranopia':
        return 'Deutéranopie';
      case 'protanopia':
        return 'Protanopie';
      case 'tritanopia':
        return 'Tritanopie';
      default:
        return 'Aucun';
    }
  }

  String _targetsLabel(String mode) {
    switch (mode) {
      case 'large':
        return 'Grand';
      case 'xlarge':
        return 'Très grand';
      default:
        return 'Normal';
    }
  }
}

// ---------------------------------------------------------------------------
// En-tête de section
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carte de gestion du code PIN (espace Gestionnaire)
// ---------------------------------------------------------------------------

class _PinManagementCard extends ConsumerStatefulWidget {
  const _PinManagementCard();

  @override
  ConsumerState<_PinManagementCard> createState() => _PinManagementCardState();
}

class _PinManagementCardState extends ConsumerState<_PinManagementCard> {
  bool? _hasPin;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final has = await ref.read(pinServiceProvider).hasPin();
    if (mounted) setState(() => _hasPin = has);
  }

  /// Affiche un dialogue de saisie du nouveau PIN.
  Future<void> _showSetPinDialog({required bool isChange}) async {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var obscure = true;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title:
              Text(isChange ? 'Modifier le code PIN' : 'Activer le code PIN'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: pinCtrl,
                  decoration: InputDecoration(
                    labelText: 'Code PIN (4 à 6 chiffres)',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setLocal(() => obscure = !obscure),
                      tooltip: obscure ? 'Afficher' : 'Masquer',
                    ),
                  ),
                  obscureText: obscure,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requis';
                    if (v.length < 4) return 'Minimum 4 chiffres';
                    if (!RegExp(r'^\d+$').hasMatch(v)) {
                      return 'Chiffres uniquement';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: confirmCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer le code',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                  obscureText: obscure,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (v) {
                    if (v != pinCtrl.text) {
                      return 'Les codes ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(pinServiceProvider).setPin(pinCtrl.text);
        await _reload();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code PIN enregistré')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e')),
          );
        }
      }
    }
    pinCtrl.dispose();
    confirmCtrl.dispose();
  }

  /// Affiche un dialogue de confirmation avant de supprimer le PIN.
  Future<void> _disablePin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver le code PIN ?'),
        content: const Text(
          'L\'espace Gestionnaire sera accessible sans saisie de code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(pinServiceProvider).clearPin();
        await _reload();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code PIN désactivé')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPin == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _hasPin! ? Icons.lock : Icons.lock_open,
              color: _hasPin!
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(_hasPin! ? 'Code PIN actif' : 'Code PIN inactif'),
            subtitle: Text(
              _hasPin!
                  ? 'Le code PIN protège l\'accès à l\'espace Gestionnaire.'
                  : 'Aucune protection — l\'espace est accessible librement.',
            ),
            trailing: _hasPin!
                ? null
                : Semantics(
                    label: 'Activer le code PIN',
                    child: FilledButton(
                      onPressed: () => _showSetPinDialog(isChange: false),
                      child: const Text('Activer'),
                    ),
                  ),
          ),
          if (_hasPin!) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                children: [
                  Semantics(
                    label: 'Désactiver le code PIN',
                    child: TextButton.icon(
                      onPressed: _disablePin,
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Désactiver'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    label: 'Modifier le code PIN',
                    child: FilledButton.icon(
                      onPressed: () => _showSetPinDialog(isChange: true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

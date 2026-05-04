// ============================================================
// Fichier : lib/core/theme/theme_providers.dart
// Description : Providers Riverpod pour la gestion des thèmes.
//               AppThemeNotifier gère le thème praticien (clair/sombre/système)
//               et le thème enfant (espace/forêt/océan/fantasy).
//               Persistance dans app_settings. 100% hors ligne.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database/app_database.dart';
import '../database/database_providers.dart';
import 'child_themes.dart';
import 'typography.dart';

// ---------------------------------------------------------------------------
// État du thème
// ---------------------------------------------------------------------------

/// État immutable du thème de l'application.
class AppThemeState {
  const AppThemeState({
    this.themeMode = ThemeMode.system,
    this.childThemeKey = defaultChildThemeKey,
    this.fontSize = 1.0,
    // Accessibilité
    this.dyslexicFont = false,
    this.highContrast = false,
    this.colorBlindMode = 'none',
    this.reduceAnimations = false,
    this.largeTargets = 'normal',
    this.hapticFeedback = true,
    this.textSpacing = false,
    this.showCaptions = false,
    // Audio
    this.ttsEnabled = true,
    this.ttsRate = 0.8,
    this.ttsVolume = 1.0,
    this.soundEnabled = true,
    // Jeux
    this.sessionDurationLimitMin = 0,
  });

  /// Mode du thème praticien : clair, sombre ou système.
  final ThemeMode themeMode;

  /// Clé du thème enfant actif.
  final String childThemeKey;

  /// Facteur de taille de police (1.0 = normal).
  final double fontSize;

  // ---- Accessibilité ----

  /// Police dyslexique (OpenDyslexic) activée.
  final bool dyslexicFont;

  /// Mode contraste élevé activé.
  final bool highContrast;

  /// Mode daltonisme : 'none' | 'deuteranopia' | 'protanopia' | 'tritanopia'.
  final String colorBlindMode;

  /// Réduire les animations.
  final bool reduceAnimations;

  /// Taille des cibles tactiles : 'normal' | 'large' | 'xlarge'.
  final String largeTargets;

  /// Retour haptique activé.
  final bool hapticFeedback;

  /// Espacement texte dyslexie activé.
  final bool textSpacing;

  /// Afficher les sous-titres audio.
  final bool showCaptions;

  // ---- Audio ----

  /// Synthèse vocale activée.
  final bool ttsEnabled;

  /// Vitesse TTS (0.5 = lent, 1.0 = normal).
  final double ttsRate;

  /// Volume TTS (0.0–1.0).
  final double ttsVolume;

  /// Sons de feedback activés.
  final bool soundEnabled;

  // ---- Jeux ----

  /// Durée maximale d'une session en minutes (0 = illimitée).
  final int sessionDurationLimitMin;

  /// Retourne le [ChildTheme] actif.
  ChildTheme get childTheme =>
      childThemes[childThemeKey] ?? childThemes[defaultChildThemeKey]!;

  AppThemeState copyWith({
    ThemeMode? themeMode,
    String? childThemeKey,
    double? fontSize,
    bool? dyslexicFont,
    bool? highContrast,
    String? colorBlindMode,
    bool? reduceAnimations,
    String? largeTargets,
    bool? hapticFeedback,
    bool? textSpacing,
    bool? showCaptions,
    bool? ttsEnabled,
    double? ttsRate,
    double? ttsVolume,
    bool? soundEnabled,
    int? sessionDurationLimitMin,
  }) =>
      AppThemeState(
        themeMode: themeMode ?? this.themeMode,
        childThemeKey: childThemeKey ?? this.childThemeKey,
        fontSize: fontSize ?? this.fontSize,
        dyslexicFont: dyslexicFont ?? this.dyslexicFont,
        highContrast: highContrast ?? this.highContrast,
        colorBlindMode: colorBlindMode ?? this.colorBlindMode,
        reduceAnimations: reduceAnimations ?? this.reduceAnimations,
        largeTargets: largeTargets ?? this.largeTargets,
        hapticFeedback: hapticFeedback ?? this.hapticFeedback,
        textSpacing: textSpacing ?? this.textSpacing,
        showCaptions: showCaptions ?? this.showCaptions,
        ttsEnabled: ttsEnabled ?? this.ttsEnabled,
        ttsRate: ttsRate ?? this.ttsRate,
        ttsVolume: ttsVolume ?? this.ttsVolume,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        sessionDurationLimitMin:
            sessionDurationLimitMin ?? this.sessionDurationLimitMin,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Notifier Riverpod pour la gestion du thème.
///
/// Charge le thème depuis app_settings au lancement et persiste
/// les modifications en temps réel dans app.db.
class AppThemeNotifier extends StateNotifier<AppThemeState> {
  AppThemeNotifier(this._db) : super(const AppThemeState());

  final AppDatabase _db;
  int? _profileId;

  /// Charge les préférences de thème pour un profil.
  Future<void> loadForProfile(int profileId) async {
    _profileId = profileId;
    try {
      final row = await (_db.select(_db.appSettings)
            ..where((t) => t.profileId.equals(profileId)))
          .getSingleOrNull();
      if (row != null) {
        state = AppThemeState(
          themeMode: _parseThemeMode(row.themeName),
          childThemeKey: row.childThemeName,
          fontSize: row.fontSize,
          dyslexicFont: row.dyslexicFont,
          highContrast: row.highContrast,
          colorBlindMode: row.colorBlindMode,
          reduceAnimations: row.reduceAnimations,
          largeTargets: row.largeTargets,
          hapticFeedback: row.hapticFeedback,
          textSpacing: row.textSpacing,
          showCaptions: row.showCaptions,
          ttsEnabled: row.ttsEnabled,
          ttsRate: row.ttsRate,
          ttsVolume: row.ttsVolume,
          soundEnabled: row.soundEnabled,
          sessionDurationLimitMin: row.sessionDurationLimitMin,
        );
      }
    } catch (_) {
      // Garde les valeurs par défaut en cas d'erreur
    }
  }

  /// Change le mode de thème praticien (clair/sombre/système).
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
  }

  /// Change le thème enfant.
  Future<void> setChildTheme(String themeKey) async {
    if (!childThemes.containsKey(themeKey)) return;
    state = state.copyWith(childThemeKey: themeKey);
    await _persist();
  }

  /// Change le facteur de taille de police.
  Future<void> setFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize.clamp(0.8, 2.0));
    await _persist();
  }

  /// Active/désactive la police dyslexique.
  Future<void> setDyslexicFont(bool value) async {
    state = state.copyWith(dyslexicFont: value);
    await _persist();
  }

  /// Active/désactive le mode contraste élevé.
  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(highContrast: value);
    await _persist();
  }

  /// Définit le mode daltonisme ('none' | 'deuteranopia' | 'protanopia' | 'tritanopia').
  Future<void> setColorBlindMode(String mode) async {
    state = state.copyWith(colorBlindMode: mode);
    await _persist();
  }

  /// Active/désactive la réduction des animations.
  Future<void> setReduceAnimations(bool value) async {
    state = state.copyWith(reduceAnimations: value);
    await _persist();
  }

  /// Définit la taille des cibles ('normal' | 'large' | 'xlarge').
  Future<void> setLargeTargets(String value) async {
    state = state.copyWith(largeTargets: value);
    await _persist();
  }

  /// Active/désactive le retour haptique.
  Future<void> setHapticFeedback(bool value) async {
    state = state.copyWith(hapticFeedback: value);
    await _persist();
  }

  /// Active/désactive l'espacement texte dyslexie.
  Future<void> setTextSpacing(bool value) async {
    state = state.copyWith(textSpacing: value);
    await _persist();
  }

  /// Active/désactive les sous-titres audio.
  Future<void> setShowCaptions(bool value) async {
    state = state.copyWith(showCaptions: value);
    await _persist();
  }

  /// Active/désactive la synthèse vocale.
  Future<void> setTtsEnabled(bool value) async {
    state = state.copyWith(ttsEnabled: value);
    await _persist();
  }

  /// Change la vitesse TTS (0.5–1.0).
  Future<void> setTtsRate(double value) async {
    state = state.copyWith(ttsRate: value.clamp(0.5, 1.0));
    await _persist();
  }

  /// Change le volume TTS (0.0–1.0).
  Future<void> setTtsVolume(double value) async {
    state = state.copyWith(ttsVolume: value.clamp(0.0, 1.0));
    await _persist();
  }

  /// Active/désactive les sons de feedback.
  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await _persist();
  }

  /// Change la durée maximale de session en minutes (0 = illimitée).
  Future<void> setSessionDuration(int minutes) async {
    state = state.copyWith(sessionDurationLimitMin: minutes.clamp(0, 120));
    await _persist();
  }

  /// Persiste l'état courant dans app_settings.
  Future<void> _persist() async {
    if (_profileId == null) return;
    try {
      await _db.into(_db.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion(
              profileId: Value(_profileId!),
              themeName: Value(_themeModeToString(state.themeMode)),
              childThemeName: Value(state.childThemeKey),
              fontSize: Value(state.fontSize),
              dyslexicFont: Value(state.dyslexicFont),
              highContrast: Value(state.highContrast),
              colorBlindMode: Value(state.colorBlindMode),
              reduceAnimations: Value(state.reduceAnimations),
              largeTargets: Value(state.largeTargets),
              hapticFeedback: Value(state.hapticFeedback),
              textSpacing: Value(state.textSpacing),
              showCaptions: Value(state.showCaptions),
              ttsEnabled: Value(state.ttsEnabled),
              ttsRate: Value(state.ttsRate),
              ttsVolume: Value(state.ttsVolume),
              soundEnabled: Value(state.soundEnabled),
              sessionDurationLimitMin: Value(state.sessionDurationLimitMin),
            ),
          );
    } catch (_) {
      // Silencieux — les préférences seront réessayées
    }
  }

  static ThemeMode _parseThemeMode(String name) {
    switch (name) {
      case 'clair':
        return ThemeMode.light;
      case 'sombre':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'clair';
      case ThemeMode.dark:
        return 'sombre';
      case ThemeMode.system:
        return 'systeme';
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Provider du notifier de thème.
final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, AppThemeState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppThemeNotifier(db);
});

/// ThemeData clair praticien, construit à partir de l'état courant.
final lightThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(appThemeProvider);
  return _buildPractitionerTheme(Brightness.light, themeState.fontSize);
});

/// ThemeData sombre praticien.
final darkThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(appThemeProvider);
  return _buildPractitionerTheme(Brightness.dark, themeState.fontSize);
});

/// ThemeData enfant (dépend du thème sélectionné + mode sombre).
final childLightThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(appThemeProvider);
  final child = themeState.childTheme;
  return _buildChildTheme(child.toColorScheme(), themeState.fontSize);
});

/// ThemeData enfant sombre.
final childDarkThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(appThemeProvider);
  final child = themeState.childTheme;
  return _buildChildTheme(child.toDarkColorScheme(), themeState.fontSize);
});

// ---------------------------------------------------------------------------
// Construction des ThemeData
// ---------------------------------------------------------------------------

ThemeData _buildPractitionerTheme(Brightness brightness, double fontScale) {
  final isLight = brightness == Brightness.light;
  final colorScheme = isLight
      ? const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF6A5AE0),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFE8E5FF),
          onPrimaryContainer: Color(0xFF6A5AE0),
          secondary: Color(0xFF4CAF82),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFD8F4E8),
          onSecondaryContainer: Color(0xFF4CAF82),
          tertiary: Color(0xFFFF8A65),
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFFFE0D4),
          onTertiaryContainer: Color(0xFFFF8A65),
          error: Color(0xFFD32F2F),
          onError: Colors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFFD32F2F),
          surface: Color(0xFFF8F7FF),
          onSurface: Color(0xFF1C1B1F),
        )
      : const ColorScheme.dark(
          primary: Color(0xFF6A5AE0),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFF3D35A8),
          secondary: Color(0xFF4CAF82),
          surface: Color(0xFF121212),
          onSurface: Color(0xFFE0E0E0),
          error: Color(0xFFCF6679),
        );

  final textColor = isLight ? const Color(0xFF1C1B1F) : const Color(0xFFE0E0E0);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: AppTypography.textTheme(bodyColor: textColor),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      centerTitle: true,
      titleTextStyle: GoogleFonts.baloo2(
        fontSize: 22 * fontScale,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
      ),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(44, 44), // Cible tactile ≥ 44dp
        textStyle:
            GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 44),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: isLight ? Colors.white : const Color(0xFF1E1E1E),
    ),
    checkboxTheme: const CheckboxThemeData(
      materialTapTargetSize: MaterialTapTargetSize.padded,
    ),
  );
}

ThemeData _buildChildTheme(ColorScheme colorScheme, double fontScale) {
  final textColor = colorScheme.onSurface;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: AppTypography.textTheme(bodyColor: textColor),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      centerTitle: true,
      titleTextStyle: GoogleFonts.baloo2(
        fontSize: 22 * fontScale,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
      ),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(48, 48), // Cible tactile ≥ 48dp (enfant)
        textStyle:
            GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: colorScheme.surface,
    ),
    scaffoldBackgroundColor:
        colorScheme.brightness == Brightness.light ? colorScheme.surface : null,
  );
}

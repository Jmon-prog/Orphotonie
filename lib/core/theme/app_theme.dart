// ============================================================
// Fichier : lib/core/theme/app_theme.dart
// Description : Thème Material 3 de l'application Orphotonie.
//               Palette douce adaptée aux enfants. Polices Nunito + Baloo2.
//               Thèmes clair et sombre. Responsive via LayoutBuilder.
//
//               Hiérarchie des boutons :
//                 FilledButton    → action principale (1 par écran)
//                 OutlinedButton  → action secondaire
//                 TextButton      → navigation / lien inline
//                 (rouge)         → action destructive, style local uniquement
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette de couleurs statique de l'application Orphotonie.
///
/// Utiliser ces constantes plutôt que les valeurs hexadécimales directement
/// afin de garantir la cohérence visuelle et de faciliter les futures
/// retouches de la palette (un seul endroit à modifier).
abstract class AppColors {
  // Couleur principale — bleu-violet doux (accessible)
  static const primary = Color(0xFF6A5AE0);
  static const primaryContainer = Color(0xFFE8E5FF);
  static const onPrimary = Colors.white;

  // Couleur secondaire — vert menthe
  static const secondary = Color(0xFF4CAF82);
  static const secondaryContainer = Color(0xFFD8F4E8);

  // Couleur tertiaire — orange pêche
  static const tertiary = Color(0xFFFF8A65);
  static const tertiaryContainer = Color(0xFFFFE0D4);

  // Fond clair
  static const surface = Color(0xFFF8F7FF);
  static const surfaceContainer = Color(0xFFEEECF9);
  static const background = Color(0xFFF0EFF9);
  static const error = Color(0xFFD32F2F);

  // Fond sombre
  static const surfaceDark = Color(0xFF1C1B2E);
  static const surfaceContainerDark = Color(0xFF252438);
}

/// Fabrique les thèmes Material 3 clair et sombre de l'application.
///
/// Points d'entrée :
/// - [AppTheme.lightTheme] → à passer à [MaterialApp.theme]
/// - [AppTheme.darkTheme]  → à passer à [MaterialApp.darkTheme]
///
/// La hiérarchie de boutons est documentée dans l'en-tête du fichier.
abstract class AppTheme {
  // ---------------------------------------------------------------------------
  // Thème clair praticien
  // ---------------------------------------------------------------------------

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: Color(0xFF1A5C3A),
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: Color(0xFF8C3A1A),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: AppColors.surfaceContainer,
      surfaceContainerHigh: Color(0xFFF3F1FC),
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerLow: Color(0xFFF8F7FF),
      outline: Color(0xFFB0AEBD),
      outlineVariant: Color(0xFFD8D6E8),
    );

    final textTheme = _buildTextTheme(colorScheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // ---- AppBar ----
      // Surface avec titre coloré — la barre d'accent est ajoutée
      // via le widget ThemedAppBar (voir app_bar.dart).
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceContainer,
        foregroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.primary.withOpacity(0.12),
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 24,
        ),
      ),

      // ---- Boutons (hiérarchie claire) ----

      // Action principale : FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      // Action secondaire : OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      // Navigation / lien : TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(0, 44),
        ),
      ),

      // ElevatedButton : action secondaire dans contextes colorés (jeux)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      // ---- FAB ----
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        focusElevation: 4,
        shape: CircleBorder(),
      ),

      // ---- Cards ----
      cardTheme: CardTheme(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E0F0), width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 4,
        ),
      ),

      // ---- Saisie ----
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB0AEBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB0AEBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.nunito(
          fontSize: 16,
          color: const Color(0xFF6B6880),
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: 16,
          color: const Color(0xFF9896A8),
        ),
      ),

      // ---- Navigation bottom bar (mobile) ----
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : const Color(0xFF6B6880),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? AppColors.primary : const Color(0xFF6B6880),
            size: 24,
          );
        }),
      ),

      // ---- Navigation Rail (tablette) ----
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surfaceContainer,
        indicatorColor: AppColors.primaryContainer,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Color(0xFF6B6880),
          size: 24,
        ),
        selectedLabelTextStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6B6880),
        ),
        elevation: 0,
      ),

      // ---- Drawer ----
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // ---- Chips ----
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedColor: AppColors.primaryContainer,
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ---- Dialogues ----
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1C1B1F),
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 16,
          color: const Color(0xFF49454F),
        ),
      ),

      // ---- SnackBar ----
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D2B42),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actionTextColor: AppColors.secondary,
      ),

      // ---- Divider ----
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E0F0),
        thickness: 1,
        space: 1,
      ),

      // ---- Icônes ----
      iconTheme: const IconThemeData(
        color: Color(0xFF6B6880),
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),

      // ---- ListTile ----
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1C1B1F),
        ),
        subtitleTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: const Color(0xFF6B6880),
        ),
      ),

      // ---- BottomSheet ----
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        dragHandleColor: Color(0xFFB0AEBD),
      ),

      // ---- Tooltips ----
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2B42),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 13,
          color: Colors.white,
        ),
        waitDuration: const Duration(milliseconds: 600),
      ),

      // ---- Switch / Checkbox / Radio ----
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : const Color(0xFF9896A8),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryContainer
              : const Color(0xFFE2E0F0),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: Color(0xFFB0AEBD), width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : const Color(0xFFB0AEBD),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Thème sombre praticien
  // ---------------------------------------------------------------------------

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF9D91F0),
      onPrimary: Color(0xFF1C1459),
      primaryContainer: Color(0xFF3D35A8),
      onPrimaryContainer: Color(0xFFE8E5FF),
      secondary: Color(0xFF72CCA0),
      onSecondary: Color(0xFF003825),
      secondaryContainer: Color(0xFF1A5C3A),
      onSecondaryContainer: Color(0xFFD8F4E8),
      tertiary: Color(0xFFFFB49A),
      onTertiary: Color(0xFF5C2000),
      tertiaryContainer: Color(0xFF8C3A1A),
      onTertiaryContainer: Color(0xFFFFE0D4),
      error: Color(0xFFCF6679),
      onError: Color(0xFF3B0715),
      errorContainer: Color(0xFF8C1D31),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.surfaceDark,
      onSurface: Color(0xFFE6E1F0),
      surfaceContainerHighest: AppColors.surfaceContainerDark,
      surfaceContainerHigh: Color(0xFF2A2840),
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerLow: Color(0xFF201F32),
      outline: Color(0xFF5C5A72),
      outlineVariant: Color(0xFF3D3B52),
    );

    final textTheme = _buildTextTheme(colorScheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceContainerDark,
        foregroundColor: const Color(0xFF9D91F0),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9D91F0),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF9D91F0), size: 24),
        actionsIconTheme:
            const IconThemeData(color: Color(0xFF9D91F0), size: 24),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF9D91F0),
          foregroundColor: const Color(0xFF1C1459),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
              GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
          minimumSize: const Size(0, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF9D91F0),
          side: const BorderSide(color: Color(0xFF9D91F0), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
              GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
          minimumSize: const Size(0, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF9D91F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
          minimumSize: const Size(0, 44),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceContainerDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF3D3B52), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5C5A72)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5C5A72)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9D91F0), width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle:
            GoogleFonts.nunito(fontSize: 16, color: const Color(0xFF9896A8)),
        hintStyle:
            GoogleFonts.nunito(fontSize: 16, color: const Color(0xFF6B6880)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerDark,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF3D35A8),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color:
                isSelected ? const Color(0xFF9D91F0) : const Color(0xFF9896A8),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color:
                isSelected ? const Color(0xFF9D91F0) : const Color(0xFF9896A8),
            size: 24,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3D3B52),
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF9896A8), size: 24),
    );
  }

  // ---------------------------------------------------------------------------
  // Utilitaire : TextTheme partagé
  // ---------------------------------------------------------------------------

  /// Construit le [TextTheme] partagé entre les thèmes clair et sombre.
  ///
  /// Les titres (display, headline) utilisent **Baloo2** — arrondi et expressif.
  /// Le corps (body, label) utilise **Nunito** — lisible, adapté aux enfants.
  ///
  /// [bodyColor] est transmis à chaque style pour que les couleurs s'adaptent
  /// automatiquement au mode sombre sans duplication de code.
  static TextTheme _buildTextTheme(Color bodyColor) {
    final c = bodyColor;
    return GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.baloo2(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: c,
      ),
      displayMedium: GoogleFonts.baloo2(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: c,
      ),
      displaySmall: GoogleFonts.baloo2(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: c,
      ),
      headlineLarge: GoogleFonts.baloo2(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      headlineMedium: GoogleFonts.baloo2(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      headlineSmall: GoogleFonts.baloo2(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      titleSmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: c,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: c,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: c,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: c,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: c,
      ),
    );
  }
}

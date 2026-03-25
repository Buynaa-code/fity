import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../branding/brand_config.dart';

/// FITY App Theme
/// Бүрэн брэндинг дээр суурилсан theme систем
class AppTheme {
  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Colors
      primaryColor: BrandColors.primary,
      scaffoldBackgroundColor: BrandColors.background,
      canvasColor: BrandColors.surface,
      dividerColor: BrandColors.divider,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: BrandColors.primary,
        onPrimary: BrandColors.textOnPrimary,
        primaryContainer: BrandColors.primarySurface,
        secondary: BrandColors.secondary,
        onSecondary: BrandColors.textOnPrimary,
        secondaryContainer: BrandColors.secondarySurface,
        surface: BrandColors.surface,
        onSurface: BrandColors.textPrimary,
        error: BrandColors.error,
        onError: BrandColors.textOnPrimary,
      ),

      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: BrandColors.background,
        foregroundColor: BrandColors.textPrimary,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Rubik',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: BrandColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: BrandColors.textPrimary,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BrandColors.surface,
        selectedItemColor: BrandColors.primary,
        unselectedItemColor: BrandColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Rubik',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Rubik',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: BrandColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BrandRadius.card,
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.primary,
          foregroundColor: BrandColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BrandRadius.button,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BrandColors.primary,
          side: const BorderSide(color: BrandColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BrandRadius.button,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BrandColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BrandColors.primary,
        foregroundColor: BrandColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BrandColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BrandRadius.input,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BrandRadius.input,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BrandRadius.input,
          borderSide: const BorderSide(color: BrandColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BrandRadius.input,
          borderSide: const BorderSide(color: BrandColors.error, width: 1),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Rubik',
          color: BrandColors.textTertiary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Rubik',
          color: BrandColors.textSecondary,
          fontSize: 14,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: BrandColors.surfaceVariant,
        selectedColor: BrandColors.primarySurface,
        labelStyle: const TextStyle(
          fontFamily: 'Rubik',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BrandRadius.chip,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BrandColors.textPrimary,
        contentTextStyle: const TextStyle(
          fontFamily: 'Rubik',
          color: BrandColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BrandColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: BrandColors.disabled,
        dragHandleSize: Size(40, 4),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: BrandColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Rubik',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: BrandColors.textPrimary,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BrandColors.primary,
        linearTrackColor: BrandColors.surfaceVariant,
        circularTrackColor: BrandColors.surfaceVariant,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BrandColors.primary;
          }
          return BrandColors.disabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BrandColors.primarySurface;
          }
          return BrandColors.surfaceVariant;
        }),
      ),

      // Slider
      sliderTheme: const SliderThemeData(
        activeTrackColor: BrandColors.primary,
        inactiveTrackColor: BrandColors.surfaceVariant,
        thumbColor: BrandColors.primary,
        overlayColor: Color(0x29F72928),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: BrandColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Text Theme
      textTheme: _textTheme,
      fontFamily: 'Rubik',
    );
  }

  // ============================================
  // DARK THEME
  // ============================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Colors
      primaryColor: BrandColors.primary,
      scaffoldBackgroundColor: BrandColors.darkBackground,
      canvasColor: BrandColors.darkSurface,
      dividerColor: BrandColors.darkDivider,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: BrandColors.primary,
        onPrimary: BrandColors.textOnPrimary,
        primaryContainer: BrandColors.primaryDark,
        secondary: BrandColors.secondary,
        onSecondary: BrandColors.textOnPrimary,
        secondaryContainer: BrandColors.secondaryDark,
        surface: BrandColors.darkSurface,
        onSurface: BrandColors.darkTextPrimary,
        error: BrandColors.error,
        onError: BrandColors.textOnPrimary,
      ),

      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: BrandColors.darkBackground,
        foregroundColor: BrandColors.darkTextPrimary,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Rubik',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: BrandColors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(
          color: BrandColors.darkTextPrimary,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BrandColors.darkSurface,
        selectedItemColor: BrandColors.primary,
        unselectedItemColor: BrandColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Rubik',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Rubik',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: BrandColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BrandRadius.card,
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.primary,
          foregroundColor: BrandColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BrandRadius.button,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BrandColors.primary,
          side: const BorderSide(color: BrandColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BrandRadius.button,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BrandColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BrandColors.primary,
        foregroundColor: BrandColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BrandColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BrandRadius.input,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BrandRadius.input,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BrandRadius.input,
          borderSide: const BorderSide(color: BrandColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BrandRadius.input,
          borderSide: const BorderSide(color: BrandColors.error, width: 1),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Rubik',
          color: BrandColors.darkTextTertiary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Rubik',
          color: BrandColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: BrandColors.darkSurfaceVariant,
        selectedColor: BrandColors.primaryDark,
        labelStyle: const TextStyle(
          fontFamily: 'Rubik',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: BrandColors.darkTextPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BrandRadius.chip,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BrandColors.darkSurfaceElevated,
        contentTextStyle: const TextStyle(
          fontFamily: 'Rubik',
          color: BrandColors.darkTextPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BrandColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: BrandColors.darkTextTertiary,
        dragHandleSize: Size(40, 4),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: BrandColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Rubik',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: BrandColors.darkTextPrimary,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BrandColors.primary,
        linearTrackColor: BrandColors.darkSurfaceVariant,
        circularTrackColor: BrandColors.darkSurfaceVariant,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BrandColors.primary;
          }
          return BrandColors.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BrandColors.primaryDark;
          }
          return BrandColors.darkSurfaceVariant;
        }),
      ),

      // Slider
      sliderTheme: const SliderThemeData(
        activeTrackColor: BrandColors.primary,
        inactiveTrackColor: BrandColors.darkSurfaceVariant,
        thumbColor: BrandColors.primary,
        overlayColor: Color(0x29F72928),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: BrandColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // Text Theme
      textTheme: _darkTextTheme,
      fontFamily: 'Rubik',
    );
  }

  // ============================================
  // TEXT THEMES
  // ============================================

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.2,
      color: BrandColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
      color: BrandColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.3,
      color: BrandColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      height: 1.3,
      color: BrandColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.4,
      color: BrandColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: BrandColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: BrandColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: BrandColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: BrandColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: BrandColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: BrandColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: BrandColors.textTertiary,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      height: 1.4,
      color: BrandColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      height: 1.4,
      color: BrandColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      height: 1.4,
      color: BrandColors.textTertiary,
    ),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.2,
      color: BrandColors.darkTextPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
      color: BrandColors.darkTextPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.3,
      color: BrandColors.darkTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      height: 1.3,
      color: BrandColors.darkTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.4,
      color: BrandColors.darkTextPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: BrandColors.darkTextPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: BrandColors.darkTextPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: BrandColors.darkTextPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: BrandColors.darkTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: BrandColors.darkTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: BrandColors.darkTextSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: BrandColors.darkTextTertiary,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      height: 1.4,
      color: BrandColors.darkTextPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      height: 1.4,
      color: BrandColors.darkTextSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Rubik',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      height: 1.4,
      color: BrandColors.darkTextTertiary,
    ),
  );
}

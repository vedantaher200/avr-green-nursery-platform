import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AVRGREEN Design System — Botanical Material 3 Theme
// Color Palette: Forest Green, Terracotta, Sage Green
// ─────────────────────────────────────────────────────────────────────────────

class AVRColors {
  AVRColors._();

  // Primary — Deep Forest Green (#1F5D3A)
  static const Color forestGreen = Color(0xFF1F5D3A);
  static const Color forestGreenLight = Color(0xFF2C7D4E);
  static const Color forestGreenDark = Color(0xFF133B25);
  static const Color forestGreenSurface = Color(0xFFEAF5EE);

  // Secondary — Warm Terracotta (#C9713D)
  static const Color terracotta = Color(0xFFC9713D);
  static const Color terracottaLight = Color(0xFFDC8654);
  static const Color terracottaDark = Color(0xFFA65626);
  static const Color terracottaSurface = Color(0xFFFDF2EC);

  // Accent — Soft Sage (#A8C5A0)
  static const Color sage = Color(0xFFA8C5A0);
  static const Color sageLight = Color(0xFFC0D7BA);
  static const Color sageSurface = Color(0xFFF3F7F2);

  // Neutrals
  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color backgroundDark = Color(0xFF0F1F1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A2E27);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E3329);

  // Status Colors (Master Prompt Section 32)
  static const Color success = Color(0xFF3C9A5F);
  static const Color warning = Color(0xFFD98E27);
  static const Color error = Color(0xFFB84C3C);
  static const Color info = Color(0xFF2980B9);

  // Text
  static const Color textPrimary = Color(0xFF0F1F1A);
  static const Color textSecondary = Color(0xFF5B7168);
  static const Color textDisabled = Color(0xFFADC1BA);
  static const Color textOnDark = Color(0xFFF0F7F4);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forestGreen, forestGreenLight],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [forestGreenDark, forestGreen],
  );

  static const LinearGradient terracottaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [terracotta, terracottaLight],
  );

  static const LinearGradient sageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sage, sageLight],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Text Styles
// ─────────────────────────────────────────────────────────────────────────────
class AVRTextStyles {
  AVRTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      );
  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
      );
  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      );
  static TextStyle get titleSmall => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );
  static TextStyle get bodyLarge => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );
  static TextStyle get bodyMedium => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );
  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );
  static TextStyle get labelLarge => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );
  static TextStyle get labelSmall => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  // KPI Card number style
  static TextStyle get kpiValue => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme Builder
// ─────────────────────────────────────────────────────────────────────────────
class AVRTheme {
  AVRTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AVRColors.forestGreen,
      brightness: Brightness.light,
      primary: AVRColors.forestGreen,
      onPrimary: Colors.white,
      primaryContainer: AVRColors.forestGreenSurface,
      secondary: AVRColors.terracotta,
      onSecondary: Colors.white,
      secondaryContainer: AVRColors.terracottaSurface,
      tertiary: AVRColors.sage,
      surface: AVRColors.surfaceLight,
      onSurface: AVRColors.textPrimary,
      error: AVRColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(AVRColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AVRColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        titleTextStyle:
            AVRTextStyles.titleLarge.copyWith(color: AVRColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AVRColors.cardLight,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AVRColors.forestGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AVRTextStyles.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AVRColors.forestGreen,
          side: const BorderSide(color: AVRColors.forestGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AVRTextStyles.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AVRColors.forestGreen,
          textStyle: AVRTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AVRColors.sageSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E8E4), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AVRColors.forestGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AVRColors.error, width: 1),
        ),
        labelStyle:
            AVRTextStyles.bodyMedium.copyWith(color: AVRColors.textSecondary),
        hintStyle:
            AVRTextStyles.bodyMedium.copyWith(color: AVRColors.textDisabled),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AVRColors.forestGreen,
        unselectedItemColor: AVRColors.textDisabled,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AVRColors.forestGreenDark,
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 24),
        unselectedIconTheme:
            IconThemeData(color: Colors.white.withValues(alpha: 0.5), size: 24),
        selectedLabelTextStyle:
            AVRTextStyles.labelSmall.copyWith(color: Colors.white),
        unselectedLabelTextStyle:
            AVRTextStyles.labelSmall.copyWith(color: Colors.white54),
        indicatorColor: AVRColors.forestGreenLight,
        useIndicator: true,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AVRColors.forestGreenSurface,
        selectedColor: AVRColors.forestGreen,
        labelStyle: AVRTextStyles.labelSmall,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEF2F0),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AVRColors.forestGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      scaffoldBackgroundColor: AVRColors.backgroundLight,
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AVRColors.textPrimary,
        contentTextStyle:
            AVRTextStyles.bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AVRColors.forestGreen,
      brightness: Brightness.dark,
      primary: AVRColors.forestGreenLight,
      onPrimary: Colors.white,
      surface: AVRColors.surfaceDark,
      onSurface: AVRColors.textOnDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(AVRColors.textOnDark),
      scaffoldBackgroundColor: AVRColors.backgroundDark,
      cardTheme: CardThemeData(
        color: AVRColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AVRColors.surfaceDark,
        foregroundColor: AVRColors.textOnDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: AVRTextStyles.displayLarge.copyWith(color: baseColor),
      displayMedium: AVRTextStyles.displayMedium.copyWith(color: baseColor),
      headlineLarge: AVRTextStyles.headlineLarge.copyWith(color: baseColor),
      headlineMedium: AVRTextStyles.headlineMedium.copyWith(color: baseColor),
      headlineSmall: AVRTextStyles.headlineSmall.copyWith(color: baseColor),
      titleLarge: AVRTextStyles.titleLarge.copyWith(color: baseColor),
      titleMedium: AVRTextStyles.titleMedium.copyWith(color: baseColor),
      titleSmall: AVRTextStyles.titleSmall.copyWith(color: baseColor),
      bodyLarge: AVRTextStyles.bodyLarge.copyWith(color: baseColor),
      bodyMedium: AVRTextStyles.bodyMedium.copyWith(color: baseColor),
      bodySmall: AVRTextStyles.bodySmall
          .copyWith(color: baseColor.withValues(alpha: 0.7)),
      labelLarge: AVRTextStyles.labelLarge.copyWith(color: baseColor),
      labelSmall: AVRTextStyles.labelSmall
          .copyWith(color: baseColor.withValues(alpha: 0.7)),
    );
  }
}

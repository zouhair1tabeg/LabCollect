import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'liquid_glass_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    final textTheme = GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.dark(
        primary: LiquidGlass.accentBlue,
        secondary: LiquidGlass.accentViolet,
        tertiary: LiquidGlass.accentGreen,
        surface: Colors.transparent,
        error: LiquidGlass.error,
        onSurface: LiquidGlass.textPrimary,
        onPrimary: Colors.white,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: LiquidGlass.heading(fontSize: 32),
        headlineMedium: LiquidGlass.heading(fontSize: 28),
        headlineSmall: LiquidGlass.heading(fontSize: 24),
        titleLarge: LiquidGlass.heading(fontSize: 22),
        titleMedium: LiquidGlass.body(fontSize: 16),
        titleSmall: LiquidGlass.body(fontSize: 14),
        bodyLarge: LiquidGlass.body(fontSize: 16),
        bodyMedium: LiquidGlass.body(fontSize: 14),
        bodySmall: LiquidGlass.bodySecondary(fontSize: 12),
        labelLarge: LiquidGlass.body(fontSize: 14),
        labelMedium: LiquidGlass.bodySecondary(fontSize: 12),
        labelSmall: LiquidGlass.label(),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: LiquidGlass.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: LiquidGlass.heading(fontSize: 20),
        iconTheme: IconThemeData(color: LiquidGlass.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LiquidGlass.glassRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LiquidGlass.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LiquidGlass.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LiquidGlass.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LiquidGlass.inputFocusBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LiquidGlass.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LiquidGlass.error, width: 2),
        ),
        labelStyle: LiquidGlass.bodySecondary(),
        hintStyle: LiquidGlass.bodySecondary(),
        prefixIconColor: LiquidGlass.textSecondary,
        suffixIconColor: LiquidGlass.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: LiquidGlass.glassFill,
        selectedColor: LiquidGlass.accentBlue.withValues(alpha: 0.20),
        labelStyle: LiquidGlass.body(fontSize: 13),
        side: BorderSide(color: LiquidGlass.glassBorder),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: LiquidGlass.glassFill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: LiquidGlass.accentBlue, width: 3),
        ),
        labelColor: LiquidGlass.accentBlue,
        unselectedLabelColor: LiquidGlass.textSecondary,
        labelStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.10),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LiquidGlass.glassRadius),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: LiquidGlass.accentBlue,
        unselectedItemColor: LiquidGlass.textSecondary,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return LiquidGlass.accentBlue.withValues(alpha: 0.20);
            }
            return LiquidGlass.inputFill;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return LiquidGlass.accentBlue;
            }
            return LiquidGlass.textSecondary;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: LiquidGlass.glassBorder),
          ),
        ),
      ),
    );
  }
}

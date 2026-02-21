import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Liquid Glass Design System — iOS 26 inspired
/// Central design tokens for the entire app.
class LiquidGlass {
  LiquidGlass._();

  // ── Background ──────────────────────────────────────
  static const Color bgDark = Color(0xFF0A0A1A);

  // ── Accent Palette ──────────────────────────────────
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color accentViolet = Color(0xFFB39DDB);
  static const Color accentGreen = Color(0xFF80CBC4);

  // ── Orb Colors ──────────────────────────────────────
  static const Color orbBlue = Color(0xFF4FC3F7);
  static const Color orbViolet = Color(0xFFB39DDB);
  static const Color orbGreen = Color(0xFF80CBC4);
  static const double orbBlueOpacity = 0.35;
  static const double orbVioletOpacity = 0.30;
  static const double orbGreenOpacity = 0.20;

  // ── Text Colors ─────────────────────────────────────
  static Color textPrimary = Colors.white.withValues(alpha: 0.95);
  static Color textSecondary = Colors.white.withValues(alpha: 0.60);

  // ── Status Colors ───────────────────────────────────
  static const Color pending = Color(0xFFFFB74D);
  static const Color done = Color(0xFFA5D6A7);
  static const Color error = Color(0xFFEF9A9A);

  // ── Glass Properties ────────────────────────────────
  static const double glassBlur = 28.0;
  static const double glassRadius = 28.0;
  static Color glassFill = Colors.white.withValues(alpha: 0.10);
  static Color glassBorder = Colors.white.withValues(alpha: 0.30);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.55);

  // ── Shadows ─────────────────────────────────────────
  static List<BoxShadow> get glassShadows => [
    BoxShadow(blurRadius: 32, color: Colors.black.withValues(alpha: 0.18)),
  ];

  // ── Input ───────────────────────────────────────────
  static Color inputFill = Colors.white.withValues(alpha: 0.07);
  static Color inputBorder = Colors.white.withValues(alpha: 0.15);
  static Color inputFocusBorder = accentBlue.withValues(alpha: 0.50);
  static Color inputFocusGlow = accentBlue.withValues(alpha: 0.15);

  // ── Button ──────────────────────────────────────────
  static const double buttonRadius = 18.0;
  static Color buttonGlow(Color accent) => accent.withValues(alpha: 0.35);

  // ── Badge ───────────────────────────────────────────
  static const double badgeRadius = 20.0;

  // ── Typography ──────────────────────────────────────
  static TextStyle heading({double fontSize = 28}) => GoogleFonts.dmSans(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: textPrimary,
  );

  static TextStyle label() => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: textSecondary,
  );

  static TextStyle body({double fontSize = 14}) => GoogleFonts.dmSans(
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle bodySecondary({double fontSize = 14}) => GoogleFonts.dmSans(
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // ── Status Badge Decoration ─────────────────────────
  static BoxDecoration statusBadge(Color statusColor) => BoxDecoration(
    color: statusColor.withValues(alpha: 0.20),
    border: Border.all(color: statusColor.withValues(alpha: 0.30)),
    borderRadius: BorderRadius.circular(badgeRadius),
  );

  // ── Status helpers ──────────────────────────────────
  static Color syncOnline = const Color(0xFFA5D6A7);
  static Color syncOffline = const Color(0xFFFFB74D);
  static Color syncError = const Color(0xFFEF9A9A);
}

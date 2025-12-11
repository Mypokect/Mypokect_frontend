import 'package:flutter/material.dart';

/// Tokens de diseño locales para el módulo Calendario.
/// Mapea los colores del [ColorScheme] global a roles semánticos del calendario.
class CalendarTheme {
  const CalendarTheme._();

  // --- Watercourse Palette ---
  static const Color watercourse50 = Color(0xFFEBFEF6);
  static const Color watercourse100 = Color(0xFFCEFDE7);
  static const Color watercourse200 = Color(0xFFA2F8D4);
  static const Color watercourse300 = Color(0xFF66EFBF);
  static const Color watercourse400 = Color(0xFF29DEA5);
  static const Color watercourse500 = Color(0xFF05C48E);
  static const Color watercourse600 = Color(0xFF00A075);
  static const Color watercourse700 = Color(0xFF008060);
  static const Color watercourse800 = Color(0xFF006B52);
  static const Color watercourse900 = Color(0xFF015341);
  static const Color watercourse950 = Color(0xFF002F25);

  // --- Colores Semánticos ---

  static Color primaryBG(BuildContext context) => watercourse600;

  static Color onPrimaryBG(BuildContext context) => Colors.white;

  static Color cardBG(BuildContext context) => Colors.white;

  static Color textPrimary(BuildContext context) => watercourse950;

  static Color textSecondary(BuildContext context) => watercourse700;

  static Color badgeDue(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color badgeToday(BuildContext context) => watercourse400;

  static Color outline(BuildContext context) => watercourse200;

  static Color shadowColor(BuildContext context) => watercourse900;

  // --- Constantes de Diseño ---

  static const double shadowElevation = 6.0;
  static const double cardRadius = 20.0;
  static const double chipRadius = 20.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;

  // --- Sombras ---

  static List<BoxShadow> softShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: shadowColor(context).withOpacity(isDark ? 0.3 : 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: shadowColor(context).withOpacity(isDark ? 0.4 : 0.15),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 2,
      ),
    ];
  }

  // --- Tipografía ---

  static TextStyle h1(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: textPrimary(context),
          ) ??
      TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: textPrimary(context),
      );

  static TextStyle h2(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary(context),
          ) ??
      TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary(context),
      );

  static TextStyle subtitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary(context),
          ) ??
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary(context),
      );

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: textSecondary(context),
          ) ??
      TextStyle(
        fontSize: 14,
        color: textSecondary(context),
      );
}

import 'package:flutter/material.dart';
import '../../../../Theme/Theme.dart';

/// Tokens de diseño locales para el feature de calendario
class CalendarTokens {
  // Paleta (reutiliza solo colores globales de la app)
  static Color primary = AppTheme.primaryColor;
  static Color success = AppTheme.primaryColor; // mismo tono para estados positivos
  static Color warning = AppTheme.accentColor;  // ya definido en el tema
  static Color error = AppTheme.errorColor;

  // Espaciados
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 24;

  // Radios
  static const double radiusM = 16;
  static const double radiusL = 20;

  // Animaciones
  static const Duration animationFast = Duration(milliseconds: 220);

  static BoxShadow softShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
      blurRadius: 18,
      offset: const Offset(0, 6),
    );
  }

  // Tipografías (basadas en tipografía de sistema)
  static TextStyle h1(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ) ??
      const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);

  static TextStyle h2(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ) ??
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle body16(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16) ??
      const TextStyle(fontSize: 16);

  static TextStyle body14(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14) ??
      const TextStyle(fontSize: 14);
}
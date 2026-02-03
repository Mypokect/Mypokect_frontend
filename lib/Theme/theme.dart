// lib/Theme/Theme.dart
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppTheme {
  // ============================================================
  // COLORES PRINCIPALES
  // ============================================================
  static Color primaryColor = HexColor('#006B52');
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Colors.black;
  static const Color errorColor = Colors.red;
  static Color greyColor = HexColor('#888888');

  // ============================================================
  // COLORES DE MOVIMIENTOS
  // ============================================================
  static const Color expenseColor = Color(0xFFE57373);
  static const Color expenseDarkColor = Color(0xFFEF5350);
  static const Color incomeColor = Color(0xFF4DB6AC);
  static const Color incomeDarkColor = Color(0xFF009688);

  // ============================================================
  // COLORES PASTEL (para fondos suaves)
  // ============================================================
  static const Color pastelRed = Color(0xFFFFF0F0);
  static const Color pastelGreen = Color(0xFFF0FFF4);
  static const Color pastelBlue = Color(0xFFF0F4FF);
  static const Color pastelYellow = Color(0xFFFFFBE6);
  static const Color pastelPurple = Color(0xFFF3E5F5);

  // ============================================================
  // COLORES PARA METAS/OBJETIVOS
  // ============================================================
  static const Color goalGreen = Color(0xFF4CAF50);
  static const Color goalBlue = Color(0xFF42A5F5);
  static const Color goalOrange = Color(0xFFFF9800);
  static const Color goalPink = Color(0xFFE91E63);
  static const Color goalPurple = Color(0xFF9C27B0);
  static const Color goalTeal = Color(0xFF009688);

  // ============================================================
  // COLORES PARA CATEGORÍAS DE PRESUPUESTO (Array)
  // ============================================================
  static const List<Color> categoryColors = [
    Color(0xFF4E9F3D), // Verde
    Color(0xFFD83A56), // Rojo
    Color(0xFFFF8E00), // Naranja
    Color(0xFF1E56A0), // Azul
    Color(0xFF8E44AD), // Morado
    Color(0xFF16A085), // Teal
    Color(0xFFE74C3C), // Rojo brillante
    Color(0xFFF39C12), // Amarillo
  ];

  // ============================================================
  // BORDER RADIUS (Estandarizado)
  // ============================================================
  static const double radiusXL = 40.0; // Headers grandes
  static const double radiusL = 20.0; // Tarjetas principales
  static const double radiusM = 16.0; // Tarjetas secundarias
  static const double radiusS = 14.0; // Inputs y botones
  static const double radiusXS = 8.0; // Elementos pequeños

  // ============================================================
  // BOX SHADOWS (Estandarizado)
  // ============================================================
  static BoxShadow shadowElevation2 = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static BoxShadow shadowElevation4 = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  static BoxShadow shadowElevation8 = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );

  // ============================================================
  // PADDING (Estandarizado)
  // ============================================================
  static const EdgeInsets paddingXL = EdgeInsets.all(32.0);
  static const EdgeInsets paddingL = EdgeInsets.all(24.0);
  static const EdgeInsets paddingM = EdgeInsets.all(20.0);
  static const EdgeInsets paddingS = EdgeInsets.all(16.0);
  static const EdgeInsets paddingXS = EdgeInsets.all(12.0);

  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: 24.0);
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: 16.0);

  // ============================================================
  // FONT SIZES (Estandarizado)
  // ============================================================
  static const double fontSizeDisplay = 54.0; // Montos grandes
  static const double fontSizeH1 = 32.0; // Títulos principales
  static const double fontSizeH2 = 24.0; // Subtítulos
  static const double fontSizeH3 = 20.0; // Encabezados
  static const double fontSizeBody = 16.0; // Texto normal
  static const double fontSizeBodySmall = 14.0; // Texto secundario
  static const double fontSizeCaption = 12.0; // Texto pequeño
  static const double fontSizeTiny = 10.0; // Etiquetas

  // ============================================================
  // FUENTES (Nombres centralizados)
  // ============================================================
  static const String fontFamilyPrimary = 'Baloo2';
  static const String fontFamilySecondary = 'Poppins';

  // ============================================================
  // HELPERS (Métodos de utilidad)
  // ============================================================

  /// Retorna un BorderRadius circular con el valor especificado
  static BorderRadius radius(double value) => BorderRadius.circular(value);

  /// Retorna un EdgeInsets simétrico con los valores especificados
  static EdgeInsets padding({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// Retorna un color de categoría basado en el índice
  static Color getCategoryColor(int index) =>
      categoryColors[index % categoryColors.length];
}

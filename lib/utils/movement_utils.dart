import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utilidades para la pantalla de movimientos
class MovementUtils {
  static final NumberFormat currencyFormat = NumberFormat.decimalPattern('es_CO');

  // =====================================================
  // HELPERS DE RESPONSIVIDAD
  // =====================================================

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double responsivePadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 16.0;
    if (width < 400) return 20.0;
    if (width < 600) return 24.0;
    return 32.0;
  }

  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    final width = screenWidth(context);
    if (width < 360) return baseSpacing * 0.8;
    if (width > 600) return baseSpacing * 1.2;
    return baseSpacing;
  }

  static double toggleWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 120.0;
    if (width > 600) return 180.0;
    return 140.0;
  }

  // =====================================================
  // FORMATEO DE MONEDA
  // =====================================================

  /// Formatea un valor numérico como moneda colombiana
  static String formatCurrency(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isEmpty) return '';

    try {
      return currencyFormat.format(BigInt.parse(cleanValue));
    } catch (e) {
      return value;
    }
  }

  /// Obtiene la representación abreviada de un monto
  static String getAbbreviatedAmount(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isEmpty) return "0";

    try {
      final amount = BigInt.parse(cleanValue);
      final num = amount.toInt();

      if (num >= 1000000000) {
        final billions = num / 1000000000;
        return "${billions.toStringAsFixed(billions % 1 == 0 ? 0 : 1)} B";
      } else if (num >= 1000000) {
        final millions = num / 1000000;
        return "${millions.toStringAsFixed(millions % 1 == 0 ? 0 : 1)} M";
      } else if (num >= 10000) {
        final thousands = num / 1000;
        return "${thousands.toStringAsFixed(thousands % 1 == 0 ? 0 : 1)} K";
      }
      return currencyFormat.format(amount);
    } catch (e) {
      return value;
    }
  }

  /// Calcula el tamaño de fuente según la cantidad de dígitos
  static double calculateFontSize(int digitsCount) {
    if (digitsCount > 10) return 60.0;
    if (digitsCount > 6) return 68.0;
    return 80.0;
  }

  /// Verifica si el monto puede abreviarse (>= 10.000)
  static bool canAbbreviate(int digitsCount) => digitsCount >= 5;

  // =====================================================
  // HELPERS DE ETIQUETAS
  // =====================================================

  /// Detecta si una etiqueta es de tipo meta
  static bool isGoalTag(String tag, List<String> metas) {
    if (metas.contains(tag)) return true;
    return tag.startsWith('💰') || tag.toLowerCase().contains('meta:');
  }

  /// Detecta si un tag viene de la API de metas
  static bool isTagFromGoals(String tag) {
    if (tag.isEmpty) return false;
    final parts = tag.split(' ');
    if (parts.length < 2) return false;
    final firstPart = parts.first;
    return firstPart.runes.length <= 4;
  }

  /// Verifica si hay alta coincidencia entre texto y etiqueta
  static bool hasHighMatch(String textoEscrito, String etiqueta) {
    final texto = textoEscrito.toLowerCase();
    final tag = etiqueta.toLowerCase();

    if (texto == tag) return true;

    final textoSinEmoji = texto.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    if (tag.startsWith(texto) && textoSinEmoji.length >= 3) return true;

    return false;
  }

  /// Separa etiquetas en categorías y metas
  static ({List<String> categorias, List<String> metas}) separateTags(List<String> tags) {
    final categorias = tags
        .where((tag) =>
            !tag.startsWith('💰') &&
            !tag.toLowerCase().contains('meta:') &&
            !isTagFromGoals(tag))
        .toList();

    final metas = tags
        .where((tag) =>
            tag.startsWith('💰') ||
            tag.toLowerCase().contains('meta:') ||
            isTagFromGoals(tag))
        .toList();

    return (categorias: categorias, metas: metas);
  }
}

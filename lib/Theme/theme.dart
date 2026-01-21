// lib/Theme/Theme.dart
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppTheme {
  static Color primaryColor = HexColor('#006B52');
  static const Color secondaryColor = Color(0xFF03DAC6);

  // --- AÑADE ESTA LÍNEA ---
  static const Color accentColor = Color(0xFF03DAC6);

  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Colors.black;
  static const Color errorColor = Colors.red;
  static Color greyColor = HexColor('#888888');

  // Movement colors
  static const Color expenseColor = Color(0xFFE57373);
  static const Color expenseDarkColor = Color(0xFFEF5350);
  static const Color incomeColor = Color(0xFF4DB6AC);
  static const Color incomeDarkColor = Color(0xFF009688);
}

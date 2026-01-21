import 'package:flutter/material.dart';

class GoalColors {
  static const Color blue = Color(0xFF2196F3);
  static const Color purple = Color(0xFF9C27B0);
  static const Color orange = Color(0xFFFF5722);
  static const Color green = Color(0xFF4CAF50);
  static const Color cyan = Color(0xFF00BCD4);
  static const Color pink = Color(0xFFE91E63);
  static const Color red = Color(0xFFF44336);
  static const Color teal = Color(0xFF009688);
  static const Color amber = Color(0xFFFFC107);
  static const Color indigo = Color(0xFF3F51B5);

  static List<Color> get allColors => [
        blue,
        purple,
        orange,
        green,
        cyan,
        pink,
        red,
        teal,
        amber,
        indigo,
      ];

  static Color getRandomColor() {
    return allColors[(DateTime.now().millisecond) % allColors.length];
  }
}

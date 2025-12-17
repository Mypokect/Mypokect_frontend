import 'package:flutter/material.dart';

import '../Theme/Theme.dart';
import 'TextWidget.dart';

class Buttoncustom extends StatelessWidget {
  const Buttoncustom({
    super.key,
    required this.text,
    this.size = 16,
    this.onTap,
    this.color, // <--- 1. Agregamos el parámetro opcional aquí
  });

  final String text;
  final double size;
  final Function? onTap;
  final Color? color; // <--- 2. Definimos la variable

  @override
  Widget build(BuildContext context) {
    // 3. Lógica de color: 
    // Si nos pasan un color específico (ej: gris desde BudgetScreen), lo usamos.
    // Si no, usamos la lógica original (Primary si está activo, Grey si está deshabilitado).
    Color background = color ?? (onTap != null ? AppTheme.primaryColor : Colors.grey);

    return GestureDetector(
      onTap: onTap != null ? () {
        onTap!();
      } : null,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          color: background, // <--- 4. Usamos la variable calculada
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Textwidget(text: text, color: Colors.white, size: size,)
        ),
      ),
    );
  }
}
import 'package:MyPocket/Theme/Theme.dart';
import 'package:MyPocket/Widgets/TextWidget.dart';
import 'package:flutter/material.dart';

class AnimatedToggleSwitch extends StatefulWidget {
  const AnimatedToggleSwitch({Key? key}) : super(key: key);

  @override
  State<AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<AnimatedToggleSwitch> {
  // 1. Variable de estado para controlar si es 'Ingreso' o 'Gasto'.
  bool _isIngreso = true;

  // Duración y curva de la animación para un efecto suave y moderno.
  final Duration _animationDuration = const Duration(milliseconds: 350);
  final Curve _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    // 2. GestureDetector para detectar el toque del usuario.
    return GestureDetector(
      onTap: () {
        // Al tocar, cambiamos el estado dentro de setState para que la UI se reconstruya.
        setState(() {
          _isIngreso = !_isIngreso;
        });
      },
      child: AnimatedContainer(
        // 3. AnimatedContainer para el fondo principal.
        // Podrías animar su color también si quisieras.
        duration: _animationDuration,
        curve: _animationCurve,
        width: 150,
        height: 50,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [ // Sombra sutil para un efecto de profundidad
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        // 4. Usamos un Stack para poder posicionar libremente el texto y el círculo.
        child: Stack(
          children: [
            // 5. Círculo animado (el indicador)
            AnimatedAlign(
              duration: _animationDuration,
              curve: _animationCurve,
              // Alinea el círculo a la derecha para 'Ingreso' y a la izquierda para 'Gasto'.
              alignment: _isIngreso ? Alignment.centerRight : Alignment.centerLeft,
              child: AnimatedContainer(
                duration: _animationDuration,
                curve: _animationCurve,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  // Cambia el color del círculo según el estado.
                  color: _isIngreso ? AppTheme.primaryColor : Colors.red,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  // Cambia el icono según el estado.
                  child: Icon(
                    _isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // 6. Texto animado
            AnimatedAlign(
              duration: _animationDuration,
              curve: _animationCurve,
              // Alinea el texto a la izquierda para 'Ingreso' y a la derecha para 'Gasto'.
              // El padding asegura que no se pegue al borde.
              alignment: _isIngreso ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Textwidget(
                  // Cambia el texto según el estado.
                  text: _isIngreso ? 'Ingreso' : 'Gasto',
                  size: 16,
                  color: Colors.grey[700]!,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
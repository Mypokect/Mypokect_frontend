// lib/Widgets/animated_toggle_switch.dart

import 'package:MyPocket/Theme/Theme.dart';
import 'package:MyPocket/Widgets/TextWidget.dart';
import 'package:flutter/material.dart';

class AnimatedToggleSwitch extends StatefulWidget {
  // --- CAMBIO 1: AÑADIR PARÁMETROS DE ENTRADA ---
  // Recibimos el valor desde el padre (Movements). true = Gasto, false = Ingreso.
  final bool value;
  // Recibimos una función para notificar al padre cuando el usuario toca el widget.
  final ValueChanged<bool> onChanged;

  const AnimatedToggleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<AnimatedToggleSwitch> {
  // Mantenemos tu estado interno para que tus animaciones y diseño no cambien.
  bool _isIngreso = true;

  // Mantenemos tus constantes de animación.
  final Duration _animationDuration = const Duration(milliseconds: 350);
  final Curve _animationCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    // --- CAMBIO 2: SINCRONIZACIÓN INICIAL ---
    // Al iniciar el widget, sincronizamos nuestro estado interno `_isIngreso`
    // con el valor `_esGasto` que nos llega del padre (`widget.value`).
    // Aquí hacemos la "traducción":
    // Si el padre dice que `value` es true (es Gasto), nuestro `_isIngreso` debe ser false.
    _isIngreso = !widget.value;
  }

  @override
  void didUpdateWidget(AnimatedToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // --- CAMBIO 3: SINCRONIZACIÓN EN CALIENTE (LA MAGIA OCURRE AQUÍ) ---
    // Este método se llama cada vez que el padre reconstruye el widget con un nuevo valor
    // (por ejemplo, después de la llamada a la API de voz).
    // Si el valor que nos llega del padre es diferente al que teníamos...
    if (widget.value != oldWidget.value) {
      // ...actualizamos nuestro estado interno para que coincida.
      setState(() {
        _isIngreso = !widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector para detectar el toque del usuario.
    return GestureDetector(
      onTap: () {
        // En lugar de cambiar el estado aquí, notificamos al padre.
        // El padre cambiará el estado, y luego nos enviará el nuevo valor,
        // que será capturado por `didUpdateWidget`, manteniendo todo sincronizado.
        widget.onChanged(!widget.value);
      },
      // El resto de tu código de diseño no cambia en absoluto.
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        width: 150,
        height: 50,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: _animationDuration,
              curve: _animationCurve,
              alignment: _isIngreso ? Alignment.centerLeft : Alignment.centerRight,
              child: AnimatedContainer(
                duration: _animationDuration,
                curve: _animationCurve,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isIngreso ? AppTheme.primaryColor : Colors.red,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Icon(
                    _isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            AnimatedAlign(
              duration: _animationDuration,
              curve: _animationCurve,
              alignment: _isIngreso ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Textwidget(
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
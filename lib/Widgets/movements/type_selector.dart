import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Theme/Theme.dart';

class TypeSelector extends StatelessWidget {
  final bool esGasto;
  final bool isGoalMode;
  final Color colorActive;
  final VoidCallback onTap;

  const TypeSelector({
    super.key,
    required this.esGasto,
    required this.isGoalMode,
    required this.colorActive,
    required this.onTap,
  });

  // =====================================================
  // HELPERS DE RESPONSIVIDAD
  // =====================================================

  double _screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  double _toggleHeight(BuildContext context) {
    final width = _screenWidth(context);
    if (width < 360) return 40.0; // Más compacto
    if (width > 600) return 52.0; // Más grande en tablets
    return 48.0; // Estándar
  }

  double _fontSize(BuildContext context, double base) {
    final width = _screenWidth(context);
    if (width < 360) return base * 0.9;
    if (width > 600) return base * 1.1;
    return base;
  }

  // =====================================================
  // BUILD PRINCIPAL
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final height = _toggleHeight(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colorActive.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorActive.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Indicador deslizante animado
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: esGasto ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: height - 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorActive,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: colorActive.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Textos GASTO / INGRESO
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "GASTO",
                      style: TextStyle(
                        fontSize: _fontSize(context, 13),
                        fontWeight: FontWeight.w900,
                        color: esGasto ? Colors.white : Colors.black54,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "INGRESO",
                      style: TextStyle(
                        fontSize: _fontSize(context, 13),
                        fontWeight: FontWeight.w900,
                        color: !esGasto ? Colors.white : Colors.black54,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

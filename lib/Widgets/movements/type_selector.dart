import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Widgets/common/text_widget.dart';
import '../../Theme/Theme.dart';

class TypeSelector extends StatelessWidget {
  final bool esGasto;
  final bool isGoalMode;
  final Color colorActive;
  final Color colorTexto;
  final VoidCallback onTap;

  const TypeSelector({
    super.key,
    required this.esGasto,
    required this.isGoalMode,
    required this.colorActive,
    required this.colorTexto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: colorActive.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorActive.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: esGasto ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: colorActive,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: colorActive.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: TextWidget(
                      text: "GASTO",
                      size: 10,
                      fontWeight: FontWeight.w900,
                      color: esGasto
                          ? Colors.white
                          : AppTheme.greyColor.withOpacity(0.6),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextWidget(
                      text: "INGRESO",
                      size: 10,
                      fontWeight: FontWeight.w900,
                      color: !esGasto
                          ? Colors.white
                          : AppTheme.greyColor.withOpacity(0.6),
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

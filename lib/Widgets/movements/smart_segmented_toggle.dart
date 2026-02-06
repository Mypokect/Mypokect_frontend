import 'package:flutter/material.dart';

class SmartSegmentedToggle extends StatelessWidget {
  final bool isExpense;
  final VoidCallback onToggle;

  const SmartSegmentedToggle({super.key, required this.isExpense, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              // Fondo animado (La pastilla blanca)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                left: isExpense ? 0 : width * 0.5,
                child: Container(
                  width: width * 0.5,
                  height: 47,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))]
                  ),
                ),
              ),
              // Textos y Botones
              Row(
                children: [
                  _buildOption("GASTO", Icons.trending_down, isExpense, const Color(0xFFFF5252), width * 0.5),
                  _buildOption("INGRESO", Icons.trending_up, !isExpense, const Color(0xFF4CAF50), width * 0.5),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildOption(String text, IconData icon, bool isActive, Color activeColor, double width) {
    return GestureDetector(
      onTap: isActive ? null : onToggle,
      child: SizedBox(
        width: width,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isActive ? activeColor : Colors.grey[400]),
              const SizedBox(width: 6),
              Text(
                text, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: isActive ? activeColor : Colors.grey[500],
                  fontSize: 13
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
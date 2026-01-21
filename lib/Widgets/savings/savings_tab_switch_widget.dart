import 'package:flutter/material.dart';

class SavingsTabSwitchWidget extends StatelessWidget {
  final bool isMonthly;
  final VoidCallback onMonthlyTap;
  final VoidCallback onWeeklyTap;

  const SavingsTabSwitchWidget({
    Key? key,
    required this.isMonthly,
    required this.onMonthlyTap,
    required this.onWeeklyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          _buildTab("Mensual", isMonthly, onMonthlyTap),
          _buildTab("Semanal", !isMonthly, onWeeklyTap),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5)
                    ]
                  : []),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black : Colors.grey)),
        ),
      ),
    );
  }
}

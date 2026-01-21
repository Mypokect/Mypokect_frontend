import 'package:flutter/material.dart';
import 'package:MyPocket/utils/helpers.dart';

class BudgetValidationWidget extends StatelessWidget {
  final double total;
  final double current;
  final Color color;
  final bool isOverBudget;

  const BudgetValidationWidget({
    Key? key,
    required this.total,
    required this.current,
    required this.color,
    this.isOverBudget = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = total > 0 ? (current / total) : 0;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        children: [
          _buildProgressRow(progress, color),
          const SizedBox(height: 8),
          _buildProgressBar(progress, color),
          const SizedBox(height: 8),
          _buildAmountRow(current, total, color, isOverBudget),
        ],
      ),
    );
  }

  Widget _buildProgressRow(double progress, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text("Progreso",
          style: TextStyle(fontSize: 12, color: Colors.grey)),
      Text("${(progress * 100).toStringAsFixed(0)}%",
          style: TextStyle(color: color, fontWeight: FontWeight.bold))
    ]);
  }

  Widget _buildProgressBar(double progress, Color color) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
            value: progress > 1 ? 1 : progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8));
  }

  Widget _buildAmountRow(
      double current, double total, Color color, bool isOver) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(formatCurrency(current),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Meta: ${formatCurrency(total)}",
              style: const TextStyle(color: Colors.grey))
        ]),
        if (isOver)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text("Te pasaste por ${formatCurrency(current - total)}",
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}

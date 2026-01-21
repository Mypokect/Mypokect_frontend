import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/utils/helpers.dart';

class BudgetListCardWidget extends StatelessWidget {
  final String title;
  final double amount;
  final String mode;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const BudgetListCardWidget({
    Key? key,
    required this.title,
    required this.amount,
    required this.mode,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAI = mode == 'ai';

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
              border: isAI
                  ? Border.all(color: Colors.purple.withValues(alpha: 0.3))
                  : null),
          child: Row(
            children: [
              _buildCardIcon(isAI),
              const SizedBox(width: 15),
              Expanded(child: _buildCardContent(title, isAI)),
              _buildCardAmount(amount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.red[400], borderRadius: BorderRadius.circular(20)),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 25),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Widget _buildCardIcon(bool isAI) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAI
            ? Colors.purple.withValues(alpha: 0.1)
            : AppTheme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(isAI ? Icons.auto_awesome : Icons.edit_note,
          color: isAI ? Colors.purple : AppTheme.primaryColor, size: 24),
    );
  }

  Widget _buildCardContent(String title, bool isAI) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(isAI ? "Creado con IA" : "Manual",
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildCardAmount(double total) {
    return Text(
      formatCurrency(total),
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
    );
  }
}

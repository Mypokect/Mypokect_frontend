import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/utils/helpers.dart';

class CashflowRowWidget extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const CashflowRowWidget({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final double flujoNeto = totalIncome - totalExpense;
    final bool isPositive = flujoNeto >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Flujo Neto",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: 'Baloo2',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Ahorro potencial del mes",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontFamily: 'Baloo2',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppTheme.primaryColor : AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                "${isPositive ? '+' : ''}${formatCurrency(flujoNeto)}",
                style: TextStyle(
                  color: isPositive ? AppTheme.primaryColor : AppTheme.errorColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  fontFamily: 'Baloo2',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/utils/helpers.dart';

class HeroBalanceCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const HeroBalanceCard({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "DISPONIBLE",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontFamily: 'Baloo2',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatCurrency(balance),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: balance >= 0 ? Colors.black87 : AppTheme.errorColor,
              height: 1.0,
              fontFamily: 'Baloo2',
            ),
          ),
          const SizedBox(height: 25),
          Container(height: 1, color: const Color(0xFFF0F0F0)),
          const SizedBox(height: 25),

          // Ingresos y Gastos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ingresos
              _buildIncomeExpenseItem(
                label: "Ingresos",
                amount: totalIncome,
                icon: Icons.arrow_downward,
                backgroundColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF4CAF50),
              ),

              // Gastos
              _buildIncomeExpenseItem(
                label: "Gastos",
                amount: totalExpense,
                icon: Icons.arrow_upward,
                backgroundColor: const Color(0xFFFFEBEE),
                iconColor: const Color(0xFFFF5252),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseItem({
    required String label,
    required double amount,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Baloo2'),
            ),
            Text(
              formatCurrency(amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Baloo2',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

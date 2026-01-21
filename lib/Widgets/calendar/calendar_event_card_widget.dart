import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';

class CalendarEventCardWidget extends StatelessWidget {
  final dynamic id;
  final String title;
  final double amount;
  final String date;
  final String type;
  final bool isPaid;
  final bool isOverdue;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsPaid;

  const CalendarEventCardWidget({
    super.key,
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.isPaid,
    required this.isOverdue,
    this.onTap,
    this.onMarkAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        type == 'income' ? Colors.green : AppTheme.errorColor;
    final IconData iconData = type == 'income'
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Card(
      key: ValueKey("$id-$date"),
      elevation: 1.5,
      shadowColor: Colors.grey.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(iconData, color: iconColor, size: 32),
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isOverdue ? AppTheme.errorColor : Colors.black,
            )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\$${amount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, color: AppTheme.greyColor)),
            if (isOverdue)
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('VENCIDO',
                      style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10))),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline_rounded,
              color: Colors.grey, size: 28),
          tooltip: 'Marcar como finalizado',
          onPressed: onMarkAsPaid,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../styles/calendar_tokens.dart';

/// Célula de día accesible con badge de pendientes
class DayCell extends StatelessWidget {
  final DateTime day;
  final int pendingCount;
  final bool isToday;
  final bool isSelected;
  final bool isOutOfMonth;
  final bool hasOverdue;

  const DayCell({
    super.key,
    required this.day,
    required this.pendingCount,
    required this.isToday,
    required this.isSelected,
    required this.isOutOfMonth,
    required this.hasOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color background = Colors.transparent;
    Color textColor = isDark ? Colors.white : Colors.grey[800]!;

    if (isSelected) {
      background = CalendarTokens.primary.withOpacity(isDark ? 0.9 : 0.15);
      textColor = CalendarTokens.primary;
    } else if (isToday) {
      background = (isDark ? Colors.white : CalendarTokens.primary)
          .withOpacity(0.12);
    }

    if (isOutOfMonth) {
      textColor = textColor.withOpacity(0.4);
    }

    return Semantics(
      label:
          'Día ${day.day}, pendientes: $pendingCount${hasOverdue ? ', con vencidos' : ''}',
      button: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(CalendarTokens.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: CalendarTokens.spacingS,
          horizontal: CalendarTokens.spacingS,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (pendingCount > 0)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: hasOverdue
                        ? CalendarTokens.error
                        : CalendarTokens.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

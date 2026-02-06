import 'package:flutter/material.dart';
import '../theme/calendar_theme.dart';

enum CalendarViewType { day, week, month, year }

class CalendarSegmentedControl extends StatelessWidget {
  final CalendarViewType currentView;
  final ValueChanged<CalendarViewType> onViewChanged;

  const CalendarSegmentedControl({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: CalendarViewType.values.map((type) {
          final isSelected = type == currentView;
          return Expanded(
            child: GestureDetector(
              onTap: () => onViewChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CalendarTheme.primaryBG(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(CalendarTheme.chipRadius),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: CalendarTheme.primaryBG(context).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  _getLabel(type),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? CalendarTheme.onPrimaryBG(context)
                        : CalendarTheme.textSecondary(context),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(CalendarViewType type) {
    switch (type) {
      case CalendarViewType.day:
        return 'Day';
      case CalendarViewType.week:
        return 'Week';
      case CalendarViewType.month:
        return 'Month';
      case CalendarViewType.year:
        return 'Year';
    }
  }
}

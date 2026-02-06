import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../infrastructure/models/reminder.dart';
import '../theme/calendar_theme.dart';

class CalendarMonthView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final List<Reminder> Function(DateTime) eventLoader;
  final DateTime firstDay;
  final DateTime lastDay;

  const CalendarMonthView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.eventLoader,
    required this.firstDay,
    required this.lastDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CalendarTheme.cardBG(context),
        borderRadius: BorderRadius.circular(CalendarTheme.cardRadius),
        boxShadow: CalendarTheme.softShadow(context),
      ),
      padding: const EdgeInsets.only(bottom: 12),
      child: TableCalendar<Reminder>(
        firstDay: firstDay,
        lastDay: lastDay,
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        eventLoader: eventLoader,
        
        // Configuración visual
        headerVisible: false,
        rowHeight: 48,
        daysOfWeekHeight: 24,
        startingDayOfWeek: StartingDayOfWeek.monday,
        
        // Estilos
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          
          // Día seleccionado (Pill)
          selectedDecoration: BoxDecoration(
            color: CalendarTheme.primaryBG(context),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: CalendarTheme.primaryBG(context).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          selectedTextStyle: TextStyle(
            color: CalendarTheme.onPrimaryBG(context),
            fontWeight: FontWeight.bold,
          ),
          
          // Día actual (Borde)
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: CalendarTheme.badgeToday(context),
              width: 2,
            ),
          ),
          todayTextStyle: TextStyle(
            color: CalendarTheme.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
          
          // Días normales
          defaultTextStyle: CalendarTheme.body(context).copyWith(
            color: CalendarTheme.textPrimary(context),
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: CalendarTheme.body(context).copyWith(
            color: CalendarTheme.textSecondary(context),
          ),
          outsideTextStyle: CalendarTheme.body(context).copyWith(
            color: CalendarTheme.textSecondary(context).withOpacity(0.5),
          ),
          
          // Marcadores (Puntos)
          markerDecoration: BoxDecoration(
            color: CalendarTheme.primaryBG(context),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSize: 5,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
        ),
        
        // Días de la semana
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: CalendarTheme.textSecondary(context),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: CalendarTheme.textSecondary(context),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

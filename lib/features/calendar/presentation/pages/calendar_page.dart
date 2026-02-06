import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' as tc;

import '../../application/calendar_controller.dart';
import '../../application/reminder_controller.dart';
import '../theme/calendar_theme.dart';
import '../widgets/calendar_scaffold.dart';
import '../widgets/calendar_segmented_control.dart';
import '../widgets/calendar_header.dart';
import '../views/calendar_month_view.dart';
import '../widgets/upcoming_events_list.dart';
import '../widgets/empty_state.dart';
import '../widgets/reminder_form_sheet.dart';
import 'reminder_detail_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  CalendarViewType _currentView = CalendarViewType.month;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarControllerProvider);
    final controller = ref.read(calendarControllerProvider.notifier);

    return CalendarScaffold(
      currentView: _currentView,
      onViewChanged: (view) {
        setState(() {
          _currentView = view;
        });
        // Actualizar formato del calendario si corresponde
        if (view == CalendarViewType.month) {
          controller.changeFormat(tc.CalendarFormat.month);
        } else if (view == CalendarViewType.week) {
          controller.changeFormat(tc.CalendarFormat.week);
        } else if (view == CalendarViewType.day) {
          // Para 'Day', podríamos usar week view o simplemente mostrar la lista
          controller.changeFormat(tc.CalendarFormat.week); 
        }
        // Year no soportado por table_calendar directamente
      },
      onSearchTap: () {
        // Implementar búsqueda si es necesario
      },
      onAddTap: () => _showReminderForm(context, null),
      body: RefreshIndicator(
        color: CalendarTheme.primaryBG(context),
        onRefresh: controller.refresh,
        child: CustomScrollView(
          slivers: [
            // Header del mes (solo visible en Month/Week/Day)
            if (_currentView != CalendarViewType.year)
              SliverToBoxAdapter(
                child: CalendarHeader(
                  focusedDay: state.focusedDay,
                  onLeftArrowTap: () => controller.changeFocusedDay(
                    state.focusedDay.subtract(const Duration(days: 30)), // Aproximado, table_calendar ajusta
                  ),
                  onRightArrowTap: () => controller.changeFocusedDay(
                    state.focusedDay.add(const Duration(days: 30)),
                  ),
                  onTitleTap: controller.goToToday,
                ),
              ),

            // Calendario (Month View)
            if (_currentView != CalendarViewType.year)
              SliverToBoxAdapter(
                child: CalendarMonthView(
                  firstDay: DateTime(2020, 1, 1),
                  lastDay: DateTime(2030, 12, 31),
                  focusedDay: state.focusedDay,
                  selectedDay: state.selectedDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    controller.selectDay(selectedDay);
                    controller.changeFocusedDay(focusedDay);
                  },
                  onPageChanged: (focusedDay) {
                    controller.changeFocusedDay(focusedDay);
                  },
                  eventLoader: controller.getEventsForDay,
                ),
              ),

            // Espacio
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Lista de eventos
            SliverToBoxAdapter(
              child: state.isLoading
                  ? _buildLoadingSkeleton(context)
                  : state.error != null
                      ? _buildErrorState(context, controller, state)
                      : _buildRemindersList(state),
            ),
            
            // Espacio final para el FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList(CalendarState state) {
    final selectedDay = state.selectedDay ?? state.focusedDay;
    final reminders = state.getRemindersForDay(selectedDay);

    if (reminders.isEmpty) {
      return EmptyState(
        onAction: () => _showReminderForm(context, null),
      );
    }

    return UpcomingEventsList(
      reminders: reminders,
      onTap: (reminder) => _navigateToDetail(reminder.id),
      onDelete: (reminder) {
        // Opcional: implementar borrado directo o dejarlo en el detalle
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CalendarTheme.defaultPadding),
      child: Column(
        children: List.generate(3, (index) => 
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 80,
            decoration: BoxDecoration(
              color: CalendarTheme.cardBG(context),
              borderRadius: BorderRadius.circular(CalendarTheme.cardRadius),
              boxShadow: CalendarTheme.softShadow(context),
            ),
          )
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    CalendarController controller,
    CalendarState state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: CalendarTheme.badgeDue(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar tus recordatorios',
              style: CalendarTheme.h2(context),
              textAlign: TextAlign.center,
            ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: CalendarTheme.body(context),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CalendarTheme.primaryBG(context),
                foregroundColor: CalendarTheme.onPrimaryBG(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderForm(BuildContext context, int? reminderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReminderFormSheet(reminderId: reminderId),
    );
  }

  void _navigateToDetail(int reminderId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReminderDetailPage(reminderId: reminderId),
      ),
    );
  }
}

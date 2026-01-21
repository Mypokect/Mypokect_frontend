import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:MyPocket/Controllers/scheduled_transaction_controller.dart';
import 'package:MyPocket/models/transaction_occurrence.dart';
import 'package:MyPocket/Widgets/common/CustomAlert.dart';
import 'package:MyPocket/Widgets/calendar/calendar_header_widget.dart';
import 'package:MyPocket/Widgets/calendar/calendar_empty_state_widget.dart';
import 'package:MyPocket/Widgets/calendar/calendar_event_card_widget.dart';
import 'package:MyPocket/Widgets/calendar/add_reminder_bottom_sheet_widget.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  final ScheduledTransactionController _controller =
      ScheduledTransactionController();
  bool _isLoadingPage = true;
  Map<DateTime, List<TransactionOccurrence>> _events = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final DateTime _today = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchDataForMonth(_focusedDay);
  }

  Future<void> _fetchDataForMonth(DateTime month) async {
    if (!mounted) return;
    if (!_isLoadingPage)
      setState(() {
        _isLoadingPage = true;
      });

    final occurrences = await _controller.getOccurrencesForMonth(
        month.month, month.year, context);

    final newEvents = <DateTime, List<TransactionOccurrence>>{};
    for (var occ in occurrences) {
      if (!occ.isPaid) {
        final date = DateTime.parse(occ.date);
        final normalizedDate = DateTime.utc(date.year, date.month, date.day);
        if (newEvents[normalizedDate] == null) newEvents[normalizedDate] = [];
        newEvents[normalizedDate]!.add(occ);
      }
    }

    if (!mounted) return;
    setState(() {
      _events = newEvents;
      _isLoadingPage = false;
    });
  }

  List<TransactionOccurrence> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _showAddOrEditGastoBottomSheet({TransactionOccurrence? occurrence}) {
    final dayToRegister = _selectedDay ?? _focusedDay;
    final normalizedDayToRegister = DateTime.utc(
        dayToRegister.year, dayToRegister.month, dayToRegister.day);

    if (occurrence == null && normalizedDayToRegister.isBefore(_today)) {
      CustomAlert.show(
          context: context,
          title: 'Acción no permitida',
          message: 'No se pueden añadir recordatorios en fechas pasadas.',
          color: Colors.amber,
          icon: Icons.warning_amber_rounded);
      return;
    }

    final bool isEditing = occurrence != null;
    String? dateText;
    if (!isEditing && _selectedDay != null) {
      dateText = 'para ${DateFormat.yMMMd('es').format(_selectedDay!)}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return AddReminderBottomSheetWidget(
            isEditing: isEditing,
            selectedDateText: dateText,
            onSave: (data) async {
              final startDate =
                  isEditing ? DateTime.parse(occurrence!.date) : dayToRegister;

              final dataWithDate = {
                ...data,
                'start_date': DateFormat('y-MM-dd').format(startDate),
              };

              bool success = false;
              if (isEditing) {
                final dataForUpdate = {
                  ...dataWithDate,
                  'category': occurrence!.category,
                };
                success = await _controller.updateScheduledTransaction(
                    occurrence!.id, dataForUpdate, context);
              } else {
                final newOccurrence =
                    await _controller.createScheduledTransaction(
                        data: dataWithDate, context: context);
                success = newOccurrence != null;
              }

              return success;
            },
            onDelete: isEditing
                ? () async {
                    final success = await _controller
                        .deleteScheduledTransaction(occurrence!.id, context);
                    return success;
                  }
                : null,
          );
        },
      ),
    ).then((result) async {
      if (result == true && mounted) {
        await _fetchDataForMonth(_focusedDay);
      }
    });
  }

  Future<void> _markAsPaid(TransactionOccurrence occurrence) async {
    setState(() => _isLoadingPage = true);

    final success = await _controller.updatePaidStatus(
        transactionId: occurrence.id,
        date: occurrence.date,
        isPaid: true,
        context: context);

    if (mounted) {
      await _fetchDataForMonth(_focusedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayForEvents = _selectedDay ?? _focusedDay;
    final gastosDelDia = _getEventsForDay(dayForEvents);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Container(height: 200, color: AppTheme.primaryColor),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                  'assets/images/fondo-moderno-verde-ondulado1.png',
                  fit: BoxFit.fill,
                  width: screenWidth,
                  height: 200)),
          SafeArea(
            child: Column(
              children: [
                const CalendarHeaderWidget(),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendar(),
                        _buildEventsList(gastosDelDia),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: TableCalendar(
        locale: 'es_ES',
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          final normalizedSelectedDay = DateTime.utc(
              selectedDay.year, selectedDay.month, selectedDay.day);
          if (!normalizedSelectedDay.isBefore(_today) &&
              _getEventsForDay(selectedDay).isEmpty &&
              !_isLoadingPage) {
            _showAddOrEditGastoBottomSheet();
          }
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
            _selectedDay = focusedDay;
          });
          _fetchDataForMonth(focusedDay);
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            titleTextStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            leftChevronIcon:
                Icon(Icons.chevron_left, color: AppTheme.primaryColor),
            rightChevronIcon:
                Icon(Icons.chevron_right, color: AppTheme.primaryColor),
            formatButtonDecoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20)),
            formatButtonTextStyle: TextStyle(color: AppTheme.greyColor)),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor, width: 2),
              shape: BoxShape.circle),
          todayTextStyle: TextStyle(color: AppTheme.primaryColor),
          selectedDecoration: BoxDecoration(
              color: AppTheme.primaryColor, shape: BoxShape.circle),
          selectedTextStyle: const TextStyle(color: Colors.white),
          outsideDaysVisible: false,
        ),
        daysOfWeekStyle:
            DaysOfWeekStyle(weekendStyle: TextStyle(color: AppTheme.greyColor)),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppTheme.accentColor),
                      width: 7,
                      height: 7));
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildEventsList(List<TransactionOccurrence> gastosDelDia) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Text("Recordatorios del día",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: AppTheme.greyColor))),
          Expanded(
            child: _isLoadingPage
                ? const Center(child: CircularProgressIndicator())
                : gastosDelDia.isEmpty
                    ? const CalendarEmptyStateWidget()
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: gastosDelDia.length,
                          itemBuilder: (context, index) {
                            final gasto = gastosDelDia[index];
                            final fechaGasto = DateTime.utc(
                                DateTime.parse(gasto.date).year,
                                DateTime.parse(gasto.date).month,
                                DateTime.parse(gasto.date).day);
                            final bool estaVencido =
                                fechaGasto.isBefore(_today) && !gasto.isPaid;

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50,
                                child: FadeInAnimation(
                                  child: CalendarEventCardWidget(
                                    id: gasto.id,
                                    title: gasto.title,
                                    amount: gasto.amount,
                                    date: gasto.date,
                                    type: gasto.type,
                                    isPaid: gasto.isPaid,
                                    isOverdue: estaVencido,
                                    onTap: () => _showAddOrEditGastoBottomSheet(
                                        occurrence: gasto),
                                    onMarkAsPaid: _isLoadingPage
                                        ? null
                                        : () => _markAsPaid(gasto),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      heroTag: 'fab_calendar_screen_unique',
      onPressed: () {
        final dayToUse = _selectedDay ?? _focusedDay;
        final normalizedDay =
            DateTime.utc(dayToUse.year, dayToUse.month, dayToUse.day);
        if (!normalizedDay.isBefore(_today)) {
          _showAddOrEditGastoBottomSheet();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No se pueden añadir nuevos recordatorios en fechas pasadas.'),
                backgroundColor: Colors.amber),
          );
        }
      },
      backgroundColor: AppTheme.accentColor,
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.add_rounded, size: 30),
    );
  }
}

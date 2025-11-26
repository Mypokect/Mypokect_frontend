import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:MyPocket/Theme/Theme.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Imports necesarios (asegúrate de que las rutas sean correctas para tu proyecto)
import '../../controllers/scheduled_transaction_controller.dart';
import '../../models/transaction_occurrence.dart';
import '../../services/notification_service.dart';
import '../../Widgets/CustomAlert.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});
  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  final ScheduledTransactionController _controller = ScheduledTransactionController();
  bool _isLoadingPage = true; // Renombrado para diferenciarlo de la carga de acciones
  Map<DateTime, List<TransactionOccurrence>> _events = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final DateTime _today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchDataForMonth(_focusedDay);
  }

  Future<void> _fetchDataForMonth(DateTime month) async {
    if (!mounted) return;
    if (!_isLoadingPage) setState(() { _isLoadingPage = true; });

    final occurrences = await _controller.getOccurrencesForMonth(month.month, month.year, context);
    
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
    final normalizedDayToRegister = DateTime.utc(dayToRegister.year, dayToRegister.month, dayToRegister.day);

    if (occurrence == null && normalizedDayToRegister.isBefore(_today)) {
      CustomAlert.show(context: context, title: 'Acción no permitida', message: 'No se pueden añadir recordatorios en fechas pasadas.', color: Colors.amber, icon: Icons.warning_amber_rounded);
      return;
    }

    final bool isEditing = occurrence != null;
    final titleController = TextEditingController(text: isEditing ? occurrence.title : '');
    final amountController = TextEditingController(text: isEditing ? occurrence.amount.toString() : '');
    String typeValue = isEditing ? occurrence.type : 'expense';
    String recurrenceValue = 'none';
    
    // Bandera para el estado de carga DENTRO del BottomSheet
    bool isSaving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 15),
                  Text(isEditing ? 'Editar Recordatorio' : 'Añadir Recordatorio', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  if (!isEditing && _selectedDay != null) Text('para ${DateFormat.yMMMMd('es').format(_selectedDay!)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 25),
                  TextField(controller: titleController, enabled: !isSaving, decoration: InputDecoration(labelText: 'Descripción', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), autofocus: true),
                  const SizedBox(height: 16),
                  TextField(controller: amountController, enabled: !isSaving, decoration: InputDecoration(labelText: 'Monto', prefixText: '\$ ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: DropdownButtonFormField<String>(value: typeValue, decoration: InputDecoration(labelText: 'Tipo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: const [DropdownMenuItem(value: 'expense', child: Text('Gasto')), DropdownMenuItem(value: 'income', child: Text('Ingreso'))], onChanged: isSaving ? null : (value) { if (value != null) setModalState(() => typeValue = value); })),
                      const SizedBox(width: 16),
                      if (!isEditing) Expanded(child: DropdownButtonFormField<String>(value: recurrenceValue, decoration: InputDecoration(labelText: 'Repetir', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: const [DropdownMenuItem(value: 'none', child: Text('Nunca')), DropdownMenuItem(value: 'monthly', child: Text('Mensual'))], onChanged: isSaving ? null : (value) { if (value != null) setModalState(() => recurrenceValue = value); })),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                      // --- LÓGICA DE GUARDADO REFACTORIZADA ---
                      onPressed: isSaving ? null : () async {
                        setModalState(() => isSaving = true);
                        
                        final data = {'title': titleController.text, 'amount': double.tryParse(amountController.text) ?? 0.0, 'type': typeValue, 'start_date': DateFormat('y-MM-dd').format(isEditing ? DateTime.parse(occurrence.date) : dayToRegister), 'recurrence_type': recurrenceValue, 'recurrence_interval': 1, 'reminder_days_before': 1};
                        
                        bool success = false;
                        if (isEditing) {
                          success = await _controller.updateScheduledTransaction(occurrence.id, data, context);
                        } else {
                          final newOccurrence = await _controller.createScheduledTransaction(data: data, context: context);
                          success = newOccurrence != null;
                        }

                        if (mounted) {
                          if (success) {
                            Navigator.pop(context); // Cierra el BottomSheet
                            await _fetchDataForMonth(_focusedDay); // Refresca los datos en la página principal
                          } else {
                            // Si falla, reactivamos el formulario. El controller ya mostró la alerta.
                            setModalState(() => isSaving = false);
                          }
                        }
                      },
                      icon: isSaving ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) : const Icon(Icons.check_circle_outline),
                      label: Text(isSaving ? 'Guardando...' : (isEditing ? 'Actualizar' : 'Guardar'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (isEditing && !isSaving) ...[
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: TextButton.icon(style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor), onPressed: () async {
                       final success = await _controller.deleteScheduledTransaction(occurrence.id, context);
                       if (success && mounted) { Navigator.pop(context); await _fetchDataForMonth(_focusedDay); }
                    }, icon: const Icon(Icons.delete_forever), label: const Text('Eliminar Serie Completa')))
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.event_note, size: 80, color: Colors.grey[300]), const SizedBox(height: 20), Text('Sin recordatorios pendientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700])), const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0), child: Text('¡Estás al día! Toca un día futuro para añadir un nuevo recordatorio.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[500])))])); }
  Widget _buildCustomHeader(BuildContext context) { return Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.of(context).pop()), const Text("Recordatorios de Pagos", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(width: 48)])); }

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
          Positioned(top: 0, left: 0, right: 0, child: Image.asset('assets/images/fondo-moderno-verde-ondulado1.png', fit: BoxFit.fill, width: screenWidth, height: 200)),
          SafeArea(
            child: Column(
              children: [
                _buildCustomHeader(context),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                          child: TableCalendar<TransactionOccurrence>(
                            locale: 'es_ES',
                            firstDay: DateTime.utc(2020), lastDay: DateTime.utc(2030),
                            focusedDay: _focusedDay, calendarFormat: _calendarFormat,
                            eventLoader: _getEventsForDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              final normalizedSelectedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
                              if (!normalizedSelectedDay.isBefore(_today) && _getEventsForDay(selectedDay).isEmpty && !_isLoadingPage) {
                                _showAddOrEditGastoBottomSheet();
                              }
                            },
                            onPageChanged: (focusedDay) {
                              setState(() { _focusedDay = focusedDay; _selectedDay = focusedDay; });
                              _fetchDataForMonth(focusedDay);
                            },
                            onFormatChanged: (format) { if (_calendarFormat != format) { setState(() => _calendarFormat = format); } },
                            headerStyle: HeaderStyle(formatButtonVisible: true, titleCentered: true, titleTextStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryColor), rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryColor), formatButtonDecoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(20)), formatButtonTextStyle: TextStyle(color: AppTheme.greyColor)),
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(border: Border.all(color: AppTheme.primaryColor, width: 2), shape: BoxShape.circle), 
                              todayTextStyle: TextStyle(color: AppTheme.primaryColor), 
                              selectedDecoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle), 
                              selectedTextStyle: const TextStyle(color: Colors.white), 
                              outsideDaysVisible: false,
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(weekendStyle: TextStyle(color: AppTheme.greyColor)),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                if (events.isNotEmpty) {
                                  return Positioned(right: 1, bottom: 1, child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accentColor), width: 7.0, height: 7.0));
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 10), child: Text("Recordatorios del día", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.greyColor))),
                        Expanded(
                          child: _isLoadingPage
                              ? const Center(child: CircularProgressIndicator())
                              : gastosDelDia.isEmpty
                                  ? _buildEmptyState()
                                  : AnimationLimiter(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        itemCount: gastosDelDia.length,
                                        itemBuilder: (context, index) {
                                          final gasto = gastosDelDia[index];
                                          final fechaGasto = DateTime.utc(DateTime.parse(gasto.date).year, DateTime.parse(gasto.date).month, DateTime.parse(gasto.date).day);
                                          final bool estaVencido = fechaGasto.isBefore(_today) && !gasto.isPaid;
                                          
                                          return AnimationConfiguration.staggeredList(
                                            position: index, duration: const Duration(milliseconds: 375),
                                            child: SlideAnimation(
                                              verticalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: Card(
                                                  key: ValueKey("${gasto.id}-${gasto.date}"),
                                                  elevation: 1.5, shadowColor: Colors.grey.withOpacity(0.2),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                  margin: const EdgeInsets.only(bottom: 10),
                                                  child: ListTile(
                                                    onTap: () => _showAddOrEditGastoBottomSheet(occurrence: gasto),
                                                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                    leading: Icon(gasto.type == 'income' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: gasto.type == 'income' ? Colors.green : AppTheme.errorColor, size: 32),
                                                    title: Text(gasto.title, style: TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 16,
                                                      color: estaVencido ? AppTheme.errorColor : Colors.black,
                                                    )),
                                                    subtitle: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text('\$${gasto.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, color: AppTheme.greyColor)),
                                                        if (estaVencido)
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 4.0),
                                                            child: Text('VENCIDO', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold, fontSize: 10)),
                                                          ),
                                                      ],
                                                    ),
                                                    trailing: IconButton(
                                                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.grey, size: 28),
                                                      tooltip: 'Marcar como finalizado',
                                                      onPressed: _isLoadingPage ? null : () async {
                                                        setState(() => _isLoadingPage = true );
                                                        final success = await _controller.updatePaidStatus(
                                                          transactionId: gasto.id,
                                                          date: gasto.date,
                                                          isPaid: true,
                                                          context: context
                                                        );
                                                        
                                                        // Siempre refrescamos los datos, sin importar si falló o no.
                                                        // Si falló, la alerta se mostrará y los datos se recargarán al estado original.
                                                        // Si tuvo éxito, los datos se recargarán sin el item completado.
                                                        if (mounted) {
                                                          await _fetchDataForMonth(_focusedDay);
                                                        }
                                                      },
                                                    ),
                                                  ),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final dayToUse = _selectedDay ?? _focusedDay;
          final normalizedDay = DateTime.utc(dayToUse.year, dayToUse.month, dayToUse.day);
          if (!normalizedDay.isBefore(_today)) {
            _showAddOrEditGastoBottomSheet();
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pueden añadir nuevos recordatorios en fechas pasadas.'), backgroundColor: Colors.amber),
            );
          }
        }, 
        backgroundColor: AppTheme.accentColor, foregroundColor: Colors.white, elevation: 8, child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }
}
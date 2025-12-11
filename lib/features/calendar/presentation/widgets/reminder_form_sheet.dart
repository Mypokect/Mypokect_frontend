import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/reminder_controller.dart';
import '../theme/calendar_theme.dart';

/// Bottom sheet form for creating/editing reminders
class ReminderFormSheet extends ConsumerStatefulWidget {
  final int? reminderId;

  const ReminderFormSheet({
    super.key,
    this.reminderId,
  });

  @override
  ConsumerState<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends ConsumerState<ReminderFormSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  String _recurrence = 'none';
  int _dayOfMonth = 1;
  int _notifyOffset = 1440;
  
  String? _titleError;
  String? _amountError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    // Resetear estado del formulario fuera del ciclo de build
    Future.microtask(() {
      if (!mounted) return;
      ref.read(reminderControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reminderControllerProvider);

    final fieldErrors = state.fieldErrors;
    final titleServerError = _firstFieldError(fieldErrors, ['title']);
    final amountServerError = _firstFieldError(fieldErrors, ['amount']);
    final dateServerError = _firstFieldError(fieldErrors, ['due_date', 'due_date_local']);
    final recurrenceServerError = _firstFieldError(fieldErrors, ['recurrence']);
    final dayOfMonthServerError = _firstFieldError(fieldErrors, ['recurrence_params.day', 'day_of_month']);
    final notifyServerError = _firstFieldError(fieldErrors, ['notify_offset_minutes', 'notify_offset']);
    final noteServerError = _firstFieldError(fieldErrors, ['note']);

    final titleErrorText = _titleError ?? titleServerError;
    final amountErrorText = _amountError ?? amountServerError;
    final dateErrorText = _dateError ?? dateServerError;

    return Container(
      decoration: BoxDecoration(
        color: CalendarTheme.cardBG(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: CalendarTheme.elevatedShadow(context),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Header with close button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: CalendarTheme.textPrimary(context)),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Cerrar',
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.reminderId == null ? 'Nuevo Recordatorio' : 'Editar Recordatorio',
                            style: CalendarTheme.h2(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completa la información del recordatorio',
                            style: CalendarTheme.body(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for close button
                  ],
                ),
                const SizedBox(height: 24),

                // Title field
                _buildInputLabel('Título', true),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CalendarTheme.cardBG(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: titleErrorText != null ? CalendarTheme.badgeDue(context) : CalendarTheme.outline(context),
                      width: titleErrorText != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: CalendarTheme.primaryBG(context), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          style: CalendarTheme.body(context).copyWith(color: CalendarTheme.textPrimary(context)),
                          decoration: InputDecoration(
                            hintText: 'Ej: Pago de arriendo',
                            hintStyle: CalendarTheme.body(context).copyWith(color: CalendarTheme.textSecondary(context)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) {
                            if (_titleError != null) {
                              setState(() => _titleError = null);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (titleErrorText != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: CalendarTheme.badgeDue(context), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        titleErrorText,
                        style: CalendarTheme.body(context).copyWith(color: CalendarTheme.badgeDue(context)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Amount field
                _buildInputLabel('Monto', false),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CalendarTheme.cardBG(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: amountErrorText != null ? CalendarTheme.badgeDue(context) : CalendarTheme.outline(context),
                      width: amountErrorText != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_money, color: CalendarTheme.primaryBG(context), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          style: CalendarTheme.body(context).copyWith(color: CalendarTheme.textPrimary(context)),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Ej: 250000',
                            hintStyle: CalendarTheme.body(context).copyWith(color: CalendarTheme.textSecondary(context)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) {
                            if (_amountError != null) {
                              setState(() => _amountError = null);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (amountErrorText != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: CalendarTheme.badgeDue(context), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        amountErrorText,
                        style: CalendarTheme.body(context).copyWith(color: CalendarTheme.badgeDue(context)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Category field
                _buildInputLabel('Categoría', false),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CalendarTheme.cardBG(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CalendarTheme.outline(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.label, color: CalendarTheme.primaryBG(context), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          style: CalendarTheme.body(context).copyWith(color: CalendarTheme.textPrimary(context)),
                          decoration: InputDecoration(
                            hintText: 'Ej: Vivienda, Servicios...',
                            hintStyle: CalendarTheme.body(context).copyWith(color: CalendarTheme.textSecondary(context)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Due date picker
                _buildInputLabel('Fecha de vencimiento', true),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CalendarTheme.cardBG(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dateErrorText != null ? CalendarTheme.badgeDue(context) : CalendarTheme.outline(context),
                        width: dateErrorText != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: CalendarTheme.primaryBG(context), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Seleccionar fecha'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: CalendarTheme.body(context).copyWith(
                              fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                              color: _selectedDate == null
                                  ? CalendarTheme.textSecondary(context)
                                  : CalendarTheme.primaryBG(context),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: CalendarTheme.primaryBG(context),
                        ),
                      ],
                    ),
                  ),
                ),
                if (dateErrorText != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: CalendarTheme.badgeDue(context), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        dateErrorText,
                        style: CalendarTheme.body(context).copyWith(color: CalendarTheme.badgeDue(context)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Recurrence dropdown
                _buildInputLabel('Repetir', false),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: CalendarTheme.cardBG(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CalendarTheme.outline(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.repeat, color: CalendarTheme.primaryBG(context), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _recurrence,
                            isExpanded: true,
                            style: CalendarTheme.body(context).copyWith(color: CalendarTheme.textPrimary(context)),
                            dropdownColor: CalendarTheme.cardBG(context),
                            items: [
                              DropdownMenuItem(
                                value: 'none',
                                child: Text('Una sola vez', style: CalendarTheme.body(context)),
                              ),
                              DropdownMenuItem(
                                value: 'monthly',
                                child: Text('Mensual', style: CalendarTheme.body(context)),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _recurrence = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (recurrenceServerError != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: CalendarTheme.badgeDue(context), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        recurrenceServerError,
                        style: CalendarTheme.body(context).copyWith(color: CalendarTheme.badgeDue(context)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Day of month (if monthly)
                if (_recurrence == 'monthly') ...[
                  _buildInputLabel('Día del mes', true),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CalendarTheme.cardBG(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CalendarTheme.outline(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.date_range, color: CalendarTheme.primaryBG(context), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _dayOfMonth.toString()),
                            style: CalendarTheme.body(context).copyWith(color: CalendarTheme.textPrimary(context)),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Ej: 15',
                              hintStyle: CalendarTheme.body(context).copyWith(color: CalendarTheme.textSecondary(context)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              final day = int.tryParse(value);
                              if (day != null && day >= 1 && day <= 31) {
                                _dayOfMonth = day;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Si eliges 29, 30 o 31 y el mes no tiene ese día, se usará el último día disponible.',
                    style: CalendarTheme.body(context).copyWith(fontSize: 12),
                  ),
                  if (dayOfMonthServerError != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: CalendarTheme.badgeDue(context), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dayOfMonthServerError,
                            style: CalendarTheme.body(context).copyWith(color: CalendarTheme.badgeDue(context)),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                ],

                // Notify offset dropdown
                _buildInputLabel('Recordar', false),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: CalendarTheme.cardBG(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CalendarTheme.outline(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications, color: CalendarTheme.primaryBG(context), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _notifyOffset,
                            isExpanded: true,
                            style: CalendarTheme.body(context).copyWith(color: CalendarTheme.textPrimary(context)),
                            dropdownColor: CalendarTheme.cardBG(context),
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('El mismo día', style: CalendarTheme.body(context)),
                              ),
                              DropdownMenuItem(
                                value: 60,
                                child: Text('1 hora antes', style: CalendarTheme.body(context)),
                              ),
                              DropdownMenuItem(
                                value: 120,
                                child: Text('2 horas antes', style: CalendarTheme.body(context)),
                              ),
                              DropdownMenuItem(
                                value: 1440,
                                child: Text('1 día antes', style: CalendarTheme.body(context)),
                              ),
                              DropdownMenuItem(
                                value: 2880,
                                child: Text('2 días antes', style: CalendarTheme.body(context)),
                              ),
                              DropdownMenuItem(
                                value: 4320,
                                child: Text('3 días antes', style: CalendarTheme.body(context)),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _notifyOffset = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (notifyServerError != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: CalendarTheme.badgeDue(context), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notifyServerError,
                          style: CalendarTheme.body(context).copyWith(color: CalendarTheme.badgeDue(context)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Note field
                _buildInputLabel('Nota adicional', false),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CalendarTheme.cardBG(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CalendarTheme.outline(context)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.notes, color: CalendarTheme.primaryBG(context), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _noteController,
                          style: CalendarTheme.body(context).copyWith(color: CalendarTheme.textPrimary(context)),
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Agrega una descripción...',
                            hintStyle: CalendarTheme.body(context).copyWith(color: CalendarTheme.textSecondary(context)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (noteServerError != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: CalendarTheme.badgeDue(context), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          noteServerError,
                          style: CalendarTheme.body(context).copyWith(color: CalendarTheme.badgeDue(context)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),

                // Error message
                if (state.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CalendarTheme.badgeDue(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CalendarTheme.badgeDue(context).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: CalendarTheme.badgeDue(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: CalendarTheme.body(context).copyWith(color: CalendarTheme.badgeDue(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Submit button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        CalendarTheme.primaryBG(context),
                        CalendarTheme.primaryBG(context).withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CalendarTheme.primaryBG(context).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                widget.reminderId == null ? 'Crear Recordatorio' : 'Guardar Cambios',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text, bool required) {
    return Row(
      children: [
        Text(
          text,
          style: CalendarTheme.subtitle(context).copyWith(fontSize: 14),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: CalendarTheme.subtitle(context).copyWith(fontSize: 14, color: CalendarTheme.badgeDue(context)),
          ),
        ],
      ],
    );
  }

  String? _firstFieldError(
    Map<String, List<String>>? fieldErrors,
    List<String> keys,
  ) {
    if (fieldErrors == null) return null;
    for (final key in keys) {
      final errors = fieldErrors[key];
      if (errors != null && errors.isNotEmpty) {
        return errors.first;
      }
    }
    return null;
  }

  void _validateAndSubmit() {
    setState(() {
      _titleError = null;
      _amountError = null;
      _dateError = null;
    });

    bool isValid = true;

    if (_titleController.text.isEmpty) {
      setState(() => _titleError = 'El título es obligatorio');
      isValid = false;
    } else if (_titleController.text.length > 120) {
      setState(() => _titleError = 'Máximo 120 caracteres');
      isValid = false;
    }

    if (_amountController.text.isNotEmpty) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount < 0) {
        setState(() => _amountError = 'Ingresa un monto válido');
        isValid = false;
      }
    }

    if (_selectedDate == null) {
      setState(() => _dateError = 'Selecciona una fecha');
      isValid = false;
    }

    if (isValid) {
      _submitForm();
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CalendarTheme.primaryBG(context),
              onPrimary: CalendarTheme.onPrimaryBG(context),
              surface: CalendarTheme.cardBG(context),
            ),
            dialogBackgroundColor: CalendarTheme.cardBG(context),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: CalendarTheme.primaryBG(context),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _submitForm() async {
    final controller = ref.read(reminderControllerProvider.notifier);

    final amount = _amountController.text.isNotEmpty
        ? double.tryParse(_amountController.text)
        : null;

    if (widget.reminderId == null) {
      // Create new reminder
      final result = await controller.createReminder(
        title: _titleController.text,
        amount: amount,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        dueDate: _selectedDate!,
        timezone: 'America/Bogota',
        recurrence: _recurrence,
        recurrenceParams: _recurrence == 'monthly' ? {'day': _dayOfMonth} : null,
        notifyOffsetMinutes: _notifyOffset,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (result != null && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Recordatorio creado exitosamente',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else {
      // Update existing reminder
      final result = await controller.updateReminder(
        id: widget.reminderId!,
        title: _titleController.text,
        amount: amount,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        dueDate: _selectedDate!,
        timezone: 'America/Bogota',
        recurrence: _recurrence,
        recurrenceParams: _recurrence == 'monthly' ? {'day': _dayOfMonth} : null,
        notifyOffsetMinutes: _notifyOffset,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (result != null && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Recordatorio actualizado',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}

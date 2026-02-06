import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';

class AddReminderBottomSheetWidget extends StatefulWidget {
  final bool isEditing;
  final String? selectedDateText;
  final Future<bool> Function(Map<String, dynamic> data) onSave;
  final Future<bool> Function()? onDelete;

  const AddReminderBottomSheetWidget({
    super.key,
    required this.isEditing,
    this.selectedDateText,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<AddReminderBottomSheetWidget> createState() =>
      _AddReminderBottomSheetWidgetState();
}

class _AddReminderBottomSheetWidgetState
    extends State<AddReminderBottomSheetWidget> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _typeValue;
  late String _recurrenceValue;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _typeValue = 'expense';
    _recurrenceValue = 'none';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final data = {
      'title': _titleController.text,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'type': _typeValue,
      'recurrence_type': _recurrenceValue,
      'recurrence_interval': 1,
      'reminder_days_before': 1
    };

    final success = await widget.onSave(data);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 15),
            _buildTitle(),
            if (!widget.isEditing && widget.selectedDateText != null)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('para ${widget.selectedDateText}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey[600]))),
            const SizedBox(height: 25),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildTypeDropdown(),
            const SizedBox(height: 16),
            if (!widget.isEditing) _buildRecurrenceDropdown(),
            const SizedBox(height: 30),
            _buildSaveButton(),
            if (widget.isEditing && widget.onDelete != null && !_isSaving) ...[
              const SizedBox(height: 10),
              _buildDeleteButton(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
        child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10))));
  }

  Widget _buildTitle() {
    return Text(
        widget.isEditing ? 'Editar Recordatorio' : 'Añadir Recordatorio',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold, color: AppTheme.primaryColor));
  }

  Widget _buildTitleField() {
    return TextField(
        controller: _titleController,
        enabled: !_isSaving,
        decoration: InputDecoration(
            labelText: 'Descripción',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        autofocus: true);
  }

  Widget _buildAmountField() {
    return TextField(
        controller: _amountController,
        enabled: !_isSaving,
        decoration: InputDecoration(
            labelText: 'Monto',
            prefixText: '\$ ',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        keyboardType: const TextInputType.numberWithOptions(decimal: true));
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
        value: _typeValue,
        decoration: InputDecoration(
            labelText: 'Tipo',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        items: const [
          DropdownMenuItem(value: 'expense', child: Text('Gasto')),
          DropdownMenuItem(value: 'income', child: Text('Ingreso'))
        ],
        onChanged: _isSaving
            ? null
            : (value) {
                if (value != null) setState(() => _typeValue = value);
              });
  }

  Widget _buildRecurrenceDropdown() {
    return DropdownButtonFormField<String>(
        value: _recurrenceValue,
        decoration: InputDecoration(
            labelText: 'Repetir',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        items: const [
          DropdownMenuItem(value: 'none', child: Text('Nunca')),
          DropdownMenuItem(value: 'monthly', child: Text('Mensual'))
        ],
        onChanged: _isSaving
            ? null
            : (value) {
                if (value != null) setState(() => _recurrenceValue = value);
              });
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5),
        onPressed: _isSaving ? null : _handleSave,
        icon: _isSaving
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ))
            : const Icon(Icons.check_circle_outline),
        label: Text(
            _isSaving
                ? 'Guardando...'
                : (widget.isEditing ? 'Actualizar' : 'Guardar'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
        width: double.infinity,
        child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Eliminar Serie Completa')));
  }
}

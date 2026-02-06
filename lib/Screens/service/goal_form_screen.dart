import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../models/savings_goal.dart';
import '../../utils/goal_helpers.dart';
import '../../api/savings_goals_api.dart';
import '../../Theme/Theme.dart';

/// Form screen for creating or editing a savings goal
class GoalFormScreen extends StatefulWidget {
  final SavingsGoal? goalToEdit;

  const GoalFormScreen({super.key, this.goalToEdit});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();

  String _selectedEmoji = '🎯';
  DateTime? _selectedDeadline;
  Color _selectedColor = AppTheme.goalGreen; // Usar color del tema
  bool _isLoading = false;

  // Predefined emojis for quick selection
  final List<String> _emojiOptions = [
    '🎯',
    '🏠',
    '✈️',
    '🚗',
    '💻',
    '📚',
    '💍',
    '🛍️',
    '🎉',
    '📱',
    '🎮',
    '💪',
    '🍕',
    '🏦',
    '🏖️',
    '🏨',
    '🏥',
    '🎓',
    '💰',
    '🎁',
  ];

  // Predefined colors for quick selection (centralizados en AppTheme)
  final List<Color> _colorOptions = [
    AppTheme.goalGreen,
    AppTheme.goalBlue,
    AppTheme.goalOrange,
    AppTheme.goalPink,
    AppTheme.goalPurple,
    AppTheme.goalTeal,
    const Color(0xFFFFEB3B),
    const Color(0xFF795548),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.goalToEdit != null) {
      _loadGoalData();
    }
  }

  void _loadGoalData() {
    final goal = widget.goalToEdit!;
    _nameController.text = goal.name;
    _targetAmountController.text = goal.targetAmount.toStringAsFixed(0);
    _selectedEmoji = goal.emoji;
    _selectedDeadline = goal.deadline;
    _selectedColor = goal.color;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goalToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'EDITAR META' : 'NUEVA META',
          style: const TextStyle(
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading ? _buildLoading() : _buildForm(),
      bottomNavigationBar: _buildBottomBar(isEditing),
    );
  }

  // CORRECCIÓN 1: Se eliminó 'const' de Center
  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEmojiSelector(),
          const SizedBox(height: 20),
          _buildNameField(),
          const SizedBox(height: 20),
          _buildTargetAmountField(),
          const SizedBox(height: 20),
          _buildDeadlinePicker(),
          const SizedBox(height: 20),
          _buildColorSelector(),
          const SizedBox(height: 20),
          _buildPreviewCard(),
        ],
      ),
    );
  }

  Widget _buildEmojiSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ícono de la meta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Baloo2',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emojiOptions.map((emoji) {
              final isSelected = emoji == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withValues(alpha: 0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _selectedColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de la meta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Baloo2',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Ej: Vacaciones, Casa, Auto',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: GoalHelpers.validateGoalName,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildTargetAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monto objetivo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Baloo2',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _targetAmountController,
          decoration: InputDecoration(
            hintText: '0',
            prefixText: '\$ ',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: GoalHelpers.validateTargetAmount,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildDeadlinePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fecha límite (opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baloo2',
              ),
            ),
            if (_selectedDeadline != null)
              TextButton(
                onPressed: () => setState(() => _selectedDeadline = null),
                child: const Text('Quitar'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDeadline,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _selectedColor,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDeadline == null
                      ? 'Seleccionar fecha'
                      : GoalHelpers.formatDate(_selectedDeadline!),
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Baloo2',
                    color: _selectedDeadline == null
                        ? Colors.grey.shade500
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _selectedColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de la meta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Baloo2',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colorOptions.map((color) {
              final isSelected = color.toARGB32() == _selectedColor.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vista previa',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Baloo2',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _selectedEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _nameController.text.isEmpty
                    ? 'Nombre de la meta'
                    : _nameController.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Baloo2',
                  color: _nameController.text.isEmpty
                      ? Colors.grey.shade400
                      : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _targetAmountController.text.isEmpty
                    ? '\$0'
                    : '\$${_targetAmountController.text}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo2',
                  color: _targetAmountController.text.isEmpty
                      ? Colors.grey.shade400
                      : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 6,
                  // CORRECCIÓN 2: Se eliminó 'const' de AlwaysStoppedAnimation
                  child: LinearProgressIndicator(
                    value: 0.0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveGoal,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  isEditing ? 'GUARDAR CAMBIOS' : 'CREAR META',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo2',
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = SavingsGoalsApi();
      final name = _nameController.text.trim();
      final targetAmount = double.parse(_targetAmountController.text);
      final colorHex = GoalHelpers.colorToHex(_selectedColor);
      final isEditing = widget.goalToEdit != null;

      final response = isEditing
          ? await api.updateGoal(
              id: widget.goalToEdit!.id,
              name: name,
              targetAmount: targetAmount,
              emoji: _selectedEmoji,
              color: colorHex,
              deadline: _selectedDeadline,
            )
          : await api.createGoal(
              name: name,
              targetAmount: targetAmount,
              emoji: _selectedEmoji,
              color: colorHex,
              deadline: _selectedDeadline,
            );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Meta actualizada correctamente'
                  : 'Meta creada correctamente',
            ),
            backgroundColor: AppTheme.goalGreen,
          ),
        );
        Navigator.pop(context, true);
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Error al guardar la meta');
        } on FormatException {
          throw Exception('Error al guardar la meta');
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.expenseDarkColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }
}
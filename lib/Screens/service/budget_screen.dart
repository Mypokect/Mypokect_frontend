import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/Widgets/common/button_custom.dart';
import 'package:MyPocket/Widgets/common/text_input.dart';
import 'package:MyPocket/Widgets/budget/money_input_widget.dart';
import 'package:MyPocket/Widgets/budget/category_input_widget.dart';
import 'package:MyPocket/Widgets/budget/category_card_widget.dart';
import 'package:MyPocket/Widgets/budget/budget_validation_widget.dart';
import 'package:MyPocket/Widgets/budget/mode_switch_widget.dart';
import 'package:MyPocket/api/budget_api.dart';

class BudgetScreen extends StatefulWidget {
  final VoidCallback? onBudgetSaved;
  final Map<String, dynamic>? existingBudget;

  const BudgetScreen({super.key, this.onBudgetSaved, this.existingBudget});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _planTitleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _catNameCtrl = TextEditingController();
  final TextEditingController _catAmountCtrl = TextEditingController();

  final BudgetApi _budgetApi = BudgetApi();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Usar colores de categoría centralizados en AppTheme

  String _mode = 'manual';
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isListening = false;
  int? _editingIndex;

  Map<String, dynamic>? _budgetResult;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    if (widget.existingBudget != null) {
      _isEditing = true;
      _loadExistingData();
    }
  }

  @override
  void dispose() {
    _planTitleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _catNameCtrl.dispose();
    _catAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _listen() async {
    if (!_isListening) {
      final bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          localeId: 'es_ES',
          onResult: (val) async {
            if (val.finalResult) {
              setState(() => _isListening = false);

              final String text = val.recognizedWords;
              _catNameCtrl.text = "Procesando...";

              try {
                final result = await _budgetApi.processVoiceCommand(text);

                setState(() {
                  _catNameCtrl.text = result['name'] ?? "";
                  _catAmountCtrl.text = result['amount'].toString();
                });
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("No entendí bien, intenta de nuevo.")));
                  _catNameCtrl.clear();
                }
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _loadExistingData() {
    final b = widget.existingBudget!;
    _planTitleController.text = b['title'] ?? '';
    _amountController.text =
        double.parse(b['total_amount'].toString()).toStringAsFixed(0);
    _descriptionController.text = b['description'] ?? '';

    if (b['categories'] != null) {
      for (var cat in b['categories']) {
        _categories.add({
          'id': cat['id'],
          'name': cat['name'],
          'amount': double.tryParse(cat['amount'].toString()) ?? 0.0,
          'reason': cat['reason']
        });
      }
    }
    _mode = 'manual';
  }

  Future<void> _generateBudget() async {
    FocusScope.of(context).unfocus();
    final String title = _planTitleController.text.trim();
    final double? total =
        double.tryParse(_amountController.text.replaceAll(',', ''));
    final String desc = _descriptionController.text.trim();

    if (title.isEmpty || total == null || total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ingresa título y monto para usar la IA.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _budgetApi.generateBudgetPlan(title, total, desc);
      setState(() {
        _isLoading = false;
        _budgetResult = result;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La IA no pudo generar el plan.')));
    }
  }

  Future<void> _saveOrUpdate() async {
    final String title = _planTitleController.text.trim();
    final double? total =
        double.tryParse(_amountController.text.replaceAll(',', ''));
    final String desc = _descriptionController.text.trim();

    if (title.isEmpty || total == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faltan datos principales.')));
      return;
    }

    List<Map<String, dynamic>> catsToSend = [];
    if (_mode == 'manual' || _isEditing) {
      catsToSend = _categories;
    } else if (_budgetResult != null) {
      catsToSend =
          List<Map<String, dynamic>>.from(_budgetResult!['categories']);
    }

    if (catsToSend.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agrega al menos una categoría.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        await _budgetApi.updateBudget(
            widget.existingBudget!['id'], title, total, desc, catsToSend);
      } else {
        await _budgetApi.saveBudgetPlan(title, total, desc, catsToSend, _mode);
      }

      if (widget.onBudgetSaved != null) widget.onBudgetSaved!();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteBudget() async {
    final bool confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text("¿Borrar Plan?"),
                  content: const Text(
                      "Se eliminará todo el historial de este presupuesto."),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancelar")),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Borrar",
                            style: TextStyle(color: Colors.red))),
                  ],
                )) ??
        false;

    if (confirm) {
      try {
        await _budgetApi.deleteBudget(widget.existingBudget!['id']);
        if (widget.onBudgetSaved != null) widget.onBudgetSaved!();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  void _addOrUpdateCategory() {
    final String name = _catNameCtrl.text.trim();
    final double? val =
        double.tryParse(_catAmountCtrl.text.replaceAll(',', ''));
    if (name.isNotEmpty && val != null) {
      setState(() {
        if (_editingIndex == null) {
          _categories.add({'name': name, 'amount': val});
        } else {
          final old = _categories[_editingIndex!];
          _categories[_editingIndex!] = {
            'id': old['id'],
            'name': name,
            'amount': val,
            'reason': old['reason']
          };
          _editingIndex = null;
        }
        _catNameCtrl.clear();
        _catAmountCtrl.clear();
        FocusScope.of(context).unfocus();
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _catNameCtrl.clear();
      _catAmountCtrl.clear();
      FocusScope.of(context).unfocus();
    });
  }

  void _deleteCategory(int index) {
    setState(() {
      if (_editingIndex == index) {
        _editingIndex = null;
        _catNameCtrl.clear();
        _catAmountCtrl.clear();
      }
      _categories.removeAt(index);
    });
  }

  void _startEditingCategory(int index) {
    final cat = _categories[index];
    setState(() {
      _catNameCtrl.text = cat['name'];
      _catAmountCtrl.text = cat['amount'].toStringAsFixed(0);
      _editingIndex = index;
    });
  }

  void _switchMode(String newMode) {
    setState(() {
      _mode = newMode;
      _budgetResult = null;
      if (_mode == 'manual') _categories = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

    final List currentCats = _mode == 'manual' || _isEditing
        ? _categories
        : (_budgetResult != null ? _budgetResult!['categories'] : []);
    final double sumCategories = currentCats.fold(
        0.0, (sum, c) => sum + (double.tryParse(c['amount'].toString()) ?? 0));

    final bool isBalanced =
        totalAmount > 0 && (sumCategories - totalAmount).abs() < 1.0;
    final bool isOverBudget = sumCategories > totalAmount;
    final Color stateColor =
        isBalanced ? Colors.green : (isOverBudget ? Colors.red : Colors.orange);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextWidget(
            text: _isEditing ? 'Editar Plan' : 'Nuevo Plan',
            color: Colors.black,
            size: 16,
            fontWeight: FontWeight.bold),
        actions: [
          if (_isEditing)
            IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: _deleteBudget)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MoneyInputWidget(
                controller: _amountController,
                onChanged: () => setState(() {})),
            const SizedBox(height: 20),
            TextInput(
                controller: _planTitleController,
                hintText: "Nombre del Plan (Ej: Viaje)",
                icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                keyboardType: TextInputType.text),
            const SizedBox(height: 10),
            TextInput(
                controller: _descriptionController,
                hintText: "Detalles opcionales...",
                icon: Icon(Icons.notes, color: AppTheme.primaryColor),
                keyboardType: TextInputType.text),
            const SizedBox(height: 25),
            if (!_isEditing) ...[
              ModeSwitchWidget(currentMode: _mode, onModeChanged: _switchMode),
              const SizedBox(height: 25),
            ],
            if (_mode == 'ia' && !_isEditing && _budgetResult == null) ...[
              const Icon(Icons.auto_awesome, size: 50, color: Colors.purple),
              const SizedBox(height: 10),
              const Text("La IA organizará tu dinero por ti.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ButtonCustom(
                  text: _isLoading ? "Pensando..." : "Generar Propuesta",
                  onTap: _isLoading ? () {} : _generateBudget),
            ],
            if (_mode == 'manual' ||
                _isEditing ||
                (_mode == 'ia' && _budgetResult != null)) ...[
              BudgetValidationWidget(
                  total: totalAmount,
                  current: sumCategories,
                  color: stateColor,
                  isOverBudget: isOverBudget),
              const SizedBox(height: 20),
              if (_mode == 'manual' || _isEditing)
                CategoryInputWidget(
                    nameController: _catNameCtrl,
                    amountController: _catAmountCtrl,
                    isEditing: _editingIndex != null,
                    isListening: _isListening,
                    onListen: _listen,
                    onSave: _addOrUpdateCategory,
                    onCancel: _cancelEditing),
              const SizedBox(height: 15),
              if (currentCats.isEmpty)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Agrega categorías...",
                            style: TextStyle(color: Colors.grey))))
              else
                ...currentCats
                    .asMap()
                    .entries
                    .map((entry) => CategoryCardWidget(
                        name: entry.value['name'],
                        amount: entry.value['amount'],
                        color: AppTheme.getCategoryColor(entry.key),
                        isEditing: _editingIndex == entry.key,
                        readOnly: _mode == 'ia' && !_isEditing,
                        onEdit: _mode == 'manual' || _isEditing
                            ? () => _startEditingCategory(entry.key)
                            : null,
                        onDelete: _mode == 'manual' || _isEditing
                            ? () => _deleteCategory(entry.key)
                            : null))
                    .toList(),
              const SizedBox(height: 30),
              ButtonCustom(
                text: _isSaving
                    ? "Guardando..."
                    : (_isEditing ? "Actualizar Plan" : "Guardar Plan"),
                onTap: !_isSaving ? _saveOrUpdate : null,
                color: isBalanced ? AppTheme.primaryColor : Colors.orange,
              ),
              const SizedBox(height: 20),
            ]
          ],
        ),
      ),
    );
  }
}

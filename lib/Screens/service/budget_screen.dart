import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Importar paquete de voz

import '../../Theme/Theme.dart';
import '../../Widgets/TextWidget.dart';
import '../../Widgets/ButtonCustom.dart';
import '../../Widgets/TextInput.dart';
import '../../api/budget_api.dart';

class BudgetScreen extends StatefulWidget {
  final VoidCallback? onBudgetSaved;
  final Map<String, dynamic>? existingBudget;

  const BudgetScreen({Key? key, this.onBudgetSaved, this.existingBudget}) : super(key: key);

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // Controladores
  final TextEditingController _planTitleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Controladores Categoría
  final TextEditingController _catNameCtrl = TextEditingController();
  final TextEditingController _catAmountCtrl = TextEditingController();

  final BudgetApi _budgetApi = BudgetApi();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _mode = 'manual';
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isListening = false; // Estado del micrófono
  int? _editingIndex;

  Map<String, dynamic>? _budgetResult;
  List<Map<String, dynamic>> _categories = [];

  final List<Color> _colors = [
    const Color(0xFF4E9F3D), const Color(0xFFD83A56), const Color(0xFFFF8E00),
    const Color(0xFF27496D), const Color(0xFF9A0680), const Color(0xFF00ADB5),
    const Color(0xFFFFC75F),
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    if (widget.existingBudget != null) {
      _isEditing = true;
      _loadExistingData();
    }
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  // --- LÓGICA DE VOZ CON IA BACKEND ---
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        
        _speech.listen(
          localeId: 'es_ES',
          onResult: (val) async {
            // Solo procesamos cuando el usuario termina de hablar
            if (val.finalResult) {
              setState(() => _isListening = false);
              
              String text = val.recognizedWords;
              // Feedback visual inmediato
              _catNameCtrl.text = "Procesando...";
              
              try {
                // Llamamos a Laravel/Groq
                final result = await _budgetApi.processVoiceCommand(text);
                
                setState(() {
                  _catNameCtrl.text = result['name'] ?? "";
                  _catAmountCtrl.text = result['amount'].toString();
                });
                
              } catch (e) {
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No entendí bien, intenta de nuevo."))
                  );
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
    _amountController.text = double.parse(b['total_amount'].toString()).toStringAsFixed(0);
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
    String title = _planTitleController.text.trim();
    double? total = double.tryParse(_amountController.text.replaceAll(',', ''));
    String desc = _descriptionController.text.trim();

    if (title.isEmpty || total == null || total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa título y monto para usar la IA.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _budgetApi.generateBudgetPlan(title, total, desc);
      setState(() { _isLoading = false; _budgetResult = result; });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La IA no pudo generar el plan.')));
    }
  }

  Future<void> _saveOrUpdate() async {
    String title = _planTitleController.text.trim();
    double? total = double.tryParse(_amountController.text.replaceAll(',', ''));
    String desc = _descriptionController.text.trim();

    if (title.isEmpty || total == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos principales.')));
      return;
    }

    List<Map<String, dynamic>> catsToSend = [];
    if (_mode == 'manual' || _isEditing) {
      catsToSend = _categories;
    } else if (_budgetResult != null) {
      catsToSend = List<Map<String, dynamic>>.from(_budgetResult!['categories']);
    }

    if (catsToSend.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega al menos una categoría.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        await _budgetApi.updateBudget(widget.existingBudget!['id'], title, total, desc, catsToSend);
      } else {
        await _budgetApi.saveBudgetPlan(title, total, desc, catsToSend, _mode);
      }

      if (widget.onBudgetSaved != null) widget.onBudgetSaved!();
      if (mounted) Navigator.pop(context);

    } catch (e) {
      setState(() => _isSaving = false);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteBudget() async {
    bool confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("¿Borrar Plan?"),
        content: const Text("Se eliminará todo el historial de este presupuesto."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Borrar", style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (confirm) {
      try {
        await _budgetApi.deleteBudget(widget.existingBudget!['id']);
        if (widget.onBudgetSaved != null) widget.onBudgetSaved!();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    
    List currentCats = _mode == 'manual' || _isEditing ? _categories : (_budgetResult != null ? _budgetResult!['categories'] : []);
    double sumCategories = currentCats.fold(0, (sum, c) => sum + (double.tryParse(c['amount'].toString()) ?? 0));
    
    bool isBalanced = totalAmount > 0 && (sumCategories - totalAmount).abs() < 1.0;
    bool isOverBudget = sumCategories > totalAmount;
    Color stateColor = isBalanced ? Colors.green : (isOverBudget ? Colors.red : Colors.orange);

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
        title: Textwidget(
          text: _isEditing ? 'Editar Plan' : 'Nuevo Plan', 
          color: Colors.black, size: 16, fontWeight: FontWeight.bold
        ),
        actions: [
          if (_isEditing)
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: _deleteBudget)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMoneyInput(),
            const SizedBox(height: 20),

            Textinput(controller: _planTitleController, hintText: "Nombre del Plan (Ej: Viaje)", icon: Icon(Icons.edit, color: AppTheme.primaryColor), keyboardType: TextInputType.text),
            const SizedBox(height: 10),
            Textinput(controller: _descriptionController, hintText: "Detalles opcionales...", icon: Icon(Icons.notes, color: AppTheme.primaryColor), keyboardType: TextInputType.text),

            const SizedBox(height: 25),

            if (!_isEditing) ...[
              _buildModeSwitch(),
              const SizedBox(height: 25),
            ],

            if (_mode == 'ia' && !_isEditing && _budgetResult == null) ...[
              const Icon(Icons.auto_awesome, size: 50, color: Colors.purple),
              const SizedBox(height: 10),
              const Text("La IA organizará tu dinero por ti.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Buttoncustom(text: _isLoading ? "Pensando..." : "Generar Propuesta", onTap: _isLoading ? () {} : _generateBudget),
            ],

            if (_mode == 'manual' || _isEditing || (_mode == 'ia' && _budgetResult != null)) ...[
              _buildValidationHeader(totalAmount, sumCategories, stateColor, isBalanced, isOverBudget),
              const SizedBox(height: 20),

              // Formulario Manual / Voz
              if (_mode == 'manual' || _isEditing)
                _buildAddCategoryForm(totalAmount - sumCategories),

              const SizedBox(height: 15),

              if (currentCats.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Agrega categorías...", style: TextStyle(color: Colors.grey))))
              else
                ...currentCats.asMap().entries.map((entry) => 
                  _buildEditableCategoryCard(
                    entry.value, 
                    entry.key, 
                    _colors[entry.key % _colors.length], 
                    readOnly: _mode == 'ia' && !_isEditing
                  )
                ).toList(),
                
              const SizedBox(height: 30),
              
              Buttoncustom(
                text: _isSaving ? "Guardando..." : (_isEditing ? "Actualizar Plan" : "Guardar Plan"),
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

  // --- WIDGETS ---

  Widget _buildMoneyInput() {
    return Column(
      children: [
        const Text("Presupuesto Total", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
          decoration: const InputDecoration(hintText: "\$ 0", border: InputBorder.none, hintStyle: TextStyle(color: Colors.black12)),
          onChanged: (_) => setState((){}), 
        ),
      ],
    );
  }

  Widget _buildAddCategoryForm(double suggestedAmount) {
    bool isEditing = _editingIndex != null;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _isListening ? Colors.red[50] : Colors.grey[50], // Feedback visual si escucha
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isEditing ? AppTheme.primaryColor : (_isListening ? Colors.red : Colors.grey[300]!))
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEditing ? "Editar Categoría" : (_isListening ? "Escuchando..." : "Nueva Categoría"), style: TextStyle(fontWeight: FontWeight.bold, color: _isListening ? Colors.red : Colors.black87)),
              GestureDetector(
                onTap: _listen, // Activar micrófono
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _isListening ? Colors.red : Colors.white, shape: BoxShape.circle, boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 3)]),
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.white : Colors.black, size: 20),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(flex: 2, child: SizedBox(height: 45, child: TextField(controller: _catNameCtrl, decoration: InputDecoration(hintText: "Nombre (Ej: Hotel)", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 10))))),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: SizedBox(height: 45, child: TextField(controller: _catAmountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "Valor", prefixIcon: const Icon(Icons.attach_money, size: 16), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 10))))),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  String name = _catNameCtrl.text.trim();
                  double? val = double.tryParse(_catAmountCtrl.text.replaceAll(',', ''));
                  if (name.isNotEmpty && val != null) {
                    setState(() {
                      if (_editingIndex == null) {
                        _categories.add({'name': name, 'amount': val});
                      } else {
                        var old = _categories[_editingIndex!];
                        _categories[_editingIndex!] = {'id': old['id'], 'name': name, 'amount': val, 'reason': old['reason']};
                        _editingIndex = null;
                      }
                      _catNameCtrl.clear(); _catAmountCtrl.clear();
                      FocusScope.of(context).unfocus();
                    });
                  }
                },
                child: Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(color: isEditing ? Colors.green : Colors.black, borderRadius: BorderRadius.circular(12)),
                  child: Icon(isEditing ? Icons.check : Icons.add, color: Colors.white),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(width: 5),
                InkWell(onTap: () { setState(() { _editingIndex = null; _catNameCtrl.clear(); _catAmountCtrl.clear(); FocusScope.of(context).unfocus(); }); }, child: Container(width: 45, height: 45, decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.close, color: Colors.red))),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValidationHeader(double total, double current, Color color, bool balanced, bool over) {
    double progress = total > 0 ? (current / total) : 0;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Progreso", style: TextStyle(fontSize: 12, color: Colors.grey)), Text("${(progress * 100).toStringAsFixed(0)}%", style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress > 1 ? 1 : progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("\$ ${_fmt(current)}", style: const TextStyle(fontWeight: FontWeight.bold)), Text("Meta: \$ ${_fmt(total)}", style: const TextStyle(color: Colors.grey))]),
          if (over) Text("Te pasaste por \$ ${_fmt(current - total)}", style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _buildEditableCategoryCard(Map<String, dynamic> cat, int idx, Color color, {bool readOnly = false}) {
    bool isEditingThis = _editingIndex == idx;
    double amount = double.tryParse(cat['amount'].toString()) ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: isEditingThis ? Colors.blue[50] : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: isEditingThis ? Colors.blue : Colors.grey[200]!)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.category, color: color, size: 18)),
        title: Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("\$ ${_fmt(amount)}"),
        trailing: readOnly ? null : Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey), onPressed: () { setState(() { _catNameCtrl.text = cat['name']; _catAmountCtrl.text = amount.toStringAsFixed(0); _editingIndex = idx; }); }),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () { setState(() { if(_editingIndex == idx) { _editingIndex = null; _catNameCtrl.clear(); _catAmountCtrl.clear(); } _categories.removeAt(idx); }); }),
        ]),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)), child: Row(children: [_buildSwitchOption("Manual", Icons.edit, _mode == 'manual'), _buildSwitchOption("Asistente IA", Icons.auto_awesome, _mode == 'ia')]));
  }

  Widget _buildSwitchOption(String text, IconData icon, bool isActive) {
    return Expanded(child: GestureDetector(onTap: () => setState(() { _mode = text == "Manual" ? 'manual' : 'ia'; _budgetResult = null; if(_mode == 'manual') _categories = []; }), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(25), boxShadow: isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 5)] : []), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: isActive ? Colors.black : Colors.grey), const SizedBox(width: 8), Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey, fontSize: 13))]))));
  }

  Widget _InputLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 5, left: 5), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)));
  
  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
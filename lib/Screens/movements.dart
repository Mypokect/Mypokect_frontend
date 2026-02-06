import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../Widgets/common/text_widget.dart';
import '../Widgets/movements/campo_etiquetas.dart';
import '../Widgets/movements/tag_chip_selector.dart';
import '../Widgets/movements/type_selector.dart';
import '../Widgets/movements/money_input_widget.dart';
import '../Widgets/movements/footer_actions_widget.dart';
import '../Widgets/movements/voice_input_mixin.dart';
import '../Widgets/movements/description_input_widget.dart';
import '../Widgets/movements/invoice_toggle_widget.dart';
import '../Widgets/movements/payment_method_selector_widget.dart';
import '../Widgets/movements/processing_overlay_widget.dart';
import '../Widgets/movements/suggestion_button_widget.dart';
import '../Widgets/movements/new_tag_banner_widget.dart';
import '../Controllers/movement_controller.dart';
import '../api/goal_contributions_api.dart';
import '../api/savings_goals_api.dart';
import '../Theme/Theme.dart';
import '../utils/movement_utils.dart';
import 'main_screen.dart';

class Movements extends StatefulWidget {
  final String? preSelectedTag;
  const Movements({super.key, this.preSelectedTag});

  @override
  State<Movements> createState() => _MovementsState();
}

class _MovementsState extends State<Movements> with VoiceInputMixin {
  final MovementController _controller = MovementController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _etiquetaController = TextEditingController();
  final FocusNode _montoFocusNode = FocusNode();

  bool _esGasto = true;
  String _paymentMethod = 'digital';
  bool _isGoalMode = false;
  bool _hasInvoice = false;
  List<String> _etiquetasUsuario = [];
  List<String> _categorias = [];
  List<String> _metas = [];
  String? _selectedTag;
  bool _showAbbreviated = false;
  Timer? _abbreviationTimer;
  Timer? _suggestionTimer;
  bool _isLoadingSuggestion = false;
  bool _autoSuggestEnabled = true;
  bool _showNewTagHint = false;

  Color get _activeColor => _isGoalMode ? AppTheme.goalBlue : (_esGasto ? AppTheme.expenseDarkColor : AppTheme.primaryColor);

  @override
  void initState() {
    super.initState();
    _initLogic();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadTags());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reloadTags();
  }

  @override
  void didUpdateWidget(Movements oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preSelectedTag != widget.preSelectedTag) _reloadTags();
  }

  Future<void> _initLogic() async {
    await initVoice();
    await _loadTags();
    _setupPreSelectedTag();
    _setupListeners();
    await _loadAutoSuggestPreference();
  }

  Future<void> _loadTags() async {
    final tags = await _controller.getAllEtiquetas();
    if (!mounted) return;
    final separated = MovementUtils.separateTags(tags);
    setState(() {
      _etiquetasUsuario = tags;
      _categorias = separated.categorias;
      _metas = separated.metas;
    });
  }

  void _setupPreSelectedTag() {
    if (widget.preSelectedTag == null) return;
    _etiquetaController.text = widget.preSelectedTag!;
    _selectedTag = widget.preSelectedTag;
    _isGoalMode = MovementUtils.isGoalTag(widget.preSelectedTag!, _metas);
  }

  void _setupListeners() {
    _montoController.addListener(_formatCurrency);
    _nombreController.addListener(_onInputChanged);
    _montoController.addListener(_onInputChanged);
    _etiquetaController.addListener(_onTagTextChanged);
  }

  Future<void> _loadAutoSuggestPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _autoSuggestEnabled = prefs.getBool('auto_suggest_tags') ?? true);
  }

  Future<void> _reloadTags() async {
    try { await _loadTags(); } catch (_) {}
  }

  // === VOICE CALLBACKS ===
  @override
  void onTranscription(String text) => setState(() => _nombreController.text = text);

  @override
  Future<void> onFinalTranscription(String text) async => await _procesarVozConIA();

  @override
  void onClearFieldsForNewRecording() => setState(() {
    _nombreController.clear();
    _montoController.clear();
    _etiquetaController.clear();
    _hasInvoice = false;
    _paymentMethod = 'digital';
  });

  // === CURRENCY ===
  void _formatCurrency() {
    if (_montoController.text.isEmpty) return;
    _abbreviationTimer?.cancel();
    setState(() => _showAbbreviated = false);

    final value = _montoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return;

    final formatted = MovementUtils.formatCurrency(value);
    if (formatted.isNotEmpty) {
      _montoController.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
    }
    _abbreviationTimer = Timer(const Duration(seconds: 2), () { if (mounted) setState(() => _showAbbreviated = true); });
  }

  // === TAG SUGGESTION ===
  void _onInputChanged() {
    _suggestionTimer?.cancel();
    if (!_autoSuggestEnabled || _nombreController.text.isEmpty || _montoController.text.isEmpty) return;
    _suggestionTimer = Timer(const Duration(seconds: 1), _sugerirEtiqueta);
  }

  Future<void> _sugerirEtiqueta() async {
    if (_etiquetaController.text.isNotEmpty) return;
    if (mounted) setState(() => _isLoadingSuggestion = true);
    try {
      await _controller.getCategoriaDesdeApi(
        nombre: _nombreController.text,
        valor: _montoController.text.replaceAll('.', '').replaceAll(',', ''),
        context: context,
        onSuccess: (tag) { if (mounted && tag != null && _etiquetaController.text.isEmpty) setState(() => _etiquetaController.text = tag); },
      );
    } finally { if (mounted) setState(() => _isLoadingSuggestion = false); }
  }

  // === TAG HANDLING ===
  void _onTagSelected(String tag) => setState(() {
    _selectedTag = tag;
    _etiquetaController.text = tag;
    final esMeta = MovementUtils.isGoalTag(tag, _metas);
    if (esMeta != _isGoalMode) { _isGoalMode = esMeta; HapticFeedback.mediumImpact(); }
  });

  void _onTagDeselected() => setState(() {
    _selectedTag = null;
    _etiquetaController.clear();
    if (_isGoalMode) { _isGoalMode = false; HapticFeedback.lightImpact(); }
  });

  void _onTagTextChanged() {
    final text = _etiquetaController.text.trim();
    if (text.isEmpty) {
      if (_selectedTag != null || _showNewTagHint) setState(() { _selectedTag = null; _showNewTagHint = false; if (_isGoalMode) { _isGoalMode = false; HapticFeedback.lightImpact(); } });
      return;
    }

    String? matched;
    for (final tag in _etiquetasUsuario) { if (MovementUtils.hasHighMatch(text, tag)) { matched = tag; break; } }

    if (matched != null) {
      final esMeta = MovementUtils.isGoalTag(matched, _metas);
      if (_selectedTag != matched || _isGoalMode != esMeta || _showNewTagHint) {
        setState(() { _selectedTag = matched; _showNewTagHint = false; if (_isGoalMode != esMeta) { _isGoalMode = esMeta; HapticFeedback.mediumImpact(); } });
      }
    } else if (_selectedTag != null || !_showNewTagHint) {
      setState(() { _selectedTag = null; _showNewTagHint = true; if (_isGoalMode) { _isGoalMode = false; HapticFeedback.lightImpact(); } });
    }
  }

  // === VOICE PROCESSING ===
  Future<void> _procesarVozConIA() async {
    setState(() => isProcessingAI = true);
    try {
      final s = await _controller.procesarSugerenciaPorVoz(transcripcion: _nombreController.text, context: context);
      if (s != null && mounted) {
        setState(() {
          _nombreController.text = s['description'] ?? _nombreController.text;
          final amt = s['amount']?.toString() ?? '';
          if (amt.isNotEmpty && amt != '0') _montoController.text = amt;
          final tag = s['suggested_tag'] ?? '';
          if (tag.isNotEmpty) { _etiquetaController.text = tag; _selectedTag = tag; }
          _esGasto = s['type'] == 'expense';
          _paymentMethod = s['payment_method'] ?? 'digital';
          _hasInvoice = s['has_invoice'] ?? false;
          _isGoalMode = MovementUtils.isGoalTag(_etiquetaController.text, _metas);
          voiceState = VoiceState.success;
          isProcessingAI = false;
        });
        Future.delayed(const Duration(seconds: 1), () { if (mounted) setState(() => voiceState = VoiceState.idle); });
      } else { _handleVoiceError(); }
    } catch (e) { _handleVoiceError(e.toString()); }
  }

  void _handleVoiceError([String? msg]) {
    if (!mounted) return;
    setState(() { voiceState = VoiceState.error; isProcessingAI = false; });
    if (msg != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg'), backgroundColor: Colors.red));
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => voiceState = VoiceState.idle); });
  }

  // === SAVE ===
  Future<void> _guardarMovimiento() async {
    if (_montoController.text.isEmpty) { HapticFeedback.mediumImpact(); return; }
    HapticFeedback.lightImpact();
    final val = double.tryParse(_montoController.text.replaceAll('.', '')) ?? 0.0;
    final tag = _etiquetaController.text.trim();
    if (_isGoalMode && tag.isNotEmpty) { await _saveGoalContribution(tag, val); return; }
    await _saveRegularMovement(tag, val);
  }

  Future<void> _saveGoalContribution(String tag, double amount) async {
    try {
      final map = await _controller.getGoalTagToIdMap();
      final id = map[tag];
      if (id == null) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meta no encontrada'), backgroundColor: Colors.orange)); return; }
      await GoalContributionsApi().createContribution(goalId: id, amount: amount, description: _nombreController.text.isEmpty ? 'Abono' : _nombreController.text);
      SavingsGoalsApi.clearCache();
      if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Abono guardado!'), backgroundColor: Colors.green)); _navigateToHome(); }
    } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
  }

  Future<void> _saveRegularMovement(String tag, double amount) async {
    var finalTag = tag;
    if (finalTag.isNotEmpty && !_etiquetasUsuario.any((t) => t.toLowerCase() == finalTag.toLowerCase())) {
      final created = await _controller.crearEtiqueta(finalTag, context);
      if (created != null) { finalTag = created; setState(() => _etiquetasUsuario.add(finalTag)); }
    }
    await _controller.createMovement(type: _esGasto ? 'expense' : 'income', amount: amount, description: _nombreController.text, tag: finalTag.isEmpty ? null : finalTag, paymentMethod: _paymentMethod, hasInvoice: _hasInvoice, context: context);
    if (context.mounted) _navigateToHome();
  }

  void _navigateToHome() => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainScreen()), (_) => false);

  // === BUILD ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.transparent, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.black26), onPressed: _navigateToHome),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: TextWidget(key: ValueKey(_isGoalMode), text: _isGoalMode ? "NUEVO ABONO" : "REGISTRO", size: 13, fontWeight: FontWeight.w800, color: _isGoalMode ? AppTheme.goalBlue : Colors.grey.shade400),
        ),
      ),
      body: Stack(children: [_buildBody(), if (isProcessingAI) const ProcessingOverlayWidget()]),
    );
  }

  Widget _buildBody() {
    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: MovementUtils.responsivePadding(context)),
        child: Column(children: [
          SizedBox(height: MovementUtils.responsiveSpacing(context, 20)),
          MoneyInputWidget(controller: _montoController, focusNode: _montoFocusNode, activeColor: _activeColor, showAbbreviated: _showAbbreviated, onTap: () { _abbreviationTimer?.cancel(); setState(() => _showAbbreviated = false); }, onChanged: (_) => _formatCurrency()),
          SizedBox(height: MovementUtils.responsiveSpacing(context, 30)),
          DescriptionInputWidget(controller: _nombreController, activeColor: _activeColor),
          SizedBox(height: MovementUtils.responsiveSpacing(context, 25)),
          _buildCategorySection(),
          SizedBox(height: MovementUtils.responsiveSpacing(context, 16)),
          if (!_isGoalMode) InvoiceToggleWidget(hasInvoice: _hasInvoice, onChanged: (v) => setState(() => _hasInvoice = v)),
          SizedBox(height: MovementUtils.responsiveSpacing(context, 24)),
          if (!_isGoalMode) PaymentMethodSelectorWidget(selectedMethod: _paymentMethod, activeColor: _activeColor, onChanged: (v) => setState(() => _paymentMethod = v)),
          SizedBox(height: MovementUtils.responsiveSpacing(context, 40)),
        ]),
      )),
      FooterActionsWidget(activeColor: _activeColor, voiceState: voiceState, microphoneAvailable: microphoneAvailable, recordingSeconds: recordingSeconds, onMicTap: toggleVoice, onMicLongPress: startVoice, onMicLongPressUp: isListening ? stopVoice : null, onCancelVoice: cancelVoice, onSave: _guardarMovimiento),
    ]);
  }

  Widget _buildCategorySection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TagChipSelector(categorias: _categorias, metas: _metas, selectedTag: _selectedTag, onTagSelected: _onTagSelected, onTagDeselected: _onTagDeselected, isGoalMode: _isGoalMode, activeColor: _activeColor),
      SizedBox(height: MovementUtils.responsiveSpacing(context, 12)),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(child: Row(children: [
          Expanded(child: SizedBox(height: 48, child: CampoEtiquetas(etiquetaController: _etiquetaController, etiquetasUsuario: _etiquetasUsuario, isLoadingSuggestion: _isLoadingSuggestion, onEtiquetaSeleccionada: _onTagSelected))),
          const SizedBox(width: 8),
          SuggestionButtonWidget(isLoading: _isLoadingSuggestion, onTap: _sugerirEtiqueta),
        ])),
        SizedBox(width: MovementUtils.responsiveSpacing(context, 10)),
        if (!_isGoalMode) SizedBox(width: MovementUtils.toggleWidth(context), child: TypeSelector(esGasto: _esGasto, isGoalMode: _isGoalMode, colorActive: _esGasto ? AppTheme.expenseDarkColor : AppTheme.primaryColor, onTap: () => setState(() => _esGasto = !_esGasto))),
      ]),
      if (_showNewTagHint) ...[SizedBox(height: MovementUtils.responsiveSpacing(context, 8)), NewTagBannerWidget(tagName: _etiquetaController.text)],
    ]);
  }

  @override
  void dispose() {
    _abbreviationTimer?.cancel();
    _suggestionTimer?.cancel();
    disposeVoice();
    _nombreController.removeListener(_onInputChanged);
    _montoController.removeListener(_onInputChanged);
    _etiquetaController.removeListener(_onTagTextChanged);
    _montoController.dispose();
    _nombreController.dispose();
    _etiquetaController.dispose();
    _montoFocusNode.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../Widgets/common/text_widget.dart';
import '../Widgets/movements/campo_etiquetas.dart';
import '../Widgets/movements/sound_wave_animation.dart';
import '../Widgets/movements/tag_chip_selector.dart';
import '../Widgets/movements/type_selector.dart';
import '../Controllers/movement_controller.dart';
import '../api/goal_contributions_api.dart';
import '../api/savings_goals_api.dart';
import '../Theme/Theme.dart';
import 'main_screen.dart';

enum VoiceState { idle, listening, processing, success, error }

class Movements extends StatefulWidget {
  final String? preSelectedTag;
  const Movements({super.key, this.preSelectedTag});

  @override
  State<Movements> createState() => _MovementsState();
}

class _MovementsState extends State<Movements> {
  final MovementController _movementController = MovementController();
  final NumberFormat _currencyFormat = NumberFormat.decimalPattern('es_CO');

  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _etiquetaController = TextEditingController();
  final FocusNode _montoFocusNode = FocusNode();

  bool _esGasto = true;
  String _paymentMethod = 'digital';
  bool _isListening = false;
  bool _isGoalMode = false;
  bool _hasInvoice = false;
  List<String> _etiquetasUsuario = [];
  List<String> _categorias = [];
  List<String> _metas = [];
  String? _selectedTag;
  final SpeechToText _speechToText = SpeechToText();
  bool _showAbbreviated = false;
  Timer? _abbreviationTimer;
  Timer? _suggestionTimer;
  bool _isLoadingSuggestion = false;
  bool _autoSuggestEnabled = true;
  bool _microphoneAvailable = false;
  bool _isProcessingAI = false;
  VoiceState _voiceState = VoiceState.idle;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _showNewTagHint = false;

  // Usar colores del tema centralizado
  Color get _greenMyPocket => AppTheme.primaryColor;
  Color get _redExpense => AppTheme.expenseDarkColor;
  Color get _blueGoal => AppTheme.goalBlue;

  Color get _activeColor =>
      _isGoalMode ? _blueGoal : (_esGasto ? _redExpense : _greenMyPocket);

  // =====================================================
  // HELPERS DE RESPONSIVIDAD
  // =====================================================

  double _screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  double _responsivePadding(BuildContext context) {
    final width = _screenWidth(context);
    if (width < 360) return 16.0; // Pantallas muy pequeñas
    if (width < 400) return 20.0; // Pantallas pequeñas (iPhone SE)
    if (width < 600) return 24.0; // Pantallas medianas (mayoría)
    return 32.0; // Tablets y grandes
  }

  double _responsiveSpacing(BuildContext context, double baseSpacing) {
    final width = _screenWidth(context);
    if (width < 360) return baseSpacing * 0.8;
    if (width > 600) return baseSpacing * 1.2;
    return baseSpacing;
  }

  // =====================================================

  @override
  void initState() {
    super.initState();
    _initLogic();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadTags();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reloadTags();
  }

  @override
  void didUpdateWidget(Movements oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preSelectedTag != widget.preSelectedTag) {
      _reloadTags();
    }
  }

  void _initLogic() async {
    // Inicializar micrófono UNA SOLA VEZ - sin callbacks que interfieran
    _microphoneAvailable = await _speechToText.initialize();

    final tags = await _movementController.getAllEtiquetas();
    if (mounted) {
      // Separar categorías de metas
      final categorias = tags
          .where((tag) =>
              !tag.startsWith('💰') &&
              !tag.toLowerCase().contains('meta:') &&
              !_isTagFromGoals(tag))
          .toList();

      final metas = tags
          .where((tag) =>
              tag.startsWith('💰') ||
              tag.toLowerCase().contains('meta:') ||
              _isTagFromGoals(tag))
          .toList();

      setState(() {
        _etiquetasUsuario = tags;
        _categorias = categorias;
        _metas = metas;
      });
    }

    if (widget.preSelectedTag != null) {
      _etiquetaController.text = widget.preSelectedTag!;
      _selectedTag = widget.preSelectedTag;
      _isGoalMode = _esEtiquetaMeta(widget.preSelectedTag!);
    }
    _montoController.addListener(_formatCurrency);

    // Listeners para sugerencia automática
    _nombreController.addListener(_onDescriptionOrAmountChanged);
    _montoController.addListener(_onDescriptionOrAmountChanged);

    // Listener para sincronizar campo de etiqueta con chips
    _etiquetaController.addListener(_onTagTextChanged);

    // Cargar preferencia de autosugestión
    await _loadAutoSuggestPreference();
  }

  Future<void> _loadAutoSuggestPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _autoSuggestEnabled = prefs.getBool('auto_suggest_tags') ?? true;
      });
    }
  }

  /// Recargar etiquetas desde el servidor (útil después de crear/eliminar metas)
  Future<void> _reloadTags() async {
    try {
      final tags = await _movementController.getAllEtiquetas();
      if (mounted) {
        final categorias = tags
            .where((tag) =>
                !tag.startsWith('💰') &&
                !tag.toLowerCase().contains('meta:') &&
                !_isTagFromGoals(tag))
            .toList();

        final metas = tags
            .where((tag) =>
                tag.startsWith('💰') ||
                tag.toLowerCase().contains('meta:') ||
                _isTagFromGoals(tag))
            .toList();

        setState(() {
          _etiquetasUsuario = tags;
          _categorias = categorias;
          _metas = metas;
        });
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Detectar si un tag viene de la API de metas
  bool _isTagFromGoals(String tag) {
    if (tag.isEmpty) return false;
    final parts = tag.split(' ');
    if (parts.length < 2) return false;
    final firstPart = parts.first;
    return firstPart.runes.length <= 4;
  }

  void _formatCurrency() {
    if (_montoController.text.isEmpty) return;

    // Cancelar timer anterior
    _abbreviationTimer?.cancel();

    // Mostrar número completo mientras escribes
    setState(() => _showAbbreviated = false);

    String value = _montoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return;

    try {
      String formatted = _currencyFormat.format(BigInt.parse(value));

      _montoController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: formatted.length,
        ),
      );
    } catch (e) {}

    // Iniciar timer para mostrar abreviación después de 2 segundos
    _abbreviationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showAbbreviated = true);
      }
    });
  }

  String _getAbbreviatedAmount() {
    String value = _montoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return "0";

    try {
      final amount = BigInt.parse(value);
      final num = amount.toInt();

      // Solo abreviar si es 10.000 o mayor
      if (num >= 1000000000) {
        // Billones
        final billions = num / 1000000000;
        return billions.toStringAsFixed(billions % 1 == 0 ? 0 : 1) + " B";
      } else if (num >= 1000000) {
        // Millones
        final millions = num / 1000000;
        return millions.toStringAsFixed(millions % 1 == 0 ? 0 : 1) + " M";
      } else if (num >= 10000) {
        // Miles (solo desde 10.000)
        final thousands = num / 1000;
        return thousands.toStringAsFixed(thousands % 1 == 0 ? 0 : 1) + " K";
      }
      // Retornar formateado para números menores a 10.000
      return _currencyFormat.format(amount);
    } catch (e) {
      return _montoController.text;
    }
  }

  void _onDescriptionOrAmountChanged() {
    // Cancelar timer anterior
    _suggestionTimer?.cancel();

    // Solo si está habilitada la sugerencia automática
    if (!_autoSuggestEnabled) return;

    // Solo sugerir si hay descripción Y monto
    if (_nombreController.text.isEmpty || _montoController.text.isEmpty) {
      return;
    }

    // Esperar 1 segundo después de dejar de escribir
    _suggestionTimer = Timer(const Duration(seconds: 1), () {
      _sugerirEtiqueta();
    });
  }

  Future<void> _sugerirEtiqueta() async {
    // Solo si el campo está vacío
    if (_etiquetaController.text.isNotEmpty) return;

    if (mounted) {
      setState(() => _isLoadingSuggestion = true);
    }

    try {
      await _movementController.getCategoriaDesdeApi(
        nombre: _nombreController.text,
        valor: _montoController.text.replaceAll('.', '').replaceAll(',', ''),
        context: context,
        onSuccess: (tag) {
          if (mounted && tag != null && _etiquetaController.text.isEmpty) {
            setState(() {
              _etiquetaController.text = tag;
            });
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingSuggestion = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black26),
          onPressed: () {
            // Siempre regresar al home actualizado
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          },
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: TextWidget(
            key: ValueKey(_isGoalMode),
            text: _isGoalMode ? "NUEVO ABONO" : "REGISTRO",
            size: 13,
            fontWeight: FontWeight.w800,
            color: _isGoalMode ? _blueGoal : Colors.grey.shade400,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: _responsivePadding(context),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: _responsiveSpacing(context, 20)),
                      _buildMoneyInput(),
                      SizedBox(height: _responsiveSpacing(context, 30)),
                      _buildDescriptionInput(),
                      SizedBox(height: _responsiveSpacing(context, 25)),
                      _buildTypeAndCategoryRow(),
                      SizedBox(height: _responsiveSpacing(context, 16)),
                      if (!_isGoalMode) _buildInvoiceToggle(),
                      SizedBox(height: _responsiveSpacing(context, 24)),
                      if (!_isGoalMode) _buildPaymentMethodInput(),
                      SizedBox(height: _responsiveSpacing(context, 40)),
                    ],
                  ),
                ),
              ),
              _buildFooterActions(),
            ],
          ),

          // Processing overlay
          if (_isProcessingAI)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '🤖 Procesando con IA...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Analizando tu voz',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMoneyInput() {
    // Calcular tamaño dinámico basado en cantidad de dígitos
    final digitsCount =
        _montoController.text.replaceAll(RegExp(r'[^0-9]'), '').length;

    // Determinar si se puede abreviar (>= 10.000 = 5 dígitos)
    final canAbbreviate = digitsCount >= 5;

    // Tamaño base según dígitos (sin cambios)
    final fontSize = (digitsCount > 10
        ? 60.0
        : digitsCount > 6
            ? 68.0
            : 80.0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Símbolo $
              Text(
                "\$",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: _montoController.text.isEmpty
                      ? Colors.grey.shade400
                      : _activeColor,
                  fontFamily: 'Poppins',
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              // Stack: TextField + Display abreviado con fade suave
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Layer 0: TextField (siempre presente, editable)
                    AnimatedOpacity(
                      opacity: _showAbbreviated ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: TextField(
                        controller: _montoController,
                        focusNode: _montoFocusNode,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        cursorColor: _activeColor,
                        cursorWidth: 2.5,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: _montoController.text.isEmpty
                              ? Colors.grey.shade400
                              : _activeColor,
                          fontFamily: 'Poppins',
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                        decoration: InputDecoration(
                          hintText: "0",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                            letterSpacing: -0.5,
                            height: 1.0,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isCollapsed: true,
                        ),
                        onTap: () {
                          // Al tocar, cancelar abreviación para mostrar número completo
                          _abbreviationTimer?.cancel();
                          setState(() => _showAbbreviated = false);
                        },
                        onChanged: (value) {
                          // Aplicar formateo y mostrar abreviación después de 2 segundos
                          _formatCurrency();
                        },
                      ),
                    ),
                    // Layer 1: Display abreviado con fade suave (clickeable para editar)
                    if (canAbbreviate)
                      AnimatedOpacity(
                        opacity: _showAbbreviated ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: GestureDetector(
                          onTap: () {
                            // Al tocar el display, mostrar TextField y hacer focus
                            _abbreviationTimer?.cancel();
                            setState(() => _showAbbreviated = false);
                            // Hacer focus en el TextField después de la animación
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              if (mounted) {
                                FocusScope.of(context)
                                    .requestFocus(_montoFocusNode);
                              }
                            });
                          },
                          child: Text(
                            _getAbbreviatedAmount(),
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w700,
                              color: _montoController.text.isEmpty
                                  ? Colors.grey.shade400
                                  : _activeColor,
                              fontFamily: 'Poppins',
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeAndCategoryRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Sección CATEGORÍAS + METAS (2 secciones separadas)
        TagChipSelector(
          categorias: _categorias,
          metas: _metas,
          selectedTag: _selectedTag,
          onTagSelected: _onTagSelected,
          onTagDeselected: _onTagDeselected,
          isGoalMode: _isGoalMode,
          activeColor: _activeColor,
        ),

        SizedBox(height: _responsiveSpacing(context, 12)),

        // 2. Campo de texto + botón sugerencia + Toggle (MISMA FILA)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 2A. Campo texto + botón sugerencia (Expanded - toma espacio disponible)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: CampoEtiquetas(
                        etiquetaController: _etiquetaController,
                        etiquetasUsuario: _etiquetasUsuario,
                        isLoadingSuggestion: _isLoadingSuggestion,
                        onEtiquetaSeleccionada: _onTagSelected,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSuggestionButton(),
                ],
              ),
            ),

            // Spacing entre campo y toggle
            SizedBox(width: _responsiveSpacing(context, 10)),

            // 2B. Toggle Gasto/Ingreso (Fixed width - OCULTO en modo meta)
            if (!_isGoalMode)
              SizedBox(
                width: _toggleWidth(context),
                child: TypeSelector(
                  esGasto: _esGasto,
                  isGoalMode: _isGoalMode,
                  colorActive: _esGasto ? _redExpense : _greenMyPocket,
                  onTap: () {
                    setState(() => _esGasto = !_esGasto);
                  },
                ),
              ),
          ],
        ),

        // 3. Banner "Nueva etiqueta" (si aplica)
        if (_showNewTagHint) ...[
          SizedBox(height: _responsiveSpacing(context, 8)),
          _buildNewTagBanner(),
        ],
      ],
    );
  }

  // Helper para ancho responsive del toggle
  double _toggleWidth(BuildContext context) {
    final width = _screenWidth(context);
    if (width < 360) return 120.0;
    if (width > 600) return 180.0;
    return 140.0;
  }

  Widget _buildSuggestionButton() {
    return GestureDetector(
      onTap: _isLoadingSuggestion ? null : _sugerirEtiqueta,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: _isLoadingSuggestion
              ? Colors.grey.shade300
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: _isLoadingSuggestion
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
              )
            : Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
      ),
    );
  }

  Widget _buildNewTagBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"${_etiquetaController.text}" se creará como nueva etiqueta al guardar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: "DESCRIPCIÓN",
          size: 10,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nombreController,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "¿Qué es este movimiento?",
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _activeColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _hasInvoice
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hasInvoice
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.grey.shade300,
            width: _hasInvoice ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 22,
              color: _hasInvoice ? AppTheme.primaryColor : Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextWidget(
                text: "Factura Electrónica",
                size: 14,
                fontWeight: FontWeight.w700,
                color: _hasInvoice ? AppTheme.primaryColor : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: _hasInvoice,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() => _hasInvoice = value);
              },
              activeTrackColor: AppTheme.primaryColor.withOpacity(0.5),
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: "MÉTODO DE PAGO",
          size: 10,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child:
                  _payOption("digital", Icons.credit_card_rounded, "Digital"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _payOption("cash", Icons.payments_rounded, "Efectivo"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _payOption(String id, IconData icon, String label) {
    bool isSelected = _paymentMethod == id;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _paymentMethod = id);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? _activeColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _activeColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            TextWidget(
              text: label,
              size: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        _responsivePadding(context),
        0,
        _responsivePadding(context),
        _responsiveSpacing(context, 45),
      ),
      color: Colors.white,
      child: Row(
        children: [
          _buildMicButton(),

          // Botón de cancelar (solo visible cuando está grabando)
          if (_voiceState == VoiceState.listening) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _cancelVoice,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.shade200,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.red.shade600,
                  size: 24,
                ),
              ),
            ),
          ],

          const SizedBox(width: 18),
          Expanded(child: _buildSaveButton()),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    // Si el micrófono no está disponible, mostrar botón deshabilitado
    if (!_microphoneAvailable) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.4,
            child: GestureDetector(
              onTap: _startVoice, // Muestra el diálogo explicativo
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.mic_off_rounded,
                  color: Colors.grey.shade400,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Obtener color según estado
    Color buttonColor;
    IconData buttonIcon;
    Color iconColor;

    switch (_voiceState) {
      case VoiceState.idle:
        buttonColor = Colors.grey.shade50;
        buttonIcon = Icons.mic_none_rounded;
        iconColor = _activeColor.withOpacity(0.6);
        break;
      case VoiceState.listening:
        buttonColor = _activeColor.withOpacity(0.1);
        buttonIcon = Icons.mic_rounded;
        iconColor = _activeColor;
        break;
      case VoiceState.processing:
        buttonColor = Colors.blue.shade50;
        buttonIcon = Icons.mic_rounded;
        iconColor = Colors.blue;
        break;
      case VoiceState.success:
        buttonColor = Colors.green.shade50;
        buttonIcon = Icons.check_circle_rounded;
        iconColor = Colors.green;
        break;
      case VoiceState.error:
        buttonColor = Colors.red.shade50;
        buttonIcon = Icons.error_rounded;
        iconColor = Colors.red;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _voiceState == VoiceState.idle ||
                  _voiceState == VoiceState.listening
              ? _toggleVoice
              : null,
          onLongPress: _voiceState == VoiceState.idle ? _startVoice : null,
          onLongPressUp: _isListening ? _stopVoice : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animación de ondas solo cuando está escuchando
              if (_voiceState == VoiceState.listening)
                SoundWaveAnimation(
                  color: _activeColor,
                  size: 62,
                ),

              // Botón principal con animación
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _voiceState == VoiceState.listening
                        ? _activeColor
                        : Colors.black.withOpacity(0.05),
                    width: _voiceState == VoiceState.listening ? 2 : 1,
                  ),
                  boxShadow: _voiceState == VoiceState.listening
                      ? [
                          BoxShadow(
                            color: _activeColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : null,
                ),
                child: _voiceState == VoiceState.processing
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(iconColor),
                          ),
                        ),
                      )
                    : Icon(
                        buttonIcon,
                        color: iconColor,
                        size: 28,
                      ),
              ),
            ],
          ),
        ),

        // Contador de duración (solo visible cuando está grabando)
        if (_voiceState == VoiceState.listening)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_recordingSeconds ~/ 60}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _activeColor,
                fontFamily: 'Baloo2',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _guardarMovimiento,
      child: Container(
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _activeColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _activeColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: "GUARDAR",
              color: Colors.white,
              size: 15,
              fontWeight: FontWeight.w900,
            ),
            SizedBox(width: 8),
            Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // Métodos para manejo de etiquetas
  bool _esEtiquetaMeta(String tag) {
    if (_metas.contains(tag)) return true;
    return tag.startsWith('💰') || tag.toLowerCase().contains('meta:');
  }

  void _onTagSelected(String tag) {
    setState(() {
      _selectedTag = tag;
      _etiquetaController.text = tag;

      // Detectar si es meta
      bool esMeta = _esEtiquetaMeta(tag);

      if (esMeta != _isGoalMode) {
        _isGoalMode = esMeta;
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _onTagDeselected() {
    setState(() {
      _selectedTag = null;
      _etiquetaController.clear();

      // Volver a modo normal si estaba en modo meta
      if (_isGoalMode) {
        _isGoalMode = false;
        HapticFeedback.lightImpact();
      }
    });
  }

  // Verificar si hay alta coincidencia entre texto escrito y etiqueta
  bool _tieneAltaCoincidencia(String textoEscrito, String etiqueta) {
    final texto = textoEscrito.toLowerCase();
    final tag = etiqueta.toLowerCase();

    // Coincidencia exacta
    if (texto == tag) return true;

    // Empieza con + mínimo 3 caracteres (ignorando emojis)
    // Extraer solo letras para el conteo
    final textoSinEmoji = texto.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    if (tag.startsWith(texto) && textoSinEmoji.length >= 3) return true;

    return false;
  }

  // Listener para sincronizar campo de texto con chips
  void _onTagTextChanged() {
    final currentText = _etiquetaController.text.trim();

    // CASO 1: Campo vacío
    if (currentText.isEmpty) {
      if (_selectedTag != null || _showNewTagHint) {
        setState(() {
          _selectedTag = null;
          _showNewTagHint = false;

          if (_isGoalMode) {
            _isGoalMode = false;
            HapticFeedback.lightImpact();
          }
        });
      }
      return;
    }

    // CASO 2: Buscar coincidencia
    String? matchedTag;

    for (final tag in _etiquetasUsuario) {
      if (_tieneAltaCoincidencia(currentText, tag)) {
        matchedTag = tag;
        break;
      }
    }

    // CASO 2A: Encontró coincidencia
    if (matchedTag != null) {
      bool esMeta = _esEtiquetaMeta(matchedTag);

      if (_selectedTag != matchedTag ||
          _isGoalMode != esMeta ||
          _showNewTagHint) {
        setState(() {
          _selectedTag = matchedTag;
          _showNewTagHint = false;

          if (_isGoalMode != esMeta) {
            _isGoalMode = esMeta;
            HapticFeedback.mediumImpact();
          }
        });
      }
    }
    // CASO 2B: No hay coincidencia (texto nuevo)
    else {
      if (_selectedTag != null || !_showNewTagHint) {
        setState(() {
          _selectedTag = null;
          _showNewTagHint = true;

          if (_isGoalMode) {
            _isGoalMode = false;
            HapticFeedback.lightImpact();
          }
        });
      }
    }
  }

  void _toggleVoice() {
    if (_isListening) {
      _stopVoice();
    } else {
      _startVoice();
    }
  }

  void _cancelVoice() async {
    await _speechToText.stop();
    HapticFeedback.lightImpact();

    // Detener el contador de duración
    _recordingTimer?.cancel();

    setState(() {
      _isListening = false;
      _voiceState = VoiceState.idle;
      _nombreController.clear();
      _recordingSeconds = 0;
    });
  }

  void _startVoice() async {
    HapticFeedback.heavyImpact();

    // speech_to_text maneja los permisos automáticamente durante initialize()
    print('🔐 Inicializando sistema de reconocimiento de voz...');

    // Si no está disponible, inicializar (esto solicita permisos automáticamente)
    if (!_microphoneAvailable) {
      print('❌ Micrófono no disponible - inicializando...');
      _microphoneAvailable = await _speechToText.initialize();

      if (!_microphoneAvailable) {
        print('❌ No se pudo inicializar el micrófono');
        if (mounted) {
          // Mostrar mensaje más claro explicando el problema
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reconocimiento de voz no disponible'),
              content: const Text(
                'El reconocimiento de voz no está disponible en este dispositivo/simulador.\n\n'
                'Para usar esta función:\n'
                '• En dispositivos reales: verifica los permisos de micrófono\n'
                '• En simuladores iOS: usa un dispositivo real o emulador Android\n\n'
                'Puedes continuar ingresando los datos manualmente.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        }
        return;
      }
      print('✅ Micrófono inicializado correctamente');
    }

    // Si ya está escuchando, detener primero
    if (_speechToText.isListening) {
      print('🎤 El micrófono ya está escuchando, deteniendo primero...');
      await _speechToText.stop();
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    // 5. Limpiar todos los campos antes de iniciar nueva grabación
    if (mounted) {
      setState(() {
        _isListening = true;
        _voiceState = VoiceState.listening;
        _recordingSeconds = 0;

        // Limpiar campos previos para nueva consulta
        _nombreController.clear();
        _montoController.clear();
        _etiquetaController.clear();
        _hasInvoice = false;
        _paymentMethod = 'digital';
      });
    }

    // 6. Iniciar contador de duración
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });

    try {
      print('🎤 Iniciando escucha del micrófono...');

      // Obtener locales disponibles y seleccionar español
      final locales = await _speechToText.locales();
      String? spanishLocale;

      // Buscar el mejor locale español disponible
      for (final locale in locales) {
        if (locale.localeId.startsWith('es-')) {
          spanishLocale = locale.localeId;
          print('✅ Usando locale español: $spanishLocale');
          break;
        }
      }

      // Si no encuentra español específico, intentar con el sistema
      if (spanishLocale == null) {
        print('⚠️ No se encontró locale español específico, usando locale del sistema');
      }

      // Configuración con locale español
      await _speechToText.listen(
        onResult: (res) {
          print('📝 Transcripción: ${res.recognizedWords} (final: ${res.finalResult})');
          if (mounted) {
            setState(() {
              _nombreController.text = res.recognizedWords;
            });

            // Cuando la transcripción es final, procesar automáticamente
            if (res.finalResult && res.recognizedWords.isNotEmpty && _isListening) {
              print('🔄 Transcripción final detectada, procesando...');
              _stopVoice();
            }
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        localeId: spanishLocale, // Usar español explícitamente
        onSoundLevelChange: (level) {
          if (level > 0.5) {
            print('🔊 Nivel: $level');
          }
        },
      );

      // Esperar para que el micrófono inicie
      await Future.delayed(const Duration(milliseconds: 500));

      // Verificar si el micrófono está realmente escuchando
      if (_speechToText.isListening) {
        print('✅ Micrófono iniciado correctamente');
      } else {
        print('❌ El micrófono no pudo iniciar');
        if (mounted) {
          setState(() {
            _isListening = false;
            _voiceState = VoiceState.error;
          });
          _recordingTimer?.cancel();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo iniciar el micrófono. Intenta de nuevo.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _voiceState = VoiceState.idle;
              });
            }
          });
        }
      }
    } catch (e) {
      print('❌ Error al iniciar micrófono: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _voiceState = VoiceState.error;
        });
        _recordingTimer?.cancel();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _voiceState = VoiceState.idle;
            });
          }
        });
      }
    }
  }

  void _stopVoice() async {
    // Evitar llamadas duplicadas
    if (!_isListening) return;

    print('🛑 _stopVoice() llamado');
    _isListening = false;

    await _speechToText.stop();
    HapticFeedback.mediumImpact();

    // Detener el contador de duración
    _recordingTimer?.cancel();

    setState(() {
      _voiceState = VoiceState.processing;
    });

    // Procesar transcripción con IA
    if (_nombreController.text.isNotEmpty) {
      print('🤖 Enviando a IA: "${_nombreController.text}"');
      await _procesarVozConIA();
    } else {
      // Si no hay transcripción, volver a idle
      setState(() => _voiceState = VoiceState.idle);
    }
  }

  Future<void> _procesarVozConIA() async {
    print('🤖 _procesarVozConIA() iniciado');
    setState(() => _isProcessingAI = true);

    try {
      print('🤖 Llamando API con: "${_nombreController.text}"');
      final sugerencia = await _movementController.procesarSugerenciaPorVoz(
        transcripcion: _nombreController.text,
        context: context,
      );
      print('🤖 Respuesta IA: $sugerencia');

      if (sugerencia != null && mounted) {
        setState(() {
          // Descripción limpia
          _nombreController.text =
              sugerencia['description'] ?? _nombreController.text;

          // Monto (extraído por IA)
          final amountStr = sugerencia['amount']?.toString() ?? '';
          if (amountStr.isNotEmpty && amountStr != '0') {
            _montoController.text = amountStr;
          }

          // Etiqueta sugerida
          final suggestedTag = sugerencia['suggested_tag'] ?? '';
          if (suggestedTag.isNotEmpty) {
            _etiquetaController.text = suggestedTag;
            _selectedTag = suggestedTag; // Sincronizar con chips
          }

          // Tipo (gasto/ingreso)
          _esGasto = sugerencia['type'] == 'expense';

          // Método de pago
          _paymentMethod = sugerencia['payment_method'] ?? 'digital';

          // Factura
          _hasInvoice = sugerencia['has_invoice'] ?? false;

          // Modo meta (detectar por etiqueta)
          _isGoalMode = _esEtiquetaMeta(_etiquetaController.text);

          // Estado de éxito
          _voiceState = VoiceState.success;
          _isProcessingAI = false;
        });

        // Volver a idle después de 1 segundo
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() => _voiceState = VoiceState.idle);
          }
        });
      } else {
        // Error: no se pudo procesar
        if (mounted) {
          setState(() {
            _voiceState = VoiceState.error;
            _isProcessingAI = false;
          });

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _voiceState = VoiceState.idle);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _voiceState = VoiceState.error;
          _isProcessingAI = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error procesando voz: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _voiceState = VoiceState.idle);
          }
        });
      }
    }
  }

  void _guardarMovimiento() async {
    if (_montoController.text.isEmpty) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();

    final cleanedValue = _montoController.text.replaceAll('.', '');
    double val = double.tryParse(cleanedValue) ?? 0.0;

    String finalTag = _etiquetaController.text.trim();

    // ============================================================
    // MODO META: Crear contribución en lugar de movimiento
    // ============================================================
    if (_isGoalMode && finalTag.isNotEmpty) {
      try {
        // Obtener el mapa de etiquetas → IDs de metas
        final goalTagToIdMap = await _movementController.getGoalTagToIdMap();

        // Buscar el ID de la meta correspondiente a esta etiqueta
        final goalId = goalTagToIdMap[finalTag];

        if (goalId == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se encontró la meta correspondiente'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // Crear la contribución
        final contributionsApi = GoalContributionsApi();
        await contributionsApi.createContribution(
          goalId: goalId,
          amount: val,
          description: _nombreController.text.isEmpty
              ? 'Abono a meta'
              : _nombreController.text,
        );

        // Limpiar cache de metas para reflejar el nuevo progreso
        SavingsGoalsApi.clearCache();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Abono guardado exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
          // Regresar al home actualizado
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar abono: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    // ============================================================
    // MODO NORMAL: Crear movimiento (gasto/ingreso)
    // ============================================================

    if (finalTag.isNotEmpty) {
      // Verificar si la etiqueta NO está en la lista actual
      final tagExists = _etiquetasUsuario
          .any((tag) => tag.toLowerCase() == finalTag.toLowerCase());

      if (!tagExists) {
        // Crear la etiqueta en el backend
        final createdTag = await _movementController.crearEtiqueta(
          finalTag,
          context,
        );

        if (createdTag != null) {
          finalTag = createdTag;
          // Agregar a la lista local para futuras referencias
          setState(() {
            _etiquetasUsuario.add(finalTag);
          });
        }
      }
    }

    // Guardar el movimiento con la etiqueta (existente o nueva)
    await _movementController.createMovement(
      type: _esGasto ? 'expense' : 'income',
      amount: val,
      description: _nombreController.text,
      tag: finalTag.isEmpty ? null : finalTag,
      paymentMethod: _paymentMethod,
      hasInvoice: _hasInvoice,
      context: context,
    );

    if (context.mounted) {
      // Regresar al home actualizado
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _abbreviationTimer?.cancel();
    _suggestionTimer?.cancel();
    _recordingTimer?.cancel();

    // Remover listeners antes de dispose
    _nombreController.removeListener(_onDescriptionOrAmountChanged);
    _montoController.removeListener(_onDescriptionOrAmountChanged);
    _etiquetaController.removeListener(_onTagTextChanged);

    _montoController.dispose();
    _nombreController.dispose();
    _etiquetaController.dispose();
    _montoFocusNode.dispose();
    super.dispose();
  }
}

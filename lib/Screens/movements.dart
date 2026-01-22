import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:intl/intl.dart';

import '../Widgets/common/text_widget.dart';
import '../Widgets/movements/campo_etiquetas.dart';
import '../Controllers/movement_controller.dart';
import '../Theme/Theme.dart';

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

  bool _esGasto = true;
  String _paymentMethod = 'digital';
  bool _isListening = false;
  bool _isGoalMode = false;
  bool _hasInvoice = false;
  List<String> _etiquetasUsuario = [];
  final SpeechToText _speechToText = SpeechToText();

  final Color _greenMyPocket = const Color(0xFF006B52);
  final Color _redExpense = const Color(0xFFEF5350);
  final Color _blueGoal = const Color(0xFF42A5F5);

  Color get _activeColor =>
      _isGoalMode ? _blueGoal : (_esGasto ? _redExpense : _greenMyPocket);

  @override
  void initState() {
    super.initState();
    _initLogic();
  }

  void _initLogic() async {
    await _speechToText.initialize();
    final tags = await _movementController.getAllEtiquetas();
    if (mounted) setState(() => _etiquetasUsuario = tags);

    if (widget.preSelectedTag != null) {
      _etiquetaController.text = widget.preSelectedTag!;
      _isGoalMode = true;
    }
    _montoController.addListener(_formatCurrency);
  }

  void _formatCurrency() {
    if (_montoController.text.isEmpty) return;

    final cursorPosition = _montoController.selection.baseOffset;
    final textLength = _montoController.text.length;

    if (cursorPosition != textLength) return;

    String value = _montoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return;
    String formatted = _currencyFormat.format(int.parse(value));
    _montoController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black26),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextWidget(
          text: _isGoalMode ? "NUEVO ABONO" : "REGISTRO",
          size: 13,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade400,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildMoneyInput(),
                  const SizedBox(height: 30),
                  _buildDescriptionInput(),
                  const SizedBox(height: 25),
                  if (!_isGoalMode) _buildTypeAndCategoryRow(),
                  const SizedBox(height: 20),
                  _buildInvoiceToggle(),
                  const SizedBox(height: 30),
                  _buildPaymentMethodInput(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildFooterActions(),
        ],
      ),
    );
  }

  Widget _buildMoneyInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        TextWidget(
          text: "\$ ",
          size: 85,
          color: _montoController.text.isEmpty
              ? Colors.grey.shade400
              : _activeColor,
          fontWeight: FontWeight.bold,
        ),
        IntrinsicWidth(
          child: TextField(
            controller: _montoController,
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cursorColor: _activeColor,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 85,
              fontWeight: FontWeight.w800,
              color: _activeColor,
              fontFamily: 'Poppins',
              letterSpacing: -2,
              height: 1.0,
            ),
            decoration: InputDecoration(
              hintText: "0",
              hintStyle: TextStyle(
                color: _montoController.text.isEmpty
                    ? Colors.grey.shade400
                    : _activeColor.withOpacity(0.3),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeAndCategoryRow() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _esGasto = true);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _esGasto
                              ? const Color(0xFFE57373)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: TextWidget(
                            text: "GASTO",
                            size: 13,
                            fontWeight: FontWeight.w800,
                            color: _esGasto ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _esGasto = false);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_esGasto
                              ? const Color(0xFF4DB6AC)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: TextWidget(
                            text: "INGRESO",
                            size: 13,
                            fontWeight: FontWeight.w800,
                            color: !_esGasto ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: SizedBox(
            height: 48,
            child: CampoEtiquetas(
              etiquetaController: _etiquetaController,
              etiquetasUsuario: _etiquetasUsuario,
              onEtiquetaSeleccionada: (tag) =>
                  setState(() => _etiquetaController.text = tag),
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 45),
      color: Colors.white,
      child: Row(
        children: [
          _buildMicButton(),
          const SizedBox(width: 18),
          Expanded(child: _buildSaveButton()),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onLongPress: _startVoice,
      onLongPressUp: _stopVoice,
      child: AvatarGlow(
        animate: _isListening,
        glowColor: _activeColor,
        duration: const Duration(milliseconds: 1500),
        repeat: true,
        curve: Curves.easeInOutSine,
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  _isListening ? _activeColor : Colors.black.withOpacity(0.05),
              width: _isListening ? 2 : 1,
            ),
            boxShadow: _isListening
                ? [
                    BoxShadow(
                      color: _activeColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : null,
          ),
          child: Icon(
            _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
            color: _isListening ? _activeColor : _activeColor.withOpacity(0.6),
            size: 28,
          ),
        ),
      ),
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

  void _startVoice() async {
    HapticFeedback.heavyImpact();
    setState(() => _isListening = true);
    await _speechToText.listen(
      onResult: (res) {
        if (res.finalResult) {
          _nombreController.text = res.recognizedWords;
        }
      },
    );
  }

  void _stopVoice() async {
    await _speechToText.stop();
    HapticFeedback.mediumImpact();
    setState(() => _isListening = false);
  }

  void _guardarMovimiento() async {
    if (_montoController.text.isEmpty) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();

    double val =
        double.tryParse(_montoController.text.replaceAll('.', '')) ?? 0.0;

    await _movementController.createMovement(
      type: _isGoalMode ? 'expense' : (_esGasto ? 'expense' : 'income'),
      amount: val,
      description: _nombreController.text,
      tag: _etiquetaController.text,
      paymentMethod: _paymentMethod,
      hasInvoice: _hasInvoice,
      context: context,
    );

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _nombreController.dispose();
    _etiquetaController.dispose();
    super.dispose();
  }
}

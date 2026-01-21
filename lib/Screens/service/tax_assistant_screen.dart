import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/button_custom.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/utils/tax_engine_2023.dart';
import 'package:MyPocket/utils/helpers.dart';
import 'package:MyPocket/api/tax_api.dart';
import 'package:MyPocket/Screens/service/tax_radar_screen.dart';

class TaxAssistantScreen extends StatefulWidget {
  const TaxAssistantScreen({super.key});

  @override
  State<TaxAssistantScreen> createState() => _TaxAssistantScreenState();
}

class _TaxAssistantScreenState extends State<TaxAssistantScreen> {
  final TaxApi _taxApi = TaxApi();

  bool _isLoading = false;
  bool _isAutoMode = true;

  // Variables Financieras
  double _totalIncome = 0;
  double _totalAssets = 0;
  double _deductions = 0;
  double _withholdings = 0;
  int _dependents = 0;

  // Resultados
  bool _isObligated = false;
  double _taxToPay = 0;
  String _statusMessage = "Listo";
  Color _statusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAutoData());
  }

  // --- LÓGICA DE NEGOCIO ---

  Future<void> _fetchAutoData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _taxApi.getTaxData();
      if (!mounted) return;

      final totalIncome = _safeParse(data['ingresos_totales']);
      final totalAssets = _safeParse(data['patrimonio_estimado']);
      final withholdings = _safeParse(data['retenciones']);
      final deductions =
          _safeParse(data['deduc_vivienda']) + _safeParse(data['deduc_salud']);

      final taxResult = _calculateTaxResult(
        totalIncome: totalIncome,
        totalAssets: totalAssets,
        withholdings: withholdings,
        deductions: deductions,
      );

      if (mounted) {
        setState(() {
          _isAutoMode = true;
          _totalIncome = totalIncome;
          _totalAssets = totalAssets;
          _withholdings = withholdings;
          _deductions = deductions;
          _isObligated = taxResult['isObligated'];
          _taxToPay = taxResult['taxToPay'];
          _statusMessage = taxResult['statusMessage'];
          _statusColor = taxResult['statusColor'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _calculateTaxResult({
    required double totalIncome,
    required double totalAssets,
    required double withholdings,
    required double deductions,
  }) {
    final check = TaxEngine2023.checkObligation(
      patrimonio: totalAssets,
      ingresos: totalIncome,
      tarjetas: 0,
      consumos: 0,
      consignaciones: 0,
    );

    final bool isObligated = check['obligado'];

    if (!isObligated) {
      return {
        'isObligated': false,
        'taxToPay': 0.0,
        'statusMessage': "No estás obligado",
        'statusColor': Colors.green,
      };
    }

    double mandatoryContribution = totalIncome * 0.08;
    final result = TaxEngine2023.calculateTax(
      ingresosTotales: totalIncome,
      ingresosNoConstitutivos: mandatoryContribution,
      deducVivienda: deductions,
      deducSaludPrep: 0,
      numeroDependientes: _dependents,
      aportesVoluntarios: 0,
      costosGastos: 0,
    );

    double netPay = (result['impuesto'] ?? 0) - withholdings;

    String statusMessage;
    Color statusColor;

    if (netPay < 0) {
      statusMessage = "Saldo a Favor";
      statusColor = Colors.green;
    } else if (netPay == 0) {
      statusMessage = "Declaras en Ceros";
      statusColor = Colors.blue;
    } else {
      statusMessage = "Impuesto Estimado";
      statusColor = Colors.red;
    }

    return {
      'isObligated': true,
      'taxToPay': netPay,
      'statusMessage': statusMessage,
      'statusColor': statusColor,
    };
  }

  void _switchToManual() {
    setState(() {
      _isAutoMode = false;
      _totalIncome = 0;
      _totalAssets = 0;
      _deductions = 0;
      _withholdings = 0;
      _dependents = 0;
      _recalculate();
    });
  }

  void _recalculate() {
    final check = TaxEngine2023.checkObligation(
      patrimonio: _totalAssets,
      ingresos: _totalIncome,
      tarjetas: 0,
      consumos: 0,
      consignaciones: 0,
    );

    _isObligated = check['obligado'];

    if (!_isObligated) {
      _statusMessage = "No estás obligado";
      _statusColor = Colors.green;
      _taxToPay = 0;
      return;
    }

    double mandatoryContribution = _totalIncome * 0.08;
    final result = TaxEngine2023.calculateTax(
      ingresosTotales: _totalIncome,
      ingresosNoConstitutivos: mandatoryContribution,
      deducVivienda: _deductions,
      deducSaludPrep: 0,
      numeroDependientes: _dependents,
      aportesVoluntarios: 0,
      costosGastos: 0,
    );

    double netPay = (result['impuesto'] ?? 0) - _withholdings;
    _taxToPay = netPay;

    if (netPay < 0) {
      _statusMessage = "Saldo a Favor";
      _statusColor = Colors.green;
    } else if (netPay == 0) {
      _statusMessage = "Declaras en Ceros";
      _statusColor = Colors.blue;
    } else {
      _statusMessage = "Impuesto Estimado";
      _statusColor = Colors.red;
    }
  }

  double _safeParse(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0.0;
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const TextWidget(
            text: "Asistente Tributario 2025",
            color: Colors.black,
            size: 18,
            fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.bar_chart_rounded,
                  color: AppTheme.primaryColor, size: 28),
              tooltip: "Radar 2026",
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TaxRadarScreen())),
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. Selector
                  _buildModeTabs(),
                  const SizedBox(height: 25),
                  // 2. Resultado
                  _buildResultCard(),
                  const SizedBox(height: 30),
                  // 3. Formulario
                  _buildFormSection(),
                  const SizedBox(height: 30),
                  ButtonCustom(
                      text: "Finalizar", onTap: () => Navigator.pop(context)),
                ],
              ),
            ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
            text: _isAutoMode ? "Datos del Sistema" : "Simulador Manual",
            size: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(
              child: _buildDataCard(
                  "Ingresos", _totalIncome, Icons.attach_money, Colors.green,
                  (v) {
            setState(() {
              _totalIncome = v;
              _recalculate();
            });
          })),
          const SizedBox(width: 15),
          Expanded(
              child: _buildDataCard(
                  "Patrimonio", _totalAssets, Icons.home_work, Colors.blue,
                  (v) {
            setState(() {
              _totalAssets = v;
              _recalculate();
            });
          })),
        ]),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(
              child: _buildDataCard(
                  "Deducciones", _deductions, Icons.receipt_long, Colors.orange,
                  (v) {
            setState(() {
              _deductions = v;
              _recalculate();
            });
          })),
          const SizedBox(width: 15),
          Expanded(
              child: _buildDataCard("Retenciones", _withholdings,
                  Icons.verified_user, Colors.purple, (v) {
            setState(() {
              _withholdings = v;
              _recalculate();
            });
          })),
        ]),
        const SizedBox(height: 15),
        _buildDependentsCard(),
        const SizedBox(height: 15),
        _buildDisclaimer(),
      ],
    );
  }

  // --- COMPONENTS ---

  Widget _buildModeTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
      child: Row(children: [
        _tabItem("Automático", _isAutoMode, _fetchAutoData),
        _tabItem("Manual", !_isAutoMode, _switchToManual),
      ]),
    );
  }

  Widget _tabItem(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20)),
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.black : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _statusColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: _statusColor.withOpacity(0.1), blurRadius: 20)
          ]),
      child: Column(children: [
        Icon(_isObligated ? Icons.gavel_rounded : Icons.check_circle_outline,
            size: 40, color: _statusColor),
        const SizedBox(height: 10),
        Text(_statusMessage,
            style: TextStyle(
                color: _statusColor,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        if (_isObligated)
          Text(formatCurrency(_taxToPay.abs()),
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: _statusColor))
        else
          const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text("¡Estás libre!",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey))),
      ]),
    );
  }

  Widget _buildDataCard(String label, double value, IconData icon, Color color,
      Function(double) onChanged) {
    return GestureDetector(
      onTap: () => _showEditModal(label, value, onChanged),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          Text(formatCurrency(value),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
      ),
    );
  }

  Widget _buildDependentsCard() {
    return GestureDetector(
      onTap: () => _showDependentsModal(),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.people_outline, color: Colors.pink, size: 20)),
          const SizedBox(height: 12),
          const Text("Dependientes",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          Text("$_dependents persona${_dependents != 1 ? 's' : ''}",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber[200]!)),
      child: Row(children: [
        Icon(Icons.info_outline, size: 18, color: Colors.orange[800]),
        const SizedBox(width: 10),
        Expanded(
            child: Text(
                "Nota: El patrimonio es estimado. Edítalo para incluir bienes externos. Deducción de 72 UVT por dependiente.",
                style: TextStyle(color: Colors.brown[800], fontSize: 11)))
      ]),
    );
  }

  void _showEditModal(String title, double current, Function(double) onSave) {
    final ctrl = TextEditingController(
        text: current == 0 ? "" : current.toStringAsFixed(0));
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                  top: 25,
                  left: 20,
                  right: 20),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text("Editar $title",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(
                    controller: ctrl,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor),
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.attach_money,
                            color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none))),
                const SizedBox(height: 25),
                ButtonCustom(
                    text: "Guardar",
                    onTap: () {
                      onSave(double.tryParse(ctrl.text) ?? 0);
                      Navigator.pop(ctx);
                    })
              ]),
            ));
  }

  void _showDependentsModal() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text("Número de Dependientes",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text("Hasta 4 dependientes (72 UVT cada uno)",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _dependents = index;
                            _recalculate();
                          });
                          Navigator.pop(ctx);
                        },
                        child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: _dependents == index
                                    ? AppTheme.primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(25)),
                            child: Center(
                                child: Text(
                              index.toString(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _dependents == index
                                      ? Colors.white
                                      : Colors.black),
                            ))),
                      );
                    })),
              ]),
            ));
  }
}

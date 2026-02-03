import 'package:flutter/material.dart';
import 'package:MyPocket/api/tax_api.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/button_custom.dart';
import 'package:MyPocket/utils/tax_engine_2023.dart';
import 'package:MyPocket/utils/helpers.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  // --- DEPENDENCIAS ---
  final TaxApi _api = TaxApi();

  // --- ESTADO GLOBAL ---
  bool _loading = true;
  bool _isAutoMode = true;

  // --- DATOS SIMULADOR ---
  double _totalIncome = 0;
  double _totalAssets = 0;
  double _deductions = 0;
  double _withholdings = 0;
  int _dependents = 0;
  bool _isObligated = false;
  double _taxToPay = 0;
  String _simStatusMsg = "Calculando...";
  Color _simStatusColor = Colors.grey;

  // --- DATOS RADAR ---
  List<dynamic> _radarAlerts = [];
  String _radarMsg = "Cargando radar...";

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final results = await Future.wait([
        _api.getTaxData(),
        _api.getTaxAlerts(),
      ]);

      if (!mounted) return;

      final taxData = results[0];
      final radarData = results[1];

      double income = _safeParse(taxData['ingresos_totales']);
      double assets = _safeParse(taxData['patrimonio_estimado']);
      double ret = _safeParse(taxData['retenciones']);
      double ded = _safeParse(taxData['deduc_vivienda']) +
          _safeParse(taxData['deduc_salud']);

      List<dynamic> alerts = radarData['data'] ?? [];
      String rMsg = radarData['summary_message'] ?? "";

      setState(() {
        _isAutoMode = true;
        _totalIncome = income;
        _totalAssets = assets;
        _withholdings = ret;
        _deductions = ded;
        _radarAlerts = alerts;
        _radarMsg = rMsg;
        _calculateSimulatorLocal();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchAutoData() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getTaxData();
      if (!mounted) return;

      setState(() {
        _isAutoMode = true;
        _totalIncome = _safeParse(data['ingresos_totales']);
        _totalAssets = _safeParse(data['patrimonio_estimado']);
        _withholdings = _safeParse(data['retenciones']);
        _deductions = _safeParse(data['deduc_vivienda']) +
            _safeParse(data['deduc_salud']);
        _calculateSimulatorLocal();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- MOTOR DE CÁLCULO LOCAL ---
  void _calculateSimulatorLocal() {
    final check = TaxEngine2023.checkObligation(
      patrimonio: _totalAssets,
      ingresos: _totalIncome,
      tarjetas: 0,
      consumos: 0,
      consignaciones: 0,
    );
    bool obligated = check['obligado'];

    double mandatory = _totalIncome * 0.08;
    final result = TaxEngine2023.calculateTax(
      ingresosTotales: _totalIncome,
      ingresosNoConstitutivos: mandatory,
      deducVivienda: _deductions,
      deducSaludPrep: 0,
      numeroDependientes: _dependents,
      aportesVoluntarios: 0,
      costosGastos: 0,
    );

    double gross = result['impuesto'] ?? 0;
    double net = gross - _withholdings;

    String msg;
    Color col;

    if (!obligated) {
      msg = "No estás obligado";
      col = Colors.green;
      net = 0;
    } else if (net < 0) {
      msg = "Saldo a Favor";
      col = Colors.green;
    } else if (net == 0) {
      msg = "Declaras en Ceros";
      col = Colors.blue;
    } else {
      msg = "Impuesto Estimado";
      col = Colors.red;
    }

    _isObligated = obligated;
    _taxToPay = net;
    _simStatusMsg = msg;
    _simStatusColor = col;
  }

  void _recalculate() => setState(() => _calculateSimulatorLocal());

  void _switchToManual() {
    setState(() {
      _isAutoMode = false;
      _totalIncome = 0;
      _totalAssets = 0;
      _deductions = 0;
      _withholdings = 0;
      _dependents = 0;
      _calculateSimulatorLocal();
    });
  }

  double _safeParse(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0.0;
  }

  // ═══════════════════════════════════════════
  //  UI UNIFICADA
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Gestión de Impuestos",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Baloo2',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                // ==========================================
                // PARTE 1: SIMULADOR DE RENTA
                // ==========================================
                _sectionTitle("Simulador de Renta"),
                _buildSimResultCard(),
                const SizedBox(height: 20),

                _buildModeTabs(),
                const SizedBox(height: 20),

                // Data Cards
                Row(children: [
                  Expanded(
                      child: _buildDataCard(
                          "Ingresos", _totalIncome, Icons.attach_money,
                          Colors.green, (v) {
                    setState(() {
                      _totalIncome = v;
                      _recalculate();
                    });
                  })),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildDataCard(
                          "Patrimonio", _totalAssets, Icons.home_work,
                          Colors.blue, (v) {
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
                          "Deducciones", _deductions, Icons.receipt_long,
                          Colors.orange, (v) {
                    setState(() {
                      _deductions = v;
                      _recalculate();
                    });
                  })),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildDataCard(
                          "Retenciones", _withholdings, Icons.verified_user,
                          Colors.purple, (v) {
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

                const SizedBox(height: 30),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 30),

                // ==========================================
                // PARTE 2: RADAR DE ALERTAS
                // ==========================================
                _sectionTitle("Radar de Topes 2026"),
                _buildRadarHeader(),
                const SizedBox(height: 20),

                if (_radarAlerts.isEmpty)
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text("Sin alertas activas",
                        style: TextStyle(color: Colors.grey[500])),
                  ))
                else
                  ..._radarAlerts.map((alert) => _buildAlertBar(alert)),

                const SizedBox(height: 80),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ═══════════════════════════════════════════

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey[700])),
    );
  }

  // --- SIMULADOR ---

  Widget _buildSimResultCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _simStatusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: _simStatusColor.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(children: [
        Icon(
            _isObligated
                ? Icons.gavel_rounded
                : Icons.check_circle_outline,
            size: 40,
            color: _simStatusColor),
        const SizedBox(height: 10),
        Text(_simStatusMsg,
            style: TextStyle(
                color: _simStatusColor,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        if (_isObligated) ...[
          const SizedBox(height: 5),
          Text(formatCurrency(_taxToPay.abs()),
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _simStatusColor,
                  letterSpacing: -1))
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text("¡Estás libre!",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
          ),
      ]),
    );
  }

  Widget _buildModeTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: active
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                : [],
          ),
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.black : Colors.grey,
                  fontSize: 13)),
        ),
      ),
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
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            const BoxShadow(
                color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
          ],
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          Text(formatCurrency(value),
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildDependentsCard() {
    return GestureDetector(
      onTap: _showDependentsModal,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            const BoxShadow(
                color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
          ],
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.people_outline, color: Colors.pink, size: 22),
          const SizedBox(height: 10),
          const Text("Dependientes",
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          Text("$_dependents persona${_dependents != 1 ? 's' : ''}",
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
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

  // --- RADAR ---

  Widget _buildRadarHeader() {
    Color c1 = Colors.green, c2 = Colors.greenAccent;
    IconData icon = Icons.security;

    if (_radarMsg.contains("Atención") || _radarMsg.contains("superado")) {
      c1 = Colors.red;
      c2 = Colors.redAccent;
      icon = Icons.warning_amber_rounded;
    } else if (_radarMsg.contains("Cuidado") ||
        _radarMsg.contains("cerca")) {
      c1 = Colors.orange;
      c2 = Colors.amber;
      icon = Icons.priority_high_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [c1, c2]),
        boxShadow: [
          BoxShadow(
              color: c1.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white)),
        const SizedBox(width: 15),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text("Diagnóstico Topes 2026",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              Text(_radarMsg,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ]))
      ]),
    );
  }

  Widget _buildAlertBar(Map<String, dynamic> alert) {
    double pct = double.parse(alert['percentage'].toString());
    double cur = double.parse(alert['current_amount'].toString());
    double lim = double.parse(alert['limit_amount'].toString());
    String status = alert['status'];
    Color c = status == 'exceeded'
        ? Colors.red
        : (status == 'warning' ? Colors.orange : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: Text(alert['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14))),
          Text("${pct.clamp(0, 999)}%",
              style: TextStyle(color: c, fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(c),
              minHeight: 8),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Llevas: ${formatCurrency(cur)}",
              style: TextStyle(
                  fontSize: 12,
                  color: cur > lim ? Colors.red : Colors.grey)),
          Text("Límite: ${formatCurrency(lim)}",
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
        ])
      ]),
    );
  }

  // ═══════════════════════════════════════════
  //  MODALS
  // ═══════════════════════════════════════════

  void _showEditModal(
      String title, double current, Function(double) onSave) {
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
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(
                    controller: ctrl,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontSize: 26,
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
                    text: "Actualizar",
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
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text("Hasta 4 dependientes (72 UVT cada uno)",
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 12)),
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

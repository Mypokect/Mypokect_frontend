import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/utils/helpers.dart';
import 'package:MyPocket/utils/tax_engine_2023.dart';

class TaxMonitorScreen extends StatefulWidget {
  final double ingresos;
  final double patrimonio;
  final double tarjetas;
  final double consumos;
  final double consignaciones;

  const TaxMonitorScreen({
    super.key,
    required this.ingresos,
    required this.patrimonio,
    required this.tarjetas,
    required this.consumos,
    required this.consignaciones,
  });

  @override
  State<TaxMonitorScreen> createState() => _TaxMonitorScreenState();
}

class _TaxMonitorScreenState extends State<TaxMonitorScreen> {
  bool _loading = true;
  String _diagnosticMsg = "";
  List<Map<String, dynamic>> _alerts = [];

  // Topes UVT 2025 (según Art. 592 E.T.)
  static const double _uvt = TaxEngine2023.UVT;
  static const double _topeIngresos = 1400 * _uvt;      // Ingresos brutos
  static const double _topePatrimonio = 4500 * _uvt;    // Patrimonio bruto
  static const double _topeTarjetas = 1400 * _uvt;      // Compras tarjeta crédito
  static const double _topeConsumos = 1400 * _uvt;      // Consumos totales
  static const double _topeConsignaciones = 1400 * _uvt; // Consignaciones

  @override
  void initState() {
    super.initState();
    _calculateAlerts();
  }

  void _calculateAlerts() {
    setState(() => _loading = true);

    _alerts = [];

    // 1. Ingresos Brutos
    _addAlert(
      title: 'Ingresos Brutos',
      current: widget.ingresos,
      limit: _topeIngresos,
    );

    // 2. Patrimonio Bruto
    _addAlert(
      title: 'Patrimonio Bruto',
      current: widget.patrimonio,
      limit: _topePatrimonio,
    );

    // 3. Compras con Tarjeta de Crédito
    _addAlert(
      title: 'Compras con Tarjeta de Crédito',
      current: widget.tarjetas,
      limit: _topeTarjetas,
    );

    // 4. Consumos Totales
    _addAlert(
      title: 'Consumos Totales',
      current: widget.consumos,
      limit: _topeConsumos,
    );

    // 5. Consignaciones Bancarias
    _addAlert(
      title: 'Consignaciones Bancarias',
      current: widget.consignaciones,
      limit: _topeConsignaciones,
    );

    // Generar mensaje de diagnóstico
    bool hayExcedido = _alerts.any((a) => a['status'] == 'exceeded');
    bool hayWarning = _alerts.any((a) => a['status'] == 'warning');

    if (hayExcedido) {
      _diagnosticMsg = "⚠️ ¡Atención! Has superado uno o más topes";
    } else if (hayWarning) {
      _diagnosticMsg = "🔔 Cuidado: Estás cerca de los límites";
    } else {
      _diagnosticMsg = "✅ Todo en orden. Estás dentro de los límites";
    }

    setState(() => _loading = false);
  }

  void _addAlert({required String title, required double current, required double limit}) {
    double pct = limit > 0 ? (current / limit) * 100 : 0;
    String status = pct >= 100 ? 'exceeded' : (pct >= 80 ? 'warning' : 'ok');

    _alerts.add({
      'title': title,
      'current_amount': current,
      'limit_amount': limit,
      'percentage': pct,
      'status': status,
    });
  }

  Color _diagnosticColor() {
    if (_diagnosticMsg.contains("Atención") ||
        _diagnosticMsg.contains("superado")) {
      return Colors.red;
    } else if (_diagnosticMsg.contains("Cuidado") ||
        _diagnosticMsg.contains("cerca")) {
      return Colors.orange;
    }
    return const Color(0xFF43A047);
  }

  IconData _diagnosticIcon() {
    if (_diagnosticMsg.contains("Atención") ||
        _diagnosticMsg.contains("superado")) {
      return Icons.warning_amber_rounded;
    } else if (_diagnosticMsg.contains("Cuidado") ||
        _diagnosticMsg.contains("cerca")) {
      return Icons.priority_high_rounded;
    }
    return Icons.verified_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Monitor Fiscal",
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDiagnosticCard(),
                const SizedBox(height: 30),
                Text("Monitoreo de Topes",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey[700])),
                const SizedBox(height: 15),
                if (_alerts.isEmpty)
                  _buildEmptyState()
                else
                  ..._alerts.map((alert) => _buildAlertCard(alert)),
                const SizedBox(height: 20),
                _buildDisclaimer(),
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _buildDiagnosticCard() {
    final color = _diagnosticColor();
    final icon = _diagnosticIcon();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 40),
        const SizedBox(height: 12),
        const Text("DIAGNÓSTICO",
            style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text(
          _diagnosticMsg,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
        ],
      ),
      child: Column(children: [
        Icon(Icons.analytics_outlined, size: 50, color: Colors.grey[300]),
        const SizedBox(height: 15),
        Text("Sin datos de topes disponibles",
            style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        const SizedBox(height: 8),
        Text("Registra más movimientos para ver tu progreso",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ]),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final double pct =
        double.tryParse(alert['percentage'].toString()) ?? 0;
    final double current =
        double.tryParse(alert['current_amount'].toString()) ?? 0;
    final double limit =
        double.tryParse(alert['limit_amount'].toString()) ?? 0;
    final String status = alert['status'] ?? 'ok';
    final String title = alert['title'] ?? '';

    final Color barColor = status == 'exceeded'
        ? Colors.red
        : (status == 'warning' ? Colors.orange : const Color(0xFF43A047));

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: barColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${pct.clamp(0, 999).toStringAsFixed(0)}%",
              style: TextStyle(
                  color: barColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(barColor),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Acumulado",
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            const SizedBox(height: 2),
            Text(
              formatCurrency(current),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: status == 'exceeded' ? Colors.red : Colors.black87),
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text("Límite",
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            const SizedBox(height: 2),
            Text(
              formatCurrency(limit),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blueGrey),
            ),
          ]),
        ]),
        if (status == 'exceeded')
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "¡Superaste este tope! Estarás obligado a declarar.",
                    style: TextStyle(color: Colors.red[700], fontSize: 11),
                  ),
                ),
              ]),
            ),
          )
        else if (status == 'warning')
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Estás cerca del límite. Te faltan ${formatCurrency(limit - current)}",
                    style: TextStyle(color: Colors.orange[800], fontSize: 11),
                  ),
                ),
              ]),
            ),
          ),
      ]),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, size: 18, color: Colors.orange[800]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Los topes se calculan según la UVT 2025 (\$49.799). Si superas cualquiera de estos límites durante el año, estarás obligado a presentar declaración de renta.",
            style: TextStyle(color: Colors.brown[700], fontSize: 11),
          ),
        ),
      ]),
    );
  }
}

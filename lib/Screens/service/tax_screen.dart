import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/utils/helpers.dart';
import 'package:MyPocket/utils/tax_engine_2023.dart';
import 'package:MyPocket/api/tax_api.dart';
import 'package:MyPocket/Screens/service/tax_monitor_screen.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  final TaxApi _api = TaxApi();

  bool _loading = true;

  // Valores editables
  double _ingresos = 0;
  double _patrimonio = 0;
  double _deducciones = 0;
  double _retenciones = 0;
  int _dependientes = 0;

  // Resultado
  bool _isObligado = false;
  double _impuestoEstimado = 0;
  String _statusMsg = "";
  Color _statusColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _fetchAutoData();
  }

  Future<void> _fetchAutoData() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getTaxData();
      if (!mounted) return;

      setState(() {
        _ingresos = _safeParse(data['ingresos_totales']);
        _patrimonio = _safeParse(data['patrimonio_estimado']);
        _deducciones = _safeParse(data['deducciones']);
        _retenciones = _safeParse(data['retenciones']);
        _dependientes = (data['dependientes'] as int?) ?? 0;
        _loading = false;
      });
      _recalculate();
    } catch (e) {
      print('Error fetching tax data: $e');
      if (mounted) {
        setState(() => _loading = false);
        _recalculate();
      }
    }
  }

  double _safeParse(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  void _recalculate() {
    final obligation = TaxEngine2023.checkObligation(
      patrimonio: _patrimonio,
      ingresos: _ingresos,
      tarjetas: 0,
      consumos: 0,
      consignaciones: _ingresos,
    );

    _isObligado = obligation['obligado'] as bool;

    final result = TaxEngine2023.calculateTax(
      ingresosTotales: _ingresos,
      ingresosNoConstitutivos: 0,
      deducVivienda: _deducciones * 0.5,
      deducSaludPrep: _deducciones * 0.5,
      numeroDependientes: _dependientes,
      aportesVoluntarios: 0,
      costosGastos: 0,
    );

    double impuestoBruto = result['impuesto'] ?? 0;
    _impuestoEstimado = (impuestoBruto - _retenciones).clamp(0, double.infinity);

    if (_isObligado) {
      if (_impuestoEstimado > 0) {
        _statusMsg = "Impuesto Estimado";
        _statusColor = Colors.red;
      } else {
        _statusMsg = "Declaras en Ceros";
        _statusColor = Colors.blue;
      }
    } else {
      _statusMsg = "No estás obligado";
      _statusColor = const Color(0xFF43A047);
    }

    setState(() {});
  }


  void _showEditModal(String title, double currentValue, Color iconColor, Function(double) onSave) {
    final controller = TextEditingController(
      text: currentValue > 0 ? currentValue.toStringAsFixed(0) : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 25,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Editar $title",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money, color: iconColor),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: iconColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(controller.text) ?? 0;
                  onSave(val);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Actualizar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDependentsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Número de Dependientes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Máximo 4 dependientes con beneficio fiscal",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: List.generate(5, (i) {
                final isSelected = _dependientes == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _dependientes = i);
                    _recalculate();
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        "$i",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Mi Situación Fiscal",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                // Sección título
                _buildSectionTitle("Simulador de Renta"),

                // Resultado principal
                _buildResultCard(),
                const SizedBox(height: 20),

                // Data cards con colores
                Row(
                  children: [
                    Expanded(
                      child: _buildDataCard(
                        "Ingresos",
                        _ingresos,
                        Icons.attach_money,
                        Colors.green,
                        () => _showEditModal("Ingresos", _ingresos, Colors.green, (v) {
                          setState(() => _ingresos = v);
                          _recalculate();
                        }),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildDataCard(
                        "Patrimonio",
                        _patrimonio,
                        Icons.home_work,
                        Colors.blue,
                        () => _showEditModal("Patrimonio", _patrimonio, Colors.blue, (v) {
                          setState(() => _patrimonio = v);
                          _recalculate();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildDataCard(
                        "Deducciones",
                        _deducciones,
                        Icons.receipt_long,
                        Colors.orange,
                        () => _showEditModal("Deducciones", _deducciones, Colors.orange, (v) {
                          setState(() => _deducciones = v);
                          _recalculate();
                        }),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildDataCard(
                        "Retenciones",
                        _retenciones,
                        Icons.verified_user,
                        Colors.purple,
                        () => _showEditModal("Retenciones", _retenciones, Colors.purple, (v) {
                          setState(() => _retenciones = v);
                          _recalculate();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Dependientes
                _buildDependentsCard(),

                const SizedBox(height: 30),
                const Divider(thickness: 1.5, color: Colors.black12),
                const SizedBox(height: 20),

                // CTA al Monitor Fiscal
                _buildSectionTitle("Radar de Topes"),
                _buildMonitorCTA(),

                const SizedBox(height: 25),
                _buildDisclaimer(),
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _isObligado ? Icons.gavel : Icons.check_circle,
            size: 40,
            color: _statusColor,
          ),
          const SizedBox(height: 10),
          Text(
            _statusMsg,
            style: TextStyle(
              color: _statusColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_isObligado) ...[
            const SizedBox(height: 5),
            Text(
              formatCurrency(_impuestoEstimado.abs()),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: _statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataCard(String label, double value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22),
                Icon(Icons.edit, color: Colors.grey[400], size: 14),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              formatCurrency(value),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.family_restroom, color: Colors.teal, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dependientes",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "Deducción: ${formatCurrency(_dependientes * 72 * TaxEngine2023.UVT)}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$_dependientes",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitorCTA() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaxMonitorScreen(
              ingresos: _ingresos,
              patrimonio: _patrimonio,
              tarjetas: _ingresos * 0.3, // Estimación gastos tarjeta
              consumos: _ingresos * 0.5, // Estimación consumos
              consignaciones: _ingresos, // Consignaciones ≈ ingresos
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.amber],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Monitor Fiscal 2026",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ver progreso hacia los topes de declaración",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Este cálculo es estimado basado en la UVT 2025 (\$49.799). Para un cálculo oficial, consulta con un contador.",
              style: TextStyle(color: Colors.blue[800], fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

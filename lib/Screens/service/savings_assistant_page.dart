import 'package:flutter/material.dart';
import '../../api/savings_api.dart'; // Tu servicio API existente
import '../../Theme/Theme.dart';
import '../../Widgets/TextWidget.dart';
import '../../Widgets/ButtonCustom.dart';

class AsistenteAhorroPage extends StatefulWidget {
  const AsistenteAhorroPage({super.key});

  @override
  State<AsistenteAhorroPage> createState() => _AsistenteAhorroPageState();
}

class _AsistenteAhorroPageState extends State<AsistenteAhorroPage> {
  final SavingsApi _api = SavingsApi();
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  
  // Control para ver mensual o semanal
  bool _isMonthly = true; 

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  void _fetchAnalysis() async {
    try {
      final result = await _api.getAnalysis();
      if (mounted) setState(() { _data = result; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Textwidget(text: "Plan de Ahorro Inteligente", color: Colors.black, size: 17, fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
        : _data == null 
            ? const Center(child: Text("No hay datos suficientes"))
            : _buildContent(),
    );
  }

  Widget _buildContent() {
    final math = _data!['math_data'];
    final ai = _data!['ai_insight'];

    // Determinar valores según switch mensual/semanal
    double ahorroSugerido = _isMonthly 
        ? double.parse(math['ahorro_mensual_sugerido'].toString()) 
        : double.parse(math['ahorro_semanal_sugerido'].toString());

    // Color del tema según IA
    Color themeColor = ai['color'] == 'red' ? Colors.red 
        : ai['color'] == 'orange' ? Colors.orange 
        : const Color(0xFF00C853); // Verde bonito

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // 1. SELECTOR MENSUAL / SEMANAL
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25)
            ),
            child: Row(
              children: [
                _buildTab("Mensual", _isMonthly, () => setState(() => _isMonthly = true)),
                _buildTab("Semanal", !_isMonthly, () => setState(() => _isMonthly = false)),
              ],
            ),
          ),
          
          const SizedBox(height: 25),

          // 2. TARJETA DE META DE AHORRO (BIG NUMBER)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]
            ),
            child: Column(
              children: [
                Text("Tu Capacidad de Ahorro", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 10),
                Text(
                  _fmt(ahorroSugerido), 
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: themeColor)
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    _isMonthly ? "Meta para este mes" : "Meta por semana",
                    style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12)
                  ),
                ),
                const SizedBox(height: 25),
                // BARRA DE PROGRESO (GASTOS VS INGRESOS)
                _buildProgressBar(math['ingresos'], math['gastos'], themeColor),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 3. TARJETA DEL COACH (IA)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ai['titulo'] ?? "Análisis", 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ai['mensaje'] ?? "...",
                  style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 14),
                ),
                if(ai['alerta'] == true) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Expanded(child: Text("Tus gastos están peligrosamente altos.", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),

          const SizedBox(height: 20),
          
          // 4. DATOS CRUDOS (DESGLOSE)
          _buildInfoRow("Ingresos reales", math['ingresos']),
          _buildInfoRow("Gastos reales", math['gastos']),
          
          const SizedBox(height: 30),
          Buttoncustom(text: "Volver", onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildTab(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : []
          ),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isActive ? Colors.black : Colors.grey)
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(dynamic ing, dynamic gas, Color color) {
    double ingresos = double.parse(ing.toString());
    double gastos = double.parse(gas.toString());
    double porcentaje = (ingresos == 0) ? 0 : (gastos / ingresos);
    if(porcentaje > 1) porcentaje = 1; // Tope visual

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Nivel de Gasto", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text("${(porcentaje * 100).toStringAsFixed(0)}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(5))),
            FractionallySizedBox(
              widthFactor: porcentaje,
              child: Container(height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(_fmt(value), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _fmt(dynamic amount) {
    double val = double.parse(amount.toString());
    return "\$ ${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}";
  }
}
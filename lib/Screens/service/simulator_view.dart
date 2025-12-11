import 'package:flutter/material.dart';
import '../../Theme/Theme.dart';
import '../../Widgets/ButtonCustom.dart';
import '../../Widgets/TextWidget.dart';
import '../../utils/tax_engine_2023.dart';
import '../../api/tax_api.dart';

class ImpuestoRentaPersonalPage extends StatefulWidget {
  const ImpuestoRentaPersonalPage({super.key});

  @override
  State<ImpuestoRentaPersonalPage> createState() => _ImpuestoRentaState();
}

class _ImpuestoRentaState extends State<ImpuestoRentaPersonalPage> {
  final TaxApi _taxApi = TaxApi();
  bool _isLoading = false;
  
  // Control de Modo: true = Automático, false = Manual
  bool _isAutoMode = true; 

  // --- DATOS FINANCIEROS ---
  double _ingresos = 0;
  double _patrimonio = 0;
  double _deducciones = 0;
  double _retenciones = 0;

  // --- RESULTADOS ---
  bool _obligado = false;
  double _impuestoPagar = 0;
  String _mensajeEstado = "---";
  Color _colorEstado = Colors.grey;

  @override
  void initState() {
    super.initState();
    // Esperamos un momento para que se construya el widget antes de cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAutoData();
    });
  }

  // --- 1. MODO AUTOMÁTICO (Traer de Laravel) ---
  void _loadAutoData() async {
    // 1. Actualizamos UI inmediatamente
    setState(() {
      _isLoading = true;
      _isAutoMode = true; 
    });

    try {
      final data = await _taxApi.getTaxData();
      print("Datos recibidos del Backend: $data"); // DEBUG: Mira la consola

      if (mounted) {
        setState(() {
          // 2. Parseo Seguro (Evita que se rompa si llega null o string)
          _ingresos = _safeParse(data['ingresos_totales']);
          _patrimonio = _safeParse(data['patrimonio_estimado']);
          _retenciones = _safeParse(data['retenciones']);
          
          double viv = _safeParse(data['deduc_vivienda']);
          double sal = _safeParse(data['deduc_salud']);
          _deducciones = viv + sal;
          
          _recalcular(); // Ejecutar matemáticas
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error cargando datos: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudieron cargar datos automáticos: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- 2. MODO MANUAL (Limpiar todo) ---
  void _switchToManual() {
    setState(() {
      _isAutoMode = false;
      // Opcional: ¿Quieres borrar los datos o dejarlos para que el usuario edite?
      // Si quieres borrar todo ponlos en 0. Si quieres editar, comenta estas líneas:
      _ingresos = 0;
      _patrimonio = 0;
      _deducciones = 0;
      _retenciones = 0;
      
      _recalcular();
    });
  }

  // --- HERRAMIENTA DE PARSEO SEGURO ---
  double _safeParse(dynamic value) {
    if (value == null) return 0.0;
    try {
      return double.parse(value.toString().replaceAll(',', ''));
    } catch (e) {
      return 0.0;
    }
  }

  // --- MOTOR DE CÁLCULO ---
  void _recalcular() {
    // A. Verificar si declara
    final check = TaxEngine2023.checkObligation(
      patrimonio: _patrimonio,
      ingresos: _ingresos,
      tarjetas: 0, 
      consumos: 0, 
      consignaciones: 0,
    );

    _obligado = check['obligado'];

    if (!_obligado) {
      _mensajeEstado = "No estás obligado";
      _colorEstado = Colors.green;
      _impuestoPagar = 0;
      return;
    }

    // B. Calcular Impuesto
    double aportesLey = _ingresos * 0.08; 

    final result = TaxEngine2023.calculateTax(
      ingresosTotales: _ingresos,
      ingresosNoConstitutivos: aportesLey,
      deducVivienda: _deducciones, 
      deducSaludPrep: 0,
      deducDependientes: 0, 
      aportesVoluntarios: 0,
      costosGastos: 0,
    );

    double impuestoGenerado = result['impuesto'] ?? 0;
    double finalPagar = impuestoGenerado - _retenciones;
    
    _impuestoPagar = finalPagar;

    if (finalPagar < 0) {
      _mensajeEstado = "Saldo a Favor";
      _colorEstado = Colors.green;
    } else if (finalPagar == 0) {
      _mensajeEstado = "Declaras en Ceros";
      _colorEstado = Colors.blue;
    } else {
      _mensajeEstado = "Impuesto Estimado";
      _colorEstado = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Textwidget(text: "Asistente Tributario", color: Colors.black, size: 18, fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. SELECTOR DE MODO
            _buildModeSelector(),
            const SizedBox(height: 25),

            // Si está cargando mostramos spinner, si no, el contenido
            _isLoading 
              ? SizedBox(
                  height: 200, 
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                )
              : Column(
                  children: [
                    // 2. TARJETA DE RESULTADO
                    _buildResultCard(),
                    
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft, 
                      child: Textwidget(
                        text: _isAutoMode ? "Datos encontrados (Año Anterior)" : "Simulador Manual", 
                        size: 14, 
                        color: Colors.grey, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 15),
                    
                    // 3. TARJETAS DE VALORES (EDITABLES)
                    
                    // FILA 1: INGRESOS Y PATRIMONIO
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmartInputCard(
                            "Ingresos", 
                            _ingresos, 
                            Icons.attach_money, 
                            Colors.green, 
                            (v) => setState(() { _ingresos = v; _recalcular(); })
                          )
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildSmartInputCard(
                            "Patrimonio (App + Bienes)", // <--- Texto actualizado
                            _patrimonio, 
                            Icons.house, 
                            Colors.blue, 
                            (v) => setState(() { _patrimonio = v; _recalcular(); })
                          )
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // FILA 2: DEDUCCIONES Y RETENCIONES
                    Row(
                      children: [
                        Expanded(child: _buildSmartInputCard("Deducciones", _deducciones, Icons.receipt_long, Colors.orange, (v) => setState(() { _deducciones = v; _recalcular(); }))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildSmartInputCard("Retenciones", _retenciones, Icons.verified, Colors.purple, (v) => setState(() { _retenciones = v; _recalcular(); }))),
                      ],
                    ),

                    // --- NOTA DE ADVERTENCIA (NUEVA) ---
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.yellow[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.yellow.shade200)
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.orange[800]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: const Text(
                              "Nota: El patrimonio automático es tu saldo en la App. Toca la tarjeta azul para sumar tu casa o vehículo.",
                              style: TextStyle(color: Colors.brown, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // -----------------------------------

                    const SizedBox(height: 30),
                    
                    if (_isAutoMode)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                            const SizedBox(width: 10),
                            Expanded(child: Text("Cálculo basado en tus movimientos registrados.", style: TextStyle(color: AppTheme.primaryColor, fontSize: 12))),
                          ],
                        ),
                      ),
                      
                    const SizedBox(height: 20),
                    Buttoncustom(text: "Finalizar", onTap: () => Navigator.pop(context)),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          _buildTabButton("Automático", _isAutoMode, () => _loadAutoData()),
          _buildTabButton("Manual", !_isAutoMode, () => _switchToManual()),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : []
          ),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: _colorEstado.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: _colorEstado.withOpacity(0.5))
      ),
      child: Column(
        children: [
          Text(_mensajeEstado, style: TextStyle(color: _colorEstado, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          if (_obligado)
            Text("\$ ${_fmt(_impuestoPagar.abs())}", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: _colorEstado))
          else
            const Icon(Icons.check_circle_outline, size: 50, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSmartInputCard(String label, double value, IconData icon, Color color, Function(double) onChanged) {
    return GestureDetector(
      onTap: () => _showEditSheet(label, value, onChanged),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 5),
            Text("\$ ${_fmt(value)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(String title, double currentVal, Function(double) onSave) {
    final ctrl = TextEditingController(text: currentVal == 0 ? "" : currentVal.toStringAsFixed(0));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
          top: 20, left: 20, right: 20
        ),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Editar $title", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money, color: Colors.black),
                hintText: "0",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[100]
              ),
            ),
            const SizedBox(height: 20),
            Buttoncustom(text: "Guardar", onTap: () {
              double val = double.tryParse(ctrl.text) ?? 0;
              onSave(val);
              Navigator.pop(context);
            }),
          ],
        ),
      )
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
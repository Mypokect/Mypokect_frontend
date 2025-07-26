import 'dart:async';
import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/Theme.dart';
import 'package:MyPocket/Widgets/TextWidget.dart';
import 'package:MyPocket/Widgets/animated_toggle_switch.dart';
import 'package:MyPocket/Widgets/campo_etiquetas.dart';
import '../../Controllers/movement_controller.dart';

class Movements extends StatefulWidget {
  const Movements({super.key});

  @override
  State<Movements> createState() => _MovementsState();
}

class _MovementsState extends State<Movements> {
  final MovementController _movementController = MovementController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _etiquetaController = TextEditingController();

  Timer? _debounceTimer;
  List<String> _etiquetasUsuario = [];
  String? _etiquetaSeleccionada;

  @override
  void initState() {
    super.initState();
    _nombreController.addListener(_onTextChanged);
    _montoController.addListener(_onTextChanged);
    _cargarEtiquetas();
  }

  Future<void> _cargarEtiquetas() async {
    final etiquetas = await _movementController.getEtiquetasUsuario();
    setState(() => _etiquetasUsuario = etiquetas);
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 5), () async {
      final nombre = _nombreController.text.trim();
      final monto = _montoController.text.trim();

      if (nombre.isNotEmpty && monto.isNotEmpty) {
        await _movementController.getCategoriaDesdeApi(
          nombre: nombre,
          valor: monto,
          context: context,
          onSuccess: (etiqueta) {
            if (etiqueta != null) {
              setState(() {
                _etiquetaSeleccionada = etiqueta;
                _etiquetaController.text = etiqueta;
              });
            }
          },
        );
      }
    });
  }

  Future<void> _crearEtiquetaSiNoExiste() async {
    final texto = _etiquetaController.text.trim();
    if (texto.isEmpty) return;

    if (!_etiquetasUsuario.contains(texto)) {
      final creada = await _movementController.crearEtiqueta(texto, context);
      if (creada != null) {
        setState(() {
          _etiquetasUsuario.add(creada);
          _etiquetaSeleccionada = creada;
        });
      }
    } else {
      setState(() {
        _etiquetaSeleccionada = texto;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nombreController.dispose();
    _montoController.dispose();
    _etiquetaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.only(left: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black, size: 20),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Spacer(flex: 1),
            Textwidget(
              text: 'Dale un nombre a tu movimiento 💵',
              size: 35,
              color: Colors.black,
              fontWeight: FontWeight.w500,
              maxLines: 2,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                icon: Text('🏷', style: TextStyle(fontSize: 20)),
                hintText: 'Ej. Compra del hogar',
                hintStyle: TextStyle(
                    color: Colors.grey, fontSize: 20, fontFamily: 'Baloo2'),
                border: InputBorder.none,
              ),
            ),
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                icon: Text('💰', style: TextStyle(fontSize: 20)),
                hintText: 'Ej. \$15.000',
                hintStyle: TextStyle(
                    color: Colors.grey, fontSize: 20, fontFamily: 'Baloo2'),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedToggleSwitch(),
                SizedBox(width: 10),
                Expanded(
                  child: CampoEtiquetas(
                    etiquetaController: _etiquetaController,
                    etiquetasUsuario: _etiquetasUsuario,
                    onEtiquetaSeleccionada: (etiqueta) {
                      setState(() {
                        _etiquetaSeleccionada = etiqueta;
                      });
                    },
                  ),
                ),
              ],
            ),
            Spacer(flex: 2),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.grey[500], size: 20),
                    Textwidget(
                      text: 'Agrega una nueva transacción',
                      size: 14,
                      color: Colors.grey[500]!,
                      fontWeight: FontWeight.w500,
                      maxLines: 2,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await _crearEtiquetaSiNoExiste();
                    // Guardar movimiento aquí si lo necesitas
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          offset: Offset(0, 6),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Icon(Icons.mic_none_rounded,
                        color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// lib/Screens/Movements.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/Theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/Widgets/movements/animated_toggle_switch.dart';
import 'package:MyPocket/Widgets/movements/campo_etiquetas.dart';
import '../../Controllers/movement_controller.dart';
// Nuevas importaciones
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';

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

  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  // ESTADOS PARA CONTROLAR LA UI Y EVITAR ERRORES
  bool _esGasto = true; // true = Gasto, false = Ingreso
  bool _isSettingFromVoice = false; // Bandera para evitar doble llamada a la API

  @override
  void initState() {
    super.initState();
    _nombreController.addListener(_onTextChanged);
    _montoController.addListener(_onTextChanged);
    _cargarEtiquetas();
    _initSpeech();
  }

  void _initSpeech() async {
    // La inicialización se maneja en _startListening
  }

  void _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (errorNotification) => print('onError: $errorNotification'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) async {
          _lastWords = result.recognizedWords;
          print('Palabras reconocidas: $_lastWords');

          if (result.finalResult) {
            setState(() => _isListening = false);
            _speechToText.stop();

            if (_lastWords.isNotEmpty) {
              final sugerencia = await _movementController.procesarSugerenciaPorVoz(
                transcripcion: _lastWords,
                context: context,
              );

              if (sugerencia != null) {
                // Se activa la bandera para evitar que _onTextChanged se dispare
                _isSettingFromVoice = true;

                setState(() {
                  final String description = sugerencia['description'] ?? '';
                  final String amount = sugerencia['amount'] ?? '';
                  final String tag = sugerencia['suggested_tag'] ?? '';
                  final String type = sugerencia['type'] ?? 'expense';

                  _nombreController.text = description;
                  _montoController.text = amount;
                  _etiquetaController.text = tag;
                  _etiquetaSeleccionada = tag;
                  
                  // Se actualiza el estado que controla el switch
                  _esGasto = (type.toLowerCase() == 'expense');

                  if (tag.isNotEmpty && !_etiquetasUsuario.contains(tag)) {
                    _etiquetasUsuario.insert(0, tag);
                  }
                });

                // Se desactiva la bandera después de un breve instante
                Future.delayed(const Duration(milliseconds: 100), () {
                  _isSettingFromVoice = false;
                });
              }
            }
          }
        },
        localeId: 'es_ES',
      );
    } else {
      print("El reconocimiento de voz no está disponible.");
      setState(() => _isListening = false);
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  Future<void> _cargarEtiquetas() async {
    final etiquetas = await _movementController.getEtiquetasUsuario();
    setState(() => _etiquetasUsuario = etiquetas);
  }

  // Listener modificado para respetar la bandera _isSettingFromVoice
  void _onTextChanged() {
    if (_isSettingFromVoice) return; // Si los cambios vienen de la voz, no hacer nada

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () async {
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
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black, size: 20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: availableHeight,
            child: Column(
              children: [
                const Spacer(flex: 1),
                TextWidget(
                  text: 'Dale un nombre a tu movimiento 💵',
                  size: 35,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
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
                  decoration: const InputDecoration(
                    icon: Text('💰', style: TextStyle(fontSize: 20)),
                    hintText: 'Ej. \$15.000',
                    hintStyle: TextStyle(
                        color: Colors.grey, fontSize: 20, fontFamily: 'Baloo2'),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LLAMADA FINAL Y CORRECTA AL WIDGET ---
                    AnimatedToggleSwitch(
                      value: _esGasto,
                      onChanged: (newValue) {
                        setState(() {
                          _esGasto = newValue;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
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
                const Spacer(flex: 2),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            _isListening ? Icons.mic_none : Icons.add,
                            color: Colors.grey[500],
                            size: 20),
                        TextWidget(
                          text: _isListening
                              ? 'Escuchando...'
                              : 'Toca para hablar, mantén para guardar',
                          size: 14,
                          color: Colors.grey[500]!,
                          fontWeight: FontWeight.w500,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AvatarGlow(
                      animate: _isListening,
                      glowColor: AppTheme.primaryColor,
                      duration: const Duration(milliseconds: 2000),
                      repeat: true,
                      child: GestureDetector(
                        onTap: _isListening ? _stopListening : _startListening,
                        onLongPress: () async {
                          if (_isListening) _stopListening();
                          await _crearEtiquetaSiNoExiste();
                          final tipoMovimiento = _esGasto ? 'Gasto' : 'Ingreso';
                          print(
                              'Acción de guardar ejecutada. Tipo: $tipoMovimiento');
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
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                offset: const Offset(0, 6),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
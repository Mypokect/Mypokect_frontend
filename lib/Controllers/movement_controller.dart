import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/movement_api.dart';
import '../api/savings_goals_api.dart';
import '../models/savings_goal.dart';
import '../Core/Managers/tag_history_manager.dart';

class MovementController {
  final MovementApi _movementApi = MovementApi();

  // 1. GUARDAR
  Future<void> createMovement({
    required String type,
    required double amount,
    required String description,
    required BuildContext context,
    String? paymentMethod,
    String? tag,
    bool? hasInvoice,
  }) async {
    try {
      // LLAMADA AL API SIN EL PARÁMETRO TOKEN (Ya lo maneja el API internamente)
      final response = await _movementApi.createMovement(
        type: type,
        amount: amount,
        description: description,
        // paymentMethod obligatorio para el backend nuevo, enviamos 'digital' si es null
        paymentMethod: paymentMethod ?? 'digital',
        tagName: tag,
        hasInvoice: hasInvoice ?? false,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Mensaje flotante de éxito seguro
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('¡Movimiento guardado!'),
            backgroundColor: Colors.green));
      } else {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? json['error'] ?? 'Error al guardar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  // 2. VOZ (Corrigiendo el error "undefined method")
  Future<Map<String, dynamic>?> procesarSugerenciaPorVoz({
    required String transcripcion,
    required BuildContext context,
  }) async {
    try {
      final result = await _movementApi.procesarVoz(transcripcion);

      if (result != null) {
        String suggestedTag = result['suggested_tag'] ?? result['tag'] ?? '';
        bool esMeta = suggestedTag.startsWith('💰') ||
            suggestedTag.toLowerCase().contains('meta:');

        return {
          'description': result['description'] ?? result['name'] ?? '',
          'amount': (result['amount'] ?? 0).toString(),
          'suggested_tag': suggestedTag,
          'type': result['type'] ?? 'expense',
          'payment_method': result['payment_method'] ?? 'digital',
          'has_invoice': result['has_invoice'] ?? false,
          'is_goal': esMeta,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 3. OBTENER ETIQUETAS (Híbrido)
  Future<List<String>> getEtiquetasUsuario() async {
    final tags = await _movementApi.getTags();
    final savingsGoals = await _getSavingsGoals();
    
    return await TagHistoryManager.getAllTags(
      serverTags: tags,
      goalTags: savingsGoals,
    );
  }
  
  // NUEVO: Obtener etiquetas completas (híbrido)
  Future<List<String>> getAllEtiquetas() async {
    final serverTags = await _movementApi.getTags();
    final goals = await _getSavingsGoals();
    
    return await TagHistoryManager.getAllTags(
      serverTags: serverTags,
      goalTags: goals,
    );
  }
  
  // NUEVO: Agregar uso de etiqueta al historial
  Future<void> recordTagUsage(String tag) async {
    await TagHistoryManager.recordUsage(tag);
  }

  // Obtener metas de ahorro para integrarlas en el autocompletado
  Future<List<String>> _getSavingsGoals() async {
    try {
      final savingsApi = SavingsGoalsApi();
      final goals = await savingsApi.getGoals();

      // Convertir metas a formato de etiqueta: "💰 Meta: nombre"
      final goalTags = goals.map((goal) {
        // Extraer el nombre del goal (quitar "Meta:" si ya existe)
        String goalName = goal.name;
        if (goalName.toLowerCase().contains('meta:')) {
          goalName = goalName.split(':').last.trim();
        }

        return '${goal.emoji} Meta: $goalName';
      }).toList();

      return goalTags;
    } catch (e) {
      print("Error loading savings goals for tags: $e");
      return [];
    }
  }

  // 4. CREAR ETIQUETA (Corrigiendo el error "createTag undefined")
  Future<String?> crearEtiqueta(String nombre, BuildContext context) async {
    return await _movementApi.createTag(nombre);
  }

  // 5. SUGERIR (Modo manual)
  Future<void> getCategoriaDesdeApi({
    required String nombre,
    required String valor,
    required BuildContext context,
    required Function(String?) onSuccess,
  }) async {
    double m = double.tryParse(valor) ?? 0;
    // Llamada corregida
    final tag =
        await _movementApi.getTagSuggestion(descripcion: nombre, monto: m);
    if (tag != null) onSuccess(tag);
  }
}

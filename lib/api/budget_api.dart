import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart';

class BudgetApi {
  
  // Helper para headers
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');
    if (token == null) throw Exception('No has iniciado sesión.');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // 1. MODO IA: GENERAR
  Future<Map<String, dynamic>> generateBudgetPlan(String title, double amount, String description) async {
    final url = Uri.parse('${BaseUrl.apiUrl}budgets/ai/generate');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'title': title, 'total_amount': amount, 'description': description}),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] != null ? Map<String, dynamic>.from(json['data']) : json;
      } else {
        _handleError(response);
        throw Exception('Error desconocido');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 2. CREAR MANUALMENTE
  Future<void> createManualBudget(String title, double amount, String description, List<Map<String, dynamic>> categories) async {
    final url = Uri.parse('${BaseUrl.apiUrl}budgets/manual');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'title': title, 'total_amount': amount, 'description': description, 'categories': categories, 'status': 'active'}),
      );
      if (response.statusCode != 201 && response.statusCode != 200) _handleError(response);
    } catch (e) {
      rethrow;
    }
  }

  // 3. GUARDAR IA
  Future<void> saveAIBudget(String title, double amount, String description, List<Map<String, dynamic>> categories) async {
    final url = Uri.parse('${BaseUrl.apiUrl}budgets/ai/save');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'title': title, 'total_amount': amount, 'description': description, 'categories': categories, 'status': 'active'}),
      );
      if (response.statusCode != 201 && response.statusCode != 200) _handleError(response);
    } catch (e) {
      rethrow;
    }
  }

  // 4. GUARDAR UNIFICADO (Crear)
  Future<void> saveBudgetPlan(String title, double totalAmount, String description, List<Map<String, dynamic>> categories, String mode) async {
    if (mode == 'manual') {
      await createManualBudget(title, totalAmount, description, categories);
    } else {
      await saveAIBudget(title, totalAmount, description, categories);
    }
  }

  // 5. OBTENER LISTA
  Future<List<dynamic>> getBudgets() async {
    final url = Uri.parse('${BaseUrl.apiUrl}budgets');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] != null) {
          if (json['data'] is List) return List<dynamic>.from(json['data']);
          else if (json['data'] is Map && json['data']['data'] != null) return List<dynamic>.from(json['data']['data']);
        }
        return [];
      } else {
        throw Exception('Error servidor (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error al cargar presupuestos.');
    }
  }

  // 6. ACTUALIZAR (Solo Cabecera)
  // 6. ACTUALIZAR PRESUPUESTO COMPLETO
  // Agregamos el parámetro 'categories'
  Future<void> updateBudget(int id, String title, double amount, String description, List<Map<String, dynamic>> categories) async {
    final url = Uri.parse('${BaseUrl.apiUrl}budgets/$id');
    
    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'title': title,
          'total_amount': amount,
          'description': description,
          'categories': categories, // <--- Enviamos la lista
        }),
      );

      if (response.statusCode != 200) {
        _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // 7. ELIMINAR
  Future<void> deleteBudget(int id) async {
    final url = Uri.parse('${BaseUrl.apiUrl}budgets/$id');
    try {
      final response = await http.delete(url, headers: await _getHeaders());
      if (response.statusCode != 200) _handleError(response);
    } catch (e) {
      rethrow;
    }
  }

  void _handleError(http.Response response) {
    String msg = 'Error (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body['message'] != null) msg = body['message'];
      else if (body['error'] != null) msg = body['error'];
    } catch (_) {}
    throw Exception(msg);
  }
  // Procesar comando de voz
  Future<Map<String, dynamic>> processVoiceCommand(String text) async {
    final url = Uri.parse('${BaseUrl.apiUrl}process-voice');
    
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data']; // {name: "Hotel", amount: 200000}
      } else {
        throw Exception('No entendí el comando.');
      }
    } catch (e) {
      throw Exception('Error de conexión.');
    }
  }
}
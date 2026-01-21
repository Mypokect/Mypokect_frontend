import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart';

class TaxApi {
  
  // --- 1. DATOS PARA ASISTENTE (Llenado Automático) ---
  Future<Map<String, dynamic>> getTaxData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke'); // Asegúrate que tu key es 'toke' como en login

    final url = Uri.parse('${BaseUrl.apiUrl}taxes/data'); 

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error Backend (${response.statusCode}): ${response.body}');
    }
  }

  // --- 2. NUEVO: DATOS PARA RADAR DE ALERTAS 2026 ---
  // Esta es la función que necesitas para ver las barras de progreso
  Future<Map<String, dynamic>> getTaxAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');
    
    // Apunta al nuevo endpoint checkLimits que creamos en Laravel
    final url = Uri.parse('${BaseUrl.apiUrl}taxes/alerts'); 

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar alertas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
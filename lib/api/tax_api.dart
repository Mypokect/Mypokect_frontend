import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart';

class TaxApi {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');
    if (token == null) throw Exception('No has iniciado sesión.');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  /// GET /taxes/data → retorna el contenido de `data` directamente
  Future<Map<String, dynamic>> getTaxData() async {
    final url = Uri.parse('${BaseUrl.apiUrl}taxes/data');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      print('🔵 getTaxData status: ${response.statusCode}');
      print('🔵 getTaxData body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Backend: {status, message, data: {ingresos_totales, patrimonio_estimado, ...}}
        if (json['data'] is Map) {
          return Map<String, dynamic>.from(json['data']);
        }
        return json;
      } else {
        throw Exception('Error Backend (${response.statusCode})');
      }
    } catch (e) {
      print('🔴 getTaxData error: $e');
      rethrow;
    }
  }

  /// GET /taxes/alerts → retorna {data: [...], summary_message: "..."}
  Future<Map<String, dynamic>> getTaxAlerts() async {
    final url = Uri.parse('${BaseUrl.apiUrl}taxes/alerts');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      print('🔵 getTaxAlerts status: ${response.statusCode}');
      print('🔵 getTaxAlerts body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Backend puede enviar: {status, message, data: [...], summary_message: "..."}
        // o: {data: [...], summary_message: "..."}
        return json;
      } else {
        throw Exception('Error alertas (${response.statusCode})');
      }
    } catch (e) {
      print('🔴 getTaxAlerts error: $e');
      rethrow;
    }
  }
}

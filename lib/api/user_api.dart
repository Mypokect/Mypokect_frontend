import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart'; // Asegúrate de tener tu BaseUrl aquí

class UserApi {
  
  Future<Map<String, dynamic>> getHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke'); // Tu llave del token

    final url = Uri.parse('${BaseUrl.apiUrl}home-data');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // Retorna {name: 'Carlos', balance: 50000}
    } else {
      throw Exception('Error cargando datos');
    }
  }

  // Obtener resumen financiero detallado (ingresos, gastos, etiquetas)
  Future<Map<String, dynamic>> getFinancialSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    final url = Uri.parse('${BaseUrl.apiUrl}financial-summary');

    print('═══════════════════════════════════════════');
    print('🔍 INICIANDO LLAMADA A FINANCIAL SUMMARY');
    print('📍 URL: $url');
    print('🔑 Token presente: ${token != null && token.isNotEmpty}');
    print('═══════════════════════════════════════════');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 RESPUESTA RECIBIDA');
      print('📊 Status code: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      print('═══════════════════════════════════════════');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('✅ JSON parseado exitosamente');
        print('📦 Estructura: ${json.keys}');
        final result = json['data'] ?? json;
        print('💰 Total income: ${result['total_income']}');
        print('💸 Total expense: ${result['total_expense']}');
        print('🏷️  Top tags: ${result['top_tags']}');
        print('═══════════════════════════════════════════');
        return result;
      } else if (response.statusCode == 404) {
        print('❌ ENDPOINT NO ENCONTRADO (404)');
        print('⚠️  El endpoint financial-summary no existe en el backend');
        print('═══════════════════════════════════════════');
        return {
          'total_income': 0.0,
          'total_expense': 0.0,
          'top_tags': {},
          '_error': 'endpoint_not_found',
        };
      } else {
        print('⚠️  ENDPOINT RETORNÓ ERROR: ${response.statusCode}');
        print('📄 Mensaje: ${response.body}');
        print('═══════════════════════════════════════════');
        return {
          'total_income': 0.0,
          'total_expense': 0.0,
          'top_tags': {},
          '_error': 'http_error_${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ EXCEPCIÓN EN getFinancialSummary');
      print('🔥 Error: $e');
      print('🔥 Tipo: ${e.runtimeType}');
      print('═══════════════════════════════════════════');
      return {
        'total_income': 0.0,
        'total_expense': 0.0,
        'top_tags': {},
        '_error': 'exception: $e',
      };
    }
  }
}
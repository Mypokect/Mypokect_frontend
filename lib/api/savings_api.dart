import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart'; // Tu archivo de configuración

class SavingsApi {
  Future<Map<String, dynamic>> getAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke'); // Asegúrate que la llave sea correcta

    final url = Uri.parse('${BaseUrl.apiUrl}savings/analyze');
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
      throw Exception('Error al analizar finanzas');
    }
  }
}
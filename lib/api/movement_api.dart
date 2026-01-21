import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart';

class MovementApi {
  // Helper interno para el token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke'); // Asegúrate que tu key es 'toke'
    if (token == null) throw Exception('No has iniciado sesión.');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // 1. Guardar Movimiento
  Future<http.Response> createMovement({
    required String type,
    required double amount,
    required String description,
    required String paymentMethod,
    String? tagName,
    bool? hasInvoice,
  }) async {
    final url = Uri.parse('${BaseUrl.apiUrl}movements');

    // NOTA: No recibimos 'token' como parámetro, lo obtenemos en _getHeaders
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'type': type,
        'amount': amount,
        'description': description,
        'payment_method': paymentMethod,
        'tag_name': tagName,
        'has_invoice': hasInvoice ?? false,
      }),
    );
    return response;
  }

  // 2. IA de Voz (Corrigiendo el nombre para el controlador)
  // Laravel espera: { "transcripcion": "..." }
  // Endpoint: /movements/sugerir-voz
  Future<Map<String, dynamic>?> procesarVoz(String transcription) async {
    final url = Uri.parse('${BaseUrl.apiUrl}movements/sugerir-voz');

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'transcripcion': transcription}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Retornamos el mapa interno de sugerencia
        return json['movement_suggestion'] ?? json['data'];
      }
    } catch (e) {}
    return null;
  }

  // 3. Crear Etiqueta Manualmente
  Future<String?> createTag(String name) async {
    final url = Uri.parse('${BaseUrl.apiUrl}tags/create');

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'name_tag': name}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['tag']?['name_tag'] ?? name;
      }
    } catch (e) {}
    return null;
  }

  // 4. Obtener Lista de Etiquetas
  Future<List<String>> getTags() async {
    final url = Uri.parse('${BaseUrl.apiUrl}tags');
    try {
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Laravel: { status: success, data: [...] }
        final List list = json['data'] ?? json['tags'] ?? [];
        return list.map<String>((e) => e['name_tag'].toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  // 5. Sugerencia de Etiqueta (IA Texto)
  Future<String?> getTagSuggestion(
      {required String descripcion, required double monto}) async {
    final url = Uri.parse('${BaseUrl.apiUrl}tags/suggestion');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'descripcion': descripcion, 'monto': monto}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data']?['tag'];
      }
    } catch (_) {}
    return null;
  }
}

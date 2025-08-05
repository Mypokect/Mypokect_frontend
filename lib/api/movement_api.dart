import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Services/base_url.dart';

class MovementApi {
  Future<http.Response> getCategoria({
    required String nombre,
    required String valor,
    required String token,
  }) async {
    try {
      final url = Uri.parse('${BaseUrl.apiUrl}tags/suggestion');
      print('🔗 URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'descripcion': nombre,
          'monto': valor,
        },
      );

      print('🔁 Status code: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        return response;
      } else {
        final json = jsonDecode(response.body);
        final msg = json['message'] ?? 'Error desconocido';
        throw Exception(msg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<http.Response> crearEtiqueta(String nombre, String token) async {
    try {
      final url = Uri.parse('${BaseUrl.apiUrl}tags/create');
      print('📤 Creando etiqueta en: $url');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'name_tag': nombre,
        },
      );

      print('📥 Respuesta crearEtiqueta: ${response.body}');
      return response;
    } catch (e) {
      throw Exception('Error al crear etiqueta: $e');
    }
  }

  Future<http.Response> getEtiquetasUsuario(String token) async {
    try {
      final url = Uri.parse('${BaseUrl.apiUrl}tags');
      print('🔍 Consultando etiquetas en: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📥 Respuesta getEtiquetasUsuario: ${response.body}');
      return response;
    } catch (e) {
      throw Exception('Error al obtener etiquetas: $e');
    }
  }
  Future<http.Response> sugerirMovimientoPorVoz({
  required String transcripcion,
  required String token,
}) async {
  try {
    // La nueva URL que proporcionaste
    final url = Uri.parse('${BaseUrl.apiUrl}movements/sugerir-voz');
    print('🗣️  Enviando transcripción a: $url');
    print('📝 Transcripción: $transcripcion');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        // Es crucial especificar que el cuerpo es JSON
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // El cuerpo debe ser un string JSON codificado
      body: jsonEncode({
        'transcripcion': transcripcion,
      }),
    );

    print('🔁 Status code sugerencia: ${response.statusCode}');
    print('📥 Body sugerencia: ${response.body}');

    return response;
  } catch (e) {
    print('❌ Error en sugerirMovimientoPorVoz: $e');
    throw Exception('Error al procesar la sugerencia por voz: $e');
  }
}
}

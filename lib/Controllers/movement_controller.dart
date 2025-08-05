import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/movement_api.dart';
import '../Widgets/CustomAlert.dart';

class MovementController {
  final MovementApi _movementApi = MovementApi();

  Future<void> getCategoriaDesdeApi({
    required String nombre,
    required String valor,
    required BuildContext context,
    required Function(String?) onSuccess,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('toke');

      if (token == null) {
        throw Exception('Token no disponible. Inicia sesión nuevamente.');
      }

      final response = await _movementApi.getCategoria(
        nombre: nombre,
        valor: valor,
        token: token,
      );

      debugPrint('🔁 Status code: ${response.statusCode}');
      debugPrint('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final etiqueta = json['data']['tag'];

        onSuccess(etiqueta);

        CustomAlert.show(
          context: context,
          title: 'Etiqueta sugerida',
          message: etiqueta.toString(),
          icon: Icons.sell_outlined,
          color: Colors.green,
        );
      } else {
        throw Exception('Error al obtener categoría: ${response.statusCode}');
      }
    } catch (e) {
      CustomAlert.show(
        context: context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
  }
  // Dentro de MovementController
Future<List<String>> getEtiquetasUsuario() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    if (token == null) throw Exception('Token no disponible');

    final response = await _movementApi.getEtiquetasUsuario(token);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> tags = data['tags']; // ✅ Aquí está el cambio

      return tags.map<String>((e) => e['name_tag'].toString()).toList();
    } else {
      throw Exception('Error al obtener etiquetas: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('❌ Error en getEtiquetasUsuario: $e');
    return [];
  }
}

Future<String?> crearEtiqueta(String nombre, BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    if (token == null) throw Exception('Token no disponible');

    final response = await _movementApi.crearEtiqueta(nombre, token);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final nueva = data['tag']['name_tag'];
      return nueva;
    } else {
      final json = jsonDecode(response.body);
      final error = json['error'] ?? 'Error al crear etiqueta';
      throw Exception(error);
    }
  } catch (e) {
    CustomAlert.show(
      context: context,
      title: 'Error',
      message: e.toString().replaceFirst('Exception: ', ''),
      icon: Icons.error_outline,
      color: Colors.red,
    );
    return null;
  }
}
Future<Map<String, dynamic>?> procesarSugerenciaPorVoz({
  required String transcripcion,
  required BuildContext context,
}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    if (token == null) {
      throw Exception('Token no disponible. Inicia sesión nuevamente.');
    }

    // Llama al nuevo método de la API
    final response = await _movementApi.sugerirMovimientoPorVoz(
      transcripcion: transcripcion,
      token: token,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      
      // Accede a los datos anidados en "movement_suggestion"
      final sugerencia = json['movement_suggestion'];

      // Retorna un mapa con los datos que la vista necesita
      return {
        'description': sugerencia['description'],
        'amount': sugerencia['amount'].toString(), // Convertimos a String para el controller
        'suggested_tag': sugerencia['suggested_tag'],
      };

    } else {
      final json = jsonDecode(response.body);
      final msg = json['message'] ?? 'Error al procesar la transcripción';
      throw Exception(msg);
    }
  } catch (e) {
    CustomAlert.show(
      context: context,
      title: 'Error de Sugerencia',
      message: e.toString().replaceFirst('Exception: ', ''),
      icon: Icons.error_outline,
      color: Colors.red,
    );
    return null; // Retorna null si hubo un error
  }
}

}

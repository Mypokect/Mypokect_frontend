import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Services/base_url.dart';

class AuthApi {

  Future<http.Response> login({
    required String phone,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${BaseUrl.apiUrl}login');
      final response = await http.post(
        url,
        body: {
          'phone': phone,
          'password': password,
        }
      );

      if (response.statusCode == 200) {
        return response.body.isNotEmpty
            ? response
            : throw Exception('Empty response body');
      } else {
        final json = jsonDecode(response.body);
        final msg = json['message'] ?? 'Error desconocido';
        throw Exception(msg); // 👈 Solo lanza el mensaje limpio
      }

    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));

    }
  }
  // En tu archivo api/auth_api.dart

// ... imports y clase ...

  Future<http.Response> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('${BaseUrl.apiUrl}register'); // Asegúrate que baseUrl apunte a /api/auth o /api según configuraste
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      // Manejo básico de errores para que el catch del Controller lo capture
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Error desconocido al registrar');
    }
  }
}
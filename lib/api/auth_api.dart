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
}
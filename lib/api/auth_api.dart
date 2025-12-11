import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Services/base_url.dart';

class AuthApi {

  // --- FUNCIÓN LOGIN CORREGIDA ---
  Future<http.Response> login({
    required String phone,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${BaseUrl.apiUrl}login');
      
      final response = await http.post(
        url,
        // 1. AGREGAMOS HEADERS PARA JSON
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // 2. USAMOS JSON ENCODE (Para que el +57 se envíe bien)
        body: jsonEncode({
          'phone': phone,
          'password': password,
        })
      );

      if (response.statusCode == 200) {
        return response.body.isNotEmpty
            ? response
            : throw Exception('Empty response body');
      } else {
        final json = jsonDecode(response.body);
        final msg = json['message'] ?? 'Error desconocido';
        throw Exception(msg); 
      }

    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // --- FUNCIÓN REGISTER (YA ESTABA BIEN, LA DEJAMOS IGUAL) ---
  Future<http.Response> register({
    required String name,
    required String phone,
    required String password, 
    required String countryCode,
  }) async {
    final url = Uri.parse('${BaseUrl.apiUrl}register'); 
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'country_code': countryCode, // Correcto
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      final body = jsonDecode(response.body);
      String msg = body['message'] ?? 'Error desconocido al registrar';
      
      if(body['errors'] != null) {
         msg = body['errors'].toString(); 
      }
      
      throw Exception(msg);
    }
  }
}
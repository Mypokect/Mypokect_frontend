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
        throw Exception('Failed to login: ${response.statusCode}');
      }

    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
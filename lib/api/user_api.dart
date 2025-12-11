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
}
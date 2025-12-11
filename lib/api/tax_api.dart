import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart';

class TaxApi {
  Future<Map<String, dynamic>> getTaxData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    final url = Uri.parse('${BaseUrl.apiUrl}taxes/data'); // Ojo a la ruta

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
      // Esto nos mostrará el error real en la pantalla roja de Flutter si falla
      throw Exception('Error Backend (${response.statusCode}): ${response.body}');
    }
  }
}
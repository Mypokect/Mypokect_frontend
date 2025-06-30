import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth_api.dart';
import '../mainScreen.dart';
import '../Widgets/CustomAlert.dart'; // Asegúrate de importar tu widget

class AuthController {
  final AuthApi _authApi = AuthApi();

  Future<void> login({
    required String phone,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await _authApi.login(phone: phone, password: password);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('toke', jsonData['data']['token']);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Mainscreen()),
          (_) => false,
        );
      } else {
        // Si status != 200, muestra alerta
        final jsonData = jsonDecode(response.body);
        final msg = jsonData['message'] ?? 'Credenciales incorrectas';

        CustomAlert.show(
          context: context,
          title: 'Acceso denegado',
          message: msg,
          icon: Icons.lock,
          color: Colors.orange,
        );
      }
    } catch (e) {
      // Error general (conexión, parseo, etc.)
      CustomAlert.show(
        context: context,
        title: 'Error de conexión',
        message: 'Intenta de nuevo.',
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
  }
}

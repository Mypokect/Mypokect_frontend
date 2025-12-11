import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth_api.dart';
import '../mainScreen.dart';
import '../Widgets/CustomAlert.dart'; 

class AuthController {
  final AuthApi _authApi = AuthApi();

  // --- LOGIN ---
  Future<void> login({
    required String phone,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await _authApi.login(phone: phone, password: password);
      // print('Response status: ${response.body}'); // Debug opcional
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Guardamos el token
        prefs.setString('toke', jsonData['data']['token']);

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Mainscreen()),
            (_) => false,
          );
        }
      } 
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (context.mounted) {
        CustomAlert.show(
          context: context,
          title: 'Acceso denegado',
          message: msg,
          icon: Icons.lock_outline,
          color: Colors.orange,
        );
      }
    }
  }

  // --- REGISTRO (NUEVO) ---
Future<void> register({
    required String name,
    required String phone,
    required String countryCode, // <--- RECIBIR AQUÍ
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await _authApi.register(
        name: name, 
        phone: phone, 
        countryCode: countryCode, // <--- PASAR AQUÍ
        password: password
      );
      
      // ... resto del código igual ...
      
      //print('Register Response: ${response.body}'); // Para depurar errores de validación

      // Laravel devuelve 201 Created al registrar, pero aceptamos 200 por si acaso
      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Guardamos el token para loguear automáticamente al usuario
        prefs.setString('toke', jsonData['data']['token']);

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Mainscreen()),
            (_) => false,
          );
        }
      } 
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      
      if (context.mounted) {
        CustomAlert.show(
          context: context,
          title: 'Error de Registro',
          message: msg, // Aquí saldrá si el teléfono ya existe o el pin no es válido
          icon: Icons.error_outline,
          color: Colors.redAccent,
        );
      }
    }
  }
}
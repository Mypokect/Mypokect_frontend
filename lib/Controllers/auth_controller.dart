
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth_api.dart';
import '../mainScreen.dart';

class AuthController {

  final AuthApi _authApi = AuthApi();

  Future<void> login({
    required String phone,
    required String password,
    required BuildContext context,
  }) async {
    final response = await _authApi.login(phone: phone, password: password);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final jsonData = jsonDecode(response.body);
      prefs.setString('toke', jsonData['data']['token']);

      // Navigate to the home screen or perform any other action
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const Mainscreen()), 
        (_) => false
      );
    } 
  }
}
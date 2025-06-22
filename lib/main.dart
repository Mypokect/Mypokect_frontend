import 'package:app_mobil_finanzas/Screens/Auth/Login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EasyEconomi());
}


class EasyEconomi extends StatelessWidget {
  const EasyEconomi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login()
    );
  }
}
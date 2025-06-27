import 'package:flutter/material.dart';

import 'Screens/Auth/splash_screen.dart';

void main() {
  runApp(const EasyEconomi());
}


class EasyEconomi extends StatelessWidget {
  const EasyEconomi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen()
    );
  }
}
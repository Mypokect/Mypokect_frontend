import 'package:flutter/material.dart';

import '../../mainScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verifyToken();
  }

  _verifyToken() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Mainscreen()), (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
            child: Image.asset(
              'assets/images/logo.gif',
              width: 300,
              height: 300,
            ),
        ),
      ),
    );
  }
}
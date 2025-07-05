import 'package:flutter/material.dart';

class Movements extends StatefulWidget {
  const Movements({super.key});

  @override
  State<Movements> createState() => _MovementsState();
}

class _MovementsState extends State<Movements> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class MovementAmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final Color mainColor;

  const MovementAmountInputWidget({
    Key? key,
    required this.controller,
    required this.mainColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 48, fontWeight: FontWeight.w900, color: mainColor),
        decoration: InputDecoration(
          hintText: "\$0",
          hintStyle: TextStyle(color: Colors.grey[300]),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

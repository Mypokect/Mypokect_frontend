import 'package:flutter/material.dart';

class MovementDescriptionInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const MovementDescriptionInputWidget({
    Key? key,
    required this.controller,
    this.hintText = "¿En qué gastaste?",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
              border: InputBorder.none,
              suffixIcon: Icon(Icons.edit, size: 16, color: Colors.grey[400])),
        ),
        Divider(thickness: 1, color: Colors.grey[200]),
      ],
    );
  }
}

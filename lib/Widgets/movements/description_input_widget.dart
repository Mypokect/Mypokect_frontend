import 'package:flutter/material.dart';
import '../common/text_widget.dart';

class DescriptionInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final Color activeColor;

  const DescriptionInputWidget({
    super.key,
    required this.controller,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(text: "DESCRIPCIÓN", size: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade500),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.black87),
          decoration: InputDecoration(
            hintText: "¿Qué es este movimiento?",
            hintStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500, fontSize: 15),
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: activeColor, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
          ),
        ),
      ],
    );
  }
}

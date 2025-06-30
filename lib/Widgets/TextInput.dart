import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Textinput extends StatelessWidget {
  const Textinput({
    super.key,
    this.icon,
    this.hintText = 'Texto de entrada',
    required this.controller,
    this.obscureText = false,

    });

    final SvgPicture? icon;
    final String hintText;
    final TextEditingController? controller;
    final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: icon,
            ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontFamily: 'Urbanist',
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
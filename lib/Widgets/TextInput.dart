import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para TextInputFormatter
import 'package:flutter_svg/flutter_svg.dart';

class Textinput extends StatelessWidget {
  const Textinput({
    super.key,
    this.icon,
    this.hintText = 'Texto de entrada',
    required this.controller,
    this.obscureText = false,
    // Nuevas propiedades para hacerlo adaptable
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.textInputAction,
    this.validator,
    this.onChanged,
  });

  final SvgPicture? icon;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  
  // Definición de las nuevas variables
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

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
              
              // Asignamos las propiedades dinámicas
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLength: maxLength, // Controla la cantidad de caracteres
              textInputAction: textInputAction,
              validator: validator,
              onChanged: onChanged,
              
              decoration: InputDecoration(
                hintText: hintText,
                // Esto oculta el contador "0/10" que sale por defecto con maxLength
                // para que no rompa tu diseño de altura fija (55px)
                counterText: "", 
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontFamily: 'Baloo2',
                ),
                border: const UnderlineInputBorder(
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
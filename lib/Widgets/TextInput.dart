import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Textinput extends StatelessWidget {
  const Textinput({
    super.key,
    this.icon,
    this.hintText = 'Texto de entrada',
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.textInputAction,
    this.validator,
    this.onChanged,
  });

  final Widget? icon; // Cambiado a Widget para mayor flexibilidad
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      
      // ESTILO DECORATIVO INTERNO
      decoration: InputDecoration(
        // 1. Esto pone el fondo gris DENTRO del input, no afuera
        filled: true,
        fillColor: Colors.grey[200],
        
        // 2. Bordes redondos
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none, // Opcional: BorderSide(color: Colors.red)
        ),

        // 3. Ícono integrado
        prefixIcon: icon != null 
            ? Padding(padding: const EdgeInsets.all(12.0), child: icon) 
            : null,
            
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
          fontFamily: 'Baloo2',
        ),
        
        counterText: "", 
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        
        // 4. EL ERROR SALDRÁ ABAJO SIN DEFORMAR EL GRIS
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          height: 1.0, 
        ),
      ),
    );
  }
}
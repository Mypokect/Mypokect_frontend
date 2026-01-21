import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeaderMonto extends StatelessWidget {
  final TextEditingController controller;
  final String mode; // 'expense', 'income', 'goal'
  final String title;
  final VoidCallback onBackPressed;

  const HeaderMonto({
    super.key,
    required this.controller,
    required this.mode,
    required this.title,
    required this.onBackPressed,
  });

  // Colores PASTEL para el fondo (No chillones)
  Color get _backgroundColor {
    switch (mode) {
      case 'expense': return const Color(0xFFFFF0F0); // Rojo pastel muy claro
      case 'income': return const Color(0xFFF0FFF4); // Verde pastel muy claro
      case 'goal': return const Color(0xFFF0F4FF);   // Azul pastel muy claro
      default: return const Color(0xFFF0F0F0);
    }
  }

  // Colores FUERTES para el texto
  Color get _accentColor {
    switch (mode) {
      case 'expense': return const Color(0xFFFF5252);
      case 'income': return const Color(0xFF4CAF50);
      case 'goal': return const Color(0xFF536DFE);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Configura la barra de estado del celular para que combine
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return Container(
      height: MediaQuery.of(context).size.height * 0.35, // 35% de la pantalla
      width: double.infinity,
      decoration: BoxDecoration(
        color: _backgroundColor,
        // Pequeño borde abajo para dar efecto de "capa"
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Botón Atrás
            Positioned(
              top: 10,
              left: 15,
              child: IconButton(
                onPressed: onBackPressed,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
                ),
              ),
            ),
            
            // Título
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Text(title, style: TextStyle(color: _accentColor.withOpacity(0.8), fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 14)),
              ),
            ),

            // INPUT GIGANTE
            Center(
              child: IntrinsicWidth(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  autofocus: true, // Abre el teclado de una
                  style: TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: _accentColor, height: 1.0),
                  cursorColor: _accentColor,
                  decoration: InputDecoration(
                    prefixText: "\$",
                    prefixStyle: TextStyle(fontSize: 30, color: _accentColor.withOpacity(0.5), fontWeight: FontWeight.bold),
                    hintText: "0",
                    hintStyle: TextStyle(color: _accentColor.withOpacity(0.3)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
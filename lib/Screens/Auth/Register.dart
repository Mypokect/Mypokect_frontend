import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Controllers/auth_controller.dart';
import '../../Theme/Theme.dart';
import '../../Widgets/ButtonCustom.dart';
import '../../Widgets/TextInput.dart';
import '../../Widgets/TextWidget.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final AuthController _authController = AuthController();

  // Controladores de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildWidgetBody()
                ],
              ),
            ))
          ],
        ));
  }

  Widget _buildHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.30, // Reduje un poco la altura para que sea más sobrio
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30), // Más padding lateral
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30), // Curva ligeramente más sutil (menos redonda)
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end, // Texto pegado al fondo del header
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Se eliminó la flecha y el GestureDetector
          const Textwidget(
            text: 'Crear Cuenta',
            color: Colors.white,
            size: 32, // Un poco más grande para mayor impacto
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          Textwidget(
            text: 'Completa tus datos para registrarte',
            color: Colors.white.withOpacity(0.9), // Blanco un poco más suave
            size: 16,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  // Body Widget
  Widget _buildWidgetBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20, 
        children: [
          
          // --- CAMPO NOMBRE ---
          Textinput(
            hintText: 'Nombre completo',
            controller: _nameController,
            icon: SvgPicture.asset('assets/svg/user.svg'), 
            keyboardType: TextInputType.name,
          ),

          // --- CAMPO TELÉFONO ---
          Textinput(
            hintText: 'Número de teléfono',
            controller: _phoneController,
            icon: SvgPicture.asset('assets/svg/phone.svg'), 
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),

          // --- CAMPO PIN ---
          Textinput(
            hintText: 'Define tu Pin (4 dígitos)',
            controller: _passwordController,
            obscureText: true,
            icon: SvgPicture.asset('assets/svg/password.svg'),
            keyboardType: TextInputType.number,
            maxLength: 4, 
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),

          const SizedBox(height: 10),

          Buttoncustom(
            text: 'Registrarme',
            onTap: () async {
              await _authController.register(
                name: _nameController.text,
                phone: _phoneController.text,
                password: _passwordController.text,
                context: context
              );
            },
          ),
          
          // Link para ir al Login
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Textwidget(
                  text: '¿Ya tienes una cuenta? ', 
                  color: Colors.grey, 
                  size: 14
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Vuelve al login
                  },
                  child: Textwidget(
                    text: 'Inicia Sesión', 
                    color: AppTheme.primaryColor, 
                    size: 14, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
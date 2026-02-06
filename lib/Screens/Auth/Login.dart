import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:MyPocket/Controllers/auth_controller.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/button_custom.dart';
import 'package:MyPocket/Widgets/common/text_input.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:MyPocket/Screens/Auth/Register.dart'; // O la ruta correcta donde lo guardaste

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthController _authController = AuthController();

  //controladores de texto
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
                children: [_buildHeader(), _buildWidgetBody()],
              ),
            ))
          ],
        ));
  }

  Widget _buildHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Hola, Bienvenido',
            color: Colors.white,
            size: 30,
            fontWeight: FontWeight.w600,
          ),
          TextWidget(
            text: 'Inicia sesion para continuar...',
            color: Colors.white,
            size: 15,
            fontWeight: FontWeight.w300,
          ),
        ],
      ),
    );
  }

  // body _build Widget
  Widget _buildWidgetBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          TextWidget(
              text: 'Iniciar Sesion',
              color: AppTheme.primaryColor,
              size: 30,
              fontWeight: FontWeight.w600),

          // --- INPUT TELÉFONO ---
          TextInput(
            hintText: 'Número de teléfono',
            controller: _phoneController,
            icon: SvgPicture.asset('assets/svg/user.svg'),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),

          // --- INPUT PASSWORD ---
          TextInput(
            hintText: 'Pin de seguridad',
            controller: _passwordController,
            obscureText: true,
            icon: SvgPicture.asset('assets/svg/password.svg'),
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),

          // --- BOTÓN LOGIN ---
          ButtonCustom(
            text: 'Iniciar Sesion',
            onTap: () async {
              await _authController.login(
                  phone: _phoneController.text,
                  password: _passwordController.text,
                  context: context);
            },
          ),

          // --- AGREGAR ESTO AL FINAL: LINK AL REGISTRO ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TextWidget(
                  text: '¿No tienes cuenta? ', color: Colors.grey, size: 14),
              GestureDetector(
                onTap: () {
                  // Navegar a la pantalla de Registro
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Registro()),
                  );
                },
                child: TextWidget(
                    text: 'Regístrate aquí',
                    color: AppTheme.primaryColor,
                    size: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}

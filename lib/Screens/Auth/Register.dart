import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // <--- IMPORTANTE

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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Variables para el teléfono
  String _phoneNumber = "";
  String _countryCode = "CO"; // Valor por defecto

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
      height: MediaQuery.of(context).size.height * 0.30,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Textwidget(
            text: 'Crear Cuenta',
            color: Colors.white,
            size: 32,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          Textwidget(
            text: 'Completa tus datos para registrarte',
            color: Colors.white.withOpacity(0.9),
            size: 16,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // --- NOMBRE ---
          Textinput(
            hintText: 'Nombre completo',
            controller: _nameController,
            icon: SvgPicture.asset('assets/svg/user.svg'), 
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 20),

          // --- CAMPO DE TELÉFONO CON DETECCIÓN DE PAÍS ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 55, // Misma altura que tu TextInput
            decoration: BoxDecoration(
              color: Colors.grey[200], // Mismo color de fondo
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: IntlPhoneField(
                decoration: const InputDecoration(
                  hintText: 'Número de teléfono',
                  border: InputBorder.none,
                  counterText: "", // Ocultar contador de caracteres
                  contentPadding: EdgeInsets.only(top: 13), // Ajuste visual
                ),
                initialCountryCode: 'CO', // País inicial
                languageCode: 'es', // Textos en español
                dropdownIconPosition: IconPosition.trailing, // Flecha a la derecha de la bandera
                flagsButtonPadding: const EdgeInsets.only(left: 10),
                showDropdownIcon: false, // Opcional: quitar flecha si quieres más limpio
                
                onChanged: (phone) {
                  setState(() {
                    _phoneNumber = phone.number; // Guarda +57300...
                    _countryCode = phone.countryISOCode; // Guarda 'CO', 'MX', etc.
                  });
                },
                onCountryChanged: (country) {
                  setState(() {
                    _countryCode = country.code;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- PIN ---
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

          const SizedBox(height: 30),

          Buttoncustom(
            text: 'Registrarme',
            onTap: () async {
               if (_phoneNumber.isEmpty || _nameController.text.isEmpty || _passwordController.text.length != 4) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor completa todos los datos")));
                 return;
               }

              await _authController.register(
                name: _nameController.text,
                phone: _phoneNumber,       // Ej: +57300...
                countryCode: _countryCode, // Ej: CO <--- ESTO ES LO NUEVO
                password: _passwordController.text,
                context: context
              );
            },
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Textwidget(text: '¿Ya tienes una cuenta? ', color: Colors.grey, size: 14),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Textwidget(text: 'Inicia Sesión', color: AppTheme.primaryColor, size: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
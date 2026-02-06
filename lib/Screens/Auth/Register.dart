import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    hide TextInput; // Necesario para FilteringTextInputFormatter
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';

import 'package:MyPocket/Controllers/auth_controller.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/button_custom.dart';
import 'package:MyPocket/Widgets/common/text_input.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final AuthController _authController = AuthController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _phoneNumber = "";
  String _countryCode = "CO";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
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
          const TextWidget(
              text: 'Crear Cuenta',
              color: Colors.white,
              size: 32,
              fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          TextWidget(
              text: 'Completa tus datos para registrarte',
              color: Colors.white.withOpacity(0.9),
              size: 16,
              fontWeight: FontWeight.w400),
        ],
      ),
    );
  }

  Widget _buildWidgetBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      child: Column(
        children: [
          // --- NOMBRE ---
          TextInput(
            hintText: 'Nombre completo',
            controller: _nameController,
            icon: SvgPicture.asset('assets/svg/user.svg'),
            keyboardType: TextInputType.name,
          ),

          const SizedBox(height: 20),

          // --- CAMPO DE TELÉFONO (SOLO NÚMEROS) ---
          IntlPhoneField(
            // 1. RESTRICCIÓN DE SOLO NÚMEROS
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],

            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Número de teléfono',
              hintStyle: const TextStyle(
                  color: Colors.grey, fontSize: 16, fontFamily: 'Baloo2'),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
              counterText: "",
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
            ),

            initialCountryCode: 'CO',
            languageCode: 'es',

            showDropdownIcon: false,
            flagsButtonPadding: const EdgeInsets.only(left: 15),
            flagsButtonMargin: const EdgeInsets.only(right: 10),
            dropdownTextStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
            style: const TextStyle(
                fontSize: 16, color: Colors.black87, fontFamily: 'Baloo2'),

            pickerDialogStyle: PickerDialogStyle(
              backgroundColor: Colors.white,
              countryNameStyle:
                  const TextStyle(fontSize: 16, color: Colors.black87),
              countryCodeStyle:
                  const TextStyle(fontSize: 15, color: Colors.grey),
              searchFieldInputDecoration: InputDecoration(
                hintText: 'Buscar país...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),

            onChanged: (phone) {
              setState(() {
                _phoneNumber = phone.number;
                _countryCode = phone.countryISOCode;
              });
            },
            onCountryChanged: (country) {
              setState(() {
                _countryCode = country.code;
              });
            },
          ),

          const SizedBox(height: 20),

          // --- PIN (SOLO NÚMEROS) ---
          TextInput(
            hintText: 'Define tu Pin (4 dígitos)',
            controller: _passwordController,
            obscureText: true,
            icon: SvgPicture.asset('assets/svg/password.svg'),

            // Restricción de solo números
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),

          const SizedBox(height: 30),

          ButtonCustom(
            text: 'Registrarme',
            onTap: () async {
              if (_nameController.text.isEmpty ||
                  _phoneNumber.isEmpty ||
                  _passwordController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Por favor completa todos los datos")));
                return;
              }

              await _authController.register(
                  name: _nameController.text,
                  phone: _phoneNumber,
                  countryCode: _countryCode,
                  password: _passwordController.text,
                  context: context);
            },
          ),

          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextWidget(
                    text: '¿Ya tienes una cuenta? ',
                    color: Colors.grey,
                    size: 14),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: TextWidget(
                      text: 'Inicia Sesión',
                      color: AppTheme.primaryColor,
                      size: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

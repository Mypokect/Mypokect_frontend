import 'package:flutter/material.dart';

// TUS IMPORTS
import 'package:MyPocket/Screens/service/calendario_page.dart';
import 'package:MyPocket/Screens/service/savings_assistant_fixed.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/Widgets/home/principal_actions_widget.dart';
import 'package:MyPocket/Screens/service/tax_assistant_screen.dart';
import 'package:MyPocket/Controllers/home_controller.dart';
import 'package:MyPocket/utils/helpers.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController _homeController = HomeController();

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // --- LÓGICA DE DATOS ---
  void _loadHomeData() async {
    await _homeController.loadHomeData(onDataLoaded: () {
      if (mounted) setState(() {});
    });
  }

  // --- ESTRUCTURA VISUAL PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // Fondo
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Image.asset(
                'assets/images/fondo-moderno-verde-ondulado1.png',
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
                height: 200),
          ),

          // Contenido Principal (Texto Hola + Cuerpo Blanco)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 95),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _homeController.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : TextWidget(
                        text: 'Hola, ${_homeController.userName}!',
                        color: Colors.white,
                        size: 24,
                        fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              _buildWhiteBody(), // Cuerpo blanco extraído para limpieza
            ],
          ),

          // Tarjeta Flotante (Tu diseño exacto)
          _buildFloatingCard(),
        ],
      ),
    );
  }

  // --- WIDGET DE LA TARJETA FLOTANTE (TU DISEÑO ORIGINAL) ---
  Widget _buildFloatingCard() {
    return Positioned(
      top: 150,
      left: 20,
      child: Container(
        width: 180, // Medida original
        height: 50, // Medida original
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Círculo con Ícono (Dinámico)
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Icon(_homeController.statusIcon,
                    color: _homeController.statusColor, size: 30),
              ),
            ),
            const SizedBox(width: 10),

            // Texto (Dinámico pero con tu estilo)
            Expanded(
              // Expanded evita errores si el texto es largo, pero mantiene el diseño
              child: TextWidget(
                  text: _homeController.statusLabel,
                  color: _homeController.statusColor,
                  size: 15, // Tamaño original
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // --- CUERPO BLANCO Y ACCIONES ---
  Widget _buildWhiteBody() {
    // Función auxiliar para navegar y recargar al volver
    void navigateTo(Widget page) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page))
          .then((_) {
        // ESTA ES LA CLAVE: Al volver, recargamos los datos
        _loadHomeData();
      });
    }

    final List<ActionCardData> principalActions = [
      ActionCardData(
          title: "Simulador de Tarifas",
          iconData: Icons.calculate_outlined,
          onTap: () => navigateTo(const TaxAssistantScreen())),
      ActionCardData(
          title: "Calendario de Pagos",
          iconData: Icons.calendar_month,
          onTap: () => navigateTo(const CalendarioPage())),
      ActionCardData(
          title: "Asistente Ahorro",
          iconData: Icons.savings_outlined,
          onTap: () => navigateTo(const AsistenteAhorroPage())),
    ];

    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextWidget(
                    text: 'Tu cuenta',
                    color: AppTheme.greyColor,
                    size: 15,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              _buildBalanceCard(),
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextWidget(
                    text: 'Transacciones principales',
                    color: AppTheme.greyColor,
                    size: 15,
                    fontWeight: FontWeight.w500),
              ),
              PrincipalActionsWidget(actions: principalActions),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- TARJETA DE BALANCE ---
  Widget _buildBalanceCard() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 150,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                            text: 'Balance',
                            color: AppTheme.primaryColor,
                            size: 20,
                            fontWeight: FontWeight.w500),
                        TextWidget(
                            text: 'Conoce tu saldo',
                            color: AppTheme.greyColor,
                            size: 15),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
                const SizedBox(height: 10),
                TextWidget(
                    text: 'Tu saldo actual es',
                    color: AppTheme.greyColor,
                    size: 15),
                _homeController.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : TextWidget(
                        text: formatCurrency(_homeController.balance),
                        color: Colors.black,
                        size: 20),
              ],
            ),
          ),
          Positioned(
            bottom: -25,
            left: 30,
            right: 30,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2))
                ],
              ),
              child: const Center(
                  child: TextWidget(
                      text: 'Conoce más de tus finanzas',
                      color: Colors.white,
                      size: 16,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

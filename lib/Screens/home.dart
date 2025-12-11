import 'package:MyPocket/Screens/service/calendario_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Theme/Theme.dart';
import '../Widgets/TextWidget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/fondo-moderno-verde-ondulado1.png',
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: 200,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CAMBIO 1: Aumentamos la altura para bajar el contenido ---
              // Cambiamos el valor de 65 a 95 (o el que necesites para que coincida)
              const SizedBox(height: 95), 
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Textwidget(
                  text: 'Hola, David!',
                  color: Colors.white,
                  size: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _buildBody(),
            ],
          ),
          
          // --- CAMBIO 2: Bajamos la tarjeta flotante para que mantenga su posición relativa ---
          // Cambiamos el valor 'top' de 120 a 150 (la misma cantidad que aumentamos arriba)
          Positioned(
            top: 150,
            left: 20,
            child: Container(
              width: 180,
              height: 50,
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
                      child: Icon(
                        Icons.bar_chart_rounded,
                        color: AppTheme.primaryColor,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Textwidget(
                    text: '20% Efectivo',
                    color: AppTheme.primaryColor,
                    size: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final List<ActionCardData> principalActions = [
      ActionCardData(
        title: "Compras",
        iconPath: "assets/svg/cash-register.svg",
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComprasPage())),
      ),
      ActionCardData(
        title: "Calendario",
        iconData:  Icons.calendar_month,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarioPage())),
      ),
      ActionCardData(
        title: "Suscripciones",
        iconPath: "assets/svg/subscription.svg",
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuscripcionesPage())),
      ),
      ActionCardData(
        title: "Recordatorios",
        iconPath: "assets/svg/reminder.svg",
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecordatoriosPage())),
      ),
    ];

    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70), // Este espacio sigue siendo necesario para que el contenido no quede detrás de la tarjeta flotante
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Textwidget(
                  text: 'Tu cuenta',
                  color: AppTheme.greyColor,
                  size: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _buildBalanceCard(),
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Textwidget(
                  text: 'Transacciones principales',
                  color: AppTheme.greyColor,
                  size: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              PrincipalActionsWidget(actions: principalActions),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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
                  offset: const Offset(0, 4),
                )
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
                        Textwidget(
                          text: 'Balance',
                          color: AppTheme.primaryColor,
                          size: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        Textwidget(
                          text: 'Conoce tu saldo',
                          color: AppTheme.greyColor,
                          size: 15,
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
                const SizedBox(height: 10),
                Textwidget(
                  text: 'Tu saldo actual es',
                  color: AppTheme.greyColor,
                  size: 15,
                ),
                const Textwidget(
                  text: '\$1,500.00',
                  color: Colors.black,
                  size: 20,
                ),
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
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Center(
                child: Textwidget(
                  text: 'Conoce más de tus finanzas',
                  color: Colors.white,
                  size: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- PÁGINAS SECUNDARIAS -------------------
class ComprasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Compras")),
      body: const Center(child: Text("Aquí se mostrarán tus compras.")),
    );
  }
}

class SuscripcionesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Suscripciones")),
      body: const Center(child: Text("Aquí estarán tus suscripciones.")),
    );
  }
}

class RecordatoriosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recordatorios de Pagos")),
      body: const Center(child: Text("Aquí estarán tus recordatorios.")),
    );
  }
}

class ActionCardData {
  final String title;
  final String? iconPath;   // Para íconos SVG/PNG desde assets
  final IconData? iconData; // Para íconos nativos de Flutter
  final VoidCallback onTap;

  ActionCardData({
    required this.title,
    this.iconPath,
    this.iconData,
    required this.onTap,
  }) : assert(iconPath != null || iconData != null,
              "Debes proveer un iconPath o un iconData");
}

// 2. Widget de tarjetas horizontales
class PrincipalActionsWidget extends StatelessWidget {
  final List<ActionCardData> actions;

  const PrincipalActionsWidget({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildActionCard(action, index == 0);
        },
      ),
    );
  }

  Widget _buildActionCard(ActionCardData action, bool isFirst) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        width: 120,
        margin: EdgeInsets.only(
          left: isFirst ? 20 : 10,
          top: 10,
          bottom: 10,
          right: 10,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: action.iconPath != null
                  ? SvgPicture.asset(
                      action.iconPath!,
                      colorFilter: ColorFilter.mode(
                        Colors.grey[600]!,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      action.iconData,
                      color: Colors.grey[600],
                      size: 30,
                    ),
            ),
            const SizedBox(height: 8),
            Textwidget(
              text: action.title,
              color: AppTheme.greyColor,
              size: 15,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
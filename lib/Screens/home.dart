import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TUS IMPORTS
import 'package:MyPocket/Screens/service/calendario_page.dart';
import 'package:MyPocket/Screens/service/savings_assistant_page.dart';
import '../Theme/Theme.dart';
import '../Widgets/TextWidget.dart';
import '../Widgets/principal_actions_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // --- 1. VARIABLES DE ESTADO ---
  String _userName = "Cargando...";
  double _balance = 0.0;
  bool _isLoading = true;

  // Variables para la tarjeta flotante (Inicializadas para que no falle)
  String _statusLabel = "Analizando...";
  Color _statusColor = AppTheme.primaryColor;
  IconData _statusIcon = Icons.bar_chart_rounded;

  final UserApi _userApi = UserApi();

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // --- 2. LÓGICA DE DATOS ---
  void _loadHomeData() async {
    try {
      final data = await _userApi.getHomeData();
      if (mounted) {
        // Mapeo de colores desde el Backend
        Color color = AppTheme.primaryColor;
        if (data['status_color'] == 'green') color = Colors.green;
        else if (data['status_color'] == 'red') color = Colors.red;
        else if (data['status_color'] == 'orange') color = Colors.orange;

        // Mapeo de íconos
        IconData icon = Icons.bar_chart_rounded;
        if (data['icon_type'] == 'up') icon = Icons.trending_up;
        else if (data['icon_type'] == 'down') icon = Icons.trending_down;

        setState(() {
          _userName = data['name'];
          _balance = double.parse(data['balance'].toString());
          _statusLabel = data['status_label'] ?? "Sin datos";
          _statusColor = color;
          _statusIcon = icon;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error en Home: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. ESTRUCTURA VISUAL PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // Fondo
          Positioned(
            top: 30, left: 0, right: 0,
            child: Image.asset('assets/images/fondo-moderno-verde-ondulado1.png', fit: BoxFit.fill, width: MediaQuery.of(context).size.width, height: 200),
          ),
          
          // Contenido Principal (Texto Hola + Cuerpo Blanco)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 95),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Textwidget(text: 'Hola, $_userName!', color: Colors.white, size: 24, fontWeight: FontWeight.w500),
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

  // --- 4. WIDGET DE LA TARJETA FLOTANTE (TU DISEÑO ORIGINAL) ---
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
              width: 45, height: 45,
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
                child: Icon(_statusIcon, color: _statusColor, size: 30),
              ),
            ),
            const SizedBox(width: 10),
            
            // Texto (Dinámico pero con tu estilo)
            Expanded( // Expanded evita errores si el texto es largo, pero mantiene el diseño
              child: Textwidget(
                text: _statusLabel, 
                color: _statusColor, 
                size: 15, // Tamaño original
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. CUERPO BLANCO Y ACCIONES ---
Widget _buildWhiteBody() {
    // Función auxiliar para navegar y recargar al volver
    void navigateTo(Widget page) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => page)
      ).then((_) {
        // ESTA ES LA CLAVE: Al volver, recargamos los datos
        _loadHomeData(); 
      });
    }

    final List<ActionCardData> principalActions = [
      ActionCardData(
        title: "Simulador de Tarifas", 
        iconData: Icons.calculate_outlined, 
        onTap: () => navigateTo(const ImpuestoRentaPersonalPage())
      ),
      ActionCardData(
        title: "Calendario de Pagos",
        iconData:  Icons.calendar_month,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarioPage())),
      ),
      ActionCardData(
        title: "Asistente Ahorro", 
        iconData: Icons.savings_outlined, 
        onTap: () => navigateTo(const AsistenteAhorroPage())
      ),
    ];

    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Textwidget(text: 'Tu cuenta', color: AppTheme.greyColor, size: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              _buildBalanceCard(), 
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Textwidget(text: 'Transacciones principales', color: AppTheme.greyColor, size: 15, fontWeight: FontWeight.w500),
              ),
              PrincipalActionsWidget(actions: principalActions),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- 6. TARJETA DE BALANCE ---
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
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
                        Textwidget(text: 'Balance', color: AppTheme.primaryColor, size: 20, fontWeight: FontWeight.w500),
                        Textwidget(text: 'Conoce tu saldo', color: AppTheme.greyColor, size: 15),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
                const SizedBox(height: 10),
                Textwidget(text: 'Tu saldo actual es', color: AppTheme.greyColor, size: 15),
                _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Textwidget(text: _formatCurrency(_balance), color: Colors.black, size: 20),
              ],
            ),
          ),
          Positioned(
            bottom: -25, left: 30, right: 30,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: const Center(child: Textwidget(text: 'Conoce más de tus finanzas', color: Colors.white, size: 16, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) => "\$ ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}";
}
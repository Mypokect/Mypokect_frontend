import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/utils/helpers.dart';
import 'package:MyPocket/api/user_api.dart';
import 'package:MyPocket/api/tax_api.dart';
import 'package:MyPocket/api/budget_api.dart';
import 'package:MyPocket/api/savings_goals_api.dart';
import 'package:MyPocket/models/savings_goal.dart';
import 'package:MyPocket/Screens/service/tax_screen.dart';
import 'package:MyPocket/Screens/service/budgets_list_screen.dart';
import 'package:MyPocket/Screens/service/savings_goals_screen_new.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UserApi _userApi = UserApi();
  final TaxApi _taxApi = TaxApi();
  final BudgetApi _budgetApi = BudgetApi();
  final SavingsGoalsApi _goalsApi = SavingsGoalsApi();

  bool _loading = true;

  // Balance y Financiero
  double _balance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;

  // Factura Electrónica
  double _gastoConFE = 0;
  double _gastoSinFE = 0;
  double _descuento1Porciento = 0;
  double _dineroPerdido = 0;
  double _ingresosFE = 0; // Ingresos con factura electrónica

  // Topes DIAN 2025 (en pesos)
  static const double _topeDeclaracion = 69718600; // UVT 1400 * 49799

  // Metas de Ahorro
  List<SavingsGoal> _goals = [];
  double _totalSaved = 0;
  double _totalGoalTarget = 0;

  // Presupuestos
  double _totalBudgetAmount = 0;
  double _totalBudgetSpent = 0;

  // Impuestos
  int _alertsExceeded = 0;
  int _alertsWarning = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _loading = true);

    try {
      final results = await Future.wait([
        _userApi.getHomeData().catchError((_) => <String, dynamic>{}),
        _userApi.getFinancialSummary().catchError((_) => <String, dynamic>{}),
        _taxApi.getTaxData().catchError((_) => <String, dynamic>{}),
        _taxApi.getTaxAlerts().catchError((_) => <String, dynamic>{}),
        _goalsApi.getGoals().catchError((_) => <SavingsGoal>[]),
        _budgetApi.getBudgets().catchError((_) => []),
      ]);

      if (!mounted) return;

      final homeData = results[0] as Map<String, dynamic>;
      final financialData = results[1] as Map<String, dynamic>;
      final taxData = results[2] as Map<String, dynamic>;
      final taxAlerts = results[3] as Map<String, dynamic>;
      final goals = results[4] as List<SavingsGoal>;
      final budgets = results[5] as List<dynamic>;

      _balance = _safeParse(homeData['balance']);
      _totalIncome = _safeParse(financialData['total_income']);
      _totalExpense = _safeParse(financialData['total_expense']);

      // Factura Electrónica
      _gastoConFE = _safeParse(taxData['gasto_con_fe']);
      _gastoSinFE = _safeParse(taxData['gasto_sin_fe']);
      _ingresosFE = _safeParse(taxData['ingreso_con_fe']);

      // Si no hay datos de FE, estimar basado en totales
      if (_gastoConFE == 0 && _gastoSinFE == 0 && _totalExpense > 0) {
        _gastoConFE = _totalExpense * 0.6;
        _gastoSinFE = _totalExpense * 0.4;
      }

      if (_ingresosFE == 0 && _totalIncome > 0) {
        _ingresosFE = _totalIncome * 0.7; // Estimar 70% con FE
      }

      _descuento1Porciento = _gastoConFE * 0.01;
      const double uvt2025 = 49799;
      final topeMinimo = 5 * uvt2025;
      _dineroPerdido = _gastoSinFE > topeMinimo ? _gastoSinFE : 0;

      final alertsList = _extractAlertsList(taxAlerts);
      _alertsExceeded = alertsList.where((a) => a['status'] == 'exceeded').length;
      _alertsWarning = alertsList.where((a) => a['status'] == 'warning').length;

      _goals = goals;
      _totalSaved = goals.fold(0.0, (sum, g) => sum + g.savedAmount);
      _totalGoalTarget = goals.fold(0.0, (sum, g) => sum + g.targetAmount);

      _totalBudgetAmount = budgets.fold(0.0, (sum, b) => sum + _safeParse(b['total_amount']));
      _totalBudgetSpent = budgets.fold(0.0, (sum, b) => sum + _safeParse(b['spent_amount']));

      setState(() => _loading = false);
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _extractAlertsList(Map<String, dynamic> json) {
    if (json['data'] is List) return List<Map<String, dynamic>>.from(json['data']);
    if (json['data'] is Map && json['data']['data'] is List) {
      return List<Map<String, dynamic>>.from(json['data']['data']);
    }
    return [];
  }

  double _safeParse(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // 1. FONDO (IDENTIDAD)
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. HEADER
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      text: "Panorama Financiero",
                      color: Colors.white,
                      size: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Resumen de ${DateFormat('MMMM yyyy', 'es').format(DateTime.now())}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 3. CUERPO BLANCO CURVO
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: _loading
                      ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                          child: Column(
                            children: [
                              // A. TARJETA PRINCIPAL (BALANCE)
                              _buildHeroBalanceCard(),

                              const SizedBox(height: 25),

                              // B. ACCESOS RÁPIDOS (METAS Y PRESUPUESTO)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      title: "Presupuesto",
                                      value: _totalBudgetAmount > 0
                                          ? "${((_totalBudgetSpent / _totalBudgetAmount) * 100).toStringAsFixed(0)}% usado"
                                          : "Sin datos",
                                      icon: Icons.pie_chart_outline,
                                      color: AppTheme.goalOrange,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const BudgetsListScreen()),
                                      ),
                                      progress: _totalBudgetAmount > 0
                                          ? (_totalBudgetSpent / _totalBudgetAmount).clamp(0.0, 1.0)
                                          : 0.0,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildInfoCard(
                                      title: "Mis Metas",
                                      value: "${_goals.where((g) => g.progress >= 100).length} de ${_goals.length}",
                                      icon: Icons.flag_outlined,
                                      color: AppTheme.goalPurple,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SavingsGoalsScreenNew()),
                                      ),
                                      isProgressCircle: true,
                                      circleProgress: _totalGoalTarget > 0
                                          ? (_totalSaved / _totalGoalTarget).clamp(0.0, 1.0)
                                          : 0.0,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              // C. MONITOR FISCAL
                              _buildTaxMonitorCard(),

                              const SizedBox(height: 25),

                              // D. ALERTAS DE FACTURA ELECTRÓNICA
                              _buildInvoiceAlertsSection(),

                              const SizedBox(height: 25),

                              // E. FLUJO DE CAJA
                              _buildCashflowRow(),

                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO BALANCE CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "DISPONIBLE",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontFamily: 'Baloo2',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatCurrency(_balance),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: _balance >= 0 ? Colors.black87 : AppTheme.errorColor,
              height: 1.0,
              fontFamily: 'Baloo2',
            ),
          ),
          const SizedBox(height: 25),
          Container(height: 1, color: const Color(0xFFF0F0F0)),
          const SizedBox(height: 25),

          // Ingresos y Gastos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ingresos
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_downward, color: Color(0xFF4CAF50), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ingresos",
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Baloo2'),
                      ),
                      Text(
                        formatCurrency(_totalIncome),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Gastos
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_upward, color: Color(0xFFFF5252), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gastos",
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Baloo2'),
                      ),
                      Text(
                        formatCurrency(_totalExpense),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INFO CARD (Presupuesto / Metas)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double? progress,
    bool isProgressCircle = false,
    double circleProgress = 0.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (isProgressCircle)
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      value: circleProgress,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.1),
                      strokeWidth: 3,
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Baloo2',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Baloo2',
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAX MONITOR CARD (Premium Dark)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTaxMonitorCard() {
    final String estadoFiscal;
    final Color colorFiscal;
    final String subtitulo;

    if (_alertsExceeded > 0) {
      estadoFiscal = "ALERTA";
      colorFiscal = AppTheme.errorColor;
      subtitulo = "$_alertsExceeded topes superados";
    } else if (_alertsWarning > 0) {
      estadoFiscal = "CUIDADO";
      colorFiscal = AppTheme.goalOrange;
      subtitulo = "$_alertsWarning cerca del límite";
    } else {
      estadoFiscal = "SEGURO";
      colorFiscal = AppTheme.goalGreen;
      subtitulo = "Topes bajo control";
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TaxScreen()),
      ).then((_) => _loadAllData()),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF1A1A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MONITOR FISCAL",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorFiscal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                estadoFiscal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo2',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INVOICE ALERTS SECTION (Facturas Electrónicas)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInvoiceAlertsSection() {
    // Cálculos de alertas
    final porcentajeDeclaracion = (_ingresosFE / _topeDeclaracion * 100).clamp(0.0, 100.0);
    final faltaParaDeclarar = (_topeDeclaracion - _ingresosFE).clamp(0.0, _topeDeclaracion);
    final ahorroFE = _descuento1Porciento;

    // Determinar alerta de ingresos
    Color colorAlertaIngreso;
    String textoAlertaIngreso;
    IconData iconoAlertaIngreso;

    if (_ingresosFE >= _topeDeclaracion) {
      colorAlertaIngreso = AppTheme.errorColor;
      textoAlertaIngreso = "Debes declarar renta el próximo año";
      iconoAlertaIngreso = Icons.warning_rounded;
    } else if (porcentajeDeclaracion >= 80) {
      colorAlertaIngreso = AppTheme.goalOrange;
      textoAlertaIngreso = "Cerca del tope (${porcentajeDeclaracion.toStringAsFixed(0)}%)";
      iconoAlertaIngreso = Icons.info_outline;
    } else {
      colorAlertaIngreso = AppTheme.goalGreen;
      textoAlertaIngreso = "Aún no estás obligado a declarar";
      iconoAlertaIngreso = Icons.check_circle_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 15),
          child: Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 20, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                "FACTURA ELECTRÓNICA",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  fontFamily: 'Baloo2',
                ),
              ),
            ],
          ),
        ),

        // 1. ALERTA DE INGRESOS
        _buildInvoiceAlertCard(
          title: "Ingresos Facturados",
          subtitle: textoAlertaIngreso,
          mainValue: formatCurrency(_ingresosFE),
          secondaryInfo: "Faltan ${formatCurrency(faltaParaDeclarar)} para declarar",
          progress: porcentajeDeclaracion / 100,
          color: colorAlertaIngreso,
          icon: iconoAlertaIngreso,
        ),

        const SizedBox(height: 12),

        // 2. CONTADOR DE AHORRO (1%)
        _buildInvoiceAlertCard(
          title: "Tu Ahorro Fiscal",
          subtitle: "Descuento del 1% en gastos con FE",
          mainValue: formatCurrency(ahorroFE),
          secondaryInfo: "De ${formatCurrency(_gastoConFE)} en compras",
          progress: null,
          color: AppTheme.primaryColor,
          icon: Icons.savings_outlined,
          isPositive: true,
        ),

        const SizedBox(height: 12),

        // 3. ALERTA DE DINERO PERDIDO
        if (_dineroPerdido > 0)
          _buildInvoiceAlertCard(
            title: "Oportunidad Perdida",
            subtitle: "Gastos sin Factura Electrónica",
            mainValue: formatCurrency(_dineroPerdido),
            secondaryInfo: "No podrás deducir estos gastos",
            progress: null,
            color: Colors.orange,
            icon: Icons.error_outline,
            isNegative: true,
          ),
      ],
    );
  }

  Widget _buildInvoiceAlertCard({
    required String title,
    required String subtitle,
    required String mainValue,
    required String secondaryInfo,
    required double? progress,
    required Color color,
    required IconData icon,
    bool isPositive = false,
    bool isNegative = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'Baloo2',
                      ),
                    ),
                  ],
                ),
              ),
              if (isPositive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.goalGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "AHORRO",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                ),
              if (isNegative)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "PÉRDIDA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 15),

          // Main Value
          Text(
            mainValue,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              fontFamily: 'Baloo2',
            ),
          ),

          const SizedBox(height: 6),

          // Secondary Info
          Text(
            secondaryInfo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Baloo2',
            ),
          ),

          // Progress Bar (si aplica)
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CASHFLOW ROW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCashflowRow() {
    final double flujoNeto = _totalIncome - _totalExpense;
    final bool isPositive = flujoNeto >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Flujo Neto",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: 'Baloo2',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Ahorro potencial del mes",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontFamily: 'Baloo2',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppTheme.primaryColor : AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                "${isPositive ? '+' : ''}${formatCurrency(flujoNeto)}",
                style: TextStyle(
                  color: isPositive ? AppTheme.primaryColor : AppTheme.errorColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  fontFamily: 'Baloo2',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

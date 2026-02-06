import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/api/user_api.dart';
import 'package:MyPocket/api/tax_api.dart';
import 'package:MyPocket/api/budget_api.dart';
import 'package:MyPocket/api/savings_goals_api.dart';
import 'package:MyPocket/models/savings_goal.dart';
import 'package:MyPocket/Screens/service/tax_screen.dart';
import 'package:MyPocket/Screens/service/budgets_list_screen.dart';
import 'package:MyPocket/Screens/service/savings_goals_screen_new.dart';
import 'package:MyPocket/utils/dashboard_utils.dart';
import 'package:MyPocket/Widgets/dashboard/hero_balance_card.dart';
import 'package:MyPocket/Widgets/dashboard/info_card_widget.dart';
import 'package:MyPocket/Widgets/dashboard/tax_monitor_card.dart';
import 'package:MyPocket/Widgets/dashboard/invoice_alerts_section.dart';
import 'package:MyPocket/Widgets/dashboard/cashflow_row_widget.dart';

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
  double _dineroPerdido = 0;
  double _ingresosFE = 0;

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

      _balance = DashboardUtils.safeParse(homeData['balance']);
      _totalIncome = DashboardUtils.safeParse(financialData['total_income']);
      _totalExpense = DashboardUtils.safeParse(financialData['total_expense']);

      // Factura Electrónica
      _gastoConFE = DashboardUtils.safeParse(taxData['gasto_con_fe']);
      _gastoSinFE = DashboardUtils.safeParse(taxData['gasto_sin_fe']);
      _ingresosFE = DashboardUtils.safeParse(taxData['ingreso_con_fe']);

      // Si no hay datos de FE, estimar basado en totales
      if (_gastoConFE == 0 && _gastoSinFE == 0 && _totalExpense > 0) {
        _gastoConFE = _totalExpense * 0.6;
        _gastoSinFE = _totalExpense * 0.4;
      }

      if (_ingresosFE == 0 && _totalIncome > 0) {
        _ingresosFE = _totalIncome * 0.7; // Estimar 70% con FE
      }

      final topeMinimo = 5 * DashboardUtils.uvt2025;
      _dineroPerdido = _gastoSinFE > topeMinimo ? _gastoSinFE : 0;

      final alertsList = DashboardUtils.extractAlertsList(taxAlerts);
      _alertsExceeded = alertsList.where((a) => a['status'] == 'exceeded').length;
      _alertsWarning = alertsList.where((a) => a['status'] == 'warning').length;

      _goals = goals;
      _totalSaved = goals.fold(0.0, (sum, g) => sum + g.savedAmount);
      _totalGoalTarget = goals.fold(0.0, (sum, g) => sum + g.targetAmount);

      _totalBudgetAmount = budgets.fold(0.0, (sum, b) => sum + DashboardUtils.safeParse(b['total_amount']));
      _totalBudgetSpent = budgets.fold(0.0, (sum, b) => sum + DashboardUtils.safeParse(b['spent_amount']));

      setState(() => _loading = false);
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
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
                  clipBehavior: Clip.hardEdge,
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
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
                          child: Column(
                            children: [
                              // A. TARJETA PRINCIPAL (BALANCE)
                              HeroBalanceCard(
                                balance: _balance,
                                totalIncome: _totalIncome,
                                totalExpense: _totalExpense,
                              ),

                              const SizedBox(height: 25),

                              // B. ACCESOS RÁPIDOS (METAS Y PRESUPUESTO)
                              Row(
                                children: [
                                  Expanded(
                                    child: InfoCardWidget(
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
                                    child: InfoCardWidget(
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
                              TaxMonitorCard(
                                alertsExceeded: _alertsExceeded,
                                alertsWarning: _alertsWarning,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TaxScreen()),
                                ).then((_) => _loadAllData()),
                              ),

                              const SizedBox(height: 25),

                              // D. ALERTAS DE FACTURA ELECTRÓNICA
                              InvoiceAlertsSection(
                                ingresosFE: _ingresosFE,
                                gastoConFE: _gastoConFE,
                                dineroPerdido: _dineroPerdido,
                              ),

                              const SizedBox(height: 25),

                              // E. FLUJO DE CAJA
                              CashflowRowWidget(
                                totalIncome: _totalIncome,
                                totalExpense: _totalExpense,
                              ),

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
}

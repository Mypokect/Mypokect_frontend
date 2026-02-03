import 'package:flutter/material.dart';
import '../../Theme/theme.dart';
import '../../Widgets/common/text_widget.dart';
import '../../api/user_api.dart';
import '../../api/savings_goals_api.dart';
import '../../utils/helpers.dart';

class BalanceDetailScreen extends StatefulWidget {
  const BalanceDetailScreen({super.key});

  @override
  State<BalanceDetailScreen> createState() => _BalanceDetailScreenState();
}

class _BalanceDetailScreenState extends State<BalanceDetailScreen> {
  final UserApi _userApi = UserApi();
  final SavingsGoalsApi _goalsApi = SavingsGoalsApi();

  bool _isLoading = true;
  double _balance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _totalGoalContributionsMonth = 0.0; // Aportes del mes
  double _totalInGoals = 0.0; // Total acumulado en metas
  Map<String, double> _topTags = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBalanceData();
  }

  Future<void> _loadBalanceData() async {
    try {
      print('═══════════════════════════════════════════');
      print('🏁 INICIANDO CARGA DE BALANCE DETAIL SCREEN');
      print('═══════════════════════════════════════════');

      // Obtener datos del home (balance)
      print('📌 PASO 1: Obteniendo balance...');
      final homeData = await _userApi.getHomeData();
      _balance = double.parse(homeData['balance'].toString());
      print('✅ Balance obtenido: $_balance');

      // Obtener datos financieros detallados
      print('\n📌 PASO 2: Llamando a getFinancialSummary()...');
      final financialData = await _userApi.getFinancialSummary();
      print('📦 Datos financieros recibidos: $financialData');

      // Detectar si hubo error
      if (financialData.containsKey('_error')) {
        _errorMessage = financialData['_error'];
        print('⚠️  Se detectó error en financial summary: $_errorMessage');
      }

      _totalIncome = financialData['total_income']?.toDouble() ?? 0.0;
      _totalExpense = financialData['total_expense']?.toDouble() ?? 0.0;
      _totalGoalContributionsMonth = financialData['total_goal_contributions']?.toDouble() ?? 0.0;

      // Convertir top_tags asegurando que los valores sean double
      final topTagsData = Map<String, dynamic>.from(financialData['top_tags'] ?? {});
      _topTags = topTagsData.map((key, value) => MapEntry(
        key,
        (value as num).toDouble(),
      ));

      print('💰 Ingresos parseados: $_totalIncome');
      print('💸 Gastos parseados: $_totalExpense');
      print('🎯 Aportes a metas del mes: $_totalGoalContributionsMonth');
      print('🏷️  Top tags parseados: $_topTags');

      // Obtener metas y sumar el dinero ahorrado
      print('\n📌 PASO 3: Obteniendo metas...');
      final goals = await _goalsApi.getGoals();
      _totalInGoals = goals.fold(
        0.0,
        (sum, goal) => sum + goal.savedAmount,
      );
      print('🎯 Total en metas: $_totalInGoals');
      print('═══════════════════════════════════════════');
      print('✅ CARGA COMPLETADA EXITOSAMENTE');
      print('═══════════════════════════════════════════\n');

      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════');
      print('❌ ERROR CRÍTICO EN _loadBalanceData');
      print('🔥 Error: $e');
      print('🔥 StackTrace: $stackTrace');
      print('═══════════════════════════════════════════\n');

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.greyColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextWidget(
          text: 'Resumen Financiero',
          color: Colors.black87,
          size: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Total
                  _buildBalanceCard(),
                  const SizedBox(height: 30),

                  // Ingresos y Gastos
                  TextWidget(
                    text: 'Este mes',
                    color: AppTheme.greyColor,
                    size: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildIncomeCard()),
                      const SizedBox(width: 15),
                      Expanded(child: _buildExpenseCard()),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Aportes a metas del mes
                  _buildGoalContributionsMonthCard(),
                  const SizedBox(height: 30),

                  // Dinero total acumulado en Metas
                  _buildGoalsCard(),
                  const SizedBox(height: 30),

                  // Top Etiquetas (si hay)
                  if (_topTags.isNotEmpty) ...[
                    TextWidget(
                      text: 'Categorías frecuentes',
                      color: AppTheme.greyColor,
                      size: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 15),
                    _buildTopTagsSection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(25),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Balance Total',
                  color: AppTheme.greyColor,
                  size: 14,
                ),
                const SizedBox(height: 10),
                TextWidget(
                  text: formatCurrency(_balance),
                  color: Colors.black,
                  size: 28,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.trending_up,
              color: Colors.green.shade700,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          TextWidget(
            text: 'Ingresos',
            color: AppTheme.greyColor,
            size: 13,
          ),
          const SizedBox(height: 6),
          TextWidget(
            text: formatCurrency(_totalIncome),
            color: Colors.black,
            size: 20,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.trending_down,
              color: Colors.red.shade700,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          TextWidget(
            text: 'Gastos',
            color: AppTheme.greyColor,
            size: 13,
          ),
          const SizedBox(height: 6),
          TextWidget(
            text: formatCurrency(_totalExpense),
            color: Colors.black,
            size: 20,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalContributionsMonthCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.toll_outlined,
              color: Colors.purple.shade700,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          TextWidget(
            text: 'Aportes a metas',
            color: AppTheme.greyColor,
            size: 13,
          ),
          const SizedBox(height: 6),
          TextWidget(
            text: formatCurrency(_totalGoalContributionsMonth),
            color: Colors.black,
            size: 20,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(22),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.savings_outlined,
              color: AppTheme.primaryColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Total acumulado en metas',
                  color: AppTheme.greyColor,
                  size: 14,
                ),
                const SizedBox(height: 6),
                TextWidget(
                  text: formatCurrency(_totalInGoals),
                  color: Colors.black,
                  size: 24,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTagsSection() {
    final entries = _topTags.entries.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.map((entry) {
          final isLast = entry == entries.last;
          return Container(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextWidget(
                    text: entry.key,
                    color: Colors.black87,
                    size: 15,
                  ),
                ),
                TextWidget(
                  text: formatCurrency(entry.value),
                  color: AppTheme.greyColor,
                  size: 15,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

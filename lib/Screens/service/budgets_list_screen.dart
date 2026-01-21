import 'package:flutter/material.dart';

import 'package:MyPocket/api/budget_api.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/Widgets/budget/budget_list_card_widget.dart';
import 'package:MyPocket/Screens/service/budget_screen.dart';
import 'package:MyPocket/utils/helpers.dart';

class BudgetsListScreen extends StatefulWidget {
  const BudgetsListScreen({super.key});

  @override
  State<BudgetsListScreen> createState() => _BudgetsListScreenState();
}

class _BudgetsListScreenState extends State<BudgetsListScreen> {
  final BudgetApi _budgetApi = BudgetApi();
  late Future<List<dynamic>> _budgetsFuture;

  double _totalGlobal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    setState(() {
      _budgetsFuture = _budgetApi.getBudgets().then((data) {
        double sum = 0.0;
        for (var item in data) {
          sum += double.tryParse(item['total_amount'].toString()) ?? 0.0;
        }
        _totalGlobal = sum;
        return data;
      });
    });
  }

  Future<void> _navigateToDetail(Map<String, dynamic>? budget) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BudgetScreen(existingBudget: budget)),
    );
    _loadBudgets();
  }

  Future<void> _deleteBudget(
      int id, int index, List<dynamic> currentList) async {
    final deletedItem = currentList[index];
    setState(() {
      currentList.removeAt(index);
      _totalGlobal -=
          double.tryParse(deletedItem['total_amount'].toString()) ?? 0.0;
    });

    try {
      await _budgetApi.deleteBudget(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Plan eliminado"), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      setState(() {
        currentList.insert(index, deletedItem);
        _totalGlobal +=
            double.tryParse(deletedItem['total_amount'].toString()) ?? 0.0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildMainContent(),
          _buildSummaryCard(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned(
      top: 30,
      left: 0,
      right: 0,
      child: Image.asset('assets/images/fondo-moderno-verde-ondulado1.png',
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
          height: 200),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 95),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextWidget(
              text: 'Mis Presupuestos',
              color: Colors.white,
              size: 24,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _buildWhiteBody(),
        ),
      ],
    );
  }

  Widget _buildWhiteBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: FutureBuilder<List<dynamic>>(
        future: _budgetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final budgets = snapshot.data!;

          return ListView.builder(
            padding:
                const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 80),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return BudgetListCardWidget(
                title: budget['title'] ?? 'Sin título',
                amount:
                    double.tryParse(budget['total_amount'].toString()) ?? 0.0,
                mode: budget['mode'] ?? 'manual',
                onTap: () => _navigateToDetail(budget),
                onDismiss: () => _deleteBudget(budget['id'], index, budgets),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Positioned(
      top: 150,
      left: 20,
      child: Container(
        width: 220,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            _buildSummaryIcon(),
            const SizedBox(width: 10),
            _buildSummaryText(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryIcon() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: Center(
          child: Icon(Icons.account_balance_wallet,
              color: AppTheme.primaryColor, size: 28)),
    );
  }

  Widget _buildSummaryText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Total Planificado",
            style: TextStyle(fontSize: 10, color: Colors.grey)),
        FutureBuilder(
            future: _budgetsFuture,
            builder: (context, snapshot) {
              return TextWidget(
                  text: snapshot.hasData ? formatCurrency(_totalGlobal) : "...",
                  color: AppTheme.primaryColor,
                  size: 14,
                  fontWeight: FontWeight.bold);
            }),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: 'fab_budget_list_unique',
        onPressed: () => _navigateToDetail(null),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        icon:
            const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
        label: const Text("CREAR PLAN",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_customize_outlined,
                size: 60, color: Colors.grey[300]),
            const SizedBox(height: 15),
            Text("Aún no tienes planes",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            const Text("Toca el botón 'Crear Plan' para empezar.",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../api/budget_api.dart';
import '../../Theme/Theme.dart';
import '../../Widgets/TextWidget.dart';
import 'budget_screen.dart'; 

class BudgetsListScreen extends StatefulWidget {
  const BudgetsListScreen({Key? key}) : super(key: key);

  @override
  BudgetsListScreenState createState() => BudgetsListScreenState();
}

class BudgetsListScreenState extends State<BudgetsListScreen> {
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
        double sum = 0;
        for (var item in data) {
          sum += double.tryParse(item['total_amount'].toString()) ?? 0;
        }
        _totalGlobal = sum;
        return data;
      });
    });
  }

  void _navigateToDetail(Map<String, dynamic>? budget) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BudgetScreen(existingBudget: budget)),
    );
    _loadBudgets(); 
  }

  void _deleteBudget(int id, int index, List<dynamic> currentList) async {
    final deletedItem = currentList[index];
    
    setState(() {
      currentList.removeAt(index);
      _totalGlobal -= double.tryParse(deletedItem['total_amount'].toString()) ?? 0;
    });

    try {
      await _budgetApi.deleteBudget(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plan eliminado"), duration: Duration(seconds: 2)),
      );
    } catch (e) {
      setState(() {
        currentList.insert(index, deletedItem);
        _totalGlobal += double.tryParse(deletedItem['total_amount'].toString()) ?? 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo casi blanco, muy limpio
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. HEADER ELÁSTICO ---
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "Mis Proyectos", 
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)
              ),
              background: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // Usamos tu color primario y uno un poco más oscuro para dar profundidad
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8), 
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decoración de fondo sutil
                    Positioned(
                      top: -50, right: -50,
                      child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1)),
                    ),
                    Positioned(
                      bottom: -30, left: 20,
                      child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
                    ),
                    
                    // Contenido del Header
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3))
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 30),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "TOTAL PLANIFICADO", 
                            style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)
                          ),
                          const SizedBox(height: 5),
                          FutureBuilder(
                            future: _budgetsFuture,
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.hasData ? _formatCurrency(_totalGlobal) : "...",
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 34, 
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1
                                ),
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. LISTA DE TARJETAS ---
          FutureBuilder<List<dynamic>>(
            future: _budgetsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return SliverFillRemaining(child: Center(child: Text("Error: ${snapshot.error}")));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(child: _EmptyStateWidget());
              }

              final budgets = snapshot.data!;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final budget = budgets[index];
                      return _buildPremiumCard(budget, index, budgets);
                    },
                    childCount: budgets.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      
      // --- 3. BOTÓN FLOTANTE ELEGANTE ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToDetail(null),
        backgroundColor: Colors.black, // El negro combina bien con todo y se ve moderno
        elevation: 10,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("CREAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- TARJETA PREMIUM (COMBINA CON EL TEMA) ---
  Widget _buildPremiumCard(dynamic budget, int index, List<dynamic> list) {
    String title = budget['title'] ?? 'Sin título';
    double total = double.tryParse(budget['total_amount'].toString()) ?? 0.0;
    String mode = budget['mode'] ?? 'manual';
    int id = budget['id'];

    bool isAI = mode == 'ai';

    // ESTILOS DINÁMICOS QUE COMBINAN CON TU APP
    
    // Si es IA: Usa tu color primario con degradado
    // Si es Manual: Blanco limpio
    List<Color> gradient = isAI 
        ? [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)] 
        : [Colors.white, Colors.white];
    
    Color textColor = isAI ? Colors.white : Colors.black87;
    Color subTextColor = isAI ? Colors.white70 : Colors.grey;
    Color iconBg = isAI ? Colors.white.withOpacity(0.2) : const Color(0xFFF3F4F6);
    Color iconColor = isAI ? Colors.white : AppTheme.primaryColor;

    return Dismissible(
      key: Key(id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4757),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFFFF4757).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
      ),
      onDismissed: (_) => _deleteBudget(id, index, list),
      child: GestureDetector(
        onTap: () => _navigateToDetail(budget),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [
              BoxShadow(
                color: isAI ? AppTheme.primaryColor.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Stack(
            children: [
              // Decoración de fondo sutil (Olas abstractas)
              if (isAI)
                Positioned(
                  right: -10, bottom: -10,
                  child: Icon(Icons.auto_awesome, size: 100, color: Colors.white.withOpacity(0.1)),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Columna Izquierda: Icono y Datos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(isAI ? Icons.bolt : Icons.edit, size: 12, color: iconColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      isAI ? "INTELIGENCIA ARTIFICIAL" : "MANUAL", 
                                      style: TextStyle(
                                        fontSize: 10, 
                                        fontWeight: FontWeight.w800, 
                                        color: iconColor
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            title, 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Presupuesto asignado", 
                            style: TextStyle(color: subTextColor, fontSize: 12)
                          ),
                        ],
                      ),
                    ),
                    
                    // Columna Derecha: Monto Grande
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(total),
                          style: TextStyle(
                            color: textColor, 
                            fontSize: 20, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return "\$ ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}";
  }
}

// Widget Estado Vacío Limpio
class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle
            ),
            child: Icon(Icons.dashboard_outlined, size: 60, color: AppTheme.primaryColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          Text("Tu tablero está vacío", style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Crea tu primer plan financiero.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
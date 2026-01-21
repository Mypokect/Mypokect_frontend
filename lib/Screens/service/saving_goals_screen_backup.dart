import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/Widgets/common/button_custom.dart';
import 'package:MyPocket/Widgets/savings/circular_progress_custom.dart';
import 'package:MyPocket/Widgets/savings/savings_goal_card_widget.dart';
import 'package:MyPocket/api/savings_goals_api.dart';
import 'package:MyPocket/models/savings_goal.dart';
import 'package:MyPocket/Screens/movements.dart';

class SavingGoalsScreen extends StatefulWidget {
  const SavingGoalsScreen({super.key});

  @override
  State<SavingGoalsScreen> createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen>
    with SingleTickerProviderStateMixin {
  final SavingsGoalsApi _api = SavingsGoalsApi();
  List<SavingsGoal> _goals = [];
  bool _isLoading = true;
  late AnimationController _fabAnimationController;
  Animation<double>? _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabAnimationController.forward();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final goals = await _api.getGoals();
      if (mounted) {
        setState(() {
          _goals = goals;
          _isLoading = false;
        });
        _fabAnimationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar metas: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleContribute(SavingsGoal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Movements(),
        settings: RouteSettings(
          arguments: {
            'preSelectedTag': goal.name,
            'isExpense': false,
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  double get _totalSavings {
    return _goals.fold<double>(
      0,
      (sum, goal) => sum + goal.currentAmount,
    );
  }

  int get _completedGoals {
    return _goals.where((goal) {
      final current = goal.currentAmount;
      final target = goal.targetAmount;
      return current >= target;
    }).length;
  }

  Future<void> _createGoal({
    required String name,
    required double targetAmount,
  }) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _api.createGoal(
          name: name,
          tag: name.toLowerCase().replaceAll(' ', '_'),
          targetAmount: targetAmount,
          emoji: '🎯',
          icon: 'flag',
          color: '#006B52',
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("¡Meta creada exitosamente!"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            _loadGoals();
          }
        } else {
          final message = response.statusCode == 500
              ? "Error del servidor"
              : "Error al crear la meta";

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error de conexión: ${e.toString()}"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _showCreateGoalDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextWidget(
              text: "Nueva Meta de Ahorro",
              size: 24,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nombre de la meta",
                hintText: "Ej: Vacaciones, Auto Nuevo",
                prefixIcon: const Icon(Icons.emoji_events_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monto objetivo",
                hintText: "Ej: 5000000",
                prefixText: "\$",
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final name = nameController.text.trim();
                    final amount = double.tryParse(
                        amountController.text.replaceAll(',', ''));

                    if (name.isEmpty || amount == null || amount! <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Por favor completa todos los campos"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    _createGoal(name: name, targetAmount: amount!);
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: const Center(
                    child: TextWidget(
                      text: "Crear Meta",
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const TextWidget(
          text: "Metas de Ahorro",
          size: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: Icon(Icons.add_circle_outline,
                  color: AppTheme.primaryColor, size: 28),
              onPressed: _showCreateGoalDialog,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _goals.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadGoals,
                  color: AppTheme.primaryColor,
                  child: FadeTransition(
                    opacity: _fabScaleAnimation ?? AlwaysStoppedAnimation(1.0),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        return SavingsGoalCardWidget(
                          name: _goals[index].name,
                          emoji: _goals[index].emoji,
                          icon: _goals[index].icon,
                          color: _goals[index].color,
                          currentAmount: _goals[index].currentAmount,
                          targetAmount: _goals[index].targetAmount,
                          onContribute: () => _handleContribute(_goals[index]),
                          index: index,
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation?.value ?? 1.0,
            child: child,
          );
        },
        child: FloatingActionButton.extended(
          heroTag: 'fab_savings_goals_backup_unique',
          onPressed: _showCreateGoalDialog,
          backgroundColor: AppTheme.primaryColor,
          elevation: 8,
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          label: const TextWidget(
            text: "Nueva Meta",
            size: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const TextWidget(
            text: "Aún no tienes metas de ahorro",
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          const TextWidget(
            text: "Crea tu primera meta para empezar",
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(height: 30),
          ButtonCustom(
            text: "Crear Meta",
            onTap: _showCreateGoalDialog,
          ),
        ],
      ),
    );
  }
}

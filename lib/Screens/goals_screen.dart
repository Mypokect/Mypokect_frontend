import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/Widgets/goals/goal_card_widget.dart';
import 'package:MyPocket/Widgets/goals/goals_summary_widget.dart';
import 'package:MyPocket/Screens/movements.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  List<Map<String, dynamic>> _goals = [
    {
      'id': '1',
      'name': 'Vacaciones en Europa',
      'emoji': '✈️',
      'icon': Icons.flight,
      'color': const Color(0xFF2196F3),
      'currentAmount': 3500000,
      'targetAmount': 8000000,
    },
    {
      'id': '2',
      'name': 'MacBook Pro M3',
      'emoji': '💻',
      'icon': Icons.computer,
      'color': const Color(0xFF9C27B0),
      'currentAmount': 2800000,
      'targetAmount': 5000000,
    },
    {
      'id': '3',
      'name': 'Auto Nuevo',
      'emoji': '🚗',
      'icon': Icons.directions_car,
      'color': const Color(0xFFFF5722),
      'currentAmount': 15000000,
      'targetAmount': 35000000,
    },
    {
      'id': '4',
      'name': 'Fondo de Emergencia',
      'emoji': '🏦',
      'icon': Icons.account_balance,
      'color': const Color(0xFF4CAF50),
      'currentAmount': 8500000,
      'targetAmount': 10000000,
    },
    {
      'id': '5',
      'name': 'PlayStation 5',
      'emoji': '🎮',
      'icon': Icons.sports_esports,
      'color': const Color(0xFF00BCD4),
      'currentAmount': 1200000,
      'targetAmount': 3500000,
    },
    {
      'id': '6',
      'name': 'Gimnasio Anual',
      'emoji': '💪',
      'icon': Icons.fitness_center,
      'color': const Color(0xFFE91E63),
      'currentAmount': 0,
      'targetAmount': 800000,
    },
  ];

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
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  double get _totalSavings {
    return _goals.fold<double>(
      0,
      (sum, goal) => sum + (goal['currentAmount'] as double),
    );
  }

  int get _completedGoals {
    return _goals.where((goal) {
      final current = goal['currentAmount'] as double;
      final target = goal['targetAmount'] as double;
      return current >= target;
    }).length;
  }

  void _handleContribute(Map<String, dynamic> goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Movements(),
        settings: RouteSettings(
          arguments: {
            'preSelectedTag': goal['name'] as String,
            'isExpense': false,
          },
        ),
      ),
    );
  }

  void _showCreateGoalDialog() {
    final nameController = TextEditingController();
    final targetController = TextEditingController();

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
              controller: targetController,
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
                  onTap: () => Navigator.pop(context),
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
          text: "Mis Metas",
          size: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GoalsSummaryWidget(
                totalSavings: _totalSavings,
                totalGoals: _goals.length,
                completedGoals: _completedGoals,
              ),
              const SizedBox(height: 30),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85,
                ),
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  return GoalCard(
                    id: goal['id'] as String,
                    name: goal['name'] as String,
                    emoji: goal['emoji'] as String,
                    icon: goal['icon'] as IconData,
                    color: goal['color'] as Color,
                    currentAmount: goal['currentAmount'] as double,
                    targetAmount: goal['targetAmount'] as double,
                    onContribute: () => _handleContribute(goal),
                    index: index,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: child,
          );
        },
        child: FloatingActionButton.extended(
          heroTag: 'fab_goals_screen_unique',
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
}

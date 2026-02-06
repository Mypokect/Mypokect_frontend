import 'package:flutter/material.dart';
import '../../Controllers/goals_controller.dart';
import '../../models/savings_goal.dart';
import '../../Widgets/goals/goal_header_summary.dart';
import '../../Widgets/goals/goal_card_improved.dart';
import '../../api/savings_goals_api.dart';
import '../movements.dart';
import 'goal_form_screen.dart';
import 'goal_history_screen.dart';
import '../../Theme/Theme.dart';

/// New and improved savings goals screen with enhanced UI
/// Shows total progress, grid of goal cards, and easy access to actions
class SavingsGoalsScreenNew extends StatefulWidget {
  const SavingsGoalsScreenNew({super.key});

  @override
  State<SavingsGoalsScreenNew> createState() => _SavingsGoalsScreenNewState();
}

class _SavingsGoalsScreenNewState extends State<SavingsGoalsScreenNew> {
  final GoalsController _controller = GoalsController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    await _controller.loadGoals();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshGoals() async {
    await _controller.refreshGoals();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // Fondo ondulado (mismo que Home)
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

          // Contenido principal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 95),
              // Título
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Metas de Ahorro',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Baloo2',
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Cuerpo blanco con bordes redondeados
              Expanded(
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: _isLoading ? _buildLoading() : _buildBody(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Loading indicator
  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
      ),
    );
  }

  /// Main body with pull-to-refresh
  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refreshGoals,
      color: AppTheme.primaryColor,
      child: _controller.goals.isEmpty ? _buildEmptyState() : _buildGoalsList(),
    );
  }

  /// Goals list with header and grid
  Widget _buildGoalsList() {
    final totalProgress = _controller.getTotalProgress();

    return CustomScrollView(
      slivers: [
        // Header Summary
        SliverToBoxAdapter(
          child: GoalHeaderSummary(
            totalSaved: totalProgress['total_saved'],
            totalTarget: totalProgress['total_target'],
            completedCount: totalProgress['completed_count'],
            totalCount: totalProgress['total_count'],
            progressColor: AppTheme.primaryColor,
          ),
        ),

        // Grid of goal cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final goal = _controller.goals[index];
                return GoalCardImproved(
                  goal: goal,
                  onAbonar: () => _navigateToAbonar(goal),
                  onEdit: () => _navigateToEdit(goal),
                  onDelete: () => _deleteGoal(goal),
                  onViewHistory: () => _navigateToHistory(goal),
                );
              },
              childCount: _controller.goals.length,
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  /// Empty state when no goals exist
  Widget _buildEmptyState() {
    return ListView(
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.savings_outlined,
                size: 100,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                'Sin metas de ahorro',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo2',
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Crea tu primera meta y comienza a ahorrar para tus objetivos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade500,
                    fontFamily: 'Baloo2',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('CREAR META'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo2',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Floating action button to create new goal
  Widget _buildFAB() {
    if (_controller.goals.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: _navigateToCreate,
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Navigate to create goal form
  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoalFormScreen(),
      ),
    );

    if (result == true && mounted) {
      _refreshGoals();
    }
  }

  /// Navigate to edit goal form
  Future<void> _navigateToEdit(SavingsGoal goal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalFormScreen(goalToEdit: goal),
      ),
    );

    if (result == true && mounted) {
      _refreshGoals();
    }
  }

  /// Navigate to abonar (using movements screen with goal mode)
  Future<void> _navigateToAbonar(SavingsGoal goal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Movements(
          preSelectedTag: goal.tag,
        ),
      ),
    );

    if (result == true && mounted) {
      _refreshGoals();
    }
  }

  /// Navigate to goal history screen
  Future<void> _navigateToHistory(SavingsGoal goal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalHistoryScreen(goal: goal),
      ),
    );

    // Refresh in case contributions were deleted
    if (mounted) {
      _refreshGoals();
    }
  }

  /// Delete goal with confirmation
  Future<void> _deleteGoal(SavingsGoal goal) async {
    try {
      final success = await _controller.deleteGoal(goal.id);

      if (!mounted) return;

      if (success) {
        SavingsGoalsApi.clearCache();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meta "${goal.name}" eliminada'),
            backgroundColor: AppTheme.goalGreen,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.expenseDarkColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

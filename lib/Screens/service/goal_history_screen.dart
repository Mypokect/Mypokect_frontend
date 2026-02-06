import 'package:flutter/material.dart';
import '../../models/savings_goal.dart';
import '../../models/goal_contribution.dart';
import '../../Controllers/goals_controller.dart';
import '../../Widgets/goals/contribution_item.dart';
import '../../utils/goal_helpers.dart';

/// Screen showing contribution history for a specific goal
class GoalHistoryScreen extends StatefulWidget {
  final SavingsGoal goal;

  const GoalHistoryScreen({super.key, required this.goal});

  @override
  State<GoalHistoryScreen> createState() => _GoalHistoryScreenState();
}

class _GoalHistoryScreenState extends State<GoalHistoryScreen> {
  final GoalsController _controller = GoalsController();
  List<GoalContribution> _contributions = [];
  Map<String, List<GoalContribution>> _groupedContributions = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final contributions = await _controller.getContributions(widget.goal.id);
      final grouped = await _controller.getContributionsByMonth(widget.goal.id);

      if (mounted) {
        setState(() {
          _contributions = contributions;
          _groupedContributions = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshHistory() async {
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF006B52),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.goal.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.goal.name,
                  style: const TextStyle(
                    fontFamily: 'Baloo2',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            'Historial de abonos',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontFamily: 'Baloo2',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(widget.goal.progressColor),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    if (_contributions.isEmpty) {
      return ContributionEmptyState(goalName: widget.goal.name);
    }

    return RefreshIndicator(
      onRefresh: _refreshHistory,
      color: widget.goal.progressColor,
      child: CustomScrollView(
        slivers: [
          // Goal Summary Header
          SliverToBoxAdapter(
            child: _buildGoalSummary(),
          ),

          // Contribution Stats
          SliverToBoxAdapter(
            child: _buildContributionStats(),
          ),

          // Grouped Contributions List
          ..._buildGroupedContributions(),
        ],
      ),
    );
  }

  Widget _buildGoalSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress Circle
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: widget.goal.progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF006B52)),
                ),
                Text(
                  '${(widget.goal.progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006B52),
                    fontFamily: 'Baloo2',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.goal.formattedSavedAmount} / ${widget.goal.formattedTargetAmount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo2',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.goal.isCompleted
                      ? '¡Meta completada! 🎉'
                      : 'Falta: ${widget.goal.formattedRemaining}',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.goal.isCompleted
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade600,
                    fontFamily: 'Baloo2',
                  ),
                ),
                if (widget.goal.deadline != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: widget.goal.deadlineColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        GoalHelpers.getRemainingTimeText(
                          widget.goal.deadline,
                          widget.goal.isCompleted,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.goal.deadlineColor,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionStats() {
    final totalContributions = _contributions.length;
    final totalAmount = _contributions.fold<double>(
      0.0,
      (sum, c) => sum + c.amount,
    );
    final averageAmount =
        totalContributions > 0 ? totalAmount / totalContributions : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.savings,
            label: 'Total',
            value: GoalHelpers.formatCurrency(totalAmount, compact: true),
            color: const Color(0xFF006B52),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
          ),
          _buildStatItem(
            icon: Icons.add_circle_outline,
            label: 'Abonos',
            value: totalContributions.toString(),
            color: const Color(0xFF006B52),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
          ),
          _buildStatItem(
            icon: Icons.show_chart,
            label: 'Promedio',
            value: GoalHelpers.formatCurrency(averageAmount, compact: true),
            color: const Color(0xFF006B52),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Baloo2',
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontFamily: 'Baloo2',
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedContributions() {
    final widgets = <Widget>[];

    // Sort months in reverse chronological order
    final sortedMonths = _groupedContributions.keys.toList()
      ..sort((a, b) {
        // Simple reverse sort (most recent first)
        return b.compareTo(a);
      });

    for (final month in sortedMonths) {
      final contributions = _groupedContributions[month]!;
      final monthTotal =
          contributions.fold<double>(0.0, (sum, c) => sum + c.amount);

      // Month header
      widgets.add(
        SliverToBoxAdapter(
          child: ContributionMonthHeader(
            monthYear: month,
            contributionCount: contributions.length,
            totalAmount: monthTotal,
          ),
        ),
      );

      // Contributions for this month
      widgets.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final contribution = contributions[index];
              return ContributionItem(
                contribution: contribution,
                onDelete: () => _deleteContribution(contribution),
                showDeleteButton: !widget.goal.isCompleted,
              );
            },
            childCount: contributions.length,
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baloo2',
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontFamily: 'Baloo2',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B52),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteContribution(GoalContribution contribution) async {
    // TODO: Implement delete contribution via API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de eliminar abono - En desarrollo'),
        backgroundColor: Color(0xFF42A5F5),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

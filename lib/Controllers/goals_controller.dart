import 'package:flutter/material.dart';
import '../api/savings_goals_api.dart';
import '../api/goal_contributions_api.dart';
import '../models/savings_goal.dart';
import '../models/goal_contribution.dart';
import '../Core/Managers/tag_history_manager.dart';

/// Business logic controller for savings goals
/// Coordinates between API calls, state management, and UI
class GoalsController extends ChangeNotifier {
  final SavingsGoalsApi _goalsApi = SavingsGoalsApi();
  final GoalContributionsApi _contributionsApi = GoalContributionsApi();

  List<SavingsGoal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get all goals and update state
  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _goalsApi.getGoals();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print("Error loading goals: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a single goal by ID
  Future<SavingsGoal?> getGoalById(String id) async {
    try {
      return await _goalsApi.getGoalById(id);
    } catch (e) {
      print("Error fetching goal: $e");
      return null;
    }
  }

  /// Delete a goal
  Future<bool> deleteGoal(String id) async {
    try {
      // Buscar la meta antes de borrarla para obtener su tag
      final goalToDelete = _goals.firstWhere(
        (goal) => goal.id == id,
        orElse: () => throw Exception('Meta no encontrada'),
      );

      final success = await _goalsApi.deleteGoal(id);
      if (success) {
        // Remove from local list
        _goals.removeWhere((goal) => goal.id == id);

        // Limpiar la etiqueta del historial local (por si quedó guardada)
        await TagHistoryManager.removeTag(goalToDelete.tag);

        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh goals list (pull-to-refresh)
  Future<void> refreshGoals() async {
    SavingsGoalsApi.clearCache();
    await loadGoals();
  }

  /// Get contributions for a specific goal
  Future<List<GoalContribution>> getContributions(String goalId) async {
    try {
      return await _contributionsApi.getContributions(goalId);
    } catch (e) {
      print("Error fetching contributions: $e");
      return [];
    }
  }

  /// Get contributions grouped by month
  Future<Map<String, List<GoalContribution>>> getContributionsByMonth(
      String goalId) async {
    try {
      return await _contributionsApi.getContributionsByMonth(goalId);
    } catch (e) {
      print("Error fetching contributions by month: $e");
      return {};
    }
  }

  /// Get statistics for a goal
  Future<Map<String, dynamic>> getGoalStats(String goalId) async {
    try {
      return await _contributionsApi.getStats(goalId);
    } catch (e) {
      print("Error fetching goal stats: $e");
      return {
        'total_contributions': 0,
        'total_amount': 0.0,
        'average_contribution': 0.0,
        'largest_contribution': 0.0,
        'smallest_contribution': 0.0,
        'last_contribution_date': null,
      };
    }
  }

  /// Calculate total progress across all goals
  Map<String, dynamic> getTotalProgress() {
    if (_goals.isEmpty) {
      return {
        'total_saved': 0.0,
        'total_target': 0.0,
        'progress': 0.0,
        'completed_count': 0,
        'total_count': 0,
      };
    }

    final totalSaved =
        _goals.fold<double>(0.0, (sum, g) => sum + g.savedAmount);
    final totalTarget =
        _goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount);
    final completedCount = _goals.where((g) => g.isCompleted).length;

    return {
      'total_saved': totalSaved,
      'total_target': totalTarget,
      'progress':
          totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0,
      'completed_count': completedCount,
      'total_count': _goals.length,
    };
  }

  /// Get goals filtered by status
  List<SavingsGoal> getGoalsByStatus({
    bool? completed,
    bool? overdue,
  }) {
    return _goals.where((goal) {
      if (completed != null && goal.isCompleted != completed) return false;
      if (overdue != null && goal.isOverdue != overdue) return false;
      return true;
    }).toList();
  }

  /// Get active goals (not completed)
  List<SavingsGoal> get activeGoals => getGoalsByStatus(completed: false);

  /// Get completed goals
  List<SavingsGoal> get completedGoals => getGoalsByStatus(completed: true);

  /// Get overdue goals
  List<SavingsGoal> get overdueGoals =>
      getGoalsByStatus(overdue: true, completed: false);

  /// Get urgent goals (deadline < 15 days)
  List<SavingsGoal> get urgentGoals {
    return _goals.where((goal) {
      if (goal.deadline == null || goal.isCompleted) return false;
      final daysUntil = goal.deadline!.difference(DateTime.now()).inDays;
      return daysUntil < 15 && daysUntil >= 0;
    }).toList();
  }

  /// Sort goals by different criteria
  void sortGoals(GoalSortCriteria criteria, {bool descending = false}) {
    switch (criteria) {
      case GoalSortCriteria.progress:
        _goals.sort((a, b) => descending
            ? b.progress.compareTo(a.progress)
            : a.progress.compareTo(b.progress));
        break;
      case GoalSortCriteria.deadline:
        _goals.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return descending
              ? b.deadline!.compareTo(a.deadline!)
              : a.deadline!.compareTo(b.deadline!);
        });
        break;
      case GoalSortCriteria.amount:
        _goals.sort((a, b) => descending
            ? b.targetAmount.compareTo(a.targetAmount)
            : a.targetAmount.compareTo(b.targetAmount));
        break;
      case GoalSortCriteria.name:
        _goals.sort((a, b) =>
            descending ? b.name.compareTo(a.name) : a.name.compareTo(b.name));
        break;
      case GoalSortCriteria.created:
        _goals.sort((a, b) => descending
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt));
        break;
    }
    notifyListeners();
  }

  /// Search goals by name or tag
  List<SavingsGoal> searchGoals(String query) {
    if (query.isEmpty) return _goals;

    final lowerQuery = query.toLowerCase();
    return _goals.where((goal) {
      return goal.name.toLowerCase().contains(lowerQuery) ||
          goal.tag.toLowerCase().contains(lowerQuery) ||
          goal.emoji.contains(query);
    }).toList();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Enum for goal sorting criteria
enum GoalSortCriteria {
  progress,
  deadline,
  amount,
  name,
  created,
}

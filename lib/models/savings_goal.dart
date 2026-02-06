import 'package:flutter/material.dart';

class SavingsGoal {
  final String id;
  final String name;
  final Color color;
  final double savedAmount;
  final double targetAmount;
  final String emoji;
  final DateTime? deadline;
  final double percentage;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.color,
    required this.savedAmount,
    required this.targetAmount,
    required this.emoji,
    this.deadline,
    this.percentage = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Tag construido a partir de emoji + nombre (no viene del backend)
  String get tag => '$emoji $name';

  double get progress {
    if (targetAmount == 0) return 0.0;
    return (savedAmount / targetAmount).clamp(0.0, 1.0);
  }

  String get percentageStr => '${(progress * 100).toInt()}%';

  String get remaining {
    final rem = targetAmount - savedAmount;
    if (rem <= 0) return '¡Completado!';
    return '\$${rem.toStringAsFixed(0)}';
  }

  bool get isCompleted => savedAmount >= targetAmount;

  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  String get deadlineStatus {
    if (deadline == null) return 'Normal';
    if (isCompleted) return 'Completada';
    if (isOverdue) return 'Atrasada';

    final daysUntilDeadline = deadline!.difference(DateTime.now()).inDays;
    if (daysUntilDeadline < 15) return 'Urgente';
    if (daysUntilDeadline <= 30) return 'Próxima';
    return 'Normal';
  }

  Color get progressColor {
    final progressPercent = progress * 100;
    if (progressPercent >= 100)
      return const Color(0xFF006B52);
    if (progressPercent >= 81)
      return const Color(0xFF4CAF50);
    if (progressPercent >= 61)
      return const Color(0xFF42A5F5);
    if (progressPercent >= 31)
      return const Color(0xFFFF9800);
    return const Color(0xFFEF5350);
  }

  String get progressBadge {
    final progressPercent = progress * 100;
    if (progressPercent >= 100) return '✅ Completado';
    if (progressPercent >= 81) return '¡Casi listo!';
    if (progressPercent >= 61) return 'Avanzando bien';
    if (progressPercent >= 31) return 'En progreso';
    return 'Recién comenzando';
  }

  double get remainingAmount {
    final rem = targetAmount - savedAmount;
    return rem > 0 ? rem : 0.0;
  }

  String get formattedRemaining {
    final rem = remainingAmount;
    if (rem == 0) return '¡Completado!';
    if (rem >= 1000000) {
      return '\$${(rem / 1000000).toStringAsFixed(1)}M';
    }
    if (rem >= 1000) {
      return '\$${(rem / 1000).toStringAsFixed(0)}K';
    }
    return '\$${rem.toStringAsFixed(0)}';
  }

  String get formattedSavedAmount {
    if (savedAmount >= 1000000) {
      return '\$${(savedAmount / 1000000).toStringAsFixed(1)}M';
    }
    if (savedAmount >= 1000) {
      return '\$${(savedAmount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${savedAmount.toStringAsFixed(0)}';
  }

  String get formattedTargetAmount {
    if (targetAmount >= 1000000) {
      return '\$${(targetAmount / 1000000).toStringAsFixed(1)}M';
    }
    if (targetAmount >= 1000) {
      return '\$${(targetAmount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${targetAmount.toStringAsFixed(0)}';
  }

  String get deadlineBadge {
    if (deadline == null) return '';
    if (isOverdue) return '⛔ Atrasada';

    final daysUntilDeadline = deadline!.difference(DateTime.now()).inDays;
    if (daysUntilDeadline < 15) return '⚠️ Urgente';
    if (daysUntilDeadline <= 30) return '⏰ Próxima';
    return '';
  }

  Color get deadlineColor {
    if (deadline == null) return Colors.grey;
    if (isOverdue) return const Color(0xFFEF5350);

    final daysUntilDeadline = deadline!.difference(DateTime.now()).inDays;
    if (daysUntilDeadline < 15) return const Color(0xFFEF5350);
    if (daysUntilDeadline <= 30) return const Color(0xFFFF9800);
    return Colors.grey;
  }

  static double _parseDoubleField(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return 0.0;
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  static Color _parseColorField(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return const Color(0xFF4CAF50);
    if (value is String) {
      try {
        String cleanColor = value.startsWith('#') ? value.substring(1) : value;
        if (cleanColor.length == 6) {
          return Color(int.parse('FF$cleanColor', radix: 16));
        } else if (cleanColor.length == 8) {
          return Color(int.parse(cleanColor, radix: 16));
        }
      } catch (e) {
        print("DEBUG: Error parsing color '$value': $e");
      }
    }
    return const Color(0xFF4CAF50);
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: _parseColorField(json, 'color'),
      savedAmount: _parseDoubleField(json, 'saved_amount'),
      targetAmount: _parseDoubleField(json, 'target_amount'),
      emoji: json['emoji'] as String? ?? '🎯',
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
      percentage: _parseDoubleField(json, 'percentage'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target_amount': targetAmount,
      'emoji': emoji,
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'deadline': deadline?.toIso8601String(),
    };
  }
}

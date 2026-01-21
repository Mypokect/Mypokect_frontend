import 'package:flutter/material.dart';

class SavingsGoal {
  final String id;
  final String name;
  final String tag;
  final IconData icon;
  final Color color;
  final double currentAmount;
  final double targetAmount;
  final String emoji;
  final DateTime? deadline;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.tag,
    required this.icon,
    required this.color,
    required this.currentAmount,
    required this.targetAmount,
    required this.emoji,
    this.deadline,
  });

  double get progress {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  String get percentage => '${(progress * 100).toInt()}%';

  String get remaining {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return '¡Completado!';
    return '\$${remaining.toStringAsFixed(0)}';
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
        // Handle both #RRGGBB and #AARRGGBB formats
        String cleanColor = value.startsWith('#') ? value.substring(1) : value;

        // Remove # if present and handle different formats
        if (cleanColor.length == 6) {
          // #RRGGBB format
          return Color(int.parse('FF$cleanColor', radix: 16));
        } else if (cleanColor.length == 8) {
          // #AARRGGBB format
          return Color(int.parse(cleanColor, radix: 16));
        }
      } catch (e) {
        print("DEBUG: Error parsing color '$value': $e");
      }
    }
    return const Color(0xFF4CAF50);
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    try {
      print("DEBUG: Parsing SavingsGoal from JSON: $json");

      return SavingsGoal(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        tag: json['tag']?.toString() ?? json['name_tag']?.toString() ?? '',
        icon: _getIconFromString(json['icon'] as String?),
        color: _parseColorField(json, 'color'),
        currentAmount: _parseDoubleField(json, 'saved_amount') ??
            _parseDoubleField(json, 'current_amount') ??
            0.0,
        targetAmount: _parseDoubleField(json, 'target_amount') ?? 0.0,
        emoji: json['emoji'] as String? ?? '🎯',
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
      );
    } catch (e) {
      print("DEBUG: Error parsing SavingsGoal: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'icon': _iconToString(icon),
      'color': '#${color.toARGB32().toRadixString(16).substring(2)}',
      'current_amount': currentAmount,
      'target_amount': targetAmount,
      'emoji': emoji,
      'deadline': deadline?.toIso8601String(),
    };
  }

  static IconData _getIconFromString(String? iconStr) {
    switch (iconStr) {
      case 'home':
        return Icons.home;
      case 'flight':
        return Icons.flight;
      case 'directions_car':
        return Icons.directions_car;
      case 'computer':
        return Icons.computer;
      case 'school':
        return Icons.school;
      case 'favorite':
        return Icons.favorite;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'celebration':
        return Icons.celebration;
      case 'phone_iphone':
        return Icons.phone_iphone;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
        return Icons.restaurant;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.savings;
    }
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.home) return 'home';
    if (icon == Icons.flight) return 'flight';
    if (icon == Icons.directions_car) return 'directions_car';
    if (icon == Icons.computer) return 'computer';
    if (icon == Icons.school) return 'school';
    if (icon == Icons.favorite) return 'favorite';
    if (icon == Icons.shopping_bag) return 'shopping_bag';
    if (icon == Icons.celebration) return 'celebration';
    if (icon == Icons.phone_iphone) return 'phone_iphone';
    if (icon == Icons.sports_esports) return 'sports_esports';
    if (icon == Icons.fitness_center) return 'fitness_center';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.account_balance) return 'account_balance';
    return 'savings';
  }
}

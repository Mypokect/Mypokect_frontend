import 'package:intl/intl.dart';

/// Model representing an individual contribution (abono) to a savings goal
class GoalContribution {
  final String id;
  final String goalId;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.description,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Returns formatted date string (e.g., "27 Ene 2026")
  String get formattedDate {
    final formatter = DateFormat('d MMM yyyy', 'es_ES');
    return formatter.format(date);
  }

  /// Returns short date string (e.g., "27/01")
  String get shortDate {
    final formatter = DateFormat('dd/MM', 'es_ES');
    return formatter.format(date);
  }

  /// Returns formatted amount with currency symbol
  String get formattedAmount {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  /// Returns full formatted amount (e.g., "$1,234,567")
  String get fullFormattedAmount {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
      locale: 'es_ES',
    );
    return formatter.format(amount);
  }

  /// Returns month and year for grouping (e.g., "Enero 2026")
  String get monthYear {
    final formatter = DateFormat('MMMM yyyy', 'es_ES');
    return formatter.format(date);
  }

  /// Returns month abbreviation for grouping (e.g., "Ene 2026")
  String get shortMonthYear {
    final formatter = DateFormat('MMM yyyy', 'es_ES');
    return formatter.format(date);
  }

  /// Returns relative time string (e.g., "Hace 2 días", "Hoy", "Ayer")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'Hace 1 semana' : 'Hace $weeks semanas';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'Hace 1 mes' : 'Hace $months meses';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'Hace 1 año' : 'Hace $years años';
    }
  }

  /// Parse contribution from JSON response
  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    try {
      return GoalContribution(
        id: json['id']?.toString() ?? '',
        goalId: json['goal_id']?.toString() ??
            json['saving_goal_id']?.toString() ??
            '',
        amount: _parseDoubleField(json, 'amount'),
        description: json['description']?.toString() ??
            json['note']?.toString() ??
            'Abono',
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : DateTime.now(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print("Error parsing GoalContribution: $e");
      rethrow;
    }
  }

  /// Convert contribution to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper method to parse double fields from various formats
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

  /// Copy with method for creating modified copies
  GoalContribution copyWith({
    String? id,
    String? goalId,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return GoalContribution(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'GoalContribution(id: $id, goalId: $goalId, amount: $amount, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoalContribution && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

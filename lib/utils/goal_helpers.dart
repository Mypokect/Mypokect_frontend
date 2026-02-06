import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility functions and helpers for savings goals
class GoalHelpers {
  /// Format currency amount with Colombian peso formatting
  static String formatCurrency(double amount, {bool compact = false}) {
    if (compact) {
      if (amount >= 1000000000) {
        // Billions
        return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
      } else if (amount >= 1000000) {
        // Millions
        return '\$${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        // Thousands
        return '\$${(amount / 1000).toStringAsFixed(0)}K';
      }
      return '\$${amount.toStringAsFixed(0)}';
    }

    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
      locale: 'es_CO',
    );
    return formatter.format(amount);
  }

  /// Format date in Spanish locale
  static String formatDate(DateTime date, {String pattern = 'd MMM yyyy'}) {
    final formatter = DateFormat(pattern, 'es_ES');
    return formatter.format(date);
  }

  /// Get progress color based on percentage
  static Color getProgressColor(double progress) {
    final progressPercent = progress * 100;
    if (progressPercent >= 100) {
      return const Color(0xFF006B52); // Dark green - Completed
    }
    if (progressPercent >= 81) {
      return const Color(0xFF4CAF50); // Light green - Almost ready
    }
    if (progressPercent >= 61) {
      return const Color(0xFF42A5F5); // Blue - Advancing well
    }
    if (progressPercent >= 31) {
      return const Color(0xFFFF9800); // Orange - In progress
    }
    return const Color(0xFFEF5350); // Red - Just starting
  }

  /// Get progress badge text
  static String getProgressBadge(double progress) {
    final progressPercent = progress * 100;
    if (progressPercent >= 100) return '✅ Completado';
    if (progressPercent >= 81) return '¡Casi listo!';
    if (progressPercent >= 61) return 'Avanzando bien';
    if (progressPercent >= 31) return 'En progreso';
    return 'Recién comenzando';
  }

  /// Get deadline status
  static String getDeadlineStatus(DateTime? deadline, bool isCompleted) {
    if (deadline == null) return 'Normal';
    if (isCompleted) return 'Completada';

    final now = DateTime.now();
    if (now.isAfter(deadline)) return 'Atrasada';

    final daysUntil = deadline.difference(now).inDays;
    if (daysUntil < 15) return 'Urgente';
    if (daysUntil <= 30) return 'Próxima';
    return 'Normal';
  }

  /// Get deadline badge with emoji
  static String getDeadlineBadge(DateTime? deadline, bool isCompleted) {
    if (deadline == null) return '';
    if (isCompleted) return '';

    final now = DateTime.now();
    if (now.isAfter(deadline)) return '⛔ Atrasada';

    final daysUntil = deadline.difference(now).inDays;
    if (daysUntil < 15) return '⚠️ Urgente';
    if (daysUntil <= 30) return '⏰ Próxima';
    return '';
  }

  /// Get deadline color
  static Color getDeadlineColor(DateTime? deadline, bool isCompleted) {
    if (deadline == null) return Colors.grey;
    if (isCompleted) return const Color(0xFF4CAF50);

    final now = DateTime.now();
    if (now.isAfter(deadline)) return const Color(0xFFEF5350); // Red

    final daysUntil = deadline.difference(now).inDays;
    if (daysUntil < 15) return const Color(0xFFEF5350); // Red
    if (daysUntil <= 30) return const Color(0xFFFF9800); // Orange
    return Colors.grey;
  }

  /// Get remaining time text
  static String getRemainingTimeText(DateTime? deadline, bool isCompleted) {
    if (deadline == null) return 'Sin fecha límite';
    if (isCompleted) return 'Meta completada';

    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      final daysOverdue = difference.inDays.abs();
      if (daysOverdue == 0) return 'Venció hoy';
      if (daysOverdue == 1) return 'Venció ayer';
      if (daysOverdue < 30) return 'Venció hace $daysOverdue días';
      if (daysOverdue < 365) {
        final months = (daysOverdue / 30).floor();
        return 'Venció hace ${months} ${months == 1 ? 'mes' : 'meses'}';
      }
      final years = (daysOverdue / 365).floor();
      return 'Venció hace ${years} ${years == 1 ? 'año' : 'años'}';
    }

    final daysRemaining = difference.inDays;
    if (daysRemaining == 0) return 'Vence hoy';
    if (daysRemaining == 1) return 'Vence mañana';
    if (daysRemaining < 7) return 'Quedan $daysRemaining días';
    if (daysRemaining < 30) {
      final weeks = (daysRemaining / 7).floor();
      return 'Quedan ${weeks} ${weeks == 1 ? 'semana' : 'semanas'}';
    }
    if (daysRemaining < 365) {
      final months = (daysRemaining / 30).floor();
      return 'Quedan ${months} ${months == 1 ? 'mes' : 'meses'}';
    }
    final years = (daysRemaining / 365).floor();
    return 'Quedan ${years} ${years == 1 ? 'año' : 'años'}';
  }

  /// Calculate how many days per week/month to contribute to reach goal
  static Map<String, dynamic> calculateContributionPlan({
    required double currentAmount,
    required double targetAmount,
    required DateTime? deadline,
  }) {
    if (deadline == null || currentAmount >= targetAmount) {
      return {
        'daily': 0.0,
        'weekly': 0.0,
        'monthly': 0.0,
        'is_achievable': currentAmount >= targetAmount,
        'days_remaining': 0,
      };
    }

    final remaining = targetAmount - currentAmount;
    final now = DateTime.now();
    final daysRemaining = deadline.difference(now).inDays;

    if (daysRemaining <= 0) {
      return {
        'daily': 0.0,
        'weekly': 0.0,
        'monthly': 0.0,
        'is_achievable': false,
        'days_remaining': 0,
      };
    }

    final daily = remaining / daysRemaining;
    final weekly = daily * 7;
    final monthly = daily * 30;

    return {
      'daily': daily,
      'weekly': weekly,
      'monthly': monthly,
      'is_achievable': true,
      'days_remaining': daysRemaining,
    };
  }

  /// Get suggestion text for contribution frequency
  static String getContributionSuggestion({
    required double currentAmount,
    required double targetAmount,
    required DateTime? deadline,
  }) {
    final plan = calculateContributionPlan(
      currentAmount: currentAmount,
      targetAmount: targetAmount,
      deadline: deadline,
    );

    if (!plan['is_achievable']) {
      if (currentAmount >= targetAmount) {
        return '¡Meta completada! 🎉';
      }
      return 'La fecha límite ha pasado. Considera extender el plazo.';
    }

    final daily = plan['daily'] as double;
    final weekly = plan['weekly'] as double;
    final monthly = plan['monthly'] as double;
    final daysRemaining = plan['days_remaining'] as int;

    if (daysRemaining > 90) {
      // More than 3 months - suggest monthly
      return 'Ahorra ${formatCurrency(monthly, compact: true)} al mes para cumplir tu meta.';
    } else if (daysRemaining > 21) {
      // More than 3 weeks - suggest weekly
      return 'Ahorra ${formatCurrency(weekly, compact: true)} a la semana para cumplir tu meta.';
    } else {
      // Less than 3 weeks - suggest daily
      return 'Ahorra ${formatCurrency(daily, compact: true)} diario para cumplir tu meta.';
    }
  }

  /// Get motivational message based on progress
  static String getMotivationalMessage(double progress) {
    final progressPercent = (progress * 100).toInt();

    if (progressPercent >= 100) {
      return '¡Felicitaciones! Has alcanzado tu meta 🎉';
    } else if (progressPercent >= 90) {
      return '¡Ya casi! Solo un pequeño empujón más 💪';
    } else if (progressPercent >= 75) {
      return '¡Excelente progreso! Vas por muy buen camino 🚀';
    } else if (progressPercent >= 50) {
      return '¡Vas a la mitad! Sigue así 👏';
    } else if (progressPercent >= 25) {
      return 'Buen comienzo. Mantén el ritmo 📈';
    } else if (progressPercent > 0) {
      return 'Cada abono te acerca más a tu meta 🎯';
    } else {
      return 'Es hora de comenzar a ahorrar 💰';
    }
  }

  /// Parse color from hex string
  static Color parseColor(String? colorStr,
      {Color defaultColor = const Color(0xFF4CAF50)}) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;

    try {
      String cleanColor =
          colorStr.startsWith('#') ? colorStr.substring(1) : colorStr;

      if (cleanColor.length == 6) {
        // #RRGGBB format
        return Color(int.parse('FF$cleanColor', radix: 16));
      } else if (cleanColor.length == 8) {
        // #AARRGGBB format
        return Color(int.parse(cleanColor, radix: 16));
      }
    } catch (e) {
      print("Error parsing color '$colorStr': $e");
    }

    return defaultColor;
  }

  /// Convert color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Get icon from string identifier
  static IconData getIconFromString(String? iconStr) {
    switch (iconStr?.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'flight':
        return Icons.flight;
      case 'car':
      case 'directions_car':
        return Icons.directions_car;
      case 'computer':
      case 'laptop':
        return Icons.computer;
      case 'school':
      case 'education':
        return Icons.school;
      case 'favorite':
      case 'heart':
        return Icons.favorite;
      case 'shopping':
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'celebration':
      case 'party':
        return Icons.celebration;
      case 'phone':
      case 'phone_iphone':
        return Icons.phone_iphone;
      case 'games':
      case 'sports_esports':
        return Icons.sports_esports;
      case 'fitness':
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'bank':
      case 'account_balance':
        return Icons.account_balance;
      case 'beach':
      case 'beach_access':
        return Icons.beach_access;
      case 'hotel':
        return Icons.hotel;
      case 'medical':
      case 'local_hospital':
        return Icons.local_hospital;
      default:
        return Icons.savings;
    }
  }

  /// Get responsive padding based on screen width
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    return 24.0;
  }

  /// Get responsive spacing based on screen width
  static double getResponsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 8.0;
    if (width < 600) return 12.0;
    return 16.0;
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double base,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return base * 0.9;
    if (width < 600) return base;
    return base * 1.1;
  }

  /// Validate goal data
  static String? validateGoalName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (name.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    if (name.length > 50) {
      return 'El nombre no puede exceder 50 caracteres';
    }
    return null;
  }

  static String? validateTargetAmount(String? amount) {
    if (amount == null || amount.trim().isEmpty) {
      return 'El monto es requerido';
    }

    final parsed = double.tryParse(amount.replaceAll(',', ''));
    if (parsed == null) {
      return 'Ingresa un monto válido';
    }
    if (parsed <= 0) {
      return 'El monto debe ser mayor a 0';
    }
    if (parsed > 999999999999) {
      return 'El monto es demasiado grande';
    }
    return null;
  }

  static String? validateDeadline(DateTime? deadline) {
    if (deadline == null) return null;

    final now = DateTime.now();
    if (deadline.isBefore(now)) {
      return 'La fecha límite debe ser futura';
    }

    // Optional: Warn if deadline is too far in the future (e.g., > 10 years)
    final tenYearsFromNow = now.add(const Duration(days: 3650));
    if (deadline.isAfter(tenYearsFromNow)) {
      return 'La fecha límite es demasiado lejana';
    }

    return null;
  }
}

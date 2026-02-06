import 'package:flutter/material.dart';
import '../../Theme/Theme.dart';
import '../../utils/goal_helpers.dart';

/// Header summary widget - Diseño simple estilo Home
/// Muestra resumen de progreso total sin gradientes ni decoración excesiva
class GoalHeaderSummary extends StatelessWidget {
  final double totalSaved;
  final double totalTarget;
  final int completedCount;
  final int totalCount;
  final Color progressColor;

  const GoalHeaderSummary({
    super.key,
    required this.totalSaved,
    required this.totalTarget,
    required this.completedCount,
    required this.totalCount,
    this.progressColor = const Color(0xFF006B52),
  });

  double get progress {
    if (totalTarget == 0) return 0.0;
    return (totalSaved / totalTarget).clamp(0.0, 1.0);
  }

  int get progressPercentage => (progress * 100).toInt();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;

    return Container(
      margin: EdgeInsets.all(isCompact ? 16 : 20),
      padding: EdgeInsets.all(isCompact ? 16 : 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(
                Icons.savings_outlined,
                color: AppTheme.primaryColor,
                size: isCompact ? 22 : 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Mis Metas de Ahorro',
                style: TextStyle(
                  fontSize: isCompact ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Baloo2',
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: isCompact ? 14 : 16),

          // Monto ahorrado con porcentaje
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ahorrado:',
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  color: AppTheme.greyColor,
                  fontFamily: 'Baloo2',
                ),
              ),
              Row(
                children: [
                  Text(
                    GoalHelpers.formatCurrency(totalSaved, compact: true),
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($progressPercentage%)',
                    style: TextStyle(
                      fontSize: isCompact ? 13 : 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Baloo2',
                      color: AppTheme.greyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: isCompact ? 10 : 12),

          // Barra de progreso simple
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: isCompact ? 8 : 10,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
          ),

          SizedBox(height: isCompact ? 10 : 12),

          // Estadísticas de metas completadas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalCount == 0
                    ? 'No hay metas creadas'
                    : completedCount == totalCount
                        ? '¡Todas las metas completadas! 🎉'
                        : '$completedCount de $totalCount ${totalCount == 1 ? 'meta completada' : 'metas completadas'}',
                style: TextStyle(
                  fontSize: isCompact ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Baloo2',
                  color: completedCount == totalCount && totalCount > 0
                      ? AppTheme.primaryColor
                      : AppTheme.greyColor,
                ),
              ),
              if (completedCount > 0 && completedCount == totalCount)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: isCompact ? 18 : 20,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Versión compacta para espacios pequeños
class GoalHeaderSummaryCompact extends StatelessWidget {
  final double totalSaved;
  final double totalTarget;
  final int completedCount;
  final int totalCount;

  const GoalHeaderSummaryCompact({
    super.key,
    required this.totalSaved,
    required this.totalTarget,
    required this.completedCount,
    required this.totalCount,
  });

  double get progress {
    if (totalTarget == 0) return 0.0;
    return (totalSaved / totalTarget).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mini progress circle
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${GoalHelpers.formatCurrency(totalSaved, compact: true)} / ${GoalHelpers.formatCurrency(totalTarget, compact: true)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo2',
                  ),
                ),
                Text(
                  '$completedCount de $totalCount completadas',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.greyColor,
                    fontFamily: 'Baloo2',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

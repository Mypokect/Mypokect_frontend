import 'package:flutter/material.dart';
import '../../models/savings_goal.dart';
import '../../Theme/Theme.dart';
import '../../utils/goal_helpers.dart';

/// Tarjeta de meta rediseñada - Estilo simple como Home
/// Diseño limpio, solo color verde, emoji en círculo gris
class GoalCardImproved extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onAbonar;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewHistory;

  const GoalCardImproved({
    super.key,
    required this.goal,
    this.onTap,
    this.onAbonar,
    this.onEdit,
    this.onDelete,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;

    return GestureDetector(
      onTap: onTap ?? onViewHistory,
      child: Container(
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
        child: Stack(
          children: [
            // Contenido principal
            Padding(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Emoji en círculo gris (estilo Home)
                  Container(
                    width: isCompact ? 55 : 60,
                    height: isCompact ? 55 : 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        goal.emoji,
                        style: TextStyle(fontSize: isCompact ? 28 : 32),
                      ),
                    ),
                  ),

                  SizedBox(height: isCompact ? 8 : 10),

                  // Nombre de la meta
                  Text(
                    goal.name,
                    style: TextStyle(
                      fontSize: isCompact ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Baloo2',
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isCompact ? 6 : 8),

                  // Monto actual (grande, verde)
                  Text(
                    goal.formattedSavedAmount,
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  SizedBox(height: isCompact ? 4 : 6),

                  // Barra de progreso verde simple
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: goal.progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isCompact ? 4 : 6),

                  // Porcentaje pequeño
                  Text(
                    '${goal.percentage} de ${goal.formattedTargetAmount}',
                    style: TextStyle(
                      fontSize: isCompact ? 11 : 12,
                      color: AppTheme.greyColor,
                      fontFamily: 'Baloo2',
                    ),
                  ),

                  SizedBox(height: isCompact ? 8 : 10),

                  // Deadline (si existe) - Simple, sin badge
                  if (goal.deadline != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: isCompact ? 11 : 12,
                            color: AppTheme.greyColor,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              GoalHelpers.formatDate(
                                goal.deadline!,
                                pattern: 'd MMM yyyy',
                              ),
                              style: TextStyle(
                                fontSize: isCompact ? 10 : 11,
                                color: AppTheme.greyColor,
                                fontFamily: 'Baloo2',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Botón ABONAR - Siempre verde
                  SizedBox(
                    width: double.infinity,
                    height: isCompact ? 36 : 40,
                    child: goal.isCompleted
                        ? Container(
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '¡Completado!',
                                  style: TextStyle(
                                    fontSize: isCompact ? 11 : 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontFamily: 'Baloo2',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: onAbonar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'ABONAR',
                              style: TextStyle(
                                fontSize: isCompact ? 11 : 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Baloo2',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Menú (⋮) en esquina superior derecha
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppTheme.greyColor,
                  size: isCompact ? 18 : 20,
                ),
                padding: EdgeInsets.zero,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 18,
                          color: AppTheme.greyColor,
                        ),
                        const SizedBox(width: 8),
                        const Text('Ver historial'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: AppTheme.greyColor,
                        ),
                        const SizedBox(width: 8),
                        const Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete,
                          size: 18,
                          color: Color(0xFFEF5350),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Eliminar',
                          style: TextStyle(color: Color(0xFFEF5350)),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'history':
                      onViewHistory?.call();
                      break;
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      _confirmDelete(context);
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Diálogo de confirmación para eliminar
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: Text(
          '¿Estás seguro de eliminar la meta "${goal.name}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF5350),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../infrastructure/models/reminder.dart';
import '../theme/calendar_theme.dart';

class EventCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.reminder,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = reminder.status == 'paid';
    final isOverdue = reminder.dueDateLocal.isBefore(DateTime.now()) && !isPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CalendarTheme.cardBG(context),
        borderRadius: BorderRadius.circular(CalendarTheme.cardRadius),
        boxShadow: CalendarTheme.softShadow(context),
        border: Border.all(
          color: isOverdue
              ? CalendarTheme.badgeDue(context).withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CalendarTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(CalendarTheme.defaultPadding),
            child: Row(
              children: [
                // Indicador de estado (punto o línea vertical)
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green
                        : isOverdue
                            ? CalendarTheme.badgeDue(context)
                            : CalendarTheme.primaryBG(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: CalendarTheme.subtitle(context).copyWith(
                          decoration: isPaid ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatTime(context, reminder.dueDateLocal),
                            style: CalendarTheme.body(context),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: CalendarTheme.textSecondary(context),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getRelativeTime(reminder.dueDateLocal),
                              style: CalendarTheme.body(context).copyWith(
                                color: isOverdue
                                    ? CalendarTheme.badgeDue(context)
                                    : CalendarTheme.primaryBG(context),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Icono de acción o recordatorio
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: CalendarTheme.textSecondary(context),
                      size: 20,
                    ),
                    onPressed: onDelete,
                  )
                else
                  Icon(
                    Icons.notifications_none,
                    color: CalendarTheme.primaryBG(context).withOpacity(0.6),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime date) {
    return DateFormat.jm(Localizations.localeOf(context).toString()).format(date);
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      if (difference.inDays.abs() > 0) {
        return 'Hace ${difference.inDays.abs()} días';
      } else if (difference.inHours.abs() > 0) {
        return 'Hace ${difference.inHours.abs()} horas';
      } else {
        return 'Vencido';
      }
    }

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Mañana';
      return 'En ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'En ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'En ${difference.inMinutes} min';
    } else {
      return 'Ahora';
    }
  }
}

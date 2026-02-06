import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/reminder_controller.dart';
import '../theme/calendar_theme.dart';

/// Reminder detail page
class ReminderDetailPage extends ConsumerWidget {
  final int reminderId;

  const ReminderDetailPage({
    super.key,
    required this.reminderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderAsync = ref.watch(reminderProvider(reminderId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: CalendarTheme.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detalle del Recordatorio',
          style: CalendarTheme.h2(context),
        ),
        centerTitle: true,
      ),
      body: reminderAsync.when(
        data: (reminder) {
          final isPaid = reminder.status == 'paid';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Status and Amount
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPaid ? 'Pagado' : 'Pendiente',
                          style: TextStyle(
                            color: isPaid ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (reminder.amount != null)
                        Text(
                          '\$${reminder.amount!.toStringAsFixed(0)}',
                          style: CalendarTheme.h1(context).copyWith(fontSize: 40),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        reminder.title,
                        style: CalendarTheme.subtitle(context).copyWith(
                          color: CalendarTheme.textSecondary(context),
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Details Section
                _buildDetailItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha de vencimiento',
                  value: '${reminder.dueDateLocal.day}/${reminder.dueDateLocal.month}/${reminder.dueDateLocal.year} ${reminder.dueDateLocal.hour}:${reminder.dueDateLocal.minute.toString().padLeft(2, '0')}',
                ),
                if (reminder.category != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailItem(
                    context,
                    icon: Icons.category_outlined,
                    label: 'Categoría',
                    value: reminder.category!,
                  ),
                ],
                const SizedBox(height: 24),
                _buildDetailItem(
                  context,
                  icon: Icons.repeat,
                  label: 'Recurrencia',
                  value: reminder.recurrence == 'monthly' ? 'Mensual' : 'Una vez',
                ),
                const SizedBox(height: 24),
                _buildDetailItem(
                  context,
                  icon: Icons.notifications_none,
                  label: 'Notificación',
                  value: _formatNotifyOffset(reminder.notifyOffsetMinutes),
                ),

                if (reminder.note != null && reminder.note!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Nota',
                    style: CalendarTheme.subtitle(context),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CalendarTheme.cardBG(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Text(
                      reminder.note!,
                      style: CalendarTheme.body(context),
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // Actions
                if (!isPaid) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _markAsPaid(context, ref, reminderId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CalendarTheme.primaryBG(context),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Marcar como Pagado',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () => _deleteReminder(context, ref, reminderId),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Eliminar Recordatorio',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error al cargar el recordatorio', style: CalendarTheme.body(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CalendarTheme.primaryBG(context).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: CalendarTheme.primaryBG(context), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: CalendarTheme.body(context).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: CalendarTheme.subtitle(context).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNotifyOffset(int minutes) {
    if (minutes == 0) return 'El mismo día';
    if (minutes < 60) return '$minutes minutos antes';
    if (minutes < 1440) return '${minutes ~/ 60} horas antes';
    return '${minutes ~/ 1440} días antes';
  }

  Future<void> _markAsPaid(BuildContext context, WidgetRef ref, int id) async {
    final controller = ref.read(reminderControllerProvider.notifier);
    final result = await controller.markAsPaid(id: id);
    if (result != null && context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio marcado como pagado')),
      );
    }
  }

  Future<void> _deleteReminder(BuildContext context, WidgetRef ref, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar recordatorio?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final controller = ref.read(reminderControllerProvider.notifier);
      final success = await controller.deleteReminder(id);
      if (success && context.mounted) {
        Navigator.pop(context); // Close detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recordatorio eliminado')),
        );
      }
    }
  }
}

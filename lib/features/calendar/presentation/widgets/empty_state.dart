import 'package:flutter/material.dart';
import '../theme/calendar_theme.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onAction;

  const EmptyState({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CalendarTheme.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: CalendarTheme.primaryBG(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_note,
                size: 64,
                color: CalendarTheme.primaryBG(context).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay eventos',
              style: CalendarTheme.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para crear un recordatorio',
              style: CalendarTheme.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: const Text('Crear recordatorio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CalendarTheme.primaryBG(context),
                foregroundColor: CalendarTheme.onPrimaryBG(context),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CalendarTheme.chipRadius),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

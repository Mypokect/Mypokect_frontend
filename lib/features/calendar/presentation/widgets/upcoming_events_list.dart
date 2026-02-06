import 'package:flutter/material.dart';
import '../../infrastructure/models/reminder.dart';
import '../theme/calendar_theme.dart';
import 'event_card.dart';

class UpcomingEventsList extends StatelessWidget {
  final List<Reminder> reminders;
  final Function(Reminder) onTap;
  final Function(Reminder)? onDelete;

  const UpcomingEventsList({
    super.key,
    required this.reminders,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return const SizedBox.shrink(); // Empty state handled separately usually
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CalendarTheme.defaultPadding,
            vertical: 8,
          ),
          child: Text(
            'Upcoming events', // Could be localized
            style: CalendarTheme.h2(context),
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: CalendarTheme.defaultPadding,
            vertical: 8,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Assuming it's inside a scrollable view
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return EventCard(
              reminder: reminder,
              onTap: () => onTap(reminder),
              onDelete: onDelete != null ? () => onDelete!(reminder) : null,
            );
          },
        ),
      ],
    );
  }
}

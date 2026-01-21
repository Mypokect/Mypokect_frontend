import 'package:flutter/material.dart';

class CalendarEmptyStateWidget extends StatelessWidget {
  const CalendarEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
      const SizedBox(height: 20),
      Text('Sin recordatorios pendientes',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700])),
      const SizedBox(height: 8),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
              '¡Estás al día! Toca un día futuro para añadir un nuevo recordatorio.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[500])))
    ]));
  }
}

import 'package:flutter/material.dart';
import '../theme/calendar_theme.dart';

class PrimaryFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const PrimaryFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: CalendarTheme.primaryBG(context),
      foregroundColor: CalendarTheme.onPrimaryBG(context),
      elevation: CalendarTheme.shadowElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.add, size: 32),
    );
  }
}

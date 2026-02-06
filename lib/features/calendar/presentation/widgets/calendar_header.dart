import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/calendar_theme.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback? onTitleTap;

  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos el locale del contexto o por defecto 'es_CO' si no está disponible
    final locale = Localizations.localeOf(context).toString();
    final titleText = DateFormat.yMMMM(locale).format(focusedDay);
    // Capitalizar primera letra
    final capitalizedTitle = titleText.isNotEmpty
        ? '${titleText[0].toUpperCase()}${titleText.substring(1)}'
        : titleText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: CalendarTheme.primaryBG(context)),
            onPressed: onLeftArrowTap,
            tooltip: 'Mes anterior',
          ),
          GestureDetector(
            onTap: onTitleTap,
            child: Text(
              capitalizedTitle,
              style: CalendarTheme.h1(context),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: CalendarTheme.primaryBG(context)),
            onPressed: onRightArrowTap,
            tooltip: 'Mes siguiente',
          ),
        ],
      ),
    );
  }
}

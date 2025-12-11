import 'package:flutter/material.dart';
import '../theme/calendar_theme.dart';
import 'calendar_segmented_control.dart';

class CalendarScaffold extends StatelessWidget {
  final CalendarViewType currentView;
  final ValueChanged<CalendarViewType> onViewChanged;
  final Widget body;
  final VoidCallback? onSearchTap;
  final VoidCallback? onAddTap;
  final Widget? floatingActionButton;

  const CalendarScaffold({
    super.key,
    required this.currentView,
    required this.onViewChanged,
    required this.body,
    this.onSearchTap,
    this.onAddTap,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: CalendarTheme.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Calendar',
          style: CalendarTheme.h1(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: CalendarTheme.textPrimary(context)),
            onPressed: onSearchTap,
          ),
          IconButton(
            icon: Icon(Icons.add, color: CalendarTheme.textPrimary(context)),
            onPressed: onAddTap,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          CalendarSegmentedControl(
            currentView: currentView,
            onViewChanged: onViewChanged,
          ),
          const SizedBox(height: 8),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

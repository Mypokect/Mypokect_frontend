import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MyPocket/features/calendar/presentation/pages/calendar_page.dart';

void main() {
  testWidgets('CalendarPage shows title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CalendarPage(),
        ),
      ),
    );

    expect(find.text('Calendario Financiero'), findsOneWidget);
  });

  testWidgets('CalendarPage shows FAB for creating reminder', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CalendarPage(),
        ),
      ),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

# AGENTS.md

This file contains project-specific guidelines for agentic coding assistants working on this Flutter finance app (MyPocket).

## Build/Lint/Test Commands

### Build & Run
```bash
flutter run              # Run the app on connected device
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
```

### Linting & Analysis
```bash
flutter analyze          # Run static analysis (uses analysis_options.yaml)
flutter format .         # Format all Dart files
```

### Testing
```bash
flutter test                              # Run all tests
flutter test test/widget_test.dart        # Run specific test file
flutter test --name "test_name"           # Run tests matching name pattern
flutter test -v                           # Run with verbose output
flutter test --coverage                   # Generate coverage report
```

## Project Structure

```
lib/
├── Screens/          # UI screens (Auth, Home, Movements, service pages)
├── Controllers/      # Business logic layer (auth_controller, movement_controller)
├── api/             # API client classes (auth_api, movement_api, etc.)
├── Widgets/         # Reusable UI components (ButtonCustom, TextWidget)
├── Services/        # Services (notification_service, base_url)
├── Theme/           # App theme configuration (AppTheme class)
├── utils/           # Utility functions (helpers, tax_engine)
└── models/          # Data models (transaction_occurrence)
```

## Code Style Guidelines

### Naming Conventions
- **Classes**: PascalCase (e.g., `AuthController`, `MovementApi`, `Textwidget`)
- **Files**: lowercase_with_underscores (e.g., `auth_api.dart`, `movement_controller.dart`)
- **Private members**: Prefix with underscore (e.g., `_userName`, `_loadHomeData`)
- **Constants**: static const with lowerCamelCase (e.g., `primaryColor`, `apiUrl`)
- **Methods**: lowerCamelCase (e.g., `login`, `register`, `createMovement`)
- **Parameters**: lowerCamelCase with required keyword (e.g., `required String phone`)
- **Local variables**: lowerCamelCase (e.g., `final url =`, `final data = await`)

### Import Organization
```dart
// 1. Dart core imports
import 'dart:convert';
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 3. Package imports
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 4. Relative project imports
import '../api/auth_api.dart';
import '../Controllers/auth_controller.dart';
import '../Widgets/CustomAlert.dart';
```

### Type Safety & Null Safety
- Use `required` for non-nullable required parameters
- Use nullable types with `?` for optional values (e.g., `String? category`, `Function? onTap`)
- Use `final` for variables that won't change after assignment
- Use `const` for compile-time constants

### Error Handling
```dart
Future<void> someMethod() async {
  try {
    final response = await apiCall();
    if (response.statusCode == 200) {
      // Success handling
    }
  } catch (e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
}
```

### JSON Parsing
```dart
factory ModelClass.fromJson(Map<String, dynamic> json) {
  try {
    return ModelClass(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Default Value',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
    );
  } catch (e) {
    print("Error parsing ModelClass: $e");
    rethrow;
  }
}
```

### Widget Best Practices
- Always check `if (context.mounted)` before navigation after async operations
- Use `Key` for widgets when necessary (`const MyWidget({super.key})`)
- Prefer `const` constructors where possible
- Extract large widget trees into separate methods or widgets
- Use `setState()` only for UI-related state, not for business logic

### API Integration
- Use `http` package for HTTP requests
- Always include headers: `Content-Type: application/json`, `Accept: application/json`
- Use `jsonEncode()` for request bodies
- Store auth token in SharedPreferences with key `'toke'` (note: intentional typo)
- Use `BaseUrl.apiUrl` constant for base URL

### State Management
- Use StatefulWidget with `State<T>` for component-level state
- Use Controllers (from `Controllers/`) for business logic
- Keep UI in Screens/Widgets, business logic in Controllers
- Use `SharedPreferences` for local data persistence

### Internationalization
- Use `intl` package for date/time formatting
- Initialize with `initializeDateFormatting('es_ES', null)`
- Set locale to `Locale('es')` in MaterialApp

### Testing
- Use `flutter_test` package for all tests
- Use `testWidgets()` for widget tests
- Use `WidgetTester` to interact with widgets (`tap()`, `enterText()`, `pumpWidget()`)
- Use `find.byType()`, `find.text()`, `find.byIcon()` to locate widgets
- Always use `expect()` assertions for test verification
- Follow AAA pattern: Arrange, Act, Assert

### Fonts & Assets
- Custom font family: `'Baloo2'` (weights: 400, 500, 600, 700, 800)
- Assets location: `assets/images/`, `assets/fonts/`, `assets/svg/`

### Color Scheme
Use `AppTheme` class for colors:
- `primaryColor`: #006B52 (green)
- `secondaryColor`: #03DAC6 (teal)
- `backgroundColor`: #F5F5F5
- `greyColor`: #888888
- `errorColor`: red

### Linter Configuration
- Uses `flutter_lints` package
- Run `flutter analyze` before committing
- Use `// ignore: rule_name` sparingly to suppress lints
- Prefer `// ignore_for_file: rule_name` for file-wide suppression

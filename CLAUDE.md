# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MyPocket is a Flutter-based personal finance mobile application supporting iOS, Android, and macOS. The app manages financial movements, budgets, savings goals, recurring transactions, and tax calculations with AI-powered voice input and tag suggestions.

## Common Commands

### Development
```bash
flutter run                      # Run app in debug mode
flutter run --debug              # Explicit debug mode
flutter run --profile            # Profile mode for performance testing
flutter pub get                  # Install/update dependencies
```

### Code Quality
```bash
flutter analyze                  # Run static analysis (run before commits)
flutter format .                 # Format all Dart files
flutter test                     # Run all tests
flutter test test/widget_test.dart  # Run specific test file
flutter test --name "test_name"  # Run tests matching name
```

### Build
```bash
flutter clean                    # Clean build artifacts and cache
flutter build apk --release      # Build Android APK
flutter build appbundle --release  # Build Android App Bundle (for Google Play)
flutter build ios --release      # Build iOS app (requires macOS & Xcode)
flutter build macos --release    # Build macOS app
```

### Assets
```bash
flutter pub run flutter_launcher_icons  # Generate app icons
```

## Architecture

### Layered Clean Architecture

The codebase follows a **layered architecture** with clear separation:

```
UI Layer (Screens/Widgets)
    ↓ uses
Business Logic Layer (Controllers)
    ↓ calls
Data Access Layer (API Services)
    ↓ uses
Models & Services
```

#### 1. **Controllers** ([lib/Controllers/](lib/Controllers/))
- Business logic orchestrators that **do NOT extend ChangeNotifier** (except [GoalsController](lib/Controllers/goals_controller.dart))
- Receive `BuildContext` to show UI feedback (SnackBars, alerts)
- Instantiated fresh in each screen's `initState()`
- Key controllers:
  - [MovementController](lib/Controllers/movement_controller.dart): Handles transactions, voice input, AI tag suggestions, hybrid tag system
  - [GoalsController](lib/Controllers/goals_controller.dart): Savings goals CRUD, contribution tracking (extends ChangeNotifier)
  - [HomeController](lib/Controllers/home_controller.dart): Aggregates home screen data
  - [AuthController](lib/Controllers/auth_controller.dart): Login/register
  - [BudgetController](lib/Controllers/budget_controller.dart): Budget management
  - [ScheduledTransactionController](lib/Controllers/scheduled_transaction_controller.dart): Recurring transactions

#### 2. **API Services** ([lib/api/](lib/api/))
- HTTP client wrappers with token management
- **Critical quirk**: Token stored in SharedPreferences with key `'toke'` (typo, not `'token'`)
- All API classes implement `_getHeaders()` to retrieve Bearer token
- [SavingsGoalsApi](lib/api/savings_goals_api.dart) uses **static caching** with 5-minute TTL:
  ```dart
  static List<SavingsGoal>? _goalsCache;
  static DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 5);
  ```
  - Call `SavingsGoalsApi.clearCache()` after mutations

#### 3. **Models** ([lib/models/](lib/models/))
- Domain objects with rich computed properties and formatting
- [SavingsGoal](lib/models/savings_goal.dart): Progress tracking, intelligent currency formatting, color-coded states
- [GoalContribution](lib/models/goal_contribution.dart): Individual deposits/contributions
- [TransactionOccurrence](lib/models/transaction_occurrence.dart): Recurring transaction definitions

#### 4. **Screens** ([lib/Screens/](lib/Screens/))
- `StatefulWidget` components using **local setState()** for state
- Main navigation in [main_screen.dart](lib/Screens/main_screen.dart): 5-tab BottomNavigationBar
  - Index 2 (center tab) navigates modally to Movements screen
- Key screens:
  - [movements.dart](lib/Screens/movements.dart): Complex form with voice input, tag autocomplete, AI suggestions
  - [savings_goals_screen_new.dart](lib/Screens/service/savings_goals_screen_new.dart): New goals architecture
  - [home.dart](lib/Screens/home.dart): Dashboard with balance, status cards

#### 5. **Widgets** ([lib/Widgets/](lib/Widgets/))
- Organized by **feature domain**:
  - `movements/`: Movement-specific components (type selector, tag chips, voice UI)
  - `goals/`: Goal cards, progress indicators, contribution items
  - `budget/`: Budget list cards, category inputs, validation
  - `common/`: Shared components (buttons, alerts, text inputs)

### State Management

1. **Primary**: Local `setState()` in StatefulWidgets
2. **Secondary**: `ChangeNotifier` (only GoalsController)
3. **Persistence**: SharedPreferences for tokens, tag history, settings
4. **Caching**: Static cache in SavingsGoalsApi (5-minute TTL)

## Key Patterns & Conventions

### Savings Goals & Contributions System

**Important architectural change:** The app uses a **dual-track system** for savings goals:

1. **Goal Contributions (Recommended)**:
   - When user selects a goal tag in Movements screen, `_isGoalMode` becomes `true`
   - Saving creates a **contribution** via [GoalContributionsApi](lib/api/goal_contributions_api.dart) instead of a movement
   - Contributions are stored in separate `goal_contributions` table (not `movements`)
   - **Reason**: Tax compliance - contributions are NOT taxable transactions
   - After creating contribution, call `SavingsGoalsApi.clearCache()` to refresh goal progress

2. **Legacy Movement Method (Still Supported)**:
   - Old approach: create income movement with goal tag
   - Backend still calculates progress from both contributions AND tagged movements
   - Not recommended for new code

**Implementation in [Movements screen](lib/Screens/movements.dart):**
```dart
if (_isGoalMode && finalTag.isNotEmpty) {
  // Get goal ID from tag
  final goalTagToIdMap = await _movementController.getGoalTagToIdMap();
  final goalId = goalTagToIdMap[finalTag];

  // Create contribution instead of movement
  await GoalContributionsApi().createContribution(
    goalId: goalId,
    amount: val,
    description: description,
  );

  SavingsGoalsApi.clearCache(); // Important!
}
```

### Hybrid Tag System
Tags come from **three sources** merged intelligently:
1. **Server tags**: Fetched from `/tags` endpoint (user-created categories)
2. **Local tag history**: Recent 10 tags stored in SharedPreferences via [TagHistoryManager](lib/Core/TagHistoryManager.dart)
3. **Savings goal tags**: Active savings goals used as tag options (format: "{emoji} {name}")

Managed by [TagHistoryManager.getAllTags()](lib/Core/TagHistoryManager.dart) which combines and deduplicates all three sources.

**Critical safeguards:**
- **Goal tags are READ-ONLY**: They come exclusively from backend, never saved to local history
- **Auto-detection**: `TagHistoryManager._isGoalTag()` detects goal tags by emoji prefix (runes length ≤ 4)
- **No orphaned tags**: When a goal is deleted:
  1. Backend removes the tag ✓
  2. Cache is cleared via `SavingsGoalsApi.clearCache()` ✓
  3. Local history is cleaned via `TagHistoryManager.removeTag()` ✓
- **recordUsage() filtering**: Automatically skips goal tags to prevent local storage pollution

### AI & Voice Features
- **Speech-to-Text**: Real-time voice transcription for movement entry
- **Voice suggestions**: POST to `/movements/sugerir-voz` with audio transcription
- **Manual tag suggestions**: POST to `/tags/suggestion` with description + amount
- **Auto-tagging**: AI suggests tags based on transaction context
- Voice states: `VoiceState` enum (listening, processing, success, error)

### Authentication Flow
1. Login/Register → [AuthApi](lib/api/auth_api.dart) → JWT token in response
2. Token saved to SharedPreferences with key `'toke'` (**note the typo**)
3. All API calls retrieve token via `_getHeaders()` and add as `Authorization: Bearer <token>`

### Responsive Design
- Helper methods calculate padding/spacing based on screen width
- Breakpoints: `<360px` (very small), `360-400px` (small), `400-600px` (medium), `>600px` (large/tablets)

### Error Handling
```dart
try {
  final response = await api.call();
  if (response.statusCode == 200) {
    // Success
  } else if (response.statusCode == 401) {
    // Auth error
  } else if (response.statusCode == 404) {
    // Not found
  }
} on FormatException {
  // JSON parsing errors
} catch (e) {
  // General errors - show SnackBar via BuildContext
}
```

## File Naming & Code Style

### Naming Conventions
- **Files**: `lowercase_with_underscores.dart`
- **Classes**: `PascalCase`
- **Variables/methods**: `lowerCamelCase`
- **Private members**: Prefix with `_`

### Import Order
1. Dart core libraries
2. Flutter imports
3. Package imports
4. Relative project imports

### Linting
- Uses `flutter_lints` package
- **Always run `flutter analyze` before commits**

## Technology Stack

- **Flutter**: ^3.6.0
- **Dart**: ^3.6.0
- **HTTP Client**: http ^1.4.0
- **State Persistence**: shared_preferences ^2.5.3
- **Voice Input**: speech_to_text 7.1.0
- **Notifications**: flutter_local_notifications ^17.1.2 + timezone ^0.9.3
- **UI Components**: table_calendar, fl_chart, flutter_svg, avatar_glow
- **Localization**: intl ^0.20.2 (Spanish `es_ES` primary, English `en`)

## Localization

- **Primary locale**: Spanish (`es_ES`)
- **Secondary**: English (`en`)
- Date/currency formatting via `intl` package

## API Configuration

- Base URL configured in [lib/Services/base_url.dart](lib/Services/base_url.dart)
- Token retrieval centralized in API service `_getHeaders()` methods
- **Important**: Token key in SharedPreferences is `'toke'` (not `'token'`)

## Theme

- **Primary color**: `#006B52` (green)
- **Secondary color**: `#03DAC6` (teal)
- **Font**: Baloo2 (weights: 400, 500, 600, 700, 800)
- Configured in [lib/Theme/theme.dart](lib/Theme/theme.dart)

## Data Flow Examples

### Creating a Movement (Expense/Income)
1. User fills form in [Movements screen](lib/Screens/movements.dart)
2. User does NOT select a goal tag (`_isGoalMode = false`)
3. Calls `MovementController.createMovement()`
4. Controller calls `MovementApi.createMovement()`
5. API retrieves token from SharedPreferences (`'toke'` key)
6. POST to `/movements` with transaction data
7. Response handled, SnackBar shown via BuildContext
8. [TagHistoryManager](lib/Core/TagHistoryManager.dart) records tag usage
9. Screen resets/pops

### Creating a Goal Contribution (Abono)
1. User fills form in [Movements screen](lib/Screens/movements.dart)
2. User selects a goal tag (e.g., "✈️ Viaje a París")
3. `_isGoalMode` becomes `true`, UI changes to "NUEVO ABONO"
4. User taps save button
5. `_guardarMovimiento()` detects goal mode
6. Calls `MovementController.getGoalTagToIdMap()` to get goal ID
7. Creates contribution via `GoalContributionsApi.createContribution()`
8. POST to `/goal-contributions` with `{goalId, amount, description}`
9. Calls `SavingsGoalsApi.clearCache()` to refresh goal progress
10. SnackBar shown, **Navigator.pop(context, true)** ← passes success flag
11. Goals screen receives `true`, calls `_refreshGoals()` to update UI
12. User sees updated goal progress immediately ✓

### Deleting a Goal
1. User deletes a goal in Goals screen
2. [GoalsController.deleteGoal()](lib/Controllers/goals_controller.dart) gets goal's tag before deletion
3. Calls `SavingsGoalsApi.deleteGoal(id)` → DELETE to `/saving-goals/{id}`
4. On success:
   - Removes goal from local `_goals` list ✓
   - Calls `TagHistoryManager.removeTag(goalTag)` to clean local history ✓
   - Calls `notifyListeners()` to update UI ✓
5. Next time Movements opens, goal tag is completely gone (no orphans) ✓

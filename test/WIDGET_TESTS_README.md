/// Widget Test README
///
/// This file provides documentation for running and understanding the widget tests
/// in the Dentist Management System.

# Widget Tests Documentation

## Overview

This test suite provides comprehensive widget testing for the Dentist Management System desktop application. The tests validate UI components, user interactions, state changes, and navigation flows.

## Test Structure

### Features Covered

1. **Authentication** (`test/features/auth/`)
   - Login page rendering and interactions
   - Authentication flow
   - Loading states
   - Error handling

2. **Patients** (`test/features/patients/`)
   - Patient list and cards
   - Patient filters dialog
   - Patient statistics cards
   - Delete confirmation dialog
   - Patient profile display

3. **Appointments** (`test/features/appointments/`)
   - Appointment cards
   - Schedule appointment dialog
   - Calendar widget
   - Appointment list views

4. **Billing** (`test/features/billing/`)
   - Invoice cards
   - Add payment dialog
   - Treatment details dialog
   - Payment history

5. **Dashboard** (`test/features/dashboard/`)
   - Metric cards (KPIs)
   - Charts and statistics
   - Overview panels

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/features/auth/presentation/pages/login_page_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### Run Tests for Specific Feature

```bash
# Patients feature
flutter test test/features/patients/

# Appointments feature
flutter test test/features/appointments/

# Billing feature
flutter test test/features/billing/

# Dashboard feature
flutter test test/features/dashboard/
```

## Test Helpers

### Using Test Helpers

The `test/helpers/test_helpers.dart` file provides utilities:

```dart
import '../helpers/test_helpers.dart';

// Wrap widget with MaterialApp
final widget = WidgetTestHelper.wrapWithMaterialApp(MyWidget());

// Generate mock data
final patient = MockDataGenerator.mockPatient(firstName: 'Alice');

// Set screen size for responsive testing
ScreenSizeHelper.setScreenSize(tester, TestScreenSizes.desktop);
```

## Writing New Tests

### Basic Widget Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('MyWidget Tests', () {
    testWidgets('should render widget', (tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(home: MyWidget()));

      // Act
      // Perform interactions here

      // Assert
      expect(find.byType(MyWidget), findsOneWidget);
    });
  });
}
```

### Testing User Interactions

```dart
testWidgets('should handle button tap', (tester) async {
  // Arrange
  bool tapped = false;
  await tester.pumpWidget(
    MaterialApp(
      home: ElevatedButton(
        onPressed: () => tapped = true,
        child: Text('Tap Me'),
      ),
    ),
  );

  // Act
  await tester.tap(find.text('Tap Me'));
  await tester.pumpAndSettle();

  // Assert
  expect(tapped, true);
});
```

### Testing Forms

```dart
testWidgets('should validate form fields', (tester) async {
  // Arrange
  final formKey = GlobalKey<FormState>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: TextFormField(
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
        ),
      ),
    ),
  );

  // Act - Try to validate empty field
  formKey.currentState?.validate();
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Required'), findsOneWidget);
});
```

### Testing with Bloc/Provider

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockMyBloc extends Mock implements MyBloc {}

testWidgets('should display data from bloc', (tester) async {
  // Arrange
  final mockBloc = MockMyBloc();
  when(() => mockBloc.state).thenReturn(MyState(data: 'Test'));

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<MyBloc>.value(
        value: mockBloc,
        child: MyWidget(),
      ),
    ),
  );

  // Assert
  expect(find.text('Test'), findsOneWidget);
});
```

## Best Practices

1. **Use Keys**: Add keys to important widgets for reliable testing

   ```dart
   ElevatedButton(
     key: Key('submit_button'),
     onPressed: () {},
   )
   ```

2. **Test User Flows**: Test complete user interactions, not just rendering

   ```dart
   // Bad
   expect(find.byType(TextField), findsOneWidget);

   // Good
   await tester.enterText(find.byType(TextField), 'test@example.com');
   await tester.tap(find.text('Submit'));
   expect(find.text('Success'), findsOneWidget);
   ```

3. **Mock Dependencies**: Always mock external dependencies (APIs, databases)

   ```dart
   class MockPatientRepository extends Mock implements PatientRepository {}
   ```

4. **Use pumpAndSettle**: Wait for animations to complete

   ```dart
   await tester.tap(find.text('Button'));
   await tester.pumpAndSettle(); // Wait for animations
   ```

5. **Group Related Tests**: Organize tests logically

   ```dart
   group('Form Validation', () {
     testWidgets('validates email', (tester) async { ... });
     testWidgets('validates password', (tester) async { ... });
   });
   ```

6. **Clean Up Resources**: Always dispose controllers and reset state
   ```dart
   tearDown(() {
     controller.dispose();
   });
   ```

## Common Assertions

```dart
// Widget existence
expect(find.byType(MyWidget), findsOneWidget);
expect(find.text('Hello'), findsNothing);

// Multiple widgets
expect(find.byType(ListTile), findsNWidgets(5));
expect(find.byType(Card), findsWidgets);

// Text content
expect(find.text('Submit'), findsOneWidget);
expect(find.textContaining('Error'), findsOneWidget);

// Widget properties
final widget = tester.widget<Text>(find.text('Hello'));
expect(widget.style?.color, Colors.blue);
```

## Troubleshooting

### Test Fails with "Finder returned no matching widgets"

- Ensure widget is actually built: `await tester.pump()`
- Check if widget is scrolled off-screen
- Verify widget tree structure

### Test Timeout

- Add `await tester.pumpAndSettle()` after interactions
- Increase timeout if needed: `testWidgets('...', timeout: Timeout(...), (tester) async {...})`

### State Not Updating

- Use `pumpAndSettle()` instead of `pump()`
- Check if setState() is being called
- Verify bloc/provider is emitting new states

## Coverage Goals

- **Overall Coverage**: Target 80%+
- **Critical Paths**: 100% coverage for auth, patient management, billing
- **UI Components**: All dialogs, forms, and interactive widgets tested

## CI/CD Integration

Tests run automatically on:

- Pull requests
- Main branch commits
- Release builds

```yaml
# GitHub Actions example
- name: Run tests
  run: flutter test --coverage
```

## Additional Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Widget Testing Guide](https://flutter.dev/docs/cookbook/testing/widget/introduction)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Flutter Bloc Testing](https://bloclibrary.dev/#/testing)

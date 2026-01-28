# 🧪 Integration Tests - Complete Guide

## 📋 Overview

This directory contains **end-to-end integration tests** for the Dentist Management System Flutter desktop application. These tests validate complete user journeys across the entire application, simulating real user interactions.

---

## 📁 Test Structure

```
integration_test/
├── helpers/
│   ├── test_keys.dart          # Centralized widget keys for testing
│   └── test_helpers.dart       # Reusable test utilities and mocks
├── auth_flow_test.dart         # Authentication flow tests
├── patient_crud_flow_test.dart # Patient management tests
├── appointment_flow_test.dart  # Appointment scheduling tests
├── billing_flow_test.dart      # Billing and invoice tests
├── navigation_flow_test.dart   # Navigation and routing tests
└── README.md                   # This file
```

---

## 🎯 Test Coverage

### 1. Authentication Flow Tests (`auth_flow_test.dart`)

**User Journey Tested:**

- ✅ App launch and login page display
- ✅ Email/password authentication
- ✅ Form validation (empty fields, invalid credentials)
- ✅ Tab switching (Password / Facial Recognition)
- ✅ Forgot password functionality
- ✅ Navigation to dashboard after successful login
- ✅ Logout and return to login page

**Test Count:** 7 test cases

---

### 2. Patient CRUD Flow Tests (`patient_crud_flow_test.dart`)

**User Journey Tested:**

- ✅ Navigate to patients page
- ✅ **CREATE:** Add new patient with complete details
- ✅ **READ:** Search and view patient information
- ✅ **UPDATE:** Edit patient details
- ✅ **DELETE:** Remove patient from system
- ✅ Filter and search functionality
- ✅ Patient statistics display
- ✅ View patient profile with full details

**Test Count:** 5 test cases

---

### 3. Appointment Scheduling Flow Tests (`appointment_flow_test.dart`)

**User Journey Tested:**

- ✅ View appointments calendar
- ✅ Schedule new appointment
- ✅ View appointment details
- ✅ Filter appointments by status
- ✅ Calendar navigation (next/previous month)
- ✅ Select date in calendar
- ✅ View appointments for specific date
- ✅ Status badges display
- ✅ View all appointments list

**Test Count:** 8 test cases

---

### 4. Billing and Invoice Flow Tests (`billing_flow_test.dart`)

**User Journey Tested:**

- ✅ View billing page and invoices list
- ✅ Create new invoice
- ✅ Add payment to invoice
- ✅ View invoice details and status
- ✅ Filter invoices by status
- ✅ View billing statistics
- ✅ Search invoices
- ✅ View payment history
- ✅ Export/print invoice (if available)

**Test Count:** 9 test cases

---

### 5. Navigation Flow Tests (`navigation_flow_test.dart`)

**User Journey Tested:**

- ✅ Navigate between all main screens
- ✅ Navigation bar state persistence
- ✅ Navigation bar visibility on all screens
- ✅ Rapid navigation handling
- ✅ Counter badges update
- ✅ User profile display
- ✅ Collapsible sidebar (desktop)
- ✅ Deep link navigation
- ✅ Scroll position preservation
- ✅ All navigation items functional

**Test Count:** 10 test cases

---

## 🚀 Running Integration Tests

### Prerequisites

1. **Ensure dependencies are installed:**

   ```bash
   flutter pub get
   ```

2. **Set up test environment variables:**
   - Create or update `.env` file with test credentials
   - Example:
     ```
     SUPABASE_URL=your_test_supabase_url
     SUPABASE_ANON_KEY=your_test_anon_key
     ```

3. **Close any running instances of the app**

---

### Run All Integration Tests

```bash
# Run all integration tests
flutter test integration_test/

# Run with verbose output
flutter test integration_test/ --verbose

# Run with coverage
flutter test integration_test/ --coverage
```

---

### Run Specific Test Files

```bash
# Authentication tests only
flutter test integration_test/auth_flow_test.dart

# Patient CRUD tests only
flutter test integration_test/patient_crud_flow_test.dart

# Appointment tests only
flutter test integration_test/appointment_flow_test.dart

# Billing tests only
flutter test integration_test/billing_flow_test.dart

# Navigation tests only
flutter test integration_test/navigation_flow_test.dart
```

---

### Run Specific Test Cases

```bash
# Run a specific test group
flutter test integration_test/auth_flow_test.dart --name "Complete login flow"

# Run tests matching a pattern
flutter test integration_test/ --name "CRUD"
```

---

## 🔧 Test Configuration

### Test Credentials

The tests use the following default credentials (update in your `.env`):

```
Email: test@dentalcare.com
Password: TestPassword123
```

**⚠️ Important:** Ensure these credentials exist in your test database!

---

### Mock vs Real Backend

These tests are designed to work with:

1. **Real Supabase Backend (Recommended for Integration Tests)**
   - Uses actual database
   - Tests real API interactions
   - Best for comprehensive testing

2. **Mock Backend (Optional)**
   - Use `helpers/test_helpers.dart` mock classes
   - Faster execution
   - No network dependency

To use mocks, uncomment mock setup in each test file.

---

## 📊 Test Reports

### Generate HTML Coverage Report

```bash
# Run tests with coverage
flutter test integration_test/ --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open report
start coverage/html/index.html  # Windows
open coverage/html/index.html   # macOS
xdg-open coverage/html/index.html  # Linux
```

---

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. **Tests timeout or hang**

**Solution:**

- Increase timeout in test:
  ```dart
  testWidgets('test name', (tester) async {
    // ...
  }, timeout: const Timeout(Duration(minutes: 5)));
  ```
- Check for infinite loading states
- Ensure network connectivity

#### 2. **Widget not found errors**

**Solution:**

- Add `await tester.pumpAndSettle()` after actions
- Use `waitForWidget()` helper for async elements
- Check widget keys are correct
- Verify UI is not hidden by overlays

#### 3. **Authentication fails**

**Solution:**

- Verify test credentials in `.env`
- Check Supabase project is accessible
- Ensure user exists in test database
- Check network/firewall settings

#### 4. **Flaky tests (sometimes pass, sometimes fail)**

**Solution:**

- Add more `pumpAndSettle()` calls
- Increase wait times for animations
- Use `waitForLoadingToComplete()` helper
- Avoid depending on exact timing

#### 5. **Database state issues**

**Solution:**

- Reset test database before running tests
- Use unique identifiers (timestamps) for test data
- Clean up created data in test teardown

---

## 🎨 Writing New Integration Tests

### Best Practices

1. **Follow AAA Pattern:**

   ```dart
   testWidgets('test description', (tester) async {
     // ARRANGE - Set up test state
     await loginToApp(tester);

     // ACT - Perform user actions
     await tester.tap(find.byKey(Key('button')));
     await tester.pumpAndSettle();

     // ASSERT - Verify results
     expect(find.text('Success'), findsOneWidget);
   });
   ```

2. **Use Descriptive Test Names:**

   ```dart
   // ✅ Good
   testWidgets('User can create patient with all required fields', ...);

   // ❌ Bad
   testWidgets('test1', ...);
   ```

3. **Add Comments:**

   ```dart
   // ============ ACT - Fill Patient Form ============
   await enterText(tester, nameField, 'John Doe');
   ```

4. **Use Helper Functions:**

   ```dart
   // Reusable login helper
   Future<void> loginToApp(WidgetTester tester) async {
     // Login logic here
   }
   ```

5. **Handle Different Screen Sizes:**

   ```dart
   await tester.binding.setSurfaceSize(Size(1920, 1080));
   ```

6. **Wait for Async Operations:**
   ```dart
   await IntegrationTestHelpers.waitForLoadingToComplete(tester);
   await tester.pumpAndSettle();
   ```

---

### Example Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dentist_ms/main.dart' as app;
import 'helpers/test_helpers.dart';
import 'helpers/test_keys.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Feature Name Integration Tests', () {
    testWidgets('User can perform specific action',
      (WidgetTester tester) async {
      // ============ ARRANGE ============
      await app.main();
      await tester.pumpAndSettle();

      // ============ ACT ============
      await tester.tap(find.byKey(Key('action_button')));
      await tester.pumpAndSettle();

      // ============ ASSERT ============
      expect(find.text('Expected Result'), findsOneWidget);

      print('✅ Test passed');
    });
  });
}
```

---

## 🔑 Adding Test Keys to Widgets

To make widgets testable, add keys to your UI components:

```dart
// In your widget code
TextField(
  key: const Key('email_field'),  // Add this
  decoration: InputDecoration(labelText: 'Email'),
)

ElevatedButton(
  key: const Key('submit_button'),  // Add this
  onPressed: () {},
  child: Text('Submit'),
)
```

Use the keys defined in `helpers/test_keys.dart`.

---

## 📈 CI/CD Integration

### GitHub Actions Example

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.9.2"

      - name: Install dependencies
        run: flutter pub get

      - name: Run integration tests
        run: flutter test integration_test/
        env:
          SUPABASE_URL: ${{ secrets.TEST_SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.TEST_SUPABASE_ANON_KEY }}

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

---

## 📚 Additional Resources

- **Flutter Integration Testing Guide:** https://docs.flutter.dev/testing/integration-tests
- **WidgetTester API:** https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html
- **Test Matchers:** https://api.flutter.dev/flutter/package-matcher_matcher/package-matcher_matcher-library.html
- **Integration Test Package:** https://pub.dev/packages/integration_test

---

## 📊 Test Statistics

| Category               | Test Files | Test Cases | Coverage                     |
| ---------------------- | ---------- | ---------- | ---------------------------- |
| **Authentication**     | 1          | 7          | Login, Logout, Validation    |
| **Patient Management** | 1          | 5          | CRUD, Search, Filter         |
| **Appointments**       | 1          | 8          | Scheduling, Calendar, Status |
| **Billing**            | 1          | 9          | Invoices, Payments, Reports  |
| **Navigation**         | 1          | 10         | Routing, State, UI           |
| **TOTAL**              | **5**      | **39**     | **End-to-End Flows**         |

---

## ✅ Pre-Test Checklist

Before running integration tests:

- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] Test environment configured (`.env` file)
- [ ] Test database accessible
- [ ] Test user credentials valid
- [ ] No app instances running
- [ ] Sufficient disk space for logs/screenshots

---

## 🎯 Next Steps

1. **Run the tests:**

   ```bash
   flutter test integration_test/
   ```

2. **Review test output** for any failures

3. **Check coverage report** to identify gaps

4. **Add more tests** as needed for new features

5. **Integrate with CI/CD** for automated testing

---

## 💡 Tips for Success

- **Run tests frequently** during development
- **Keep tests independent** - each test should work standalone
- **Use meaningful assertions** - verify actual business outcomes
- **Clean up test data** - don't pollute the database
- **Document edge cases** - explain why certain tests exist
- **Update tests with UI changes** - keep tests in sync with app

---

## 🤝 Contributing

When adding new features:

1. Write integration tests for the feature
2. Ensure tests pass locally
3. Update this README if adding new test files
4. Add any new test keys to `helpers/test_keys.dart`
5. Document any new test helpers in `helpers/test_helpers.dart`

---

**Happy Testing! 🚀**

_Integration tests ensure your app works as users expect, catching issues before they reach production._
